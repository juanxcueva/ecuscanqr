import 'package:ecuscanqr/app/my_app.dart';
import 'package:ecuscanqr/dependency_injector.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  injectDependencies();

  runApp(const MyApp());
}
