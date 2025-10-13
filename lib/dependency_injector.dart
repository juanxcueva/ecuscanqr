import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void injectDependencies() {
  const storage = FlutterSecureStorage();

  Get.lazyPut<FlutterSecureStorage>(() => storage);
}
