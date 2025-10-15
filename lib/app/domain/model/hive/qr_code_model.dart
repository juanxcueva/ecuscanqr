import 'package:hive/hive.dart';

part 'qr_code_model.g.dart';

@HiveType(typeId: 0)
class QrCodeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'website', 'text', 'email', 'sms', 'wifi', 'scanned'

  @HiveField(2)
  final String data; // Datos del QR

  @HiveField(3)
  final String displayTitle; // Título para mostrar

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isFavorite;

  @HiveField(6)
  final bool isScanned; // true si fue escaneado, false si fue generado

  QrCodeModel({
    required this.id,
    required this.type,
    required this.data,
    required this.displayTitle,
    required this.createdAt,
    this.isFavorite = false,
    this.isScanned = false,
  });

  // Método para copiar con cambios
  QrCodeModel copyWith({
    String? id,
    String? type,
    String? data,
    String? displayTitle,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isScanned,
  }) {
    return QrCodeModel(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      displayTitle: displayTitle ?? this.displayTitle,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isScanned: isScanned ?? this.isScanned,
    );
  }

  // Método para obtener un ícono según el tipo
  String getTypeIcon() {
    switch (type) {
      case 'website':
        return '🌐';
      case 'text':
        return '📝';
      case 'email':
        return '📧';
      case 'sms':
        return '💬';
      case 'wifi':
        return '📶';
      case 'scanned':
        return '📷';
      default:
        return '❓';
    }
  }

  // Método para obtener el nombre del tipo
  String getTypeName() {
    if (isScanned) return 'Scanned';
    
    switch (type) {
      case 'website':
        return 'Website';
      case 'text':
        return 'Text';
      case 'email':
        return 'Email';
      case 'sms':
        return 'SMS';
      case 'wifi':
        return 'WiFi';
      default:
        return 'QR Code';
    }
  }
}

// IMPORTANTE: Después de modificar este archivo, ejecutar:
// flutter packages pub run build_runner build --delete-conflicting-outputs