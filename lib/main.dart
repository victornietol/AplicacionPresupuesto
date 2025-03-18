import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/app.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar BD
  await DataBaseOperaciones().database;
  // Indicar que la app solo se visualice verticalmente
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(const MyApp());
}
