abstract class Routes {
  static const String splash = "splash";
  static const String home = "home";
  static const String about = "about";
  static const String settings = "settings";
  static const String bottomNavBar = "bottomNavBar";
  
  // Nuevas rutas para generación de QR
  static const String qrGenerator = "qr-generator";
  static const String scanQr = "scan-qr";
  static const String history = "history";
  
  // Rutas específicas por tipo de QR (opcional, si quieres páginas separadas)
  static const String qrWebsite = "qr-website";
  static const String qrText = "qr-text";
  static const String qrEmail = "qr-email";
  static const String qrSms = "qr-sms";
  static const String qrWifi = "qr-wifi";
}