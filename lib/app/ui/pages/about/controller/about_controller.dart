
import 'package:flutter_meedu/meedu.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutController extends SimpleNotifier {
  String _version = '...';
  AboutController() {
    getVersion();
  }

  String get version => _version;

  void setVersion(String value) {
    _version = value;
    notify();
  }

  Future<void> getVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      setVersion('${packageInfo.version}+${packageInfo.buildNumber}');
    } catch (e) {}
  }
}
