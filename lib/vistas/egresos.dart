import 'package:flutter/material.dart';

class Egresos extends StatefulWidget{
  const Egresos({super.key, required this.title, required this.usuario});
  final String title;
  final String usuario;

  @override
  State<Egresos> createState() => _EgresosState();
}

class _EgresosState extends State<Egresos>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF02013C),
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.toDouble(),
          ),
        ),
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