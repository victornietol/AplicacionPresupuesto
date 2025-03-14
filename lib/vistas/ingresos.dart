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
  late List<Map<String, dynamic>> _ingresosTodos; // Datos de mi ingresos
  String _totalIngresosText = '+0';
  Decimal _totalIngresos = Decimal.fromInt(0);

  final GlobalKey _tamanioTextoBalance = GlobalKey(); // global key para las dimensiones del widget
  double _lineaAncho = 0.0;

  bool _cargandoCategorias = true; // Controlar la carga de los datos
  bool _cargandoTotal = true;
  bool _cargandoIngresosTodos = true;



  @override
  void initState() {
    super.initState();

    // Obtener mi lista de categorias de ingresos para el tabController
    DataBaseOperaciones().obtenerCategorias("ingreso").then((listaCat) {
      setState(() {
        _categorias = listaCat;
        _tabController = TabController(length: listaCat.length+1, vsync: this);
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

    // datos de ejemplo ingresos y egresos
    //DataBaseOperaciones().insertarIngreso({
    //  'nombre': 'ingrso1',
    //  'monto': 1000,
    //  'descripcion': 'DEscp1',
    //  'fecha_registro': DateTime.now().toIso8601String(),
    //  'fk_id_usuario':1,
    //  'fk_id_categoria_ingreso':1
    //});


  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
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
          ),


          // Pestañas con las categorias de los ingresos
          TabBar(
            controller: _tabController,
              //labelColor: const Color(0xFF02013C),
              unselectedLabelColor: Colors.grey,
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
                children: [
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