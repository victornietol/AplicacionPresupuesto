import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

// Boton con previsualizacion del monto del ingreso o egreso
class BotonIngresoEgreso extends StatefulWidget {
  const BotonIngresoEgreso({super.key,
    required this.tipo,
    required this.listaElementos,
    required this.totalIngresos,
    required this.listaCategorias
  });
  final String tipo; // Indica si es Ingreso o Egreso
  final List<Map<String, dynamic>> listaElementos; // Datos completos de ingresos o egresos
  final Decimal totalIngresos;
  final List<Map<String, dynamic>> listaCategorias; // Datos completos de las categorias (tabla categorias)


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

  // Obtener nombre de la categoria segun su id
  String obtenerCategoria(int fk_id) {
    return widget.listaCategorias.firstWhere(
      (element) => element['id_categoria']==fk_id,
      orElse: () => {'nombre': 'Sin categoria'},
    )['nombre'];
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }
  
  // Pestaña todos
  void _crearWidgetsTodos() {
    double tamanioTextPrincipal = 20.0;
    botones.clear(); // Evitar duplicados
      // Recorrer todos los elementos de la BD
      for (var elemento in widget.listaElementos) {
        double porcentaje = (elemento['monto']*100.0) / widget.totalIngresos.toDouble(); // Se utiliza double en lugar de decimal para el porcentaje por temas de precision en el punto decimal que no puede manejar Decimal
        String categoria = obtenerCategoria(elemento['fk_id_categoria_ingreso']);
        String montoFormateado = formatearCantidad(elemento['monto']);

        // Widget que se mostrara
        botones.add(
            Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(vertical: 4.0),
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
                            Text( // Nombre de elemento
                                elemento["nombre"][0].toUpperCase()+elemento['nombre'].substring(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: tamanioTextPrincipal,
                              ),
                            ),
                            Text( // Categoria
                              categoria[0].toUpperCase()+categoria.substring(1),
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column( // parte derecha
                          crossAxisAlignment: CrossAxisAlignment.end, // ----------
                          children: [
                            Text(
                                montoFormateado,
                              style: TextStyle(
                                fontSize: tamanioTextPrincipal,
                              ),
                            ),
                            Container(
                              color: Color(0xFFd4fed7),
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Text(
                                '${porcentaje.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),

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