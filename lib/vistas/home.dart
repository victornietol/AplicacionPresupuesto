import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:decimal/decimal.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.usuario});

  final String title;
  final String usuario;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _balanceGeneral = "0.0";

  @override
  void initState() {
    super.initState();
    obtenerBalance(); // Actualizar balace

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
        _balanceGeneral = balance>=Decimal.parse('0.0') ? '+${balance.toString()}' : balance.toString();
      });
    }
  }



  // Lo que muestra la vista
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.toDouble()
          ),
        ),
          centerTitle: true,
          backgroundColor: const Color(0xFF02013C)
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text(
                _balanceGeneral,
                style: TextStyle(
                  color: _balanceGeneral.startsWith('+') ? Colors.green : Colors.red,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container( // linea debajo del balance general
              height: 1.0,

              color: Colors.black,
            ),

            const SizedBox(height: 10.0), // espacio

            const Text(
              "Balance general",
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            )


          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}