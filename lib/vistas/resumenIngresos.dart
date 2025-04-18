import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:decimal/decimal.dart';


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
  List<Widget> _widgetsGenerados = [];

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
  }

  Future<void> _cargarSumatoriaIngresosMesActual() async {
    _sumatoriaIngresosMesActual = await DataBaseOperaciones().obtenerIngresosPorSemanaMesActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<void> _cargarSumatoriaIngresosAnioActual() async {
    _sumatoriaIngresosAnioActual = await DataBaseOperaciones().obtenerIngresosPorMesAnioActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<List<Map<String, dynamic>>> _cargarSumatoriaIngresosRangoDias(DateTime fechaInicio, DateTime fechaFinal) async {
    return await DataBaseOperaciones().obtenerIngresosDentroDelRango(fechaInicio, fechaFinal, widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  double _obtenerSumaTotal(Map<String, dynamic> cantidades) {
    Decimal resultado = Decimal.zero;
    cantidades.forEach((key, value) {
      if(value!=null) {
        resultado += Decimal.parse(value.toString());
      }
    });
    return resultado.toDouble();
  }

  Future<void> _generarWidgets(List<DateTime> fechas) async {
    /*
    DataBaseOperaciones().insertarIngreso(
        {'nombre': 'ingreso semana 1',
          'monto': 50.0,
          'descripcion': 'desc1',
          'fecha_registro': DateTime(2025, 3, 1).toIso8601String(),
          'fk_id_usuario': 1,
          'fk_id_categoria_ingreso': 2
        }
    );

     */

    if(fechas.length==1) {
      // Solo se selecciono una fecha, muestran solo de ese dia
      _sumatoriaIngresosRangoDias = await _cargarSumatoriaIngresosRangoDias(fechas[0], fechas[0]);
    } else if(fechas.length>1) {
      // Se selecciono un rango
      _sumatoriaIngresosRangoDias = await _cargarSumatoriaIngresosRangoDias(fechas[0], fechas[1]);
    }

    if(_sumatoriaIngresosRangoDias.isEmpty) {
      _widgetsGenerados.clear();
      _widgetsGenerados.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Text(
              'No se encontraron registros en ese rango.',
            textAlign: TextAlign.center,
          ),
        )
      );
      setState(() {}); // Actualizar estado del widget

    } else {
      // Obtener suamtoria total de los elementos y promedio
      Decimal sumatoriaTotal = Decimal.zero;
      for(var ingreso in _sumatoriaIngresosRangoDias) {
        if(ingreso['monto']!=null) {
          sumatoriaTotal += Decimal.parse(ingreso['monto'].toString());
        }
      }

      double promedio = sumatoriaTotal.toDouble()/_sumatoriaIngresosRangoDias.length;

      _widgetsGenerados.clear();
      // Construir widgets
      // Primero se agrega el row donde se colocan todos los elementos
      _widgetsGenerados.add(
        const SizedBox(height: 15,),
      );
      _widgetsGenerados.add(
        Row(
          children: [
            // Dias
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Se agregan segun el numero de elementos en los elementos obtenidos
                for(var ingreso in _sumatoriaIngresosRangoDias)
                  Container(
                    child: Text(
                      ingreso['fecha'],
                    ),
                  ),
              ],
            ),

            // Lineas puntos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < _sumatoriaIngresosRangoDias.length; i++)
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

            // Monto de cada elemento
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for(var ingreso in _sumatoriaIngresosRangoDias)
                  Container(
                    child: Text(
                      formatearCantidad(ingreso['monto']),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            )
          ],
        ),
      );

      // Separador
      _widgetsGenerados.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          height: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
      );

      // Total de todos los elementos
      _widgetsGenerados.add(
        // Total de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                'Total:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: Text(
                formatearCantidad(sumatoriaTotal.toDouble()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

      // Promedio por dia
      _widgetsGenerados.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
              ),
              child: Text(
                'Promedio p/día:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
              ),
              child: Text(
                formatearCantidad(promedio),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
      setState(() {}); // Actualizar estado
    }

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
            // Obtener promedios
            double sumaTotalDiasSemanaActual = _obtenerSumaTotal(_sumatoriaIngresosSemanaActual);
            double sumaTotalMesActual = _obtenerSumaTotal(_sumatoriaIngresosMesActual);
            double sumaTotalAnioActual = _obtenerSumaTotal(_sumatoriaIngresosAnioActual);

            double promedioSemanaActual = sumaTotalDiasSemanaActual/7;
            double meses = _sumatoriaIngresosMesActual['semana5']!=null ? 5.0 : 4.0;
            double promedioMesActual = sumaTotalMesActual/meses;
            double promedioAnioActual = sumaTotalAnioActual/12;

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
                                          if(value!=null) {
                                            List<DateTime> valueSinNull = value.cast<DateTime>(); // Eliminar nulos
                                            _generarWidgets(valueSinNull);
                                          }
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
                                        if(_widgetsGenerados.isEmpty)
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 20),
                                            child: Text('Selecciona un rango de fechas para mostrar ingresos.'),
                                          )
                                        else
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: _widgetsGenerados,
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Segundo apartado
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
                                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                                                  child: Text(
                                                      'Sábado:'
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                    'Domingo:',
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
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['lunes']!=null ? _sumatoriaIngresosSemanaActual['lunes'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['martes']!=null ? _sumatoriaIngresosSemanaActual['martes'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['miercoles']!=null ? _sumatoriaIngresosSemanaActual['miercoles'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['jueves']!=null ? _sumatoriaIngresosSemanaActual['jueves'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['viernes']!=null ? _sumatoriaIngresosSemanaActual['viernes'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['sabado']!=null ? _sumatoriaIngresosSemanaActual['sabado'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosSemanaActual['domingo']!=null ? _sumatoriaIngresosSemanaActual['domingo'] : 0.0),
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
                                              child: Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                formatearCantidad(sumaTotalDiasSemanaActual),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Promedio
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                'Promedio p/día:',
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
                                                formatearCantidad(promedioSemanaActual),
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
                                    'Total de ingresos por semana del mes actual',
                                    style: TextStyle(
                                      //fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                                                    'Sem 1-7:',
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Sem 8-14:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Sem 15-21:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Sem 22-28:'
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Sem 29-31:'
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Lineas puntos
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  for (int i = 0; i < 5; i++)
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
                                                    formatearCantidad(_sumatoriaIngresosMesActual['sem_1_7']!=null ? _sumatoriaIngresosMesActual['sem_1_7'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['sem_8_14']!=null ? _sumatoriaIngresosMesActual['sem_8_14'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['sem_15_21']!=null ? _sumatoriaIngresosMesActual['sem_15_21'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['sem_22_28']!=null ? _sumatoriaIngresosMesActual['sem_22_28'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosMesActual['sem_29_31']!=null ? _sumatoriaIngresosMesActual['sem_29_31'] : 0.0),
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
                                              child: Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
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
                                        // Promedio
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                'Promedio p/semana:',
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
                                                formatearCantidad(promedioMesActual),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        )


                                      ],
                                    ),
                                  ),

                                  // Cuarto apartado
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
                                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['enero']!=null ? _sumatoriaIngresosAnioActual['enero'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['febrero']!=null ? _sumatoriaIngresosAnioActual['febrero'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['marzo']!=null ? _sumatoriaIngresosAnioActual['marzo'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['abril']!=null ? _sumatoriaIngresosAnioActual['abril'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['mayo']!=null ? _sumatoriaIngresosAnioActual['mayo'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['junio']!=null ? _sumatoriaIngresosAnioActual['junio'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['julio']!=null ? _sumatoriaIngresosAnioActual['junio'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['agosto']!=null ? _sumatoriaIngresosAnioActual['agosto'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['septiembre']!=null ? _sumatoriaIngresosAnioActual['septiembre'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['octubre']!=null ? _sumatoriaIngresosAnioActual['octubre'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['noviembre']!=null ? _sumatoriaIngresosAnioActual['noviembre'] : 0.0),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaIngresosAnioActual['diciembre']!=null ? _sumatoriaIngresosAnioActual['diciembre'] : 0.0),
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
                                              child: Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
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
                                        // Promedio
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                'Promedio p/mes:',
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
                                                formatearCantidad(promedioAnioActual),
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
                                  const SizedBox(height: 30),

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