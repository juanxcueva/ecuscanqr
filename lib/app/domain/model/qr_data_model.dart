
// lib/app/domain/model/qr_data_model.dart
import 'package:ecuscanqr/app/domain/model/qr_type_enum.dart';

class QrDataModel {
  final String id;
  final QrType type;
  final String data; // Datos codificados del QR
  final String displayTitle; // Título para mostrar
  final DateTime createdAt;
  final bool isFavorite;

  QrDataModel({
    required this.id,
    required this.type,
    required this.data,
    required this.displayTitle,
    required this.createdAt,
    this.isFavorite = false,
  });

  // Conversión a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'displayTitle': displayTitle,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  // Conversión desde JSON
  factory QrDataModel.fromJson(Map<String, dynamic> json) {
    return QrDataModel(
      id: json['id'],
      type: QrType.values.firstWhere((e) => e.name == json['type']),
      data: json['data'],
      displayTitle: json['displayTitle'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // CopyWith para actualizaciones inmutables
  QrDataModel copyWith({
    String? id,
    QrType? type,
    String? data,
    String? displayTitle,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return QrDataModel(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      displayTitle: displayTitle ?? this.displayTitle,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Clase auxiliar para generar datos QR según tipo
class QrDataGenerator {
  static String generate(QrType type, Map<String, String> fields) {
    switch (type) {
      case QrType.website:
        String url = fields['url'] ?? '';
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      case QrType.text:
        return fields['text'] ?? '';

      case QrType.email:
        final email = fields['email'] ?? '';
        final subject = fields['subject'] ?? '';
        final body = fields['body'] ?? '';
        return 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

      case QrType.sms:
        final phone = fields['phone'] ?? '';
        final message = fields['message'] ?? '';
        return 'SMSTO:$phone:$message';

      case QrType.wifi:
        final ssid = fields['ssid'] ?? '';
        final password = fields['password'] ?? '';
        final security = fields['security'] ?? 'WPA'; // WPA, WEP, nopass
        final hidden = fields['hidden'] == 'true' ? 'true' : 'false';
        return 'WIFI:T:$security;S:$ssid;P:$password;H:$hidden;;';

      case QrType.phone:
        final phone = fields['phone'] ?? '';
        return 'tel:$phone';

      case QrType.vcard:
        final name = fields['name'] ?? '';
        final phone = fields['phone'] ?? '';
        final email = fields['email'] ?? '';
        final organization = fields['organization'] ?? '';
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nTEL:$phone\nEMAIL:$email\nORG:$organization\nEND:VCARD';
    }
  }
}