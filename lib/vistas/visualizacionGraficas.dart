import 'package:calculadora_presupuesto/customWidgets/otrosWidgets.dart';
import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';


class VisualizacionGraficas extends StatefulWidget {
  const VisualizacionGraficas({super.key,
    required this.title,
    required this.usuario,
    required this.presupuesto});
  final String title;
  final String usuario;
  final Map<String, dynamic> presupuesto;

  @override
  State<VisualizacionGraficas> createState() => _VisualizacionGraficasState();
}

class _VisualizacionGraficasState extends State<VisualizacionGraficas> {
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos
  Map<String, dynamic> _sumatoriaIngresosDias = {};
  Map<String, dynamic> _sumatoriaEgresosDias = {};
  Map<String, dynamic> _sumatoriaIngresosMeses = {};
  Map<String, dynamic> _sumatoriaEgresosMeses = {};
  double _totalIngresos = 0.0;
  double _totalEgresos = 0.0;
  late Map<String, dynamic> _sumaTotalPorCategoriaIngresos = {};
  late Map<String, dynamic> _sumaTotalPorCategoriaEgresos = {};


  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarDatosVista(); // Carga de datos de las funciones asincronas
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    await Future.wait([
      // Funciones de las que se espera un resultado
      _obtenerTotalesDias(),
      _obtenerTotalesMeses(),
      _obtenerSumaIngresosEgresos(),
      _obtenerCategoriasIngresos(),
      _obtenerCategoriasEgresos(),
    ]);
  }

  // Obtener la sumatoria de ingresos y egresos cada dia de la semana de cada presupuesto
  Future<void> _obtenerTotalesDias() async {
    _sumatoriaIngresosDias = await DataBaseOperaciones().obtenerSumatoriaIngresosDiasSemanaPresupuesto(widget.presupuesto['id_presupuesto'], widget.usuario);
    _sumatoriaEgresosDias = await DataBaseOperaciones().obtenerSumatoriaEgresosDiasSemanaPresupuesto(widget.presupuesto['id_presupuesto'], widget.usuario);
  }

  // Obtener la sumatoria de ingresos y egresos cada dia de la semana de cada presupuesto
  Future<void> _obtenerTotalesMeses() async {
    _sumatoriaIngresosMeses = await DataBaseOperaciones().obtenerSumatoriaIngresosMesesPresupuesto(widget.presupuesto['id_presupuesto'], widget.usuario);
    _sumatoriaEgresosMeses = await DataBaseOperaciones().obtenerSumatoriaEgresosMesesPresupuesto(widget.presupuesto['id_presupuesto'], widget.usuario);
  }

  // Obtener la suma de los ingresos del usuario
  Future<void> _obtenerSumaIngresosEgresos() async {
    final valueIngresos = await DataBaseOperaciones().sumarIngresosTodos(widget.usuario, widget.presupuesto['id_presupuesto']);
    final valueEgresos = await DataBaseOperaciones().sumarEgresosTodos(widget.usuario, widget.presupuesto['id_presupuesto']);
    _totalIngresos = valueIngresos.toDouble();
    _totalEgresos = valueEgresos.toDouble();
  }

  // Obtener mi lista de categorias de ingresos
  Future<void> _obtenerCategoriasIngresos() async {
    List<Map<String, dynamic>> categorias = await DataBaseOperaciones().obtenerCategorias("ingreso", widget.presupuesto['id_presupuesto']);

    // Obtener suma del monto total por categoria
    _obtenerSumaTotalPorCategoriasIngresos(categorias).then((value) {
      setState(() {
        _sumaTotalPorCategoriaIngresos = value;
      });
    });
  }

  // Obtener mi lista de categorias de egresos
  Future<void> _obtenerCategoriasEgresos() async {
    List<Map<String, dynamic>> categorias = await DataBaseOperaciones().obtenerCategorias("egreso", widget.presupuesto['id_presupuesto']);

    // Obtener suma del monto total por categoria
    _obtenerSumaTotalPorCategoriasEgresos(categorias).then((value) {
      _sumaTotalPorCategoriaEgresos = value;
    });
  }

  // obtener suma del monto total de cada categoria pasando como argumento la lista de categorias
  Future<Map<String, dynamic>> _obtenerSumaTotalPorCategoriasIngresos(List<Map<String, dynamic>> listaCategorias) async {
    Map<String, dynamic> sumaTotalPorCategorias = {};
    for(var categoria in listaCategorias) {
      // Obtener monto
      Decimal monto = await DataBaseOperaciones().sumarIngresosCategoria(categoria['nombre'], widget.usuario, widget.presupuesto['id_presupuesto']);
      // Guardar elemento
      sumaTotalPorCategorias[categoria['nombre']] = monto.toDouble();
    }
    return sumaTotalPorCategorias;
  }

  Future<Map<String, dynamic>> _obtenerSumaTotalPorCategoriasEgresos(List<Map<String, dynamic>> listaCategorias) async {
    Map<String, dynamic> sumaTotalPorCategorias = {};
    for(var categoria in listaCategorias) {
      // Obtener monto
      Decimal monto = await DataBaseOperaciones().sumarEgresosCategoria(categoria['nombre'], widget.usuario, widget.presupuesto['id_presupuesto']);
      // Guardar elemento
      sumaTotalPorCategorias[categoria['nombre']] = monto.toDouble();
    }
    return sumaTotalPorCategorias;
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
            return Text("Ocurrio un error.");

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
                  Expanded(
                    child:  SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          // Cuerpo de mi vista
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            child: Center(
                              child: Text(
                                widget.presupuesto['nombre'][0].toUpperCase()+widget.presupuesto['nombre'].substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          // Graficas de ingresos y egresos por dias de la semana
                          Column(
                            children: [
                              const Text(
                                  'Comparativa del total de ingresos por día de la semana',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                              GraficaLinea1(
                                datosGraficar: _sumatoriaIngresosDias,
                                colorDegradado1: Colors.greenAccent,
                                colorDegradado2: Colors.green,
                              ),
                              const SizedBox(height: 20,),

                              const Text(
                                  'Comparativa del total de egresos por día de la semana',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                              GraficaLinea1(
                                datosGraficar: _sumatoriaEgresosDias,
                                colorDegradado1: Colors.orange,
                                colorDegradado2: Colors.red,
                              ),
                              const SizedBox(height: 20,),

                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width *0.8,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),

                          // Grafica de ingresos y egresos por meses
                          Column(
                            children: [
                              const SizedBox(height: 40),
                              const Text(
                                'Comparativa del total de ingresos por mes del año',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                              GraficaLineaMeses(
                                datosGraficar: _sumatoriaIngresosMeses,
                                colorDegradado1: Colors.greenAccent,
                                colorDegradado2: Colors.green,
                              ),
                              const SizedBox(height: 20,),

                              const Text(
                                'Comparativa del total de egresos por mes del año',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                              GraficaLineaMeses(
                                datosGraficar: _sumatoriaEgresosMeses,
                                colorDegradado1: Colors.orange,
                                colorDegradado2: Colors.red,
                              ),
                              const SizedBox(height: 20,),

                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width *0.8,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),


                          if(_sumaTotalPorCategoriaIngresos.isNotEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                const Text(
                                  'Cantidad de ingresos por categoria',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                      )
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.8,
                                        child: GraficaBarras2SinDialog(
                                            tipo: 'ingreso',
                                            listaCantidades: _sumaTotalPorCategoriaIngresos,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),


                          if(_sumaTotalPorCategoriaEgresos.isNotEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                const Text(
                                  'Cantidad de egresos por categoria',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                      )
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.8,
                                        child: GraficaBarras2SinDialog(
                                            tipo: 'egreso',
                                            listaCantidades: _sumaTotalPorCategoriaEgresos,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),


                          const SizedBox(height: 40),
                          GraficaRadialBarSinDialog(
                            totalIngresos: _totalIngresos,
                            totalEgresos: _totalEgresos,
                            colorIngresos: Colors.green,
                            colorEgresos: Colors.red,
                          ),
                          const SizedBox(height: 20),


                        ],
                      ),
                    ),
                  ),
                ],
              )

            );
          }
        }
    );
  }

}