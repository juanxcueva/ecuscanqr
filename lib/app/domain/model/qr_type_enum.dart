// lib/app/domain/model/qr_type_enum.dart
enum QrType {
  website,
  text,
  email,
  sms,
  wifi,
  vcard,
  phone,
}

extension QrTypeExtension on QrType {
  String get displayName {
    switch (this) {
      case QrType.website:
        return 'Website';
      case QrType.text:
        return 'Text';
      case QrType.email:
        return 'Email';
      case QrType.sms:
        return 'SMS';
      case QrType.wifi:
        return 'WiFi';
      case QrType.vcard:
        return 'vCard';
      case QrType.phone:
        return 'Phone';
    }
  }

  String get icon {
    switch (this) {
      case QrType.website:
        return '🌐';
      case QrType.text:
        return '📝';
      case QrType.email:
        return '📧';
      case QrType.sms:
        return '💬';
      case QrType.wifi:
        return '📶';
      case QrType.vcard:
        return '👤';
      case QrType.phone:
        return '📞';
    }
  }
}
