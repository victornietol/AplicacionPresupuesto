import 'package:flutter/material.dart';

class Egresos extends StatefulWidget{
  const Egresos({super.key, required this.title});
  final String title;

  @override
  State<Egresos> createState() => _EgresosState();
}

class _EgresosState extends State<Egresos>{

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
              'Pagina de Egresos',
            ),

          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}