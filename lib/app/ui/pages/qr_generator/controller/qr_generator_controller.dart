import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';
import 'package:ecuscanqr/app/domain/repository/qr_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';

class QrGeneratorController extends SimpleNotifier {
  final qrRepository = Get.find<QrRepository>();

  String _qrType = '';
  final Map<String, String> _fields = {};
  String _generatedData = '';
  bool _isValid = false;

  String get qrType => _qrType;
  String get generatedData => _generatedData;
  bool get isValid => _isValid;

  void setQrType(String type) {
    if (_qrType == type) return; // Evitar reinicializar si es el mismo tipo
    
    _qrType = type;
    _fields.clear();
    _generatedData = '';
    _isValid = false;
    notify();
  }

  void updateField(String key, String value) {
    _fields[key] = value;
    _generateQrData();
  }

  void _generateQrData() {
    try {
      switch (_qrType) {
        case 'website':
          _generatedData = _generateWebsite();
          break;
        case 'text':
          _generatedData = _generateText();
          break;
        case 'email':
          _generatedData = _generateEmail();
          break;
        case 'sms':
          _generatedData = _generateSms();
          break;
        case 'wifi':
          _generatedData = _generateWifi();
          break;
        default:
          _generatedData = '';
      }
      
      _isValid = _generatedData.isNotEmpty && _validateData();
      notify();
    } catch (e) {
      print('Error generating QR data: $e');
      _generatedData = '';
      _isValid = false;
      notify();
    }
  }

  bool _validateData() {
    switch (_qrType) {
      case 'website':
        return _fields['url']?.isNotEmpty == true;
      case 'text':
        return _fields['text']?.isNotEmpty == true;
      case 'email':
        final email = _fields['email'] ?? '';
        return email.isNotEmpty && _isValidEmail(email);
      case 'sms':
        return _fields['phone']?.isNotEmpty == true &&
               _fields['message']?.isNotEmpty == true;
      case 'wifi':
        return _fields['ssid']?.isNotEmpty == true &&
               _fields['password']?.isNotEmpty == true;
      default:
        return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _generateWebsite() {
    String url = _fields['url'] ?? '';
    if (url.isEmpty) return '';
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  String _generateText() {
    return _fields['text'] ?? '';
  }

  String _generateEmail() {
    final email = _fields['email'] ?? '';
    if (email.isEmpty) return '';
    
    final subject = _fields['subject'] ?? '';
    final body = _fields['body'] ?? '';
    
    String result = 'mailto:$email';
    List<String> params = [];
    
    if (subject.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(body)}');
    }
    
    if (params.isNotEmpty) {
      result += '?${params.join('&')}';
    }
    
    return result;
  }

  String _generateSms() {
    final phone = _fields['phone'] ?? '';
    final message = _fields['message'] ?? '';
    
    if (phone.isEmpty || message.isEmpty) return '';
    
    return 'SMSTO:$phone:$message';
  }

  String _generateWifi() {
    final ssid = _fields['ssid'] ?? '';
    final password = _fields['password'] ?? '';
    final security = _fields['security'] ?? 'WPA';
    
    if (ssid.isEmpty || password.isEmpty) return '';
    
    return 'WIFI:T:$security;S:$ssid;P:$password;H:false;;';
  }

  Future<void> saveQr(BuildContext context) async {
    if (!_isValid) return;

    // Deshabilitar el botón temporalmente para evitar doble tap
    _isValid = false;
    notify();

    try {
      final qrCode = QrCodeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _qrType,
        data: _generatedData,
        displayTitle: _getDisplayTitle(),
        createdAt: DateTime.now(),
        isScanned: false,
      );

      await qrRepository.saveQr(qrCode);

      if (context.mounted) {
        // Cerrar el teclado primero
        FocusScope.of(context).unfocus();
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Código QR guardado con éxito!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(milliseconds: 1500),
          ),
        );
        
        // Navegar de inmediato (sin delay)
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error guardando el código QR: $e');
      
      // Reactivar el botón si hay error
      _isValid = true;
      notify();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error guardando el código QR: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getDisplayTitle() {
    switch (_qrType) {
      case 'website':
        return _fields['url'] ?? 'Website QR';
      case 'text':
        final text = _fields['text'] ?? '';
        return text.length > 30 ? '${text.substring(0, 30)}...' : text;
      case 'email':
        return _fields['email'] ?? 'Email QR';
      case 'sms':
        return _fields['phone'] ?? 'SMS QR';
      case 'wifi':
        return _fields['ssid'] ?? 'WiFi QR';
      default:
        return 'QR Code';
    }
  }

  void clear() {
    _fields.clear();
    _generatedData = '';
    _isValid = false;
    notify();
  }

  @override
  void dispose() {
    _fields.clear();
    super.dispose();
  }
}