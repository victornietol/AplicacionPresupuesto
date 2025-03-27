import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


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
  List<Color> _gradientColors = [];
  List<FlSpot> _valoresXYSpotFl = [];
  double _valorMayorY = 0.0;


  @override
  void initState() {
    super.initState();
    _valorMayorY = _obtenerValorMayor(widget.datosGraficar);
    _generarValoresXYSpot();
  }


  // Obtener valores en x para la grafica
  void _generarValoresXYSpot() {
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
  List<Color> _gradientColors = [];
  List<FlSpot> _valoresXYSpotFl = [];
  double _valorMayorY = 0.0;


  @override
  void initState() {
    super.initState();
    _valorMayorY = _obtenerValorMayor(widget.datosGraficar);
    _generarValoresXYSpot();
  }

  // Obtener valores en x para la grafica
  void _generarValoresXYSpot() {
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



// Grafica del resumen 2
class GraficaBarras2SinDialog extends StatefulWidget {
  const GraficaBarras2SinDialog({super.key,
    required this.tipo,
    required this.listaCantidades,
  });
  final String tipo;
  final Map<String, dynamic> listaCantidades;

  @override
  State<GraficaBarras2SinDialog> createState() => _GraficaBarras2SinDialogState();
}

class _GraficaBarras2SinDialogState extends State<GraficaBarras2SinDialog> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grafica Scroll horizontal
        SizedBox(
            height: MediaQuery.of(context).size.height*0.4,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: widget.listaCantidades.length*80, // ancho dependiendo del numero de elementos
                child: TweenAnimationBuilder<double>( // Animador para la barra
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, animationValue, child) {
                    return BarChart( // Grafica de barras
                        BarChartData(
                            borderData: FlBorderData(show: false),
                            alignment: BarChartAlignment.spaceAround,
                            maxY: widget.listaCantidades.values.reduce((a, b) => a>b ? a : b)*1.1, // obtener el valor maximo para Y
                            barGroups: widget.listaCantidades.entries.toList().asMap().entries.map((entry) {
                              int index = entry.key; // indice manual
                              MapEntry<String, dynamic> datosEntry = entry.value; // entrada del map
                              double cantidad = datosEntry.value; // monto de la categoria

                              return BarChartGroupData(
                                x: index, // Indice de la barra del grafico
                                barRods: [
                                  BarChartRodData( // Barras
                                    toY: cantidad * animationValue, // altura de la barra (eje Y)
                                    color: Colors.primaries[index % Colors.primaries.length], // Agregar color dinamicamente
                                    width: 30, // ancho de la barras
                                  ),
                                ],
                                //showingTooltipIndicators: [0] // Donde mostrar tooltip
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)
                                ),
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          // Obtener titulo
                                          int index = value.toInt();
                                          if(index>=0 && index<widget.listaCantidades.length) {
                                            String titulo = widget.listaCantidades.keys.elementAt(index)[0].toUpperCase()+widget.listaCantidades.keys.elementAt(index).substring(1); // obtener categoria
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Transform.rotate(
                                                angle: -0.6, // Rotar texto
                                                child: Text(
                                                  titulo,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            );
                                          }
                                          // Si no hay valores validos no se muestra nada
                                          return Container();
                                        },
                                        reservedSize: 60 // espacio para los titulos del eje X
                                    )
                                )
                            )
                        )
                    );
                  },
                ),
              ),
            )
        ),
        const SizedBox(height: 10,),

        // Leyenda de colores
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.listaCantidades.entries.toList().asMap().entries.map((entry) {
            int index = entry.key;
            String categoria = entry.value.key;
            return Row(
              children: <Widget>[
                Container(
                  width: 15,
                  height: 15,
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                const SizedBox(width: 8,),
                Text(categoria[0].toUpperCase()+categoria.substring(1))
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

}


// Grafica Radial Bar
class GraficaRadialBarSinDialog extends StatefulWidget {
  const GraficaRadialBarSinDialog({super.key,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.colorIngresos,
    required this.colorEgresos,
  });
  final double totalIngresos;
  final double totalEgresos;
  final Color colorIngresos;
  final Color colorEgresos;

  @override
  State<GraficaRadialBarSinDialog> createState() => GraficaRadialBarSinDialogState();
}

class GraficaRadialBarSinDialogState extends State<GraficaRadialBarSinDialog> {

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> datos = [
      {'tipo':'Ingresos', 'monto':widget.totalIngresos, 'color':widget.colorIngresos},
      {'tipo':'Egresos', 'monto':widget.totalEgresos, 'color':widget.colorEgresos}
    ];

    return SfCircularChart(
      title: const ChartTitle(
        text: 'Cantidades',
      ),
      legend: const Legend(isVisible: true, isResponsive: true),
      series: <RadialBarSeries<Map<String, dynamic>, String>>[
        RadialBarSeries<Map<String, dynamic>, String>(
          dataSource: datos,
          xValueMapper: (Map<String, dynamic> data, _) => data['tipo'],
          yValueMapper: (Map<String, dynamic> data, _) => data['monto'],
          pointColorMapper: (Map<String, dynamic> data, _) => data['color'],
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}