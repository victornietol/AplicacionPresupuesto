import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:calculadora_presupuesto/navegador.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


// Cuadro de de dialogo para agregar un ingreso o egreso
class CuadroDialogoAgregar extends StatefulWidget {
  const CuadroDialogoAgregar({super.key,
    required this.tipo,
    required this.listaCategorias,
    required this.usuario,
    required this.vistaDestino,
    required this.idPresupuesto,
  });
  final String tipo;
  final List<Map<String, dynamic>> listaCategorias;
  final String usuario;
  final Navegador vistaDestino;
  final int idPresupuesto;


  @override
  State<CuadroDialogoAgregar> createState() => _CuadroDialogoAgregarState();
}

class _CuadroDialogoAgregarState extends State<CuadroDialogoAgregar> {
  TextEditingController _nombreTEC = TextEditingController();
  TextEditingController _montoTEC = TextEditingController();
  TextEditingController _descripcionTEC = TextEditingController();
  String? _categoriaSeleccionada;


  List<String> _obtenerCategorias(List<Map<String, dynamic>> lista) {
    List<String> nombresCategorias = [];
    lista.forEach((element) {
      nombresCategorias.add(element['nombre']);
    });
    return nombresCategorias;
  }


  Future<bool> _guardarDatos(BuildContext context) async {
    Map<String, dynamic> datos = {};

    if(widget.tipo=='ingreso') {  // Insertar ingreso
      try {
        // Verificar que no sean campos vacios
        if(_nombreTEC.text.trim().isEmpty||_nombreTEC.text.isEmpty||_categoriaSeleccionada==null||_descripcionTEC.text.isEmpty||_descripcionTEC.text.trim().isEmpty) {
          throw Exception("Campo vacio");
        }
        datos['nombre']=_nombreTEC.text;
        datos['monto']=double.parse(_montoTEC.text); // pasar a numerico para hacer la insercion
        datos['descripcion']=_descripcionTEC.text;
        datos['fecha_registro']=DateTime.now().toIso8601String();

        // Obtener id del usuario
        Map<String, dynamic> usuario = await DataBaseOperaciones().obtenerUsuario(widget.usuario);
        datos['fk_id_usuario']=usuario['id_usuario'];

        // Obtener id de la categoria
        int? idCategoria = await DataBaseOperaciones().obtenerIdCategoria('ingreso', _categoriaSeleccionada??'', widget.idPresupuesto);
        datos['fk_id_categoria_ingreso']=idCategoria ?? -1;

        // Hacer insercion
        bool carga = await DataBaseOperaciones().insertarIngreso(datos);
        return carga;

      } catch (e) {
        // Mostrar Mensaje de alerta por un error al insertar
        if(context.mounted) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                      "Error",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  content: Text(
                      e is FormatException ? "Valor del monto incorrecto." : "Ocurrio un error al guardar."
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF02013C),
                      ),
                      child: const Text("Aceptar"),
                    )
                  ],
                );
              }
          );
        }
        return false;
      }


    } else if(widget.tipo=='egreso') {  // Insertar egreso
      try {
        if(_nombreTEC.text.trim().isEmpty||_nombreTEC.text.isEmpty||_categoriaSeleccionada==null||_descripcionTEC.text.trim().isEmpty||_descripcionTEC.text.isEmpty) {
          throw Exception("Campo vacio");
        }
        datos['nombre']=_nombreTEC.text;
        datos['monto']=double.parse(_montoTEC.text); // pasar a numerico para hacer la insercion
        datos['descripcion']=_descripcionTEC.text;
        datos['fecha_registro']=DateTime.now().toIso8601String();

        // Obtener id del usuario
        Map<String, dynamic> usuario = await DataBaseOperaciones().obtenerUsuario(widget.usuario);
        datos['fk_id_usuario']=usuario['id_usuario'];

        // Obtener id de la categoria
        int? idCategoria = await DataBaseOperaciones().obtenerIdCategoria('egreso', _categoriaSeleccionada??'', widget.idPresupuesto);
        datos['fk_id_categoria_egreso']=idCategoria ?? -1;

        // Hacer insercion
        bool carga = await DataBaseOperaciones().insertarEgreso(datos);
        return carga;

      } catch (e) {
        // Mostrar Mensaje de alerta por un error al insertar
        if(context.mounted) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    "Error",
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  content: Text(
                      e is FormatException ? "Valor del monto incorrecto." : "Ocurrio un error al guardar."
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF02013C),
                      ),
                      child: const Text("Aceptar"),
                    )
                  ],
                );
              }
          );
        }
        return false;
      }

    } else {
      return false; // No se inserto
    }
  }




  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Container(
          //height: MediaQuery.of(context).size.height,// Altura de la pantalla
          width: MediaQuery.of(context).size.width, //Ancho de la pantalla
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(
                  widget.tipo=='ingreso' ? 'Nuevo ingreso' : 'Nuevo egreso',
                  style: const TextStyle(
                    fontSize: 30.0,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 20,),
              Container( // Nombre del ingreso
                child: TextField(
                  readOnly: false,
                  controller: _nombreTEC,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.tipo=='ingreso' ? 'Nombre del ingreso' : 'Nombre del egreso',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container( // Monto del ingreso
                child: TextField(
                  readOnly: false,
                  controller: _montoTEC,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.tipo=='ingreso' ? 'Monto del ingreso' : 'Monto del egreso',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container( // Descripcion del ingreso
                child: TextField(
                  readOnly: false,
                  controller: _descripcionTEC,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.tipo=='ingreso' ? 'Descripcion del ingreso' : 'Descripcion del egreso',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                height: 60.0,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black54,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Selecciona una categoria',
                      style: TextStyle(
                          color: Theme.of(context).hintColor
                      ),
                    ),
                    items: _obtenerCategorias(widget.listaCategorias)
                        .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item[0].toUpperCase()+item.substring(1),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    value: _categoriaSeleccionada,
                    onChanged: (String? value) {
                      setState(() {
                        _categoriaSeleccionada = value;
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
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, -5),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                        thumbColor: MaterialStateProperty.all(const Color(0xFF02013C)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)*0.04 ), // Separacion de los botones
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        _guardarDatos(context).then((cargaCorrecta) {
                          if(cargaCorrecta && widget.tipo=='ingreso') {
                            // Si la carga se realizo se recarga la vista de ingresos
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => widget.vistaDestino),
                                  (Route<dynamic> route) => false,
                            );
                          } else if(cargaCorrecta && widget.tipo=='egreso') {
                            // Si la carga se realizo se recarga la vista de egresos
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => widget.vistaDestino),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        });
                      },
                      color: const Color(0xFF02013C),
                      child: const Text(
                        'Agregar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// Cuadro de de dialogo para editar un ingreso o egreso
class CuadroDialogoEditar extends StatefulWidget {
  const CuadroDialogoEditar({super.key,
    required this.tipo,
    required this.listaCategorias,
    required this.usuario,
    required this.elemento,
    required this.categoriaElemento,
    required this.idPresupuesto,
  });
  final String tipo;
  final List<Map<String, dynamic>> listaCategorias;
  final String usuario;
  final Map<String, dynamic> elemento;
  final String categoriaElemento;
  final int idPresupuesto;


  @override
  State<CuadroDialogoEditar> createState() => _CuadroDialogoEditarState();
}

class _CuadroDialogoEditarState extends State<CuadroDialogoEditar> {
  late TextEditingController _nombreTEC = TextEditingController();
  late TextEditingController _montoTEC = TextEditingController();
  late TextEditingController _descripcionTEC = TextEditingController();
  String? _categoriaSeleccionada;
  bool _errorMonto = false;
  double _monto = 0.0;

  @override
  void initState() {
    super.initState();
    _nombreTEC = TextEditingController(text: widget.elemento['nombre']);
    _montoTEC = TextEditingController(text: widget.elemento['monto'].toString());
    _descripcionTEC = TextEditingController(text: widget.elemento['descripcion']);
    _categoriaSeleccionada = widget.categoriaElemento;
  }

  List<String> _obtenerCategorias(List<Map<String, dynamic>> lista) {
    List<String> nombresCategorias = [];
    lista.forEach((element) {
      nombresCategorias.add(element['nombre']);
    });
    return nombresCategorias;
  }

  Future<bool> _guardarDatos(BuildContext context) async {
    // try para identificar error al convertir tipo
    try {
      setState(() {
        _monto = double.parse(_montoTEC.text);
        _errorMonto = false;
      });
    } catch (e) {
      setState(() {
        _errorMonto = true;
      });
      return false; // Sale de la operacion
    }

    if(widget.tipo=='ingreso') {  // Insertar ingreso
      try {
        if(_nombreTEC.text==''||_nombreTEC.text==' '||_nombreTEC.text.isEmpty||_categoriaSeleccionada==null||_descripcionTEC.text==''||_descripcionTEC.text==' '||_descripcionTEC.text.isEmpty) {
          throw Exception("Campo vacio");
        }
        // Hacer insercion
        bool cargaExitosa = await DataBaseOperaciones().editarIngreso(
            widget.elemento['id_ingreso'],
            widget.elemento['fk_id_usuario'],
            _nombreTEC.text,
            _monto,
            _descripcionTEC.text,
            _categoriaSeleccionada ?? '',
            widget.idPresupuesto
        );
        return cargaExitosa;

      } catch (e) {
        return false;
      }

    } else if(widget.tipo=='egreso') {  // Insertar egreso
      try {
        if(_nombreTEC.text==''||_nombreTEC.text==' '||_nombreTEC.text.isEmpty||_categoriaSeleccionada==null||_descripcionTEC.text==''||_descripcionTEC.text==' '||_descripcionTEC.text.isEmpty) {
          throw Exception("Campo vacio");
        }
        // Hacer insercion
        bool cargaExitosa = await DataBaseOperaciones().editarEgreso(
            widget.elemento['id_egreso'],
            widget.elemento['fk_id_usuario'],
            _nombreTEC.text,
            _monto,
            _descripcionTEC.text,
            _categoriaSeleccionada ?? '',
            widget.idPresupuesto
        );
        return cargaExitosa;

      } catch (e) {
        return false;
      }

    } else {
      return false; // No se inserto
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Container(
          //height: MediaQuery.of(context).size.height,// Altura de la pantalla
          width: MediaQuery.of(context).size.width, //Ancho de la pantalla
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(
                  widget.tipo=='ingreso' ? 'Editar ingreso' : 'Editar egreso',
                  style: const TextStyle(
                    fontSize: 30.0,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 20,),
              Container( // Nombre del ingreso
                child: TextField(
                  readOnly: false,
                  controller: _nombreTEC,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.tipo=='ingreso' ? 'Nombre del ingreso' : 'Nombre del egreso',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container( // Monto del ingreso
                child: TextField(
                  readOnly: false,
                  controller: _montoTEC,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.tipo=='ingreso' ? 'Monto del ingreso' : 'Monto del egreso',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container( // Descripcion del ingreso
                child: TextField(
                  readOnly: false,
                  controller: _descripcionTEC,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.tipo=='ingreso' ? 'Descripcion del ingreso' : 'Descripcion del egreso',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                height: 60.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black54,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      ' ',
                      style: TextStyle(
                          color: Theme.of(context).hintColor
                      ),
                    ),
                    items: _obtenerCategorias(widget.listaCategorias)
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
                    value: _categoriaSeleccionada,
                    onChanged: (String? value) {
                      setState(() {
                        _categoriaSeleccionada = value;
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
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, -5),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                        thumbColor: MaterialStateProperty.all(const Color(0xFF02013C)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)*0.04 ), // Separacion de los botones
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  "Alerta",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                content: const Text(
                                  "¿Confirmar los cambios?",
                                  softWrap: true,
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Cancelar",
                                        style: TextStyle(
                                            color: Colors.black
                                        ),
                                      )
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _guardarDatos(context).then((cargaCorrecta) {
                                        if(cargaCorrecta && widget.tipo=='ingreso') {
                                          // Si la carga se realizo se recarga la vista de ingresos
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Navegador(inicio: 0, usuario: widget.usuario)),
                                                (Route<dynamic> route) => false,
                                          );
                                        } else if(cargaCorrecta && widget.tipo=='egreso') {
                                          // Si la carga se realizo se recarga la vista de egresos
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Navegador(inicio: 2, usuario: widget.usuario)),
                                                (Route<dynamic> route) => false,
                                          );
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  content: Text(
                                                      _errorMonto ? 'Valor del monto incorrecto.' : "No se pudo realizar la actualizacion del elemento."
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: const Color(0xFF02013C),
                                                      ),
                                                      child: const Text("Aceptar"),
                                                    )
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                      });
                                    },
                                    child: const Text(
                                        "Confirmar"
                                    ),
                                  ),
                                ],
                              );
                            }
                        );
                      },
                      color: const Color(0xFF02013C),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// Cuadro de de dialogo para mostrar detalles un ingreso o egreso
class CuadroDialogoDetalles extends StatefulWidget {
  const CuadroDialogoDetalles({super.key,
    required this.tipo,
    required this.listaCategorias,
    required this.elemento,
    required this.categoriaElemento,
    required this.montoFormateado,
    required this.porcentaje,
    required this.usuario,
    required this.idPresupuesto,
  });
  final String tipo;
  final List<Map<String, dynamic>> listaCategorias;
  final Map<String, dynamic> elemento;
  final String categoriaElemento;
  final String montoFormateado;
  final double porcentaje;
  final String usuario;
  final int idPresupuesto;


  @override
  State<CuadroDialogoDetalles> createState() => _CuadroDialogoDetallesState();
}

class _CuadroDialogoDetallesState extends State<CuadroDialogoDetalles> {

  String _formatearFecha(String fechaPlana) {
    DateTime fecha = DateTime.parse(fechaPlana);
    return DateFormat("dd/MM/yyyy,  h:mm a").format(fecha);
  }

  Future<bool> _eliminarElemento(String tipo, Map<String, dynamic> elemento) async {
    try {
      // Intentar eliminacion
      if(tipo=='ingreso') {
        bool eliminacionExitosa = await DataBaseOperaciones().eliminarIngreso(elemento['id_ingreso'], widget.usuario);
        return eliminacionExitosa;
      } else if(tipo=='egreso') {
        bool eliminacionExitosa = await DataBaseOperaciones().eliminarEgreso(elemento['id_egreso'], widget.usuario);
        return eliminacionExitosa;
      } else {
        return false;
      }
    } catch (e) {
      // Ocurrio un error
      return false;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width, //Ancho de la pantalla
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                // Titulo de la ventana
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.tipo=='ingreso' ? 'Detalles del ingreso' : 'Detalles del egreso',
                    style: const TextStyle(
                      fontSize: 30.0,
                    ),
                    softWrap: true,
                  ),
                ],
              ),

              Column( // Contenido de la ventana
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20,),
                  Container( // Nombre del ingreso
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        topRight: Radius.circular(6.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                            'Nombre:'
                        ),
                        Text(
                          widget.elemento['nombre'][0].toUpperCase()+widget.elemento['nombre'].substring(1),
                          softWrap: true,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Container( // Monto del ingreso
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                        color: Colors.white
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                            'Monto:'
                        ),
                        Text(
                          widget.montoFormateado,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Container( // Porcentaje del ingreso
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                        color: Colors.white
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.tipo=='ingreso' ? 'Porcentaje correspodiente al total de ingresos:' : 'Porcentaje correspodiente al total de egresos',
                          softWrap: true,
                        ),
                        Text(
                          '${widget.porcentaje.toStringAsFixed(2)}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Container( // Descripcion del ingreso
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                        color: Colors.white
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                            'Descripcion:'
                        ),
                        Text(
                          widget.elemento['descripcion'][0].toUpperCase()+widget.elemento['descripcion'].substring(1),
                          softWrap: true,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Container( // Categoria del ingreso
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                            'Categoria:'
                        ),
                        Text(
                          widget.categoriaElemento[0].toUpperCase()+widget.categoriaElemento.substring(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Container( // Fecha de registro del ingreso
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6.0),
                        bottomRight: Radius.circular(6.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                            'Fecha de registro:'
                        ),
                        Text(
                          _formatearFecha(widget.elemento['fecha_registro']),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                ],
              ),

              Column( // Botones
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Alerta",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      content: const Text(
                                        "¿Esta seguro que desea eliminar el elemento?",
                                        softWrap: true,
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Cancelar",
                                              style: TextStyle(
                                                  color: Colors.black
                                              ),
                                            )
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              _eliminarElemento(widget.tipo, widget.elemento).then((value) {
                                                if(value && widget.tipo=='ingreso') {
                                                  // Si se realizo la eliminacion se carga la vista de ingresos
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Navegador(inicio: 0, usuario: widget.usuario)),
                                                        (Route<dynamic> route) => false,
                                                  );

                                                } else if(value && widget.tipo=='egreso') {
                                                  // Si se realizo la eliminacion se carga la vista de egresos
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Navegador(inicio: 2, usuario: widget.usuario)),
                                                        (Route<dynamic> route) => false,
                                                  );

                                                } else {
                                                  // No se realizo la operacion y se muestra cuadro de dialogo
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: const Text("Ocurrio un error al eliminar el elemento."),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: const Text("Aceptar"),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  );
                                                }
                                              });
                                            },
                                            child: Text("Confirmar")
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                            color: Colors.red,
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ),
                          const SizedBox(width: 12,),
                          MaterialButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CuadroDialogoEditar(
                                        tipo: widget.tipo,
                                        listaCategorias: widget.listaCategorias,
                                        usuario: widget.usuario,
                                        elemento: widget.elemento,
                                        categoriaElemento: widget.categoriaElemento,
                                        idPresupuesto: widget.idPresupuesto,
                                    );
                                  }
                              );
                            },
                            color: const Color(0xFF02013C),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.grey,
                            child: const Text(
                              'Regresar',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  )
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}



// Cuadro de de dialogo para agregar una categoria
class CuadroDialogoAgregarCategoria extends StatefulWidget {
  const CuadroDialogoAgregarCategoria({super.key,
    required this.tipo,
    required this.usuario,
    required this.idPresupuesto,
  });
  final String tipo;
  final String usuario;
  final int idPresupuesto;

  @override
  State<CuadroDialogoAgregarCategoria> createState() => _CuadroDialogoAgregarCategoriaState();
}

class _CuadroDialogoAgregarCategoriaState extends State<CuadroDialogoAgregarCategoria> {
  TextEditingController _nombreTEC = TextEditingController();
  String? _mensajeErrorGuardar;


  Future<bool> _guardarDatos(String nombreCategoria, String tipo) async {
    if(nombreCategoria.isEmpty || nombreCategoria.trim().isEmpty) {
      _mensajeErrorGuardar = "Campo vacio.";
      return false;
    } else {
      try {
        switch (tipo) {
          case 'ingreso':
            return await DataBaseOperaciones().insertarCategoria(nombreCategoria.toLowerCase(), tipo, widget.idPresupuesto);
          case 'egreso':
            return await DataBaseOperaciones().insertarCategoria(nombreCategoria.toLowerCase(), tipo, widget.idPresupuesto);
          default:
            return false; // No se inserto
        }
      } catch (e) {
        if(e.toString().contains('UNIQUE constraint failed')) {
          _mensajeErrorGuardar = 'La categoria ya existe.';
          return false;
        } else {
          _mensajeErrorGuardar = 'No se pudo realizar la carga.';
          return false;
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Container(
          //height: MediaQuery.of(context).size.height,// Altura de la pantalla
          width: MediaQuery.of(context).size.width, //Ancho de la pantalla
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(
                  widget.tipo=='ingreso' ? 'Nueva categoria de ingresos' : 'Nueva categoria de egresos',
                  style: const TextStyle(
                    fontSize: 24.0,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 20,),
              Container( // Nombre
                child: TextField(
                  readOnly: false,
                  controller: _nombreTEC,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Nombre de la categoria',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20,),

              // Botones
              Container(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)*0.04 ), // Separacion de los botones
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        _guardarDatos(_nombreTEC.text, widget.tipo).then((cargaCorrecta) {
                          if(cargaCorrecta && widget.tipo=='ingreso') {
                            // Si la carga se realizo se recarga la vista de ingresos
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Navegador(inicio: 0, usuario: widget.usuario)),
                                  (Route<dynamic> route) => false,
                            );
                          } else if(cargaCorrecta && widget.tipo=='egreso') {
                            // Si la carga se realizo se recarga la vista de egresos
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Navegador(inicio: 2, usuario: widget.usuario)),
                                  (Route<dynamic> route) => false,
                            );
                          } else {
                            // Falla la carga
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: Text(_mensajeErrorGuardar ?? 'Ocurrio un error.'),
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
                      color: const Color(0xFF02013C),
                      child: const Text(
                        'Agregar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// Grafica del resumen 1
class GraficaBarras extends StatefulWidget {
  const GraficaBarras({super.key,
    required this.tipo,
    required this.listaCantidades,
    required this.sumaTotalElementos,
  });
  final String tipo;
  final Map<String, dynamic> listaCantidades;
  final double sumaTotalElementos;

  @override
  State<GraficaBarras> createState() => _GraficaBarrasState();
}

class _GraficaBarrasState extends State<GraficaBarras> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, //Ancho de la pantalla
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            // Contenido de widget
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Partes que componene al widget (Cuerpo)
                Text(
                  widget.tipo=='ingreso' ? 'Grafica de ingresos' : 'Grafica de egresos',
                  style: const TextStyle(
                    fontSize: 30.0,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 10,),

                // Grafica
                SizedBox(
                    height: 400,
                    child: BarChart(
                        BarChartData(
                            borderData: borderData,
                            //gridData: const FlGridData(show: false),
                            //backgroundColor: Colors.white,
                            alignment: BarChartAlignment.spaceAround,
                            maxY: widget.listaCantidades.values.reduce((a, b) { return a>b ? a : b; }), // obtener el valor maximo para Y
                            barGroups: widget.listaCantidades.entries.toList().asMap().entries.map((entry) {
                              int index = entry.key; // indice manual
                              MapEntry<String, dynamic> datosEntry = entry.value; // entrada del map
                              double cantidad = datosEntry.value; // monto de la categoria
                              String titulo = datosEntry.key; // nombre de la categoria

                              return BarChartGroupData(
                                  x: index, // Indice de la barra del grafico
                                  barRods: [
                                    BarChartRodData( // Barras
                                      toY: cantidad, // altura de la barra (eje Y)
                                      color: widget.tipo=='ingreso' ? Colors.green : Colors.red,
                                      width: 60/widget.listaCantidades.length, // ancho de la barras
                                    ),
                                  ],
                                  //showingTooltipIndicators: [0] // Donde mostrar tooltip
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)
                                ),
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          // Obtener titulo
                                          int index = value.toInt();
                                          if(index>=0 && index<widget.listaCantidades.length) {
                                            String titulo = widget.listaCantidades.keys.elementAt(index)[0].toUpperCase()+widget.listaCantidades.keys.elementAt(index).substring(1); // obtener categoria
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                  titulo
                                              ),
                                            );
                                          }
                                          // Si no hay valores validos no se muestra nada
                                          return Container();
                                        },
                                        reservedSize: 30 // espacio para los titulos del eje X
                                    )
                                )
                            )
                        )
                    )
                ),
                const SizedBox(height: 20,),

                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: const Color(0xFF02013C),
                  ),
                  child: MaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                        "Cerrar",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ),

              ]
          ),
        )
      )
    );
  }


  // Bordes de la grafica
  FlBorderData get borderData => FlBorderData(
    show: false,
  );
}



// Grafica del resumen 2
class GraficaBarras2 extends StatefulWidget {
  const GraficaBarras2({super.key,
    required this.tipo,
    required this.listaCantidades,
    required this.sumaTotalElementos,
  });
  final String tipo;
  final Map<String, dynamic> listaCantidades;
  final double sumaTotalElementos;

  @override
  State<GraficaBarras2> createState() => _GraficaBarras2State();
}

class _GraficaBarras2State extends State<GraficaBarras2> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.95, //Ancho de la pantalla
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                // Contenido de widget
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Partes que componene al widget (Cuerpo)
                    Text(
                      widget.tipo=='ingreso' ? 'Grafica de ingresos' : 'Grafica de egresos',
                      style: const TextStyle(
                        fontSize: 30.0,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 10,),

                    // Grafica Scroll horizontal
                    SizedBox(
                        height: 400,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: widget.listaCantidades.length*80, // ancho dependiendo del numero de elementos
                            child: TweenAnimationBuilder<double>( // Animador para la barra
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(begin: 0, end: 1),
                              builder: (context, animationValue, child) {
                                return BarChart( // Grafica de barras
                                    BarChartData(
                                        borderData: FlBorderData(show: false),
                                        alignment: BarChartAlignment.spaceAround,
                                        maxY: widget.listaCantidades.values.reduce((a, b) => a>b ? a : b)*1.1, // obtener el valor maximo para Y
                                        barGroups: widget.listaCantidades.entries.toList().asMap().entries.map((entry) {
                                          int index = entry.key; // indice manual
                                          MapEntry<String, dynamic> datosEntry = entry.value; // entrada del map
                                          double cantidad = datosEntry.value; // monto de la categoria

                                          return BarChartGroupData(
                                            x: index, // Indice de la barra del grafico
                                            barRods: [
                                              BarChartRodData( // Barras
                                                toY: cantidad * animationValue, // altura de la barra (eje Y)
                                                color: Colors.primaries[index % Colors.primaries.length], // Agregar color dinamicamente
                                                width: 30, // ancho de la barras
                                              ),
                                            ],
                                            //showingTooltipIndicators: [0] // Donde mostrar tooltip
                                          );
                                        }).toList(),
                                        titlesData: FlTitlesData(
                                            leftTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false)
                                            ),
                                            rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false)
                                            ),
                                            topTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false)
                                            ),
                                            bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (double value, TitleMeta meta) {
                                                      // Obtener titulo
                                                      int index = value.toInt();
                                                      if(index>=0 && index<widget.listaCantidades.length) {
                                                        String titulo = widget.listaCantidades.keys.elementAt(index)[0].toUpperCase()+widget.listaCantidades.keys.elementAt(index).substring(1); // obtener categoria
                                                        return SideTitleWidget(
                                                          axisSide: meta.axisSide,
                                                          child: Transform.rotate(
                                                            angle: -0.6, // Rotar texto
                                                            child: Text(
                                                              titulo,
                                                              style: const TextStyle(fontSize: 12),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      // Si no hay valores validos no se muestra nada
                                                      return Container();
                                                    },
                                                    reservedSize: 60 // espacio para los titulos del eje X
                                                )
                                            )
                                        )
                                    )
                                );
                              },
                            ),
                          ),
                        )
                    ),
                    const SizedBox(height: 20,),

                    // Leyenda de colores
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.listaCantidades.entries.toList().asMap().entries.map((entry) {
                        int index = entry.key;
                        String categoria = entry.value.key;
                        return Row(
                          children: <Widget>[
                            Container(
                              width: 15,
                              height: 15,
                              color: Colors.primaries[index % Colors.primaries.length],
                            ),
                            const SizedBox(width: 8,),
                            Text(categoria[0].toUpperCase()+categoria.substring(1))
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20,),
                    // Boton cerrar
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: const Color(0xFF02013C),
                      ),
                      child: MaterialButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Cerrar",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),

                  ]
              ),
            )
        )
    );
  }

}


// Grafica Radial Bar
class GraficaRadialBar extends StatefulWidget {
  const GraficaRadialBar({super.key,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.colorIngresos,
    required this.colorEgresos,
  });
  final double totalIngresos;
  final double totalEgresos;
  final Color colorIngresos;
  final Color colorEgresos;

  @override
  State<GraficaRadialBar> createState() => GraficaRadialBarState();
}

class GraficaRadialBarState extends State<GraficaRadialBar> {

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> datos = [
      {'tipo':'Ingresos', 'monto':widget.totalIngresos, 'color':widget.colorIngresos},
      {'tipo':'Egresos', 'monto':widget.totalEgresos, 'color':widget.colorEgresos}
    ];

    return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.95, //Ancho de la pantalla
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SfCircularChart(
                      title: const ChartTitle(
                        text: 'Cantidades',
                      ),
                      legend: const Legend(isVisible: true, isResponsive: true),
                      series: <RadialBarSeries<Map<String, dynamic>, String>>[
                        RadialBarSeries<Map<String, dynamic>, String>(
                          dataSource: datos,
                          xValueMapper: (Map<String, dynamic> data, _) => data['tipo'],
                          yValueMapper: (Map<String, dynamic> data, _) => data['monto'],
                          pointColorMapper: (Map<String, dynamic> data, _) => data['color'],
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: const Color(0xFF02013C),
                      ),
                      child: MaterialButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Cerrar",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )
        )
    );
  }
}



// Cuadro de de dialogo para agregar un nuevo presupuesto
class CuadroDialogoAgregarPresupuesto extends StatefulWidget {
  const CuadroDialogoAgregarPresupuesto({super.key,
    required this.usuario,
  });
  final String usuario;

  @override
  State<CuadroDialogoAgregarPresupuesto> createState() => _CuadroDialogoAgregarPresupuestoState();
}

class _CuadroDialogoAgregarPresupuestoState extends State<CuadroDialogoAgregarPresupuesto> {
  TextEditingController _nombreTEC = TextEditingController();
  String? _mensajeErrorGuardar;
  int? _idInsertado;


  Future<bool> _guardarDatos(String nombrePresupuesto) async {
    if(nombrePresupuesto.isEmpty || nombrePresupuesto.trim().isEmpty) {
      _mensajeErrorGuardar = "Campo vacio.";
      return false;
    } else {
      try {
        _idInsertado = await DataBaseOperaciones().insertarPresupuesto(nombrePresupuesto, widget.usuario);
        return _idInsertado!>0 ? true : false; // Si se devuelve id valido significa que se inserto
      } catch (e) {
        if(e.toString().contains('UNIQUE constraint failed')) {
          _mensajeErrorGuardar = 'El nombre de presupuesto ya existe.';
          return false;
        } else {
          _mensajeErrorGuardar = 'No se pudo realizar la carga.';
          return false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Container(
          //height: MediaQuery.of(context).size.height,// Altura de la pantalla
          width: MediaQuery.of(context).size.width, //Ancho de la pantalla
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: const Text(
                  'Nuevo presupuesto',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 20,),
              TextField(
                readOnly: false,
                controller: _nombreTEC,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre del presupuesto',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20,),

              // Botones
              Container(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)*0.04 ), // Separacion de los botones
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        _guardarDatos(_nombreTEC.text).then((cargaCorrecta) {
                          if(cargaCorrecta) {
                            // Si la carga se realizo se manda a la vista con ese presupuesto nuevo
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Navegador(inicio: 1, usuario: widget.usuario, idPresupuesto: _idInsertado)),
                                  (Route<dynamic> route) => false,
                            );
                          } else {
                            // Falla la carga
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: Text(_mensajeErrorGuardar ?? 'Ocurrio un error.'),
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
                      color: const Color(0xFF02013C),
                      child: const Text(
                        'Agregar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// Cuadro de de dialogo para editar un presupuesto
class CuadroDialogoEditarPresupuesto extends StatefulWidget {
  const CuadroDialogoEditarPresupuesto({super.key,
    required this.usuario,
    required this.presupuesto,
  });
  final String usuario;
  final Map<String, dynamic> presupuesto;

  @override
  State<CuadroDialogoEditarPresupuesto> createState() => _CuadroDialogoEditarPresupuestoState();
}

class _CuadroDialogoEditarPresupuestoState extends State<CuadroDialogoEditarPresupuesto> {
  TextEditingController _nombreTEC = TextEditingController();
  String? _mensajeErrorGuardar;

  @override
  void initState() {
    super.initState();
    _nombreTEC = TextEditingController(text: widget.presupuesto['nombre']);
  }

  Future<bool> _guardarDatos(String nombrePresupuesto) async {
    if(nombrePresupuesto.isEmpty || nombrePresupuesto.trim().isEmpty) {
      _mensajeErrorGuardar = "Campo vacio.";
      return false;
    } else {
      try {
        return await DataBaseOperaciones().editarPresupuesto(widget.presupuesto['id_presupuesto'], nombrePresupuesto, widget.presupuesto['fk_id_usuario']);
      } catch (e) {
        if(e.toString().contains('UNIQUE constraint failed')) {
          _mensajeErrorGuardar = 'El nombre de presupuesto ya existe.';
          return false;
        } else {
          _mensajeErrorGuardar = 'No se pudo realizar la carga.';
          return false;
        }
      }
    }
  }

  Future<bool> _eliminarPresupuesto(Map<String, dynamic> presupuesto) async {
    return await DataBaseOperaciones().eliminarPresupuesto(presupuesto['id_presupuesto'], presupuesto['fk_id_usuario']);
  }




  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Container(
          //height: MediaQuery.of(context).size.height,// Altura de la pantalla
          width: MediaQuery.of(context).size.width, //Ancho de la pantalla
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: const Text(
                  'Editar presupuesto',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 20,),
              TextField(
                readOnly: false,
                controller: _nombreTEC,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre del presupuesto',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20,),

              // Botones
              Container(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)*0.04 ), // Separacion de los botones
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton( // Boton eliminar
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: const Text('¿Estas seguro de eliminar el elemento?'),
                                  actions: [
                                    MaterialButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        _eliminarPresupuesto(widget.presupuesto).then((eliminacionCorrecta) {
                                          if(eliminacionCorrecta) {
                                            Navigator.of(context).pop();
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Navegador(inicio: 1, usuario: widget.usuario, idPresupuesto: 1)),
                                                  (Route<dynamic> route) => false,
                                            );
                                          } else {
                                            // Falla la eliminacion
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    content: const Text('No se pudo eliminar.'),
                                                    actions: [
                                                      MaterialButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text(
                                                          'Aceptar',
                                                          style: TextStyle(
                                                              color: Colors.indigo
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                            );
                                          }
                                        });
                                      },
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                );
                              }
                          );
                        },
                      minWidth: 20,
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text('¿Esta seguro de guardar los cambios?'),
                                actions: [
                                  MaterialButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancelar'),
                                  ),
                                  // Guardar
                                  MaterialButton(
                                    onPressed: () {
                                      _guardarDatos(_nombreTEC.text).then((cargaCorrecta) {
                                        if(cargaCorrecta) {
                                          // Si la carga se realizo se manda a la vista con ese presupuesto nuevo
                                          Navigator.of(context).pop();
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Navegador(inicio: 1, usuario: widget.usuario, idPresupuesto: widget.presupuesto['id_presupuesto'])),
                                                (Route<dynamic> route) => false,
                                          );
                                        } else {
                                          // Falla la carga
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Error'),
                                                  content: Text(_mensajeErrorGuardar ?? 'Ocurrio un error.'),
                                                  actions: [
                                                    MaterialButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text(
                                                          'Aceptar',
                                                        style: TextStyle(
                                                          color: Colors.indigo
                                                        ),
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                      });
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              );
                            }
                        );
                      },
                      color: const Color(0xFF02013C),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}