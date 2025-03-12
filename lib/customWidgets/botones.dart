import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

// Boton con previsualizacion del monto del ingreso o egreso
class BotonIngresoEgreso extends StatefulWidget {
  const BotonIngresoEgreso({super.key,
    required this.tipo,
    required this.listaElementos,
    required this.totalIngresos,
    //required this.listaCategorias
  });
  final String tipo; // Indica si es Ingreso o Egreso
  final List<Map<String, dynamic>> listaElementos; // Datos completos de ingresos o egresos
  final Decimal totalIngresos;
  //final List<Map<String, dynamic>> listaCategorias; // Datos completos de las categorias (tabla categorias)


  @override
  State<BotonIngresoEgreso> createState() => _BotonIngresoEgresoState();
}

class _BotonIngresoEgresoState extends State<BotonIngresoEgreso> {
  // Lista de los widgets para los ingreso o egresos
  List<Widget> botones = [];

  @override
  void initState() {
    super.initState();
    _crearWidgetsTodos();
  }
  
  // Pestaña todos
  void _crearWidgetsTodos() {
      // Recorrer todos los elementos de la BD
      for (var elemento in widget.listaElementos) {
        // Widget que se mostrara
        botones.add(
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(elemento["nombre"]),
                  Text(elemento["monto"].toString())
                ],
              ),
            )
        );
      }
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: botones,
      ),
    );
  }


}