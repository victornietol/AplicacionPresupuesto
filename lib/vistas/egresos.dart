import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:calculadora_presupuesto/customWidgets/botones.dart';
import 'package:calculadora_presupuesto/customWidgets/cuadrosDialogo.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';

class Egresos extends StatefulWidget{
  const Egresos({super.key, required this.title, required this.usuario});
  final String title;
  final String usuario;

  @override
  State<Egresos> createState() => _EgresosState();
}

class _EgresosState extends State<Egresos> with SingleTickerProviderStateMixin {
  late TabController _tabController; //  Sincronizar las pestañas

  late List<Map<String, dynamic>> _categorias;
  late Map<String, dynamic> _sumaTotalPorCategoria;
  late List<Map<String, dynamic>> _egresosTodos; // Datos de mi egreso
  String _totalEgresosText = '+0';
  Decimal _totalEgresos = Decimal.fromInt(0);

  final GlobalKey _tamanioTextoBalance = GlobalKey(); // global key para las dimensiones del widget
  double _lineaAncho = 0.0;

  bool _cargandoCategorias = true; // Controlar la carga de los datos
  bool _cargandoTotal = true;
  bool _cargandoEgresosTodos = true;

  @override
  void initState() {
    super.initState();

    // Obtener mi lista de categorias de egresos para el tabController
    DataBaseOperaciones().obtenerCategorias("egreso").then((listaCat) {
      setState(() {
        _categorias = listaCat;
        _tabController = TabController(length: listaCat.length+1, vsync: this);

        // Obtener suma del monto total por categoria
        _obtenerSumaTotalPorCategorias(listaCat).then((value) {
          _sumaTotalPorCategoria = value;
        });

        _cargandoCategorias = false; // datos cargados
      });
    });

    // Obtener la suma de los egresos del usuario
    DataBaseOperaciones().sumarEgresosTodos(widget.usuario).then((value) {
      setState(() {
        _totalEgresosText = '+${value.toString()}';
        _totalEgresos = value;
        _cargandoTotal = false;
      });
    });

    // Obtener todos los datos de egresos
    DataBaseOperaciones().obtenerEgresosTodos(widget.usuario).then((value) {
      setState(() {
        _egresosTodos = value;
        _cargandoEgresosTodos = false;
      });
    });

    // esperar a que se renderice el widget para obtener su tamanio (texto de total egresos)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obtenerTamanioTexto();
    });

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
    if(_egresosTodos.isNotEmpty) {
      // Widgets de la pestaña todos
      listaWidgets.add(
        BotonIngresoEgreso2(
            tipo: 'egreso',
            listaElementos: _egresosTodos,
            totalIngresos: _totalEgresos,
            listaCategorias: _categorias,
            usuario: widget.usuario,
            mostrarTotalIngresosCategoria: false
        ),
      );

      // Widgets de las pestañas de cada categoria
      for(var categoria in _categorias) {

        // filtrar los elementos de cada categoria
        List<Map<String, dynamic>> egresosCategoria = _egresosTodos.where(
                (element) => element['fk_id_categoria_egreso']==categoria['id_categoria']
        ).toList();

        // Verificar si hay elementos en la categoria
        if(egresosCategoria.isNotEmpty) { // Si la categoria tiene elementos para generar widgets
          listaWidgets.add(
            BotonIngresoEgreso2(
              tipo: 'egreso',
              listaElementos: egresosCategoria,
              totalIngresos: _totalEgresos,
              listaCategorias: _categorias,
              usuario: widget.usuario,
              mostrarTotalIngresosCategoria: true,
            ),
          );
        } else {  // Si no hay elementos en la categoria
          listaWidgets.add(
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Aun no hay egresos registrados en esta categoria.")
                ],
              )
          );
        }

      }

    } else {
      // Si no hay elementos para crear widgets
      listaWidgets.add(
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Aun no hay egresos registrados.")
          ],
        )
      );
      for(var _ in _categorias) {
        listaWidgets.add(
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Aun no hay egresos registrados en esta categoria.")
              ],
            )
        );
      }
    }

    return listaWidgets;
  }

  // obtener suma del monto total de cada categoria pasando como argumento la lista de categorias
  Future<Map<String, dynamic>> _obtenerSumaTotalPorCategorias(List<Map<String, dynamic>> listaCategorias) async {
    Map<String, dynamic> sumaTotalPorCategorias = {};
    for(var categoria in listaCategorias) {
      // Obtener monto
      Decimal monto = await DataBaseOperaciones().sumarEgresosCategoria(categoria['nombre'], widget.usuario);
      // Guardar elemento
      sumaTotalPorCategorias[categoria['nombre']] = monto.toDouble();
    }
    return sumaTotalPorCategorias;
  }

  @override
  Widget build(BuildContext context) {
    // Se muestra pantalla de carga mientras cargan datos
    if(_cargandoCategorias || _cargandoTotal || _cargandoEgresosTodos) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF02013C),
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.toDouble(),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Si cambio el tamaño del texto del balance
    if(_lineaAncho==0.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _obtenerTamanioTexto();
      });
    }

    //print('Egresoooos: $_egresosTodos'); // ---------------------------------------

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF02013C),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white,
              letterSpacing: 1.0,
          ),
        ),
      ),

      body: Column(
        children: <Widget>[

          // Parte superior (texto suma de egresos)
          Container(
              width: double.infinity, // Se ajusta a toda la pantalla
              padding: EdgeInsets.all(20),
              child: MaterialButton(
                onPressed: () {
                  // Motrar grafica
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        if(_egresosTodos.isNotEmpty) { // Si hay elementos para graficar
                          return GraficaBarras(
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

          MaterialButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CuadroDialogoAgregar(
                        tipo: 'egreso',
                        listaCategorias: _categorias,
                        usuario: widget.usuario,
                      );
                    }
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded),
                  Text(
                      "Agregar egreso"
                  ),
                ],
              )
          ),


        ],
      ),


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