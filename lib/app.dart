import 'package:calculadora_presupuesto/navegador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Presupuesto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      locale: const Locale('es', 'MX'),
      home: const Navegador(inicio: 1, usuario: 'generico'),

      // Para el idioma de calendar_date_picker2
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

      // Desactivar banner debug
      debugShowCheckedModeBanner: false,
    );
  }
}
