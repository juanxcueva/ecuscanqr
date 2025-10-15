import 'package:flutter/material.dart';

class AppColors {
  // 🎨 BASE PRINCIPAL
  static const Color darkColor = Color(0xFF0B0E13); // Fondo oscuro (base principal)
  static const Color lightColor = Color(0xFFFFFFFF); // Texto e íconos claros
  static const Color grey = Color(0xFFA9B3C1); // Gris metálico neutro

  // 🌌 GRADIENTES AZUL NEÓN
  static const Color gradientTop = Color(0xFF00AFFF); // Azul eléctrico principal
  static const Color gradientMed = Color(0xFF0090E0); // Azul medio brillante
  static const Color gradientBottom = Color(0xFF0066CC); // Azul profundo

  // 💫 VARIANTES DE FONDO Y CONTENEDORES
  static const Color darkContainerColor = Color(0xFF171B20); // Contenedores oscuros
  static const Color darkDialogColor = Color(0xFF1E242C); // Diálogos y overlays
  static const Color whiteDialogColor = Color(0xFFEEEBF5); // Variante clara

  // 🔵 ELEMENTOS DE MARCA
  static const Color primaryColor = Color(0xFF00AFFF); // Color principal de marca (botones, links)
  static const Color secondaryColor = Color(0xFF0090E0); // Hover, efectos de luz
  static const Color accentColor = Color(0xFF0066CC); // Resaltos sutiles

  // ⚙️ COMPLEMENTARIOS Y DECORATIVOS
  static const Color metallicGrey = Color(0xFFA9B3C1); // Toques metálicos o bordes
  static const Color shadowBlue = Color(0xFF003A66); // Sombras azuladas suaves
  static const Color glowEffect = Color(0xFF00C9FF); // Efecto glow tipo neón

  // 🌓 MODO CLARO (si lo necesitas luego para light theme)
  static const Color lightBackground = Color(0xFFF8FAFB);
  static const Color lightCard = Color(0xFFE9EDF0);
  static const Color lightText = Color(0xFF0B0E13);

  // 💠 GRADIENTES EXTRA PARA EFECTOS
  static const List<Color> gradientNeon = [
    Color(0xFF00AFFF),
    Color(0xFF0090E0),
    Color(0xFF0066CC),
  ];

  static const List<Color> gradientDark = [
    Color(0xFF0B0E13),
    Color(0xFF171B20),
    Color(0xFF1E242C),
  ];
}
