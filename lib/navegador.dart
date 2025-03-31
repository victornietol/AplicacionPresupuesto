import 'package:calculadora_presupuesto/vistas/calendario.dart';
import 'package:calculadora_presupuesto/vistas/resumenEgresos.dart';
import 'package:calculadora_presupuesto/vistas/resumenIngresos.dart';
import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/vistas/home.dart';
import 'package:calculadora_presupuesto/vistas/egresos.dart';
import 'package:calculadora_presupuesto/vistas/ingresos.dart';
import 'package:calculadora_presupuesto/vistas/bienvenido.dart';
import 'package:calculadora_presupuesto/vistas/visualizacionGraficas.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:calculadora_presupuesto/customWidgets/cuadrosDialogo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Navegador extends StatefulWidget{
  const Navegador({super.key,
    required this.inicio,
    required this.usuario,
    this.idPresupuesto,
  });
  final int inicio;
  final String usuario;
  final int? idPresupuesto;

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador>{
  late int _indice; // controlar el indice de la vista a mostrar
  final _vistas = []; // lista para las vistas
  final List _titulos = ['Ingresos', 'Resumen Presupuesto', 'Egresos'];
  int _idPresupuesto = 1;
  final List<Widget> _listTiles = [];
  List<Map<String, dynamic>> _listaPresupuestos = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos

  // Vistas que se van a manejar
  @override
  void initState(){
    super.initState();
    _cargaInicial = _cargarDatosVista();
    _indice = widget.inicio;
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    final lista = await _obtenerPresupuestos();
    if(lista.isNotEmpty) {
      // Si la lista contiene minimo un presupuesto se muestra, de lo contrario no se busca id de presupuesto
      await _obtenerIdPresupuesto(lista);
    }
  }

  Future<List<Map<String, dynamic>>> _obtenerPresupuestos() async {
    _listaPresupuestos = await DataBaseOperaciones().obtenerPresupuestos(widget.usuario);
    return _listaPresupuestos;
  }

  // Asignar el id del presupuesto a mostrar al cargar la vista de inicio
  Future<void> _obtenerIdPresupuesto(List<Map<String, dynamic>> lista) async {
    final SharedPreferences prefs = await _prefs;

    if(widget.idPresupuesto==null) {
      // No se ingreso manualmente el id del presupuesto
      final int? idGuardado = prefs.getInt('idPresupuesto');

      if(idGuardado!=null) { // Si hay datos guardados
        setState(() {
          _idPresupuesto = idGuardado;
        });
      } else if(lista.isNotEmpty) {
        prefs.setInt('idPresupuesto', lista.first['id_presupuesto']);
        setState(() {
          _idPresupuesto = lista.first['id_presupuesto'];
        });
      }

    } else {
      // Si se pasa argumento
      setState(() {
        _idPresupuesto = widget.idPresupuesto!;
      });
      prefs.setInt('idPresupuesto', _idPresupuesto);
    }

  }

  // Funcion para construir los ListTile para los presupuestos existentes
  void _crearListTiles() {
    _listTiles.clear();
    // Recorrer los presupuestos
    for(var elemento in _listaPresupuestos) {
      _listTiles.add(
        ListTile(
          title: Text(elemento['nombre'][0].toUpperCase()+elemento['nombre'].substring(1)),
          onTap: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 150), () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => Navegador(inicio: 1, usuario: widget.usuario, idPresupuesto: elemento['id_presupuesto'])),
                    (Route<dynamic> route) => false,
              );
            });
          },
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CuadroDialogoEditarPresupuesto(usuario: widget.usuario, presupuesto: elemento);
                  }
              );
            },
          ),
        ),
      );
    }
    // Boton de agregar
    _listTiles.add(
      ListTile(
        leading: const Icon(
          Icons.add_circle_outlined,
          color: Colors.grey,
        ),
        title: const Text('Agregar presupuesto'),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CuadroDialogoAgregarPresupuesto(usuario: widget.usuario);
              }
          );
        },
      ),
    );
  }

  // Funcion para obtener el presupuesto actual
  Map<String, dynamic> _obtenerNombrePresupuestoActual() {
    for(var elemento in _listaPresupuestos) {
      if(elemento['id_presupuesto']==_idPresupuesto) {
        return elemento;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
        future: _cargaInicial,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if(snapshot.hasError) {
            return const Text('Ocurrio un error');

          } else {

            if(_listaPresupuestos.isNotEmpty) {
              // Si hay al menos un presupuesto se cargan las vistas Home, Ingresos, Egresos
              // Se construyen las vistas hasta que hayan cargado los datos
              _vistas.add(
                  Ingresos(title: _titulos[_indice], usuario: widget.usuario, idPresupuesto: _idPresupuesto)
              );
              _vistas.add(
                  MyHomePage(title: _titulos[_indice], usuario: widget.usuario, idPresupuesto: _idPresupuesto)
              );
              _vistas.add(
                  Egresos(title: _titulos[_indice], usuario: widget.usuario, idPresupuesto: _idPresupuesto)
              );

              // Crear elementos del menu lateral desplegable
              _crearListTiles();
              Map<String, dynamic> presupuesto = _obtenerNombrePresupuestoActual();
              return Stack(
                children: [
                  Scaffold(
                    drawer: Drawer( // Menu lateral desplegable
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          DrawerHeader(
                            decoration: const BoxDecoration(
                              color: Color(0xFF02013C),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5,),
                                const Text(
                                  'Mostrando el presupuesto:',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 5,),
                                Text(
                                  presupuesto['nombre'][0].toUpperCase()+presupuesto['nombre'].substring(1),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.home),
                                title: Text('Inicio'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Future.delayed(const Duration(milliseconds: 150), () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Navegador(inicio: 1, usuario: widget.usuario)),
                                          (Route<dynamic> route) => false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_month),
                                title: const Text('Calendario'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Future.delayed(const Duration(milliseconds: 150), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Calendario(title: 'Calendario', usuario: widget.usuario, presupuesto: presupuesto)),
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.trending_up_outlined),
                                title: const Text('Resumen Ingresos'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Future.delayed(const Duration(milliseconds: 150), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ResumenIngresos(title: 'Resumen Ingresos', usuario: widget.usuario, presupuesto: presupuesto)),
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.trending_down_outlined),
                                title: const Text('Resumen Egresos'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Future.delayed(const Duration(milliseconds: 150), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ResumenEgresos(title: 'Resumen Egresos', usuario: widget.usuario, presupuesto: presupuesto)),
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                title: const Text('Graficas'),
                                leading: Icon(Icons.bar_chart),
                                onTap: () {
                                  if(_listaPresupuestos.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: const Text('Aún no se han agregado presupuestos para poder mostrar graficas.'),
                                            actions: [
                                              MaterialButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Aceptar'),
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    Future.delayed(const Duration(milliseconds: 150), () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => VisualizacionGraficas(title: 'Graficas', usuario: widget.usuario, presupuesto: presupuesto)),
                                      );
                                    });
                                  }
                                },
                              ),
                              ExpansionTile( // Boton que muestra una lista de botones
                                title: const Text('Presupuestos'),
                                leading: const Icon(Icons.attach_money_outlined),
                                children: _listTiles,
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height*0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  child: IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const CuadroDialogoInformacionApp();
                                          }
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),

                    ),
                    appBar: AppBar(
                      title: Text(
                        _titulos[_indice],
                        style: const TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.0
                        ),
                      ),
                      centerTitle: true,
                      backgroundColor: const Color(0xFF02013C),
                      iconTheme: const IconThemeData(color: Colors.white), // Color del icono
                      actions: <Widget>[
                        // Boton de agregar Presupuesto
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CuadroDialogoAgregarPresupuesto(usuario: widget.usuario);
                                  }
                              );
                            },
                            icon: const Icon(Icons.create_new_folder)
                        ),
                      ],
                    ),
                    body: _vistas[_indice],
                    bottomNavigationBar: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: _indice,
                      onTap: (value) {
                        setState(() {
                          _indice = value;
                        });
                      },
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.trending_up_outlined),
                            label: "Ingresos"
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home_filled),
                            label: "Inicio"
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.trending_down_outlined),
                            label: "Egresos"
                        ),
                      ],
                    ),
                  ),
                ],
              );

            } else {
              // Si despues de cargar la informacion no se encuentran presupuestos se manda a una vista especifica
              return Stack(
                children: [
                  Scaffold(
                    drawer: Drawer( // Menu lateral desplegable
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          const DrawerHeader(
                            decoration: BoxDecoration(
                              color: Color(0xFF02013C),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5,),
                                Text(
                                  'Hola,',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal
                                  ),
                                  softWrap: true,
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  'Bienvenido',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.home),
                                title: const Text('Inicio'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Future.delayed(const Duration(milliseconds: 150), () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Navegador(inicio: 1, usuario: widget.usuario)),
                                          (Route<dynamic> route) => false,
                                    );
                                  });
                                },
                              ),
                              ExpansionTile( // Boton que muestra una lista de botones
                                title: const Text('Presupuestos'),
                                leading: const Icon(Icons.attach_money_outlined),
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.add_circle_outlined,
                                      color: Colors.grey,
                                    ),
                                    title: const Text('Agregar presupuesto'),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CuadroDialogoAgregarPresupuesto(usuario: widget.usuario);
                                          }
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  child: IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const CuadroDialogoInformacionApp();
                                          }
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ),
                    appBar: AppBar(
                      title: const Text(
                        'Bienvenido',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.0
                        ),
                      ),
                      centerTitle: true,
                      backgroundColor: const Color(0xFF02013C),
                      iconTheme: const IconThemeData(color: Colors.white), // Color del icono
                      actions: <Widget>[
                        // Boton de agregar Presupuesto
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CuadroDialogoAgregarPresupuesto(usuario: widget.usuario);
                                  }
                              );
                            },
                            icon: const Icon(Icons.create_new_folder)
                        ),
                      ],
                    ),
                    body: const Bienvenido(title: 'Bienvenido'),
                    bottomNavigationBar: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: 1,
                      onTap: (value) {

                      },
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.trending_up_outlined),
                            label: "Ingresos"
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home_filled),
                            label: "Inicio"
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.trending_down_outlined),
                            label: "Egresos"
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

          }
        }
    );
  }

}