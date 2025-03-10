import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/app.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar BD
  await DataBaseOperaciones().database;

  runApp(const MyApp());
}
