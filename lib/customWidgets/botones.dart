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
        Decimal monto = Decimal.parse(elemento['monto'].toString());
        Decimal porcentaje = ((monto*Decimal.fromInt(100)) / (widget.totalIngresos)).toDecimal();
        
        // Widget que se mostrara
        botones.add(
            Container(
              margin: EdgeInsets.zero,
              child: MaterialButton(
                onPressed: () => {print("boton presionado")},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column( // parte izquieda
                          crossAxisAlignment: CrossAxisAlignment.start, // ------
                          children: [
                            Text(elemento["nombre"]),
                            Text(elemento["descripcion"]),
                          ],
                        ),
                        Column( // parte izquieda
                          crossAxisAlignment: CrossAxisAlignment.end, // ----------
                          children: [
                            Text(monto.toStringAsFixed(2)),
                            Text('%${porcentaje.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),



                    const SizedBox(
                      height: 6.0,
                    ),
                    Container( // linea de separacion
                      height: 1.0,
                      color: const Color(0xFFe6e6e6),
                    )
                  ],
                ),
              )
            ),
        );
      }
    setState(() {});
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