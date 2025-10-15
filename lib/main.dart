import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';
import 'package:ecuscanqr/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
 // Asegurarse de que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar Hive
  await HiveStorageService.init();

  // Ejecutar la app
  runApp(const MyApp());
}
