import 'package:flutter/material.dart';
import 'package:calculadora_presupuesto/vistas/home.dart';
import 'package:calculadora_presupuesto/vistas/egresos.dart';
import 'package:calculadora_presupuesto/vistas/ingresos.dart';

class Navegador extends StatefulWidget{
  const Navegador({super.key, required this.inicio, required this.usuario});
  final int inicio;
  final String usuario;

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador>{
  late int _indice; // controlar el indice de la vista a mostrar
  final _vistas = []; // lista para las vistas
  final List _titulos = ['Ingresos', 'Resumen Presupuesto', 'Egresos'];
  final int _idPresupuesto = 1;

  // Vistas que se van a manejar
  @override
  void initState(){
    super.initState();
    _indice = widget.inicio;
    _vistas.add(
      Ingresos(title: _titulos[_indice], usuario: widget.usuario, idPresupuesto: _idPresupuesto)
    );
    _vistas.add(
        MyHomePage(title: _titulos[_indice], usuario: widget.usuario, idPresupuesto: _idPresupuesto)
    );
    _vistas.add(
      Egresos(title: _titulos[_indice], usuario: widget.usuario, idPresupuesto: _idPresupuesto)
    );
  }

  @override
  Widget build(BuildContext context){
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
                  child: Text(
                    'Menú Lateral',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Inicio'),
                  onTap: () {
                    // Agregar acción al seleccionar este ítem
                    Navigator.pop(context);  // Cierra el drawer
                  },

                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Ajustes'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Cerrar sesión'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ExpansionTile(
                  title: const Text('Perfiles'),
                  leading: Icon(Icons.attach_money_outlined),
                  children: [
                    // Generar estos presupuestos dinamicamente
                    ListTile(
                      title: Text('Presupuesto 1'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('Presupuesto 2'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
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
            items: [
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