import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';


class EtiquetaPorcentaje extends StatefulWidget {
  const EtiquetaPorcentaje({super.key,
    required this.texto,
    required this.colorFondo,
    this.textStyle,
    //required this.colorTexto,
    //this.fontWeight = FontWeight.normal,
    //this.textSize = -1
  });
  final String texto;
  final Color colorFondo;
  final TextStyle? textStyle;
  //final Color colorTexto;
  //final FontWeight fontWeight;
  //final double textSize;

  @override
  State<EtiquetaPorcentaje> createState() => _EtiquetaPorcentajeState();
}

class _EtiquetaPorcentajeState extends State<EtiquetaPorcentaje> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.colorFondo,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Text(
        widget.texto,
        softWrap: true,
        style: widget.textStyle ?? const TextStyle(
          color: Colors.black
        ),
        /*
        style: TextStyle(
          color: widget.colorTexto,
          fontWeight: widget.fontWeight!=FontWeight.normal ? widget.fontWeight: FontWeight.normal,
          fontSize: widget.textSize!=-1 ? widget.textSize : null
        ),

         */
      ),
    );
  }
}


// Barra de progreso
class BarraProgreso extends StatefulWidget {
  const BarraProgreso({super.key,
    required this.labelInicio,
    required this.labelFinal,
    required this.porcentajeProgreso,
    required this.colorBarraPrincipal,
    required this.colorBarraSecundario,
  });
  final String labelInicio;
  final String labelFinal;
  final double porcentajeProgreso;
  final Color colorBarraPrincipal;
  final Color colorBarraSecundario;

  @override
  State<BarraProgreso> createState() => _BarraProgresoState();
}

class _BarraProgresoState extends State<BarraProgreso> {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 10.0, left: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Etiquetas inicio y final
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(widget.labelInicio),
                    Text(widget.labelFinal),
                  ],
                ),
                const SizedBox(height: 2.0,),

                // Barra de progreso
                Stack(
                  //alignment: Alignment.topLeft,
                  children: <Widget>[
                    // Barra
                    TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.porcentajeProgreso/100),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: widget.colorBarraSecundario,
                            color: widget.colorBarraPrincipal,
                            minHeight: 4.0,
                            borderRadius: BorderRadius.circular(10.0),
                          );
                        }
                    ),
                    // Texto con el valor de la barra
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 69) * (widget.porcentajeProgreso / 100)),
                          child: Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "${widget.porcentajeProgreso.toStringAsFixed(2)}%",
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                      ),
                    )
                  ],
                ),

              ],

            )
          ],
        )
    );
  }
}


// Grafica de linea para los dias
class GraficaLinea1 extends StatefulWidget {
  const GraficaLinea1({super.key,
    required this.datosGraficar,
    required this.colorDegradado1,
    required this.colorDegradado2,
  });
  final Map<String, dynamic> datosGraficar;
  final Color colorDegradado1;
  final Color colorDegradado2;


  @override
  State<GraficaLinea1> createState() => _GraficaLinea1State();
}

class _GraficaLinea1State extends State<GraficaLinea1> {
  late Future<void> _cargaInicial;
  List<Color> _gradientColors = [];
  List<FlSpot> _valoresXYSpotFl = [];
  double _valorMayorY = 0.0;


  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarDatosVista();
    _valorMayorY = _obtenerValorMayor(widget.datosGraficar);
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    await Future.wait([
      // Funciones de las que se espera un resultado
      _generarValoresXYSpot(),
    ]);
  }



  // Obtener valores en x para la grafica
  Future<void> _generarValoresXYSpot() async {
    int x = 0; // Valor para eje x (indice de cada elemento)
    const List<String> diasSemana = [
      'domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'
    ];
    _valoresXYSpotFl.clear();
    for(String dia in diasSemana) {
      final valor = widget.datosGraficar[dia]?.toDouble() ?? 0.0;
      _valoresXYSpotFl.add(FlSpot(x.toDouble(), valor));
      x++; // Se asigna un indice distinto
    }
  }

  double _obtenerValorMayor(Map<String, dynamic> valores) {
    double mayor = 0.0;
    valores.forEach((key, value) {
      if(value!=null && value.toDouble()>mayor) {
        mayor = value.toDouble();
      }
    });
    return mayor;
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }

  @override
  Widget build(BuildContext context) {
    // Para la grafica de linea
    _gradientColors = [
      widget.colorDegradado1, // cyan
      widget.colorDegradado2, // blueAccent
    ];

    return FutureBuilder<void>( // Se utiliza FutureBuilder porque para construir el Scaffold primero se deben de cargar datos de funciones asincronas
        future: _cargaInicial,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            // Los datos estan cargando
            return Center(child: CircularProgressIndicator());

          } else if(snapshot.hasError) {
            return Text("Ocurrio un error, ${snapshot.error}");

          } else {
            // Los datos se cargaron
            return SizedBox(
              height: MediaQuery.of(context).size.height*0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Stack(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.50,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 18,
                          left: 12,
                          top: 24,
                          bottom: 12,
                        ),
                        child: LineChart(
                          mainData(),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            );
          }
        }
    );

  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _valorMayorY>0 ? (_valorMayorY/widget.datosGraficar.length) : 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: _valoresXYSpotFl.isNotEmpty ? _valoresXYSpotFl.length.toDouble() -1 : 0,
      minY: 0,
      maxY: _valorMayorY * 1.1,
      lineBarsData: [
        LineChartBarData(
          spots: _valoresXYSpotFl,
          isCurved: true,
          gradient: LinearGradient(
            colors: _gradientColors,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: _gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const List<String> diasAbreviados = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SAB'];
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    String text = '';
    if(value.toInt()>=0 && value.toInt()<diasAbreviados.length) {
      text = diasAbreviados[value.toInt()]; // Indide del dia
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    // Mostrar solo la etiqueta en el valor maximo del eje Y
    String text;
    if (value==_valorMayorY) {
      if (_valorMayorY>=1000) {
        text = '${(_valorMayorY/1000).toStringAsFixed(2)}K';  // Convierte el número y agrega K
      } else {
        text = _valorMayorY.toStringAsFixed(0);  // Muestra sin "K" si es menor a 1000
      }
    } else {
      return Container();  // No muestra nada en otros valores
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }



}



// Grafica de linea para los meses
class GraficaLineaMeses extends StatefulWidget {
  const GraficaLineaMeses({super.key,
    required this.datosGraficar,
    required this.colorDegradado1,
    required this.colorDegradado2,
  });
  final Map<String, dynamic> datosGraficar;
  final Color colorDegradado1;
  final Color colorDegradado2;


  @override
  State<GraficaLineaMeses> createState() => _GraficaLineaMesesState();
}

class _GraficaLineaMesesState extends State<GraficaLineaMeses> {
  late Future<void> _cargaInicial;
  List<Color> _gradientColors = [];
  List<FlSpot> _valoresXYSpotFl = [];
  double _valorMayorY = 0.0;


  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarDatosVista();
    _valorMayorY = _obtenerValorMayor(widget.datosGraficar);
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    await Future.wait([
      // Funciones de las que se espera un resultado
      _generarValoresXYSpot(),
    ]);
  }



  // Obtener valores en x para la grafica
  Future<void> _generarValoresXYSpot() async {
    int x = 0; // Valor para eje x (indice de cada elemento)
    const List<String> meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    _valoresXYSpotFl.clear();
    for(String mes in meses) {
      final valor = widget.datosGraficar[mes]?.toDouble() ?? 0.0;
      _valoresXYSpotFl.add(FlSpot(x.toDouble(), valor));
      x++; // Se asigna un indice distinto
    }
  }

  double _obtenerValorMayor(Map<String, dynamic> valores) {
    double mayor = 0.0;
    valores.forEach((key, value) {
      if(value!=null && value.toDouble()>mayor) {
        mayor = value.toDouble();
      }
    });
    return mayor;
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }

  @override
  Widget build(BuildContext context) {
    // Para la grafica de linea
    _gradientColors = [
      widget.colorDegradado1, // cyan
      widget.colorDegradado2, // blueAccent
    ];

    return FutureBuilder<void>( // Se utiliza FutureBuilder porque para construir el Scaffold primero se deben de cargar datos de funciones asincronas
        future: _cargaInicial,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            // Los datos estan cargando
            return Center(child: CircularProgressIndicator());

          } else if(snapshot.hasError) {
            return Text("Ocurrio un error, ${snapshot.error}");

          } else {
            // Los datos se cargaron
            return SizedBox(
              height: MediaQuery.of(context).size.height*0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Stack(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.50,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 18,
                          left: 12,
                          top: 24,
                          bottom: 12,
                        ),
                        child: LineChart(
                          mainData(),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            );
          }
        }
    );

  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _valorMayorY>0 ? (_valorMayorY/widget.datosGraficar.length) : 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: _valoresXYSpotFl.isNotEmpty ? _valoresXYSpotFl.length.toDouble() -1 : 0,
      minY: 0,
      maxY: _valorMayorY * 1.1,
      lineBarsData: [
        LineChartBarData(
          spots: _valoresXYSpotFl,
          isCurved: false,
          gradient: LinearGradient(
            colors: _gradientColors,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: _gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const List<String> mesesAbreviados = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    String text = '';
    if(value.toInt()>=0 && value.toInt()<mesesAbreviados.length) {
      text = mesesAbreviados[value.toInt()]; // Indide del mes
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    // Mostrar solo la etiqueta en el valor maximo del eje Y
    String text;
    if (value==_valorMayorY) {
      if (_valorMayorY>=1000) {
        text = '${(_valorMayorY/1000).toStringAsFixed(2)}K';  // Convierte el número y agrega K
      } else {
        text = _valorMayorY.toStringAsFixed(0);  // Muestra sin "K" si es menor a 1000
      }
    } else {
      return Container();  // No muestra nada en otros valores
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }



}