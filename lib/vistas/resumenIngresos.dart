import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class ResumenIngresos extends StatefulWidget {
  const ResumenIngresos({super.key,
    required this.title,
    required this.usuario,
    required this.presupuesto});
  final String title;
  final String usuario;
  final Map<String, dynamic> presupuesto;

  @override
  State<ResumenIngresos> createState() => ResumenIngresosState();
}

class ResumenIngresosState extends State<ResumenIngresos> {
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos
  Map<String, dynamic> _sumatoriaIngresosSemanaActual = {};
  Map<String, dynamic> _sumatoriaIngresosMesActual = {};
  Map<String, dynamic> _sumatoriaIngresosAnioActual = {};
  List<Map<String, dynamic>> _sumatoriaIngresosRangoDias = [];

  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarDatosVista();
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    await Future.wait([
      // Funciones de las que se espera un resultado
      _cargarSumatoriaIngresosSemanaActual(),
      _cargarSumatoriaIngresosMesActual(),
      _cargarSumatoriaIngresosAnioActual(),
    ]);
  }

  Future<void> _cargarSumatoriaIngresosSemanaActual() async {
    _sumatoriaIngresosSemanaActual = await DataBaseOperaciones().obtenerIngresosPorDiaSemanaActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
    /*
    await DataBaseOperaciones().insertarIngreso({
      'nombre': 'ingreso semana anterior prueba',
      'monto': 250.0,
      'descripcion': 'ingreso prueba otra semana',
      'fecha_registro': DateTime(2025,3, 17).toIso8601String(),
      'fk_id_usuario': 1,
      'fk_id_categoria_ingreso': 2
    });
     */
  }

  Future<void> _cargarSumatoriaIngresosMesActual() async {
    _sumatoriaIngresosMesActual = await DataBaseOperaciones().obtenerIngresosPorSemanaMesActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<void> _cargarSumatoriaIngresosAnioActual() async {
    _sumatoriaIngresosAnioActual = await DataBaseOperaciones().obtenerIngresosPorMesAnioActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<void> _cargarSumatoriaIngresosRangoDias(DateTime fechaInicio, DateTime fechaFinal) async {
    List<Map<String, dynamic>> elementos = await DataBaseOperaciones().obtenerIngresosDentroDelRango(fechaInicio, fechaFinal, widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
    setState(() {
      _sumatoriaIngresosRangoDias = elementos;
    });
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }


  // Lo que muestra la vista
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>( // Se utiliza FutureBuilder porque para construir el Scaffold primero se deben de cargar datos de funciones asincronas
        future: _cargaInicial,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            // Los datos estan cargando
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title,
                  style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.0
                  ),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFF02013C),
                iconTheme: const IconThemeData(color: Colors.white), // Color del icono
              ),
              body: const Center(child: CircularProgressIndicator()),
            );

          } else if(snapshot.hasError) {
            return Text("Ocurrio un error. ${snapshot.error}");

          } else {
            // Los datos se cargaron
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.0
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: const Color(0xFF02013C),
                  iconTheme: const IconThemeData(color: Colors.white), // Color del icono
                ),

                body: Column(
                  children: [
                    // Cuerpo de mi vista

                  ],
                )

            );
          }
        }
    );
  }

}