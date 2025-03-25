import 'package:flutter/material.dart';

class Bienvenido extends StatefulWidget {
  const Bienvenido({super.key, required this.title});
  final String title;

  @override
  State<Bienvenido> createState() => _BienvenidoState();
}

class _BienvenidoState extends State<Bienvenido> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Image.asset(
                'assets/flecha1.png',
                width: MediaQuery.of(context).size.width * 0.4,
                opacity: const AlwaysStoppedAnimation(0.5),
              ),
            )
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: const Text(
              'Aún no se han agregado presupuestos para mostrar. Agregue un presupuesto con el '
                  'boton de la parte superior derecha, o si lo prefiere, puede agregar su primer presupuesto '
                  'abriendo el menu lateral izquierdo en el apartado "Presupuestos".',
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            ),
          ),
        ],
      )
    );
  }
}