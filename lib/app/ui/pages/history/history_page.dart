import 'dart:ui';
import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';
import 'package:ecuscanqr/app/ui/pages/history/controller/history_controller.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final historyProvider = SimpleProvider<HistoryController>((ref) {
  return HistoryController();
});

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        final controller = ref.watch(historyProvider);

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 92.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header más compacto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "History",
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.lightText,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        "${controller.filteredQrs.length} codes",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (controller.filteredQrs.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.red.shade400,
                        size: 26.r,
                      ),
                      onPressed: () => _showClearDialog(context, controller),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 40.w,
                        minHeight: 40.h,
                      ),
                    ),
                ],
              ),
              12.verticalSpace,

              // Search bar más compacta
              _SearchBar(
                onChanged: (query) => controller.search(query),
              ),
              12.verticalSpace,

              // Filter chips más compactos
              _FilterChips(
                selectedFilter: controller.selectedFilter,
                onSelected: controller.changeFilter,
              ),
              12.verticalSpace,

              // Lista de QRs
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredQrs.isEmpty
                        ? _EmptyState(filter: controller.selectedFilter)
                        : RefreshIndicator(
                            onRefresh: controller.loadHistory,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.filteredQrs.length,
                              itemBuilder: (context, index) {
                                final qr = controller.filteredQrs[index];
                                return _QrHistoryCard(
                                  qr: qr,
                                  onTap: () => _showQrDetails(context, qr, controller),
                                  onFavorite: () => controller.toggleFavorite(qr.id),
                                  onDelete: () => _confirmDelete(context, qr, controller),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
void _showClearDialog(BuildContext context, HistoryController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Clear History'),
        content: Text(
          'Are you sure you want to delete all ${controller.selectedFilter} QR codes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearHistory();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, QrCodeModel qr, HistoryController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete QR Code'),
        content: const Text('Are you sure you want to delete this QR code?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteQr(qr.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showQrDetails(
    BuildContext context,
    QrCodeModel qr,
    HistoryController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _QrDetailsSheet(
        qr: qr,
        onShare: () => Share.share(qr.data),
        onOpen: () => _handleOpen(qr.data),
        onFavorite: () {
          controller.toggleFavorite(qr.id);
          Navigator.pop(ctx);
        },
        onDelete: () {
          controller.deleteQr(qr.id);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _handleOpen(String data) async {
    try {
      Uri? uri;
      
      if (data.startsWith('http://') || data.startsWith('https://')) {
        uri = Uri.parse(data);
      } else if (data.startsWith('mailto:') || 
                 data.startsWith('tel:') || 
                 data.startsWith('sms:')) {
        uri = Uri.parse(data);
      } else if (data.startsWith('SMSTO:')) {
        final parts = data.substring(6).split(':');
        if (parts.isNotEmpty) {
          uri = Uri.parse('sms:${parts[0]}');
        }
      }
      
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening URL: $e');
    }
  }
}

/* ------------------------------ Search Bar ------------------------------ */

class _SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.7),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(.8)),
          ),
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search QR codes...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6461FF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Filter Chips ------------------------------ */

class _FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onSelected;

  const _FilterChips({
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'id': 'all', 'label': 'All', 'icon': Icons.grid_view},
      {'id': 'generated', 'label': 'Created', 'icon': Icons.add_circle_outline},
      {'id': 'scanned', 'label': 'Scanned', 'icon': Icons.qr_code_scanner},
      {'id': 'favorites', 'label': 'Favorites', 'icon': Icons.star},
    ];

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => 8.horizontalSpace,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['id'];
          
          return _FilterChip(
            label: filter['label'] as String,
            icon: filter['icon'] as IconData,
            isSelected: isSelected,
            onTap: () => onSelected(filter['id'] as String),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6461FF)
              : Colors.white.withOpacity(.7),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6461FF)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            6.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ QR History Card ------------------------------ */

class _QrHistoryCard extends StatelessWidget {
  final QrCodeModel qr;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _QrHistoryCard({
    required this.qr,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withOpacity(.6),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withOpacity(.8)),
                ),
                child: Row(
                  children: [
                    // QR Preview más pequeño
                    Container(
                      width: 48.r,
                      height: 48.r,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: QrImageView(
                        data: qr.data,
                        version: QrVersions.auto,
                        size: 42.r,
                      ),
                    ),
                    10.horizontalSpace,

                    // Info compacta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Type badge compacto
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(qr).withOpacity(.15),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      qr.getTypeIcon(),
                                      style: TextStyle(fontSize: 8.sp),
                                    ),
                                    2.horizontalSpace,
                                    Text(
                                      qr.getTypeName(),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _getTypeColor(qr),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              4.horizontalSpace,
                              if (qr.isFavorite)
                                Icon(
                                  Icons.star,
                                  size: 12.r,
                                  color: Colors.amber,
                                ),
                            ],
                          ),
                          4.verticalSpace,
                          // Título
                          Text(
                            qr.displayTitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          2.verticalSpace,
                          // Fecha compacta
                          Text(
                            DateFormat('MMM dd • HH:mm').format(qr.createdAt),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions compactas
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            qr.isFavorite ? Icons.star : Icons.star_border,
                            color: qr.isFavorite
                                ? Colors.amber
                                : Colors.grey.shade400,
                            size: 20.r,
                          ),
                          onPressed: onFavorite,
                          constraints: BoxConstraints(
                            minWidth: 28.w,
                            minHeight: 28.h,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                            size: 20.r,
                          ),
                          onPressed: onDelete,
                          constraints: BoxConstraints(
                            minWidth: 28.w,
                            minHeight: 28.h,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Color _getTypeColor(QrCodeModel qr) {
    if (qr.isScanned) return Colors.blue;
    
    switch (qr.type) {
      case 'website':
        return const Color(0xFF5D9BFF);
      case 'text':
        return const Color(0xFFFF9E8B);
      case 'email':
        return const Color(0xFF6CAEFF);
      case 'sms':
        return const Color(0xFFFD84BE);
      case 'wifi':
        return const Color(0xFFA895FF);
      default:
        return Colors.grey;
    }
  }
}

/* ------------------------------ Empty State ------------------------------ */
class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (filter) {
      case 'generated':
        message = 'No QR codes created yet';
        icon = Icons.add_circle_outline;
        break;
      case 'scanned':
        message = 'No QR codes scanned yet';
        icon = Icons.qr_code_scanner;
        break;
      case 'favorites':
        message = 'No favorite QR codes';
        icon = Icons.star_border;
        break;
      default:
        message = 'No QR codes yet';
        icon = Icons.qr_code_2_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100.r,
            color: Colors.grey.shade300,
          ),
          16.verticalSpace,
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          8.verticalSpace,
          Text(
            'Start creating or scanning QR codes',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ QR Details Sheet ------------------------------ */

class _QrDetailsSheet extends StatelessWidget {
  final QrCodeModel qr;
  final VoidCallback onShare;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _QrDetailsSheet({
    required this.qr,
    required this.onShare,
    required this.onOpen,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            24.verticalSpace,

            // QR Code
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: QrImageView(
                data: qr.data,
                version: QrVersions.auto,
                size: 250.w,
              ),
            ),
            24.verticalSpace,

            // Info
            Text(
              qr.displayTitle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            8.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  qr.getTypeIcon(),
                  style: TextStyle(fontSize: 14.sp),
                ),
                4.horizontalSpace,
                Text(
                  qr.getTypeName(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (qr.isScanned) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Scanned',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            24.verticalSpace,

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6461FF),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: Color(0xFF6461FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6461FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFavorite,
                    icon: Icon(qr.isFavorite ? Icons.star : Icons.star_border),
                    label: Text(qr.isFavorite ? 'Unfavorite' : 'Favorite'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: Colors.amber),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}