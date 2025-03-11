import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/vistas/home.dart';
import 'package:calculadora_presupuesto/vistas/egresos.dart';
import 'package:calculadora_presupuesto/vistas/ingresos.dart';

class Navegador extends StatefulWidget{
  const Navegador({super.key, required this.inicio, required this.usuario});
  final int inicio;
  final String usuario;

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador>{
  late int _indice; // controlar el indice de la vista a mostrar
  final _vistas = []; // lista para las vistas

  // Vistas que se van a manejar
  @override
  void initState(){
    super.initState();
    _indice = widget.inicio;
    _vistas.add(
      Ingresos(title: "Ingresos", usuario: widget.usuario)
    );
    _vistas.add(
        MyHomePage(title: "Resumen Presupuesto", usuario: widget.usuario)
    );
    _vistas.add(
      Egresos(title: "Egresos", usuario: widget.usuario)
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _vistas[_indice],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indice,
        onTap: (value) {
          setState(() {
            _indice = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: "Ingresos"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Inicio"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_down_outlined),
              label: "Egresos"
          ),
        ],
      ),
    );
  }

}