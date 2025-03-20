import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:calculadora_presupuesto/navegador.dart';
import 'package:calculadora_presupuesto/customWidgets/botones.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.usuario});

  final String title;
  final String usuario;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos

  String _balanceGeneral = "+0";
  Decimal _sumaTotalIngresos = Decimal.zero;
  Decimal _sumaTotalEgresos = Decimal.zero;
  String _mayorCategoriaIngresosNombre = '';
  String _mayorCategoriaEgresosNombre = '';
  double _mayorCategoriaIngresosMonto = 0.0;
  double _mayorCategoriaEgresosMonto = 0.0;
  List<Map<String, dynamic>> _listaCategoriasIngreso = [];
  List<Map<String, dynamic>> _listaCategoriasEgreso = [];
  Map<String, dynamic> _listaCategoriasMontosIngresos = {};
  Map<String, dynamic> _listaCategoriasMontosEgresos = {};
  List<Map<String, dynamic>> _listaTopIngresos = [];
  List<Map<String, dynamic>> _listaTopEgresos = [];

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
      _obtenerBalance(), // Actualizar balace y valores de cantidades de ingresos y egresos
      _obtenerSumatoriaPorCategoriaIngresos(), // Obtener categoria con mayor numero de ingresos
      _obtenerSumatoriaPorCategoriaEgresos(),
      _obtenerListaTopIngresosEgresos(3)
    ]);
  }

  // Obtiene o actualiza el valor del balance general
  Future<void> _obtenerBalance() async {
    _sumaTotalIngresos = await DataBaseOperaciones().sumarIngresosTodos(widget.usuario);
    _sumaTotalEgresos = await DataBaseOperaciones().sumarEgresosTodos(widget.usuario);
    Decimal balance = _sumaTotalIngresos - _sumaTotalEgresos;

    if(mounted) { // verificar que se siga mostrando la vista actual
      _balanceGeneral = balance>=Decimal.zero ? '+ ${formatearCantidad(balance.toDouble())}' : formatearCantidad(balance.toDouble());
    }
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }
  
  // Obtener la categoria con mayor sumatoria de ingresos
  Future<void> _obtenerSumatoriaPorCategoriaIngresos() async {
    
    // Obtener lista de categorias de ingresos
    _listaCategoriasIngreso = await DataBaseOperaciones().obtenerCategorias('ingreso');

    // Recorrer categorias para obtener sumatoria
    for(var categoria in _listaCategoriasIngreso) {
      Decimal valor = await DataBaseOperaciones().sumarIngresosCategoria(categoria['nombre'], widget.usuario); // Obtener sumatoria de cada categoria
      _listaCategoriasMontosIngresos[categoria['nombre']] = valor.toDouble();
    }
  }

  // Obtener la categoria con mayor sumatoria de egresos
  Future<void> _obtenerSumatoriaPorCategoriaEgresos() async {

    // Obtener lista de categorias de ingresos
    _listaCategoriasEgreso = await DataBaseOperaciones().obtenerCategorias('egreso');

    // Recorrer categorias para obtener sumatoria
    for(var categoria in _listaCategoriasEgreso) {
      Decimal valor = await DataBaseOperaciones().sumarEgresosCategoria(categoria['nombre'], widget.usuario); // Obtener sumatoria de cada categoria
      _listaCategoriasMontosEgresos[categoria['nombre']] = valor.toDouble();
    }
  }

  // Obtener la categoria con mayor monto de Ingresos y Egresos
  void _obtenerMaxCategorias(Map<String, dynamic> listaIngresos, Map<String, dynamic> listaEgresos) {
    // Ingresos
    var maxIngresos = listaIngresos.entries.reduce((a, b) => a.value>b.value ? a : b);
    _mayorCategoriaIngresosNombre = maxIngresos.value==0 ? 'Sin categoria' : maxIngresos.key;
    _mayorCategoriaIngresosMonto = maxIngresos.value;

    // Egresos
    var maxEgresos = listaEgresos.entries.reduce((a, b) => a.value>b.value ? a : b);
    _mayorCategoriaEgresosNombre = maxEgresos.value==0 ? 'Sin categoria' : maxEgresos.key;
    _mayorCategoriaEgresosMonto = maxEgresos.value;
  }

  Future<void> _obtenerListaTopIngresosEgresos(int numeroElementos) async {
    _listaTopIngresos = await DataBaseOperaciones().obtenerTopIngresos(widget.usuario, numeroElementos);
    _listaTopEgresos = await DataBaseOperaciones().obtenerTopEgresos(widget.usuario, numeroElementos);
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

          } else if(snapshot.hasError) {
            return Text("Ocurrio un error");

          } else {
            // Si cambio el tamaño del texto del balance (se construye hasta que FutureBuilder tiene datos)
            if(_lineaAncho==0.0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _obtenerTamanioTexto();
              });
            }

            // Obtener categorias con mayor monto de ingresos y egresos
            _obtenerMaxCategorias(_listaCategoriasMontosIngresos, _listaCategoriasMontosEgresos);

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
                  backgroundColor: const Color(0xFF02013C)
              ),
              body: Column(
                children: <Widget>[

                  // Parte superior (Se muestra el balance general)
                  Container(
                    width: double.infinity, // Se ajusta a toda la pantalla
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container( // Texto balance general
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            _balanceGeneral,
                            key: _tamanioTextoBalance,
                            style: TextStyle(
                              color: _balanceGeneral.startsWith('+') ? Colors.green : Colors.red,
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
                          "Balance general",
                          style: TextStyle(
                            color: Colors.black,
                            letterSpacing: 2.0,
                          ),
                        ),

                      ],
                    ),
                  ),


                  // Parte inferior de la pantalla (mostrar algunos detalles de ingresos y egresos)
                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[

                            // Total de los egresos y egresos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Ingresos
                                /*
                                MaterialButton(
                                  onPressed: () => print('pks'),
                                  padding: const EdgeInsets.all(0.0),
                                  splashColor: Colors.green,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      alignment: AlignmentDirectional.center,
                                      color: const Color(0xFFd4fed7),
                                      child: Column(
                                        children: [
                                          // Texto de ingresos
                                          const Text(
                                            'Total ingresos:',
                                            style: TextStyle(
                                              color: Colors.green,
                                              //fontWeight: FontWeight.bold
                                            ),
                                            softWrap: true,
                                          ),
                                          Text(
                                            formatearCantidad(_sumaTotalIngresos.toDouble()),
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )

                                  ),
                                ),

                                 */
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Navegador(inicio: 0, usuario: widget.usuario)
                                      )
                                    );
                                  },
                                  minWidth: MediaQuery.of(context).size.width/2,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  color: const Color(0xFFd4fed7),
                                  splashColor: Colors.green[200],
                                  highlightColor: Colors.green[200],
                                  child: Column(
                                    children: [
                                      // Texto de ingresos
                                      const Text(
                                        'Total ingresos:',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.normal
                                        ),
                                        softWrap: true,
                                      ),
                                      Text(
                                        formatearCantidad(_sumaTotalIngresos.toDouble()),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Egresos
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Navegador(inicio: 2, usuario: widget.usuario),
                                        ),
                                    );
                                  },
                                  minWidth: MediaQuery.of(context).size.width/2,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  color: const Color(0xffffdada),
                                  splashColor: Colors.red[200],
                                  highlightColor: Colors.red[200],
                                  child: Column(
                                    children: [
                                      // Texto de ingresos
                                      const Text(
                                        'Total egresos:',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.normal
                                        ),
                                        softWrap: true,
                                      ),
                                      Text(
                                        formatearCantidad(_sumaTotalEgresos.toDouble()),
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                            
                            // Categoria con mas ingresos recuadro
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              //padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: MediaQuery.of(context).size.width/8),
                              child: Column( // Contenido del recuadro
                                children: [
                                  // Titulo
                                  Container(
                                    //width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                    //margin: const EdgeInsets.only(top: 2.0),
                                    alignment: Alignment.center,
                                    //color: Colors.grey[100],
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4)
                                      ),
                                      color: Color(0xFFEEEEEE),
                                    ),
                                    child: const Text(
                                        'Categoria con más ingresos:'
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _mayorCategoriaIngresosNombre[0].toUpperCase()+_mayorCategoriaIngresosNombre.substring(1),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(
                                          formatearCantidad(_mayorCategoriaIngresosMonto),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            // Widgets de top ingresos
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              margin: const EdgeInsets.only(top: 2.0),
                              alignment: Alignment.center,
                              color: Colors.grey[200],
                              child: const Text(
                                  'Top 3 ingresos:'
                              ),
                            ),
                            BotonIngresoEgresoRanking(
                                tipo: 'ingreso',
                                listaElementos: _listaTopIngresos,
                                totalSumatoriaElementos: _sumaTotalIngresos,
                                listaCategorias: _listaCategoriasIngreso,
                                usuario: widget.usuario,
                                mostrarTotalIngresosCategoria: false
                            ),

                            // Categoria con mas egresos recuadro
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: MediaQuery.of(context).size.width/8),
                              child: Column( // Contenido del recuadro
                                children: [
                                  // Titulo
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4)
                                      ),
                                      color: Color(0xFFEEEEEE),
                                    ),
                                    child: const Text(
                                        'Categoria con más egresos:'
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _mayorCategoriaEgresosNombre[0].toUpperCase()+_mayorCategoriaEgresosNombre.substring(1),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(
                                          formatearCantidad(_mayorCategoriaEgresosMonto),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            // Widgets de top ingresos
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              margin: const EdgeInsets.only(top: 2.0),
                              alignment: Alignment.center,
                              color: Colors.grey[200],
                              child: const Text(
                                  'Top 3 egresos:'
                              ),
                            ),
                            BotonIngresoEgresoRanking(
                                tipo: 'egreso',
                                listaElementos: _listaTopEgresos,
                                totalSumatoriaElementos: _sumaTotalEgresos,
                                listaCategorias: _listaCategoriasEgreso,
                                usuario: widget.usuario,
                                mostrarTotalIngresosCategoria: false
                            ),



                          ],
                        ),
                      )
                  ),

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

}


/*

Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        BotonIngresoEgreso2(
                                            tipo: 'ingreso',
                                            listaElementos: _listaTopIngresos,
                                            totalIngresos: _sumaTotalIngresos,
                                            listaCategorias: _listaCategoriasIngreso,
                                            usuario: widget.usuario,
                                            mostrarTotalIngresosCategoria: false
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
 */