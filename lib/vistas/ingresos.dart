import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:decimal/decimal.dart';

class Ingresos extends StatefulWidget{
  const Ingresos({super.key, required this.title, required this.usuario});
  final String title;
  final String usuario;

  @override
  State<Ingresos> createState() => _IngresosState();
}

class _IngresosState extends State<Ingresos> with SingleTickerProviderStateMixin { // Para el rendimiento del tabCntroller
  late TabController _tabController; //  Sincronizar las pestañas

  late List<Map<String, dynamic>> _ingresosTodos;
  String _totalIngresos = '+0';

  final GlobalKey _tamanioTextoBalance = GlobalKey(); // global key para las dimensiones del widget
  double _lineaAncho = 0.0;

  bool _cargandoCategorias = true; // Controlar la carga de los datos
  bool _cargandoTotal = true;



  @override
  void initState() {
    super.initState();

    // Obtener mi lista de categorias de ingresos para el tabController
    DataBaseOperaciones().obtenerCategorias("ingreso").then((listaCat) {
      setState(() {
        _ingresosTodos = listaCat;
        _tabController = TabController(length: listaCat.length+1, vsync: this);
        _cargandoCategorias = false; // datos cargados
      });
    });

    // Obtener la suma de los ingresos del usuario
    DataBaseOperaciones().sumarIngresosTodos(widget.usuario).then((value) {
      setState(() {
        _totalIngresos = '+${value.toString()}';
        _cargandoTotal = false;
      });
    });

    // esperar a que se renderice el widget para obtener su tamanio (texto de total ingresos)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obtenerTamanioTexto();
    });

  }










  @override
  Widget build(BuildContext context) {
    // Se muestra pantalla de carga mientras cargan datos
    if(_cargandoCategorias && _cargandoTotal) {
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

    _obtenerTamanioTexto();

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container( // Texto balance general
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    '\$ $_totalIngresos',
                    key: _tamanioTextoBalance,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container( // linea debajo del balance general
                  height: 1.0,
                  width: _lineaAncho+30.0, // Asignar el tamanio de la linea dinamicamente
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
          ),


          // Pestañas con las categorias de los ingresos
          TabBar(
            controller: _tabController,
              //labelColor: const Color(0xFF02013C),
              unselectedLabelColor: Colors.grey,
              tabs: [ // Con cada elemento de mi lista generar una pestania
                const Tab(text: 'Todos'),
                ..._ingresosTodos.map(
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
                children: [
                  _buildScrollableList("Publicaciones"),
                  _buildScrollableList("Respuestas"),
                  _buildScrollableList("Destacados"),
                ],
              )
          )


        ],
      )
      // This trailing comma makes auto-formatting nicer for build methods.
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