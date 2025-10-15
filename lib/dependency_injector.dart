import 'package:ecuscanqr/app/data/repository_impl/qr_repository_impl.dart';
import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';
import 'package:ecuscanqr/app/domain/repository/qr_repository.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void injectDependencies() {
  const storage = FlutterSecureStorage();

  Get.lazyPut<FlutterSecureStorage>(() => storage);

   // Inyectamos HiveStorageService después de inicializarlo
  Get.lazyPut<HiveStorageService>(() => HiveStorageService());

  // Inyectamos el repositorio después de que HiveStorageService esté disponible
  Get.lazyPut<QrRepository>(() => QrRepositoryImpl(Get.find<HiveStorageService>()));
  
}
