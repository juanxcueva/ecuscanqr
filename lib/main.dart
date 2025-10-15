import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';
import 'package:ecuscanqr/app/my_app.dart';
import 'package:ecuscanqr/dependency_injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu/meedu.dart';

void main() async {
  // Asegurarse de que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inyectar dependencias usando Get.lazyPut
  injectDependencies(); // Llamamos a la función que definiste

  // Inicializar Hive
  final hiveStorageService =
      Get.find<
        HiveStorageService
      >(); // Obtener la instancia de HiveStorageService
  await hiveStorageService.init(); // Ahora lo inicializas aquí

  // Ejecutar la app
  runApp(MyApp());
}
