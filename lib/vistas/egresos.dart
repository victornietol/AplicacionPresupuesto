import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_presupuesto/customWidgets/botones.dart';
import 'package:calculadora_presupuesto/customWidgets/cuadrosDialogo.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:calculadora_presupuesto/navegador.dart';

class Egresos extends StatefulWidget{
  const Egresos({super.key, required this.title, required this.usuario, required this.idPresupuesto});
  final String title;
  final String usuario;
  final int idPresupuesto;

  @override
  State<Egresos> createState() => _EgresosState();
}

class _EgresosState extends State<Egresos> with SingleTickerProviderStateMixin {
  late TabController _tabController; //  Sincronizar las pestañas
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos

  late List<Map<String, dynamic>> _categorias;
  late Map<String, dynamic> _sumaTotalPorCategoria;
  late List<Map<String, dynamic>> _egresosTodos; // Datos de mi egreso
  String _totalEgresosText = '+0';
  Decimal _totalEgresos = Decimal.fromInt(0);

  final GlobalKey _tamanioTextoBalance = GlobalKey(); // global key para las dimensiones del widget
  double _lineaAncho = 0.0;



  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarDatosVista(); // Carga de datos de las funciones asincronas
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    await Future.wait([
      // Funciones de las que se espera un resultado
      _obtenerCategorias(),
      _obtenerSumaEgresos(),
      _obtenerDatosEgresos()
    ]);
  }

  // Obtener mi lista de categorias de egresos para el tabController
  Future<void> _obtenerCategorias() async {
    _categorias = await DataBaseOperaciones().obtenerCategorias("egreso", widget.idPresupuesto);
    _tabController = TabController(length: _categorias.length+1, vsync: this);

    // Obtener suma del monto total por categoria
    _obtenerSumaTotalPorCategorias(_categorias).then((value) {
      _sumaTotalPorCategoria = value;
    });
  }

  // Obtener la suma de los egresos del usuario
  Future<void> _obtenerSumaEgresos() async {
    final value = await DataBaseOperaciones().sumarEgresosTodos(widget.usuario, widget.idPresupuesto);
    _totalEgresosText = '+${value.toString()}';
    _totalEgresos = value;
  }

  // Obtener todos los datos de egresos
  Future<void> _obtenerDatosEgresos() async {
    _egresosTodos = await DataBaseOperaciones().obtenerEgresosTodos(widget.usuario, widget.idPresupuesto);
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }

  // Crear contenido de cada pestaña del TabBar
  List<Widget> _crearWidgetsElementos() {
    List<Widget> listaWidgets = [];

    // Si hay elementos para crear los widgets
    listaWidgets.add(
      BotonIngresoEgreso2(
          tipo: 'egreso',
          listaElementos: _egresosTodos,
          totalIngresos: _totalEgresos,
          listaCategorias: _categorias,
          usuario: widget.usuario,
          mostrarTotalIngresosCategoria: false,
          idPresupuesto: widget.idPresupuesto,
      ),
    );

    // Widgets de las pestañas de cada categoria
    for(var categoria in _categorias) {
      // filtrar los elementos de cada categoria
      List<Map<String, dynamic>> egresosCategoria = _egresosTodos.where(
              (element) => element['fk_id_categoria_egreso']==categoria['id_categoria']
      ).toList();

      listaWidgets.add(
        BotonIngresoEgreso2(
          tipo: 'egreso',
          listaElementos: egresosCategoria,
          totalIngresos: _totalEgresos,
          listaCategorias: _categorias,
          usuario: widget.usuario,
          mostrarTotalIngresosCategoria: true,
          nombreCategoria: categoria['nombre'],
          idPresupuesto: widget.idPresupuesto,
        ),
      );
    }

    return listaWidgets;
  }

  // obtener suma del monto total de cada categoria pasando como argumento la lista de categorias
  Future<Map<String, dynamic>> _obtenerSumaTotalPorCategorias(List<Map<String, dynamic>> listaCategorias) async {
    Map<String, dynamic> sumaTotalPorCategorias = {};
    for(var categoria in listaCategorias) {
      // Obtener monto
      Decimal monto = await DataBaseOperaciones().sumarEgresosCategoria(categoria['nombre'], widget.usuario, widget.idPresupuesto);
      // Guardar elemento
      sumaTotalPorCategorias[categoria['nombre']] = monto.toDouble();
    }
    return sumaTotalPorCategorias;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>( // Se utiliza FutureBuilder porque para construir el Scaffold primero se deben de cargar datos de funciones asincronas
        future: _cargaInicial,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            // Los datos estan cargando
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          } else if(snapshot.hasError) {
            return const Text("Ocurrio un error");

          } else {
            // Si cambio el tamaño del texto del balance (se construye hasta que FutureBuilder tiene datos)
            if(_lineaAncho==0.0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _obtenerTamanioTexto();
              });
            }

            // Los datos se cargaron
            return Scaffold(
              body: Column(
                children: <Widget>[

                  // Parte superior (texto suma de egresos)
                  Container(
                      width: MediaQuery.of(context).size.width*0.94,
                      margin: EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(color: Colors.red),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          // Motrar grafica
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                if(_egresosTodos.isNotEmpty) { // Si hay elementos para graficar
                                  return GraficaBarras2(
                                    tipo: 'egreso',
                                    sumaTotalElementos: _totalEgresos.toDouble(),
                                    listaCantidades: _sumaTotalPorCategoria,
                                  );
                                } else {
                                  return AlertDialog(
                                    content: const Text("Aun no hay elementos para mostrar."),
                                    actions: [
                                      MaterialButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Aceptar"),
                                      )
                                    ],
                                  );
                                }
                              }
                          );


                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container( // Texto balance general
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text(
                                formatearCantidad(_totalEgresos.toDouble()),
                                key: _tamanioTextoBalance,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container( // linea debajo del balance general
                              height: 1.0,
                              width: _lineaAncho<20 ? 40 : (_lineaAncho/2.0), // Asignar el tamanio de la linea dinamicamente
                              color: Colors.black,
                            ),
                            const SizedBox(height: 10.0), // espacio
                            const Text(
                              "Total egresos",
                              style: TextStyle(
                                color: Colors.black,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      )
                  ),

                  // Pestañas con las categorias de los ingresos
                  TabBar(
                    controller: _tabController,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    tabs: [ // Con cada elemento de mi lista generar una pestania
                      const Tab(text: 'Todos'),
                      ..._categorias.map(
                            (categoria) => Tab(
                          text: categoria['nombre'][0].toUpperCase()+categoria['nombre'].substring(1),
                        ),
                      ).toList(),
                    ],

                  ),

                  // Lista de contenido de cada pestaña
                  Expanded(
                      child: TabBarView(
                          controller: _tabController,
                          children: _crearWidgetsElementos() // Se crean los elementos para las pestañas
                      )
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Boton Agregar egreso
                      MaterialButton(
                          onPressed: () {
                            if(_categorias.isNotEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CuadroDialogoAgregar(
                                      tipo: 'egreso',
                                      listaCategorias: _categorias,
                                      usuario: widget.usuario,
                                      vistaDestino: Navegador(inicio: 2, usuario: widget.usuario),
                                      idPresupuesto: widget.idPresupuesto,
                                    );
                                  }
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text(
                                          'Antes debe agregar una categoria para el egreso.'
                                      ),
                                      actions: [
                                        MaterialButton(
                                          onPressed: () {Navigator.of(context).pop();},
                                          child: const Text('Aceptar'),
                                        )
                                      ],
                                    );
                                  }
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded),
                              Text(
                                  "Agregar egreso",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                      ),
                      // Boton Agregar categoria
                      MaterialButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CuadroDialogoAgregarCategoria(
                                      tipo: 'egreso',
                                      usuario: widget.usuario,
                                      idPresupuesto: widget.idPresupuesto,
                                  );
                                }
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded),
                              Text(
                                  "Agregar categoria",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                      ),
                    ],
                  )



                ],
              ),


            );
          }
        }
    );


  }

  // Funcion para obtener el valor del ancho del widget Text despues de renderizarse
  void _obtenerTamanioTexto() {
    final RenderBox? renderBox = _tamanioTextoBalance.currentContext?.findRenderObject() as RenderBox?;
    if(renderBox != null) {
      final tamanio = renderBox.size;
      setState(() {
        _lineaAncho = tamanio.width;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

}