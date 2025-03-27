import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_presupuesto/customWidgets/cuadrosDialogo.dart';
import 'package:calculadora_presupuesto/navegador.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:calculadora_presupuesto/customWidgets/otrosWidgets.dart';

// Widget con el contenido de cada pestaña
class BotonIngresoEgreso extends StatefulWidget {
  const BotonIngresoEgreso({super.key,
    required this.tipo,
    required this.listaElementos,
    required this.totalIngresos,
    required this.listaCategorias,
    required this.usuario,
    required this.idPresupuesto,
    required this.mostrarTotalIngresosCategoria
  });
  final String tipo; // Indica si es Ingreso o Egreso
  final List<Map<String, dynamic>> listaElementos; // Datos completos de ingresos o egresos
  final Decimal totalIngresos;
  final List<Map<String, dynamic>> listaCategorias; // Datos completos de las categorias (tabla categorias)
  final String usuario;
  final int idPresupuesto;
  final bool mostrarTotalIngresosCategoria;


  @override
  State<BotonIngresoEgreso> createState() => _BotonIngresoEgresoState();
}

class _BotonIngresoEgresoState extends State<BotonIngresoEgreso> {
  // Lista de los widgets para los ingreso o egresos
  List<Widget> botones = [];
  final List<String> _ordenarPorCampo = ['fecha_registro', 'monto', 'nombre'];
  String? _ordenarPorCampo_Valor = 'fecha_registro';
  final List<String> _ordenarAscDesc = ['descendente', 'ascendente'];
  String? _ordenarAscDesc_Valor = 'descendente';

  List<Map<String, dynamic>> _listaElementosMutable = [];

  double _sumaTotalCategoria = 0.0;
  double _porcentajeCategoria = 0.0;

  @override
  void initState() {
    super.initState();
    _listaElementosMutable = List.from(widget.listaElementos); // Hacer mutable la lista para poder ordenarla
    _sumaTotalCategoria = _obtenerSumaTotalCategoria(widget.listaElementos);
    _porcentajeCategoria = _obtenerPorcentajeCategoria(_sumaTotalCategoria, widget.totalIngresos.toDouble());
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

  void _ordenarListaElementos() {
    // Determinar si se ordena ascendete o descendente
    int Function(Map<String, dynamic>, Map<String, dynamic>) comparar;
    if(_ordenarAscDesc_Valor==_ordenarAscDesc[0]) {
      comparar = (a, b) => b[_ordenarPorCampo_Valor].compareTo(a[_ordenarPorCampo_Valor]); // descendete
    } else {
      comparar = (a, b) => a[_ordenarPorCampo_Valor].compareTo(b[_ordenarPorCampo_Valor]); // ascendente
    }
    try {
      // Realizar la comparacion para determinar el order
      setState(() {
        _listaElementosMutable.sort(comparar);
      });

    } catch (e) {
      print("Error en la funcion _ordenarListaElementos de la clase _BotonIngresoEgresoState del archivo botones.dart: $e");
    }
  }
  
  // Crear widgets con los botones que muestran los ingresos o egresos
  void _crearWidgetsTodos() {
    double tamanioTextPrincipal = 20.0;
    botones.clear(); // Evitar duplicados

    // ordenar lista de elementos antes de construir los widgets
    _ordenarListaElementos();


      // Recorrer todos los elementos de la BD y crear un boton para cada elemento
      for (var elemento in _listaElementosMutable) {
        double porcentaje = (elemento['monto']*100.0) / widget.totalIngresos.toDouble(); // Se utiliza double en lugar de decimal para el porcentaje por temas de precision en el punto decimal que no puede manejar Decimal
        String categoria = widget.tipo=='ingreso' ? obtenerCategoria(elemento['fk_id_categoria_ingreso']) : obtenerCategoria(elemento['fk_id_categoria_egreso']);
        String montoFormateado = formatearCantidad(elemento['monto']);

        // Widget que se mostrara
        botones.add(
            Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: MaterialButton(
                onPressed: () => {
                  // Construir nueva ventana para detalles
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CuadroDialogoDetalles(
                            tipo: widget.tipo,
                            listaCategorias: widget.listaCategorias,
                            elemento: elemento,
                            categoriaElemento: categoria,
                            montoFormateado: montoFormateado,
                            porcentaje: porcentaje,
                            idPresupuesto: widget.idPresupuesto,
                            usuario: widget.usuario
                        );
                      }
                  )
                },
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
                              softWrap: true,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: tamanioTextPrincipal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text( // Categoria
                              categoria[0].toUpperCase()+categoria.substring(1),
                              style: const TextStyle(
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
                            if(widget.mostrarTotalIngresosCategoria) // Si es una pestaña de una categoria (no se muestra en pestaña 'todos')
                              Row(
                                children: <Widget>[
                                  EtiquetaPorcentaje( // Porcentaje
                                    texto: '${((elemento['monto']*100.0) / _sumaTotalCategoria).toStringAsFixed(2)}%', // Porcentaje respecto al total de la categoria actual
                                    colorFondo: const Color(0xffdae9ff),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(width: 2.0,),
                                  EtiquetaPorcentaje( // Porcentaje
                                    texto: '${porcentaje.toStringAsFixed(2)}%', // Porcentaje respecto al total de ingresos o egresos
                                    colorFondo: widget.tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            else // Si es la pestaña todos
                              EtiquetaPorcentaje( // Porcentajes
                                  texto: '${porcentaje.toStringAsFixed(2)}%',
                                  colorFondo: widget.tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                  ),
                              ),
                            /*
                            Container( // Porcentajes
                              color: Color(0xFFd4fed7),
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Text(
                                '${porcentaje.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                ),
                              ),
                            ),

                             */

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

  // Obtener suma total de los elementos por categoria
  double _obtenerSumaTotalCategoria(List<Map<String, dynamic>> elementosCategoria) {
    return widget.listaElementos.fold<Decimal>(
        Decimal.zero, (total, element) => total + Decimal.parse(element['monto'].toString())
    ).toDouble();
  }

  // Obtener porcentaje de la suma de la categoria respecto al total
  double _obtenerPorcentajeCategoria(double totalCategoria, double totalElementos) {
    return (totalCategoria*100) / totalElementos;
  }

  @override
  Widget build(BuildContext context) {
    return Column( // Esto es lo que regresa el widget
      children: [
        // Mostrar total de ingresos por categoria (no se muestra en la pestaña 'todos')
        if(widget.mostrarTotalIngresosCategoria)
          Column(
            children: [
              // Texto de total de la categoria
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EtiquetaPorcentaje(
                    texto: "Total de esta categoria:",
                    colorFondo: Color(0xffdae9ff),
                    textStyle: TextStyle(
                      color: Colors.indigo,
                    ),
                    /*
                  colorTexto: Colors.green,
                  textSize: 20.0,
                  fontWeight: FontWeight.bold,

                   */
                  ),
                  EtiquetaPorcentaje(
                    texto: "${formatearCantidad(_sumaTotalCategoria)} (${_porcentajeCategoria.toStringAsFixed(2)}%)",
                    colorFondo: const Color(0xffdae9ff),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    /*
                  colorTexto: Colors.green,
                  textSize: 20.0,
                  fontWeight: FontWeight.bold,

                   */
                  ),
                ],
              ),
              // Barra porcentaje del total
              BarraProgreso(
                labelInicio: formatearCantidad(0.0),
                labelFinal: formatearCantidad(widget.totalIngresos.toDouble()),
                porcentajeProgreso: _porcentajeCategoria,
                colorBarraPrincipal: Colors.indigo,
                colorBarraSecundario: widget.tipo=='ingreso' ? Colors.green : Colors.red,
              ),
            ],
          ),



        // Botones de ordenamiento
        Row(
          children: [
            Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      _ordenarPorCampo_Valor ?? 'Fecha registro',
                      style: const TextStyle(
                          color: Colors.black
                      ),
                    ),
                    items: _ordenarPorCampo
                        .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item[0].toUpperCase()+item.substring(1)=='Fecha_registro' ?
                          'Fecha registro' :
                          item[0].toUpperCase()+item.substring(1),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ))
                        .toList(),
                    value: _ordenarPorCampo_Valor,
                    onChanged: (String? value) {
                      setState(() {
                        _ordenarPorCampo_Valor = value;
                        _crearWidgetsTodos();
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: double.maxFinite,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                  ),
                ),
            ),
            Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      _ordenarAscDesc_Valor ?? 'Descendente',
                      style: const TextStyle(
                          color: Colors.black
                      ),
                    ),
                    items: _ordenarAscDesc
                        .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item[0].toUpperCase()+item.substring(1),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ))
                        .toList(),
                    value: _ordenarAscDesc_Valor,
                    onChanged: (String? value) {
                      setState(() {
                        _ordenarAscDesc_Valor = value;
                        _crearWidgetsTodos();
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: double.maxFinite,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                  ),
                ),
            ),
          ],
        ),

        // Lista de botones de elementos
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: botones,
              ),
            ),
        ),
      ],
    );
    /*
      Column(
      children: [
        // Boton para ordenamiento
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: const Text(
              'Ordenar por',
              style: TextStyle(
                  color: Colors.black
              ),
            ),
            items: _ordenarPorCampo
                .map((String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item[0].toUpperCase()+item.substring(1),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
                .toList(),
            value: _ordenarPorCampo_Valor,
            onChanged: (String? value) {
              setState(() {
                _ordenarPorCampo_Valor = value;
              });
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              width: double.maxFinite,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
          ),
        ),

        // Lista de botones
        SingleChildScrollView(
          child: Column(
          children: botones,
          ),
        ),
      ],
    );

     */
  }


}



// Es lo mismo que BotonIngresoEgreso pero en este cambia el ordenamiento de la BarraProgreso y los botones de ordenamiento para poder hacer la vista con scroll
class BotonIngresoEgreso2 extends StatefulWidget {
  const BotonIngresoEgreso2({super.key,
    required this.tipo,
    required this.listaElementos,
    required this.totalIngresos,
    required this.listaCategorias,
    required this.usuario,
    required this.mostrarTotalIngresosCategoria,
    required this.idPresupuesto,
    this.nombreCategoria,
  });
  final String tipo; // Indica si es Ingreso o Egreso
  final List<Map<String, dynamic>> listaElementos; // Datos completos de ingresos o egresos
  final Decimal totalIngresos;
  final List<Map<String, dynamic>> listaCategorias; // Datos completos de las categorias (tabla categorias)
  final String usuario;
  final bool mostrarTotalIngresosCategoria;
  final int idPresupuesto;
  final String? nombreCategoria;


  @override
  State<BotonIngresoEgreso2> createState() => _BotonIngresoEgreso2State();
}

class _BotonIngresoEgreso2State extends State<BotonIngresoEgreso2> {
  // Lista de los widgets para los ingreso o egresos
  List<Widget> botones = [];
  final List<String> _ordenarPorCampo = ['fecha_registro', 'monto', 'nombre'];
  String? _ordenarPorCampo_Valor = 'fecha_registro';
  final List<String> _ordenarAscDesc = ['descendente', 'ascendente'];
  String? _ordenarAscDesc_Valor = 'descendente';

  List<Map<String, dynamic>> _listaElementosMutable = [];

  double _sumaTotalCategoria = 0.0;
  double _porcentajeCategoria = 0.0;

  @override
  void initState() {
    super.initState();
    _listaElementosMutable = List.from(widget.listaElementos); // Hacer mutable la lista para poder ordenarla
    _sumaTotalCategoria = _obtenerSumaTotalCategoria(widget.listaElementos);
    _porcentajeCategoria = _obtenerPorcentajeCategoria(_sumaTotalCategoria, widget.totalIngresos.toDouble());
    _crearWidgetsTodos();
  }

  // Obtener nombre de la categoria segun su id
  String obtenerCategoria(int fk_id) {
    return widget.listaCategorias.firstWhere(
          (element) => element['id_categoria']==fk_id,
      orElse: () => {'nombre': 'Sin categoria'},
    )['nombre'];
  }

  // Eliminar una categoria
  Future<bool> _eliminarCategoria(String nombreCategoria, String tipo) async {
    switch (tipo) {
      case 'ingreso':
        return await DataBaseOperaciones().eliminarCategoria(nombreCategoria, tipo, widget.idPresupuesto);
      case 'egreso':
        return await DataBaseOperaciones().eliminarCategoria(nombreCategoria, tipo, widget.idPresupuesto);
      default:
        return false;
    }
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }

  void _ordenarListaElementos() {
    // Determinar si se ordena ascendete o descendente
    int Function(Map<String, dynamic>, Map<String, dynamic>) comparar;
    if(_ordenarAscDesc_Valor==_ordenarAscDesc[0]) {
      comparar = (a, b) => b[_ordenarPorCampo_Valor].compareTo(a[_ordenarPorCampo_Valor]); // descendete
    } else {
      comparar = (a, b) => a[_ordenarPorCampo_Valor].compareTo(b[_ordenarPorCampo_Valor]); // ascendente
    }
    try {
      // Realizar la comparacion para determinar el order
      setState(() {
        _listaElementosMutable.sort(comparar);
      });

    } catch (e) {
      print("Error en la funcion _ordenarListaElementos de la clase _BotonIngresoEgresoState del archivo botones.dart: $e");
    }
  }

  // Crear widgets con los botones que muestran los ingresos o egresos
  void _crearWidgetsTodos() {
    double tamanioTextPrincipal = 20.0;
    botones.clear(); // Evitar duplicados

    // ordenar lista de elementos antes de construir los widgets
    _ordenarListaElementos();

    // Mostrar total de ingresos por categoria (no se muestra en la pestaña 'todos')
    if(widget.mostrarTotalIngresosCategoria) {
      botones.add(
        Column(
          children: [
            // Texto de total de la categoria y boton para eliminar categoria
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EtiquetaPorcentaje(
                  texto: "Total de esta categoria:",
                  colorFondo: Color(0xffdae9ff),
                  textStyle: TextStyle(
                    color: Colors.indigo,
                  ),

                ),
                EtiquetaPorcentaje(
                  texto: "${formatearCantidad(_sumaTotalCategoria)} (${_porcentajeCategoria.toStringAsFixed(2)}%)",
                  colorFondo: const Color(0xffdae9ff),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),

                ),
                MaterialButton(
                  minWidth: 20.0,
                  height: 30.0,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Pedir confirmacion para elimar
                          return AlertDialog(
                            content: const Text('¿Esta seguro de eliminar esta categoria?'),
                            actions: [
                              MaterialButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              // Boton para confirmar la eliminacion
                              MaterialButton(
                                  onPressed: () {
                                    _eliminarCategoria(widget.nombreCategoria ?? '', widget.tipo).then((value) {
                                      if(value && widget.tipo=='ingreso') {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Navegador(inicio: 0, usuario: widget.usuario)),
                                              (Route<dynamic> route) => false,
                                        );
                                      } else if(value && widget.tipo=='egreso') {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Navegador(inicio: 2, usuario: widget.usuario)),
                                              (Route<dynamic> route) => false,
                                        );
                                      } else {
                                        // No se realizo la carga
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: const Text('Error al eliminar.'),
                                                actions: [
                                                  MaterialButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Aceptar'),
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                    });


                                  },
                                child: const Text(
                                    'Confirmar',
                                  style: TextStyle(
                                    color: Colors.indigo
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                    );
                  },
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            // Barra porcentaje del total
            BarraProgreso(
              labelInicio: formatearCantidad(0.0),
              labelFinal: formatearCantidad(widget.totalIngresos.toDouble()),
              porcentajeProgreso: _porcentajeCategoria,
              colorBarraPrincipal: Colors.indigo,
              colorBarraSecundario: widget.tipo=='ingreso' ? Colors.green : Colors.red,
            ),
          ],
        ),
      );
    }



    // Recorrer todos los elementos de la BD y crear un boton para cada elemento
    for (var elemento in _listaElementosMutable) {
      double porcentaje = (elemento['monto']*100.0) / widget.totalIngresos.toDouble(); // Se utiliza double en lugar de decimal para el porcentaje por temas de precision en el punto decimal que no puede manejar Decimal
      String categoria = widget.tipo=='ingreso' ? obtenerCategoria(elemento['fk_id_categoria_ingreso']) : obtenerCategoria(elemento['fk_id_categoria_egreso']);
      String montoFormateado = formatearCantidad(elemento['monto']);

      // Widget que se mostrara
      botones.add(
        Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: MaterialButton(
              onPressed: () => {
                // Construir nueva ventana para detalles
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CuadroDialogoDetalles(
                          tipo: widget.tipo,
                          listaCategorias: widget.listaCategorias,
                          elemento: elemento,
                          categoriaElemento: categoria,
                          montoFormateado: montoFormateado,
                          porcentaje: porcentaje,
                          idPresupuesto: widget.idPresupuesto,
                          usuario: widget.usuario
                      );
                    }
                )
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  )
                ),
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column( // parte izquieda
                            crossAxisAlignment: CrossAxisAlignment.start, // ------
                            children: [
                              Text( // Nombre de elemento
                                elemento["nombre"][0].toUpperCase()+elemento['nombre'].substring(1),
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: tamanioTextPrincipal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text( // Categoria
                                categoria[0].toUpperCase()+categoria.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),

                        Column( // parte derecha
                          crossAxisAlignment: CrossAxisAlignment.end, // ----------
                          children: [
                            Text(
                              montoFormateado,
                              style: TextStyle(
                                fontSize: tamanioTextPrincipal,
                              ),
                            ),
                            if(widget.mostrarTotalIngresosCategoria) // Si es una pestaña de una categoria (no se muestra en pestaña 'todos')
                              Row(
                                children: <Widget>[
                                  EtiquetaPorcentaje( // Porcentaje
                                    texto: '${((elemento['monto']*100.0) / _sumaTotalCategoria).toStringAsFixed(2)}%', // Porcentaje respecto al total de la categoria actual
                                    colorFondo: const Color(0xffdae9ff),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(width: 2.0,),
                                  EtiquetaPorcentaje( // Porcentaje
                                    texto: '${porcentaje.toStringAsFixed(2)}%', // Porcentaje respecto al total de ingresos o egresos
                                    colorFondo: widget.tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            else // Si es la pestaña todos
                              EtiquetaPorcentaje( // Porcentajes
                                texto: '${porcentaje.toStringAsFixed(2)}%',
                                colorFondo: widget.tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                ),
                              ),
                            /*
                            Container( // Porcentajes
                              color: Color(0xFFd4fed7),
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Text(
                                '${porcentaje.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                ),
                              ),
                            ),

                             */

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
              ),
            )
        ),
      );
    }
    setState(() {});
  }

  // Obtener suma total de los elementos por categoria
  double _obtenerSumaTotalCategoria(List<Map<String, dynamic>> elementosCategoria) {
    return widget.listaElementos.fold<Decimal>(
        Decimal.zero, (total, element) => total + Decimal.parse(element['monto'].toString())
    ).toDouble();
  }

  // Obtener porcentaje de la suma de la categoria respecto al total
  double _obtenerPorcentajeCategoria(double totalCategoria, double totalElementos) {
    double porcentaje = (totalCategoria*100) / totalElementos;
    if(porcentaje.isInfinite || porcentaje.isNaN) {
      return 0.0; // Si no hay porcentaje debido a que no hay elementos
    } else {
      return porcentaje;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column( // Esto es lo que regresa el widget
      children: [

        // Botones de ordenamiento
        Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    _ordenarPorCampo_Valor ?? 'Fecha registro',
                    style: const TextStyle(
                        color: Colors.black
                    ),
                  ),
                  items: _ordenarPorCampo
                      .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item[0].toUpperCase()+item.substring(1)=='Fecha_registro' ?
                      'Fecha registro' :
                      item[0].toUpperCase()+item.substring(1),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
                      .toList(),
                  value: _ordenarPorCampo_Valor,
                  onChanged: (String? value) {
                    setState(() {
                      _ordenarPorCampo_Valor = value;
                      _crearWidgetsTodos();
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    width: double.maxFinite,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    _ordenarAscDesc_Valor ?? 'Descendente',
                    style: const TextStyle(
                        color: Colors.black
                    ),
                  ),
                  items: _ordenarAscDesc
                      .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item[0].toUpperCase()+item.substring(1),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
                      .toList(),
                  value: _ordenarAscDesc_Valor,
                  onChanged: (String? value) {
                    setState(() {
                      _ordenarAscDesc_Valor = value;
                      _crearWidgetsTodos();
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    width: double.maxFinite,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Lista de botones de elementos
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: botones,
            ),
          ),
        ),
      ],
    );
  }
}



// Botones para mostrar ingreso o egreso (solamente botones sin otro widget)
class BotonIngresoEgresoRanking extends StatefulWidget {
  const BotonIngresoEgresoRanking({super.key,
    required this.tipo,
    required this.listaElementos,
    required this.totalSumatoriaElementos,
    required this.listaCategorias,
    required this.usuario,
    required this.mostrarTotalIngresosCategoria,
    required this.idPresupuesto,
    this.nombreCategoria,
  });
  final String tipo; // Indica si es Ingreso o Egreso
  final List<Map<String, dynamic>> listaElementos; // Datos completos de ingresos o egresos
  final Decimal totalSumatoriaElementos;
  final List<Map<String, dynamic>> listaCategorias; // Datos completos de las categorias (tabla categorias)
  final String usuario;
  final bool mostrarTotalIngresosCategoria;
  final int idPresupuesto;
  final String? nombreCategoria;


  @override
  State<BotonIngresoEgresoRanking> createState() => _BotonIngresoEgresoRankingState();
}

class _BotonIngresoEgresoRankingState extends State<BotonIngresoEgresoRanking> {
  // Lista de los widgets para los ingreso o egresos
  List<Widget> botones = [];
  final List<String> _ordenarPorCampo = ['fecha_registro', 'monto', 'nombre'];
  String? _ordenarPorCampo_Valor = 'fecha_registro';
  final List<String> _ordenarAscDesc = ['descendente', 'ascendente'];
  String? _ordenarAscDesc_Valor = 'descendente';

  List<Map<String, dynamic>> _listaElementosMutable = [];

  double _sumaTotalCategoria = 0.0;
  double _porcentajeCategoria = 0.0;

  @override
  void initState() {
    super.initState();
    //_listaElementosMutable = List.from(widget.listaElementos); // Hacer mutable la lista para poder ordenarla
    _sumaTotalCategoria = _obtenerSumaTotalCategoria(widget.listaElementos);
    _porcentajeCategoria = _obtenerPorcentajeCategoria(_sumaTotalCategoria, widget.totalSumatoriaElementos.toDouble());
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

  void _ordenarListaElementos() {
    // Determinar si se ordena ascendete o descendente
    int Function(Map<String, dynamic>, Map<String, dynamic>) comparar;
    if(_ordenarAscDesc_Valor==_ordenarAscDesc[0]) {
      comparar = (a, b) => b[_ordenarPorCampo_Valor].compareTo(a[_ordenarPorCampo_Valor]); // descendete
    } else {
      comparar = (a, b) => a[_ordenarPorCampo_Valor].compareTo(b[_ordenarPorCampo_Valor]); // ascendente
    }
    try {
      // Realizar la comparacion para determinar el order
      setState(() {
        _listaElementosMutable.sort(comparar);
      });

    } catch (e) {
      print("Error en la funcion _ordenarListaElementos de la clase _BotonIngresoEgresoState del archivo botones.dart: $e");
    }
  }

  // Obtener suma total de los elementos por categoria
  double _obtenerSumaTotalCategoria(List<Map<String, dynamic>> elementosCategoria) {
    return widget.listaElementos.fold<Decimal>(
        Decimal.zero, (total, element) => total + Decimal.parse(element['monto'].toString())
    ).toDouble();
  }

  // Obtener porcentaje de la suma de la categoria respecto al total
  double _obtenerPorcentajeCategoria(double totalCategoria, double totalElementos) {
    double porcentaje = (totalCategoria*100) / totalElementos;
    if(porcentaje.isInfinite || porcentaje.isNaN) {
      return 0.0; // Si no hay porcentaje debido a que no hay elementos
    } else {
      return porcentaje;
    }
  }

  // Crear widgets con los botones que muestran los ingresos o egresos
  void _crearWidgetsTodos() {
    double tamanioTextPrincipal = 20.0;
    botones.clear(); // Evitar duplicados

    // ordenar lista de elementos antes de construir los widgets
    //_ordenarListaElementos();

    int conteoElementos = 0;
    // Recorrer todos los elementos de la BD y crear un boton para cada elemento
    for (var elemento in widget.listaElementos) {
      conteoElementos += 1;
      double porcentaje = (elemento['monto']*100.0) / widget.totalSumatoriaElementos.toDouble(); // Se utiliza double en lugar de decimal para el porcentaje por temas de precision en el punto decimal que no puede manejar Decimal
      String categoria = widget.tipo=='ingreso' ? obtenerCategoria(elemento['fk_id_categoria_ingreso']) : obtenerCategoria(elemento['fk_id_categoria_egreso']);
      String montoFormateado = formatearCantidad(elemento['monto']);

      // Widget que se mostrara
      botones.add(
        Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: MaterialButton(
              onPressed: () => {
                // Construir nueva ventana para detalles
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CuadroDialogoDetalles(
                          tipo: widget.tipo,
                          listaCategorias: widget.listaCategorias,
                          elemento: elemento,
                          categoriaElemento: categoria,
                          montoFormateado: montoFormateado,
                          porcentaje: porcentaje,
                          idPresupuesto: widget.idPresupuesto,
                          usuario: widget.usuario
                      );
                    }
                )
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Numero que representa el ranking del elemento
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: widget.tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                            color: widget.tipo=='ingreso' ? Colors.green : Colors.red,
                            width: 1
                          ),
                        ),
                        child: Text(
                          conteoElementos.toString(),
                          style: TextStyle(
                            color: widget.tipo=='ingreso' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      // Informacion del elemento
                      Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column( // parte central
                                  crossAxisAlignment: CrossAxisAlignment.start, // ------
                                  children: [
                                    Text( // Nombre de elemento
                                      elemento["nombre"][0].toUpperCase()+elemento['nombre'].substring(1),
                                      softWrap: true,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: tamanioTextPrincipal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text( // Categoria
                                      categoria[0].toUpperCase()+categoria.substring(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Column( // parte derecha
                                crossAxisAlignment: CrossAxisAlignment.end, // ----------
                                children: [
                                  Text(
                                    montoFormateado,
                                    style: TextStyle(
                                      fontSize: tamanioTextPrincipal,
                                    ),
                                  ),
                                  EtiquetaPorcentaje( // Porcentajes
                                    texto: '${porcentaje.toStringAsFixed(2)}%',
                                    colorFondo: widget.tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.tipo == 'ingreso' ? Colors.green : Colors.red,
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          )
                      ),

                    ],
                  ),

                  // ------------



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
    return Column(
      children: botones,
    );
  }

}