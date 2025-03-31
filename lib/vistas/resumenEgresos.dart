import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:decimal/decimal.dart';


class ResumenEgresos extends StatefulWidget {
  const ResumenEgresos({super.key,
    required this.title,
    required this.usuario,
    required this.presupuesto});
  final String title;
  final String usuario;
  final Map<String, dynamic> presupuesto;

  @override
  State<ResumenEgresos> createState() => ResumenEgresosState();
}

class ResumenEgresosState extends State<ResumenEgresos> {
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos
  Map<String, dynamic> _sumatoriaEgresosSemanaActual = {};
  Map<String, dynamic> _sumatoriaEgresosMesActual = {};
  Map<String, dynamic> _sumatoriaEgresosAnioActual = {};
  List<Map<String, dynamic>> _sumatoriaEgresosRangoDias = [];
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
      _cargarSumatoriaEgresosSemanaActual(),
      _cargarSumatoriaEgresosMesActual(),
      _cargarSumatoriaEgresosAnioActual(),
    ]);
  }

  Future<void> _cargarSumatoriaEgresosSemanaActual() async {
    _sumatoriaEgresosSemanaActual = await DataBaseOperaciones().obtenerEgresosPorDiaSemanaActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<void> _cargarSumatoriaEgresosMesActual() async {
    _sumatoriaEgresosMesActual = await DataBaseOperaciones().obtenerEgresosPorSemanaMesActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<void> _cargarSumatoriaEgresosAnioActual() async {
    _sumatoriaEgresosAnioActual = await DataBaseOperaciones().obtenerEgresosPorMesAnioActual(widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
  }

  Future<List<Map<String, dynamic>>> _cargarSumatoriaEgresosRangoDias(DateTime fechaInicio, DateTime fechaFinal) async {
    return await DataBaseOperaciones().obtenerEgresosDentroDelRango(fechaInicio, fechaFinal, widget.presupuesto['id_presupuesto'], widget.presupuesto['fk_id_usuario']);
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
    if(fechas.length==1) {
      // Solo se selecciono una fecha, muestran solo de ese dia
      _sumatoriaEgresosRangoDias = await _cargarSumatoriaEgresosRangoDias(fechas[0], fechas[0]);
    } else if(fechas.length>1) {
      // Se selecciono un rango
      _sumatoriaEgresosRangoDias = await _cargarSumatoriaEgresosRangoDias(fechas[0], fechas[1]);
    }

    if(_sumatoriaEgresosRangoDias.isEmpty) {
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
      for(var egreso in _sumatoriaEgresosRangoDias) {
        if(egreso['monto']!=null) {
          sumatoriaTotal += Decimal.parse(egreso['monto'].toString());
        }
      }

      double promedio = sumatoriaTotal.toDouble()/_sumatoriaEgresosRangoDias.length;

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
                for(var egreso in _sumatoriaEgresosRangoDias)
                  Container(
                    child: Text(
                      egreso['fecha'],
                    ),
                  ),
              ],
            ),

            // Lineas puntos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < _sumatoriaEgresosRangoDias.length; i++)
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
                for(var egreso in _sumatoriaEgresosRangoDias)
                  Container(
                    child: Text(
                      formatearCantidad(egreso['monto']),
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
            double sumaTotalDiasSemanaActual = _obtenerSumaTotal(_sumatoriaEgresosSemanaActual);
            double sumaTotalMesActual = _obtenerSumaTotal(_sumatoriaEgresosMesActual);
            double sumaTotalAnioActual = _obtenerSumaTotal(_sumatoriaEgresosAnioActual);

            double promedioSemanaActual = sumaTotalDiasSemanaActual/7;
            double meses = _sumatoriaEgresosMesActual['semana5']!=null ? 5.0 : 4.0;
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
                                  'Total de egresos por dia dentro de un rango',
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
                                          child: Text('Selecciona un rango de fechas para mostrar egresos.'),
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
                                  'Total de egresos por día de la semana actual',
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
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['domingo']!=null ? _sumatoriaEgresosSemanaActual['domingo'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['lunes']!=null ? _sumatoriaEgresosSemanaActual['lunes'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['martes']!=null ? _sumatoriaEgresosSemanaActual['martes'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['miercoles']!=null ? _sumatoriaEgresosSemanaActual['miercoles'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['jueves']!=null ? _sumatoriaEgresosSemanaActual['jueves'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['viernes']!=null ? _sumatoriaEgresosSemanaActual['viernes'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  bottom: 5,
                                                ),
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosSemanaActual['sabado']!=null ? _sumatoriaEgresosSemanaActual['sabado'] : 0.0),
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
                                  'Total de egresos por semana del mes actual',
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
                                              if(_sumatoriaEgresosMesActual['semana5']!=null)
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
                                                for (int i = 0; i < (_sumatoriaEgresosMesActual['semana5']!=null ? 5 : 4); i++)
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
                                                  formatearCantidad(_sumatoriaEgresosMesActual['semana1']!=null ? _sumatoriaEgresosMesActual['semana1'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosMesActual['semana2']!=null ? _sumatoriaEgresosMesActual['semana2'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosMesActual['semana3']!=null ? _sumatoriaEgresosMesActual['semana3'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosMesActual['semana4']!=null ? _sumatoriaEgresosMesActual['semana4'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              if(_sumatoriaEgresosMesActual['semana5']!=null)
                                                Container(
                                                  child: Text(
                                                    formatearCantidad(_sumatoriaEgresosMesActual['semana5']),
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
                                              formatearCantidad(_obtenerSumaTotal(_sumatoriaEgresosMesActual)),
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
                                  'Total de egresos por mes del año actual',
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
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['enero']!=null ? _sumatoriaEgresosAnioActual['enero'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['febrero']!=null ? _sumatoriaEgresosAnioActual['febrero'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['marzo']!=null ? _sumatoriaEgresosAnioActual['marzo'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['abril']!=null ? _sumatoriaEgresosAnioActual['abril'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['mayo']!=null ? _sumatoriaEgresosAnioActual['mayo'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['junio']!=null ? _sumatoriaEgresosAnioActual['junio'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['julio']!=null ? _sumatoriaEgresosAnioActual['julio'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['agosto']!=null ? _sumatoriaEgresosAnioActual['agosto'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['septiembre']!=null ? _sumatoriaEgresosAnioActual['septiembre'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['octubre']!=null ? _sumatoriaEgresosAnioActual['octubre'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['noviembre']!=null ? _sumatoriaEgresosAnioActual['noviembre'] : 0.0),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  bottom: 5,
                                                ),
                                                child: Text(
                                                  formatearCantidad(_sumatoriaEgresosAnioActual['diciembre']!=null ? _sumatoriaEgresosAnioActual['diciembre'] : 0.0),
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
                                              formatearCantidad(_obtenerSumaTotal(_sumatoriaEgresosAnioActual)),
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