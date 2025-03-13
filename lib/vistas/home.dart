import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.usuario});

  final String title;
  final String usuario;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _balanceGeneral = "+0";
  final GlobalKey _tamanioTextoBalance = GlobalKey(); // global key para las dimensiones del widget
  double _lineaAncho = 0.0;

  bool _cargandoBalance = true;


  @override
  void initState() {
    super.initState();
    obtenerBalance(); // Actualizar balace

    // esperar a que se renderice el widget para obtener su tamanio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obtenerTamanioTexto();
    });

    // Pruebas
    //_datos = DataBaseOperaciones().obtenerUsuarios();
    //_datos.then((valor) {
    //  print(valor);
    //}).catchError((error) {
    //  print("error al manejar: $error");
    //});



  }

  // Funcion de pruebas
  Future<List<Map<String, dynamic>>> pruebaDatos() async {
    final db = await  DataBaseOperaciones().database;
    return await db.query('usuario');
  }

  // Obtiene o actualiza el valor del balance general
  Future<void> obtenerBalance() async {
    Decimal sumaIngresos = await DataBaseOperaciones().sumarIngresosTodos(widget.usuario);
    Decimal sumaEgresos = await DataBaseOperaciones().sumarEgresosTodos(widget.usuario);
    Decimal balance = sumaIngresos - sumaEgresos;

    if(mounted) { // verificar que se siga mostrando la vista actual
      setState(() {
        _balanceGeneral = balance>=Decimal.parse('0.0') ?
          '+ ${formatearCantidad(balance.toDouble())}' :
          formatearCantidad(balance.toDouble());
        _cargandoBalance = false;
      });
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
    if(_cargandoBalance) {
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
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Seccion inferior para detalles"
                    ),

                  ],
                ),
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

}