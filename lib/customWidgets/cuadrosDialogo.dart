import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:calculadora_presupuesto/navegador.dart';
import 'package:intl/intl.dart';

// Cuadro de de dialogo para agregar un ingreso o egreso
class CuadroDialogoAgregar extends StatefulWidget {
  const CuadroDialogoAgregar({super.key,
    required this.tipo,
    required this.listaCategorias,
    required this.usuario
  });
  final String tipo;
  final List<Map<String, dynamic>> listaCategorias;
  final String usuario;


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
        datos['nombre']=_nombreTEC.text;
        datos['monto']=double.parse(_montoTEC.text); // pasar a numerico para hacer la insercion
        datos['descripcion']=_descripcionTEC.text;
        datos['fecha_registro']=DateTime.now().toIso8601String();

        // Obtener id del usuario
        Map<String, dynamic> usuario = await DataBaseOperaciones().obtenerUsuario(widget.usuario);
        datos['fk_id_usuario']=usuario['id_usuario'];

        // Obtener id de la categoria
        int? idCategoria = await DataBaseOperaciones().obtenerIdCategoria('ingreso', _categoriaSeleccionada??'');
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
        datos['nombre']=_nombreTEC.text;
        datos['monto']=double.parse(_montoTEC.text); // pasar a numerico para hacer la insercion
        datos['descripcion']=_descripcionTEC.text;
        datos['fecha_registro']=DateTime.now().toIso8601String();

        // Obtener id del usuario
        Map<String, dynamic> usuario = await DataBaseOperaciones().obtenerUsuario(widget.usuario);
        datos['fk_id_usuario']=usuario['id_usuario'];

        // Obtener id de la categoria
        int? idCategoria = await DataBaseOperaciones().obtenerIdCategoria('egreso', _categoriaSeleccionada??'');
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
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Navegador(inicio: 0, usuario: widget.usuario)),
                              (Route<dynamic> route) => false,
                          );
                        } else if(cargaCorrecta && widget.tipo=='ingreso') {
                          // Si la carga se realizo se recarga la vista de egresos
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Navegador(inicio: 2, usuario: widget.usuario)),
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
    required this.categoriaElemento
  });
  final String tipo;
  final List<Map<String, dynamic>> listaCategorias;
  final String usuario;
  final Map<String, dynamic> elemento;
  final String categoriaElemento;


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
        // Hacer insercion
        bool cargaExitosa = await DataBaseOperaciones().editarIngreso(
            widget.tipo=='ingreso' ? widget.elemento['id_ingreso'] : widget.elemento['id_egreso'],
            widget.elemento['fk_id_usuario'],
            _nombreTEC.text,
            _monto,
            _descripcionTEC.text,
            _categoriaSeleccionada ?? ''
        );
        return cargaExitosa;

      } catch (e) {
        return false;
      }

    } else if(widget.tipo=='egreso') {  // Insertar egreso
      try {
        // Hacer insercion
        bool cargaExitosa = await DataBaseOperaciones().editarIngreso(
            widget.tipo=='ingreso' ? widget.elemento['id_ingreso'] : widget.elemento['id_egreso'],
            widget.elemento['fk_id_usuario'],
            _nombreTEC.text,
            _monto,
            _descripcionTEC.text,
            _categoriaSeleccionada ?? ''
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
                                      } else if(cargaCorrecta && widget.tipo=='ingreso') {
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
    required this.usuario
  });
  final String tipo;
  final List<Map<String, dynamic>> listaCategorias;
  final Map<String, dynamic> elemento;
  final String categoriaElemento;
  final String montoFormateado;
  final double porcentaje;
  final String usuario;


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
                                      categoriaElemento: widget.categoriaElemento
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
    );
  }
}

