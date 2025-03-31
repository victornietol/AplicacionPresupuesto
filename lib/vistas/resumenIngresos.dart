import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';


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

  double _obtenerSumaTotal(Map<String, dynamic> cantidades) {
    double resultado = 0.0;
    cantidades.forEach((key, value) {
      if(value!=null) {
        resultado += value;
      }
    });
    return resultado;
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Cuerpo de mi vista
                            Center(
                              child: Column(
                                children: [
                                  // Primer apartado
                                  const SizedBox(height: 20),
                                  Text(
                                    'Total de ingresos por día de la semana actual',
                                    style: TextStyle(
                                      //fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    width: MediaQuery.of(context).size.width*0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                        color: Colors.grey.withOpacity(0.1)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        // Cada dia
                                        Row(
                                          children: [
                                            // Dias
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    'Domingo:',
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    'Lunes:',
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Martes:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Miércoles:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Jueves:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Viernes:'
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                      'Sábado:'
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Lineas puntos
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  for (int i = 0; i < 7; i++)
                                                    SizedBox(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          int conteoPuntos = (constraints.maxWidth / 7).floor();
                                                          String puntos = '.' * conteoPuntos;
                                                          return Text(
                                                            puntos,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(letterSpacing: 2),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            // Cantidades por dia
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['domingo']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['lunes']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['martes']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['miercoles']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['jueves']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['viernes']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['sabado']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),

                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 6),
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        // Total de la semana
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                formatearCantidad(_obtenerSumaTotal(_sumatoriaIngresosSemanaActual)),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),


                                      ],
                                    ),
                                  ),

                                  // Segundo apartado
                                  const SizedBox(height: 30),
                                  Text(
                                    'Total de ingresos por semana del mes actual',
                                    style: TextStyle(
                                      //fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    width: MediaQuery.of(context).size.width*0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                        color: Colors.grey.withOpacity(0.1)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        // Cada dia
                                        Row(
                                          children: [
                                            // Dias
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    'Semana 1:',
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Semana 2:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Semana 3:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Semana 4:'
                                                  ),
                                                ),
                                                if(_sumatoriaIngresosMesActual['semana5']!=null)
                                                  Container(
                                                    child: Text(
                                                        'Semana 5:'
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            // Lineas puntos
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  for (int i = 0; i < (_sumatoriaIngresosMesActual['semana5']!=null ? 5 : 4); i++)
                                                    SizedBox(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          int conteoPuntos = (constraints.maxWidth / 7).floor();
                                                          String puntos = '.' * conteoPuntos;
                                                          return Text(
                                                            puntos,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(letterSpacing: 2),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            // Cantidades por dia
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['semana1']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['semana2']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['semana3']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['semana4']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                if(_sumatoriaIngresosMesActual['semana5']!=null)
                                                  Container(
                                                    child: Text(
                                                      formatearCantidad(_sumatoriaIngresosMesActual['semana5']),
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                              ],
                                            )
                                          ],
                                        ),

                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 6),
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        // Total de la semana
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                formatearCantidad(_obtenerSumaTotal(_sumatoriaIngresosMesActual)),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),


                                      ],
                                    ),
                                  ),

                                  // Tercer apartado
                                  const SizedBox(height: 30),
                                  Text(
                                    'Total de ingresos por mes del año actual',
                                    style: TextStyle(
                                      //fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    width: MediaQuery.of(context).size.width*0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                        color: Colors.grey.withOpacity(0.1)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            // Meses
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    'Enero:',
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    'Febrero:',
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Marzo:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Abril:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Mayo:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Junio:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Julio:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Agosto:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Septiembre:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Octubre:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Noviembre:'
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                      'Diciembre:'
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Lineas puntos
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  for (int i = 0; i < 12; i++)
                                                    SizedBox(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          int conteoPuntos = (constraints.maxWidth / 7).floor();
                                                          String puntos = '.' * conteoPuntos;
                                                          return Text(
                                                            puntos,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(letterSpacing: 2),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            // Cantidades por dia
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['enero']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['febrero']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['marzo']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['abril']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['mayo']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['junio']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['julio']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['agosto']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['septiembre']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['octubre']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['noviembre']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['diciembre']),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),

                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 6),
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        // Total de la semana
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                formatearCantidad(_obtenerSumaTotal(_sumatoriaIngresosAnioActual)),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),


                                      ],
                                    ),
                                  ),

                                  // Cuarto apartado
                                  const SizedBox(height: 30),
                                  Text(
                                    'Total de ingresos por dia dentro de un rango',
                                    style: TextStyle(
                                      //fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  MaterialButton(
                                    onPressed: () {
                                      List<DateTime> _dates = [];
                                      showCalendarDatePicker2Dialog(
                                        context: context,
                                        config: CalendarDatePicker2WithActionButtonsConfig(
                                          calendarType: CalendarDatePicker2Type.range,
                                        ),
                                        dialogSize: const Size(325, 400),
                                        value: _dates,
                                        borderRadius: BorderRadius.circular(15),
                                      ).then((value) {
                                        var results = value;
                                        print(results);
                                      } );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                        color: const Color(0xFF02013C),
                                      ),
                                      child: Text(
                                        'Seleccionar rango',
                                        style: TextStyle(
                                          color: Colors.white
                                        ),
                                      ),
                                    )
                                  ),


                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

            );
          }
        }
    );
  }

}