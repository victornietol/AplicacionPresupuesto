import 'package:calculadora_presupuesto/navegador.dart';
import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/vistas/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presupuesto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      locale: const Locale('es', 'MX'),
      home: const Navegador(inicio: 1),
    );
  }
}
