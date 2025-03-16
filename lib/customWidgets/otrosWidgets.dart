import 'package:flutter/material.dart';

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
                          padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 62) * (widget.porcentajeProgreso / 100)),
                          child: Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "${widget.porcentajeProgreso.toStringAsFixed(2)}%",

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