import 'package:flutter/material.dart';

class Ingresos extends StatefulWidget{
  const Ingresos({super.key, required this.title});
  final String title;

  @override
  State<Ingresos> createState() => _IngresosState();
}

class _IngresosState extends State<Ingresos>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Pagina de Ingresos',
            ),

          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}