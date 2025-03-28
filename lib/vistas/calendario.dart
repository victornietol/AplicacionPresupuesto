import 'package:calculadora_presupuesto/customWidgets/cuadrosDialogo.dart';
import 'package:calculadora_presupuesto/operaciones/databaseOperaciones.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';


class Calendario extends StatefulWidget {
  const Calendario({super.key,
    required this.title,
    required this.usuario,
    required this.presupuesto});
  final String title;
  final String usuario;
  final Map<String, dynamic> presupuesto;

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late Future<void> _cargaInicial; // Indicar la carga inicial de datos

  CalendarFormat _calendarFormat = CalendarFormat.month; // Formato del calendario
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Event>> _eventos = {};
  List<Map<String, dynamic>> _datosIngresos = [];
  List<Map<String, dynamic>> _datosEgresos = [];
  List<Map<String, dynamic>> _listaCategoriasIngreso = [];
  List<Map<String, dynamic>> _listaCategoriasEgreso = [];

  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarDatosVista(); // Carga de datos de las funciones asincronas
    initializeDateFormatting('es_MX', null);
  }

  List<Event> _obtenerEventosPorDia(DateTime dia) {
    return _eventos[DateTime(dia.year, dia.month, dia.day)] ?? [];
  }

  // Funcion para ejecutar y esperar el resultado de las funcion asincronas que cargan datos
  Future<void> _cargarDatosVista() async {
    await Future.wait([
      // Funciones de las que se espera un resultado
      _obtenerIngresosEgresosTodos(),
      _obtenerCategorias(),
    ]);
  }

  Future<void> _obtenerIngresosEgresosTodos() async {
    _datosIngresos = await DataBaseOperaciones().obtenerListadoIngresosTodos(widget.presupuesto['id_presupuesto'], widget.usuario);
    _datosEgresos = await DataBaseOperaciones().obtenerListadoEgresosTodos(widget.presupuesto['id_presupuesto'], widget.usuario);

    // Agregar ingresos
    for(var ingreso in _datosIngresos) {
      List<Event> evento = [Event(ingreso['id_ingreso'], ingreso['nombre'], ingreso['monto'], ingreso['descripcion'], ingreso['fecha_registro'], ingreso['fk_id_usuario'], ingreso['id_categoria'], ingreso['categoria'], 'ingreso')];

      // Obtener fecha
      int anio = int.parse(ingreso['fecha_registro'].substring(0, 4));
      int mes = int.parse(ingreso['fecha_registro'].substring(6, 7));
      int dia = int.parse(ingreso['fecha_registro'].substring(8, 10));

      // Agregando a la lista de eventos
      _agregarEvento(DateTime(anio, mes, dia), evento);
    }

    // Agregar egresos
    for(var egreso in _datosEgresos) {
      List<Event> evento = [Event(egreso['id_egreso'] ,egreso['nombre'], egreso['monto'], egreso['descripcion'], egreso['fecha_registro'], egreso['fk_id_usuario'], egreso['id_categoria'], egreso['categoria'], 'egreso')];

      // Obtener fecha
      int anio = int.parse(egreso['fecha_registro'].substring(0, 4));
      int mes = int.parse(egreso['fecha_registro'].substring(6, 7));
      int dia = int.parse(egreso['fecha_registro'].substring(8, 10));

      // Agregando a la lista de eventos
      _agregarEvento(DateTime(anio, mes, dia), evento);
    }
  }

  // Agrega los eventos a la lista de donde los va a cargar el calendario
  void _agregarEvento(DateTime fecha, List<Event> nuevoEvento) {
    DateTime fechaAjustada = DateTime(fecha.year, fecha.month, fecha.day);

    if(_eventos.containsKey(fechaAjustada)) {
      _eventos[fechaAjustada]!.addAll(nuevoEvento);
    } else {
      _eventos[fechaAjustada] = nuevoEvento;
    }
  }

  // Formatear cantidad de dinero
  String formatearCantidad(num monto) {
    //final formato = NumberFormat("#,##0.00", "es_MX");
    final formatoDinero = NumberFormat.currency(locale: "es_MX", symbol: "\$");
    return formatoDinero.format(monto);
  }

  // Obtener categorias
  Future<void> _obtenerCategorias() async {
    _listaCategoriasIngreso = await DataBaseOperaciones().obtenerCategorias("ingreso", widget.presupuesto['id_presupuesto']);
    _listaCategoriasEgreso = await DataBaseOperaciones().obtenerCategorias("egreso", widget.presupuesto['id_presupuesto']);
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
                title: Text(
                  widget.title,
                  style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.0
                  ),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFF02013C),
                iconTheme: const IconThemeData(color: Colors.white), // Color del icono
              ),
              body: const Center(child: CircularProgressIndicator()),
            );

          } else if(snapshot.hasError) {
            return Text("Ocurrio un error. ${snapshot.error}");

          } else {
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
                  backgroundColor: const Color(0xFF02013C),
                  iconTheme: const IconThemeData(color: Colors.white), // Color del icono
                ),

                body: Column(
                  children: [
                    // Cuerpo de mi vista
                    // Calendario
                    TableCalendar(
                      locale: 'es_MX',
                      focusedDay: _focusedDay,
                      firstDay: DateTime(DateTime.now().year -3),
                      lastDay: DateTime(DateTime.now().year +5),
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          print(format);
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      availableCalendarFormats: {
                        CalendarFormat.twoWeeks: '2 Semanas',
                        CalendarFormat.week: 'Semana',
                        CalendarFormat.month: 'Mes',
                      },
                      eventLoader: _obtenerEventosPorDia,

                      calendarBuilders: CalendarBuilders(
                        // Color del texto de fines de semana
                          dowBuilder: (context, day) {
                            if (day.weekday == DateTime.sunday || day.weekday == DateTime.saturday) {
                              final text = DateFormat.E('es_MX').format(day);
                              return Center(
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                          // Cambiar color de los dias numericos
                          defaultBuilder: (context, day, focusedDay) {
                            bool isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                            return Container(
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isWeekend ? Colors.lightBlue.withOpacity(0.3) : Colors.grey.withOpacity(0.2), // Fondo rojo para fines de semana
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: isWeekend ? Colors.indigo: Colors.black,
                                    fontWeight: isWeekend ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                          // Cambiar lasmarcas de los eventos en cada dia
                          markerBuilder: (context, date, events) {
                            if(events.isNotEmpty) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: events.map((event) {
                                  final evento = event as Event?; // Asegurar que event no es nulo antes de acceder a sus propiedades
                                  Color color = evento?.tipo == 'ingreso' ? Colors.green : Colors.red;
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 1.5),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            return null;
                          }
                      ),
                    ),

                    //cLista de eventos
                    Expanded(
                      child: _buildEventList(),
                    ),
                  ],
                )

            );
          }
        }
    );
  }

  Widget _buildEventList() {
    final events = _obtenerEventosPorDia(_selectedDay);
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: ListTile(
            tileColor: events[index].tipo=='ingreso' ? const Color(0xFFd4fed7) : const Color(0xffffdada),
            iconColor: events[index].tipo=='ingreso' ? Colors.green : Colors.red,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: events[index].tipo=='ingreso' ? Colors.green : Colors.red,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              events[index].titulo[0].toUpperCase()+events[index].titulo.substring(1),
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monto: ${formatearCantidad(events[index].monto)}'),
                Text('Categoria: ${events[index].categoria[0].toUpperCase()+events[index].categoria.substring(1)}'),
              ],
            ),
            leading: events[index].tipo=='ingreso' ? Icon(Icons.trending_up_outlined) :Icon(Icons.trending_down_outlined),
            onTap: () {
              Map<String, dynamic> elemento = {
                'id_${events[index].tipo}': events[index].id,
                'nombre': events[index].titulo,
                'monto': events[index].monto,
                'descripcion': events[index].descripcion,
                'fecha_registro': events[index].fecha,
                'fk_id_usuario': events[index].fk_id_usuario,
                'fk_id_categoria_${events[index].tipo}': events[index].id_categoria
              };
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CuadroDialogoDetalles(
                        tipo: events[index].tipo,
                        listaCategorias: events[index].tipo=='ingreso' ? _listaCategoriasIngreso : _listaCategoriasEgreso,
                        elemento: elemento,
                        categoriaElemento: events[index].categoria,
                        montoFormateado: formatearCantidad(events[index].monto),
                        usuario: widget.usuario,
                        idPresupuesto: widget.presupuesto['id_presupuesto']
                    );
                  }
              );
            },
          ),
        );
      },
    );
  }

}

class Event {
  final int id;
  final String titulo;
  final double monto;
  final String descripcion;
  final String fecha;
  final int fk_id_usuario;
  final int id_categoria;
  final String categoria;
  final String tipo;

  Event(this.id, this.titulo, this.monto, this.descripcion, this.fecha, this.fk_id_usuario, this.id_categoria, this.categoria, this.tipo);

  @override
  String toString() {
    // TODO: implement toString
    return 'Event {titulo=$titulo, monto=$monto, descripcion=$descripcion, categoria=$categoria, tipo=$tipo}';
  }
}