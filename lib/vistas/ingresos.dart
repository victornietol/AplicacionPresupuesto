import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:decimal/decimal.dart';
import 'package:calculadora_presupuesto/customWidgets/botones.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_presupuesto/customWidgets/cuadrosDialogo.dart';


class Ingresos extends StatefulWidget{
  const Ingresos({super.key, required this.title, required this.usuario});
  final String title;
  final String usuario;

  @override
  State<Ingresos> createState() => _IngresosState();
}

class _IngresosState extends State<Ingresos> with SingleTickerProviderStateMixin { // Para el rendimiento del tabCntroller
  late TabController _tabController; //  Sincronizar las pestañas

  late List<Map<String, dynamic>> _categorias;
  late Map<String, dynamic> _sumaTotalPorCategoria;
  late List<Map<String, dynamic>> _ingresosTodos; // Datos de mi ingresos
  String _totalIngresosText = '+0';
  Decimal _totalIngresos = Decimal.fromInt(0);

  final GlobalKey _tamanioTextoBalance = GlobalKey(); // global key para las dimensiones del widget
  double _lineaAncho = 0.0;

  bool _cargandoCategorias = true; // Controlar la carga de los datos
  bool _cargandoTotal = true;
  bool _cargandoIngresosTodos = true;

  //List<Widget> _listaWidgets = []; // Lista con el cuerpo de cada pestaña del TabBar



  @override
  void initState() {
    super.initState();

    // Obtener mi lista de categorias de ingresos para el tabController
    DataBaseOperaciones().obtenerCategorias("ingreso").then((listaCat) {
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

    // Obtener la suma de los ingresos del usuario
    DataBaseOperaciones().sumarIngresosTodos(widget.usuario).then((value) {
      setState(() {
        _totalIngresosText = '+${value.toString()}';
        _totalIngresos = value;
        _cargandoTotal = false;
      });
    });

    // Obtener todos los datos de ingresos
    DataBaseOperaciones().obtenerIngresosTodos(widget.usuario).then((value) {
      setState(() {
        _ingresosTodos = value;
        _cargandoIngresosTodos = false;
      });
    });

    // esperar a que se renderice el widget para obtener su tamanio (texto de total ingresos)
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

  // Crear contenido de cada pestaña deñ TabBar
  List<Widget> _crearWidgetsElementos() {
    List<Widget> listaWidgets = [];

    // Widgets de la pestaña todos
    listaWidgets.add(
      BotonIngresoEgreso2(
        tipo: 'ingreso',
        listaElementos: _ingresosTodos,
        totalIngresos: _totalIngresos,
        listaCategorias: _categorias,
        usuario: widget.usuario,
        mostrarTotalIngresosCategoria: false
      ),
    );

    // Widgets de las pestañas de cada categoria
    for(var categoria in _categorias) {
      // filtrar los elementos de cada categoria
      List<Map<String, dynamic>> ingresosCategoria = _ingresosTodos.where(
              (element) => element['fk_id_categoria_ingreso']==categoria['id_categoria']
      ).toList();

      listaWidgets.add(
        BotonIngresoEgreso2(
            tipo: 'ingreso',
            listaElementos: ingresosCategoria,
            totalIngresos: _totalIngresos,
            listaCategorias: _categorias,
            usuario: widget.usuario,
            mostrarTotalIngresosCategoria: true,
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
      Decimal monto = await DataBaseOperaciones().sumarIngresosCategoria(categoria['nombre'], widget.usuario);
      // Guardar elemento
      sumaTotalPorCategorias[categoria['nombre']] = monto.toDouble();
    }
    return sumaTotalPorCategorias;
  }


  @override
  Widget build(BuildContext context) {
    // Se muestra pantalla de carga mientras cargan datos
    if(_cargandoCategorias || _cargandoTotal || _cargandoIngresosTodos) {
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

      body: Column(
        children: <Widget>[

          // Parte superior (texto suma de ingresos)
          Container(
            width: double.infinity, // Se ajusta a toda la pantalla
            padding: EdgeInsets.all(20),
            child: MaterialButton(
              onPressed: () {
                // Motrar grafica

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      if (_ingresosTodos.isNotEmpty) {
                        return GraficaBarras2(
                          tipo: 'ingreso',
                          sumaTotalElementos: _totalIngresos.toDouble(),
                          listaCantidades: _sumaTotalPorCategoria,
                        );
                      } else { // Si hay elementos para graficar
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
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      //'\$ $_totalIngresosText',
                      formatearCantidad(_totalIngresos.toDouble()),
                      key: _tamanioTextoBalance,
                      style: const TextStyle(
                        color: Colors.green,
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
                    "Total ingresos",
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
              //labelColor: const Color(0xFF02013C),
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
                    /*
                [
                  //_buildScrollableList("Publicaciones"),
                  //_buildScrollableList("Respuestas"),
                  //_buildScrollableList("Destacados"),
                  BotonIngresoEgreso(
                    tipo: 'ingreso',
                    listaElementos: _ingresosTodos,
                    totalIngresos: _totalIngresos,
                    listaCategorias: _categorias,
                    usuario: widget.usuario,
                  ),
                  Text("Hola2"),
                  Text("Hola3"),
                ],

                     */
              )
          ),

          Container(
            child: MaterialButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CuadroDialogoAgregar(
                          tipo: 'ingreso',
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
                        "Agregar ingreso"
                    ),
                  ],
                )
            ),
          ),


        ],
      ),


    );
  }



  // Método para generar listas desplazables
  Widget _buildScrollableList(String titulo) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          20, // Simulando 20 elementos
              (index) => ListTile(title: Text("$titulo $index")),
        ),
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