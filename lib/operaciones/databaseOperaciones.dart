import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:decimal/decimal.dart';

class DataBaseOperaciones {
  // Crear solo una instancia de la DB en la app
  static final DataBaseOperaciones _instancia = DataBaseOperaciones._internal();
  static Database? _database;

  // Siempre se regresara la misma instancia de la clase para no crear mas de una
  factory DataBaseOperaciones() {
    return _instancia;
  }

  DataBaseOperaciones._internal(); // Constructor privado

  // Se devuelve la db si existe y esta abierta (ya hay instancia), en caso de no existir se inicializa
  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await _iniciarDatabase();
    return _database!;
  }

  // Inicializacion de la BD
  Future<Database> _iniciarDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'aplicacion_presupuesto.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        // Valores iniciales
        List<Map<String, dynamic>> categorias_ingresos = [
          {'nombre': 'ingreso fijo'},
          {'nombre': 'ingreso variable'}
        ];

        List<Map<String, dynamic>> categorias_egresos = [
          {'nombre': 'vivienda'},
          {'nombre': 'alimentacion'},
          {'nombre': 'transporte'},
          {'nombre': 'salud y bienestar'},
          {'nombre': 'deportes'},
          {'nombre': 'educacion y desarrollo personal'},
          {'nombre': 'entretenimiento y cultura'},
          {'nombre': 'deudas y finanzas'},
          {'nombre': 'seguros y proteccion'},
          {'nombre': 'consumo personal'},
          {'nombre': 'viajes y vacaciones'},
          {'nombre': 'regalos y celebraciones'},
          {'nombre': 'imprevistos'},
          {'nombre': 'otros'},
        ];

        // Creacion de la bd
        await db.transaction((txn) async {
          // tabla usuario
          await txn.execute('''
            CREATE TABLE usuario (
              id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL,
              fecha_registro TEXT NOT NULL
            )
          ''');

          // tabla para diferentes presupuestos
          await txn.execute('''
            CREATE TABLE presupuesto (
              id_presupuesto INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE,
              fk_id_usuario INTEGER,
              FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
            )
          ''');

          // tabla categoria egresos
          await txn.execute('''
            CREATE TABLE categoria_egreso (
              id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              fk_id_presupuesto INTEGER,
              FOREIGN KEY (fk_id_presupuesto) REFERENCES presupuesto(id_presupuesto) ON DELETE CASCADE ON UPDATE CASCADE,
              UNIQUE (nombre, fk_id_presupuesto)
            )
          ''');

          // tabla categoria ingresos
          await txn.execute('''
            CREATE TABLE categoria_ingreso (
              id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              fk_id_presupuesto INTEGER,
              FOREIGN KEY (fk_id_presupuesto) REFERENCES presupuesto(id_presupuesto) ON DELETE CASCADE ON UPDATE CASCADE,
              UNIQUE (nombre, fk_id_presupuesto)
            )
          ''');

          // tabla ingreso
          await txn.execute('''
            CREATE TABLE ingreso (
              id_ingreso INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              monto REAL NOT NULL,
              descripcion TEXT NULL,
              fecha_registro TEXT NOT NULL,
              fk_id_usuario INTEGER,
              fk_id_categoria_ingreso INTEGER,
              FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE  ON UPDATE CASCADE
              FOREIGN KEY (fk_id_categoria_ingreso) REFERENCES categoria_ingreso(id_categoria) ON DELETE CASCADE  ON UPDATE CASCADE
            )
          ''');

          // tabla egresos
          await txn.execute('''
            CREATE TABLE egreso (
              id_egreso INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              monto REAL NOT NULL,
              descripcion TEXT NULL,
              fecha_registro TEXT NOT NULL,
              fk_id_usuario INTEGER,
              fk_id_categoria_egreso INTEGER,
              FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
              FOREIGN KEY (fk_id_categoria_egreso) REFERENCES categoria_egreso(id_categoria) ON DELETE CASCADE ON UPDATE CASCADE
            )
          ''');

          // Insertar usuario generico
          await txn.insert('usuario',
              {'nombre':'generico',
                'password': 'generico',
                'fecha_registro': DateTime.now().toIso8601String()
              }
          );
/*
          // Insertar presupuesto inicial
          await txn.insert('presupuesto',
              {'nombre':'inicial',
                'fk_id_usuario':1
              }
          );


          // Insertar categorias ingresos
          for(var ingreso in categorias_ingresos) {
            await txn.insert('categoria_ingreso', ingreso);
          }

          // Insertar categorias egresos
          for(var egreso in categorias_egresos) {
            await txn.insert('categoria_egreso', egreso);
          }

 */

        });
      },
      onOpen: (db) async {
        // Activar FK cada que se abra la BD
        await db.execute('PRAGMA foreign_keys = ON;');
      }
    );
  }

  // Insertar usuario
  Future<bool> insertarUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    try {
      // Intentar la insercion
      await db.insert('usuario', usuario);
      return true;
    } catch (e) {
      // No se inserto
      print('Error al insertar: $e');
      return false;
    }

  }

  // Obtener un usuario por el nombre
  Future<Map<String, dynamic>> obtenerUsuario(String nombre) async {
    final db = await database;
    final List<Map<String, dynamic>> res_consulta = await db.query(
      'usuario', // tabla
      where: 'nombre = ?', // condicion
      whereArgs: [nombre] // valor de la condicional '?'
    );

    return res_consulta.isNotEmpty ? res_consulta.first : {}; // se utiliza .first para obtener el primer y unico elemento
  }

  // Obtener usuarios
  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final db = await database;
    return await db.query('usuario');
  }

  // Borrar usuario
  Future<bool> eliminarUsuario(String usuario) async {
    final db = await database;
    try {
      await db.delete('usuario', where: 'nombre = ?', whereArgs: [usuario]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Insertar ingreso
  Future<bool> insertarIngreso(Map<String, dynamic> ingreso) async {
    final db = await database;
    try {
      // Intentar insercion
      await db.insert('ingreso', ingreso);
      return true;
    } catch (e) {
      // Falla la insercion
      print("Error al insertar ingreso: $e");
      return false;
    }
  }

  // Insertar egreso
  Future<bool> insertarEgreso(Map<String, dynamic> egreso) async {
    final db = await database;
    try {
      // Intentar insercion
      await db.insert('egreso', egreso);
      return true;
    } catch (e) {
      // Falla la insercion
      print("Error al insertar egreso: $e");
      return false;
    }
  }

  // Insertar presupuestos, regresa el id del elemento insertado
  Future<int> insertarPresupuesto(String nombrePresupuesto, String nombreUsuario) async {
    final db = await database;
    Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);
    Map<String, dynamic> datos = {'nombre': nombrePresupuesto.trimRight(), 'fk_id_usuario': datosUsuario['id_usuario']};

    int idInsertado = await db.insert('presupuesto', datos);
    return idInsertado>0 ? idInsertado : 0;
  }

  // Eliminar presupuestos
  Future<bool> eliminarPresupuesto(int idPresupuesto, int idUsuario) async {
    final db = await database;

    try {
      int eliminaciones = await db.delete(
        'presupuesto',
        where: 'id_presupuesto = ? AND fk_id_usuario = ?',
        whereArgs: [idPresupuesto, idUsuario]
      );
      return eliminaciones>0 ? true : false;
    } catch (e) {
      print("Error en la funcion eliminarPresupuesto en databaseOperaciones.dart");
      return false;
    }
  }

  // Editar presupuestos
  Future<bool> editarPresupuesto(int idPresupuesto, String nombrePresupuesto, int fkUsuario) async {
    final db = await database;

    try {
      int actualizaciones = await db.update(
          'presupuesto',
        {
          'nombre': nombrePresupuesto.trimRight(),
        },
        where: 'id_presupuesto = ? AND fk_id_usuario = ?',
        whereArgs: [idPresupuesto, fkUsuario]
      );
      return actualizaciones>0 ? true : false;
    } catch (e) {
      print("Error en la funcion editarPresupuesto en databaseOperaciones.dart");
      return false;
    }
  }

  // Obtener presupuestos de un usuario
  Future<List<Map<String, dynamic>>> obtenerPresupuestos(String nombreUsuario) async {
    Map<String, dynamic> datosUser = await obtenerUsuario(nombreUsuario);
    final db = await database;

    return db.query(
      'presupuesto',
      where: 'fk_id_usuario = ?',
      whereArgs: [datosUser['id_usuario']]
    );
  }

  // Obtener id de la categoria ingreso
  Future<int?> obtenerIdCategoria(String tipo, String categoria, int idPresupuesto) async {
    final db = await database;

    final datosCategoria = await db.query(
        'categoria_$tipo',
        where: 'nombre = ? AND fk_id_presupuesto = ?',
        whereArgs: [categoria, idPresupuesto],
        columns: ['id_categoria']
    );

    if(datosCategoria.isNotEmpty) {
      return datosCategoria[0]['id_categoria'] as int?;
    } else {
      return null; // no se encontro categoria
    }
  }

  // Obtener el listado de categorias de un presupuesto
  Future<List<Map<String, dynamic>>> obtenerCategorias(String tipo, int idPresupuesto) async {
    final db = await database;
    if(tipo=='ingreso') {
      return db.query('categoria_ingreso', where: 'fk_id_presupuesto = ?', whereArgs: [idPresupuesto]);
    } else if(tipo=='egreso') {
      return db.query('categoria_egreso', where: 'fk_id_presupuesto = ?', whereArgs: [idPresupuesto]);
    } else {
      return []; // Categoria incorrecta
    }
  }

  // Insertar categoria
  Future<bool> insertarCategoria(String nombre, String tipo, int idPresupuesto) async {
    final db = await database;
    int insercion = 0;

    if(tipo=='ingreso') {
      insercion = await db.insert(
          'categoria_ingreso', // tabla
          {'nombre': nombre.trimRight(), 'fk_id_presupuesto': idPresupuesto} // campo
      );
    } else if(tipo=='egreso') {
      insercion = await db.insert(
          'categoria_egreso', // tabla
          {'nombre': nombre.trimRight(), 'fk_id_presupuesto': idPresupuesto} // campo
      );
    } else {
      return false; // No se realizo insercion
    }
    return insercion>0 ? true : false;
  }

  // Eliminar categoria
  Future<bool> eliminarCategoria(String nombre, String tipo, int idPresupuesto) async {
    final db = await database;
    int eliminacion = 0;

    if(tipo=='ingreso') {
      eliminacion = await db.delete('categoria_ingreso', where: 'nombre = ? AND fk_id_presupuesto = ?', whereArgs: [nombre, idPresupuesto]);
    } else if(tipo=='egreso') {
      eliminacion = await db.delete('categoria_egreso', where: 'nombre = ? AND fk_id_presupuesto = ?', whereArgs: [nombre, idPresupuesto]);
    } else {
      return false; // No se realizo insercion
    }
    return eliminacion>0 ? true : false;
  }

  // Obtener lista ingresos del usuario de un presupuesto
  Future<List<Map<String, dynamic>>> obtenerIngresosTodos(String usuario, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario.isEmpty) {
      // Si el usuario no existe
      return [];
    }
    String consulta = 'SELECT i.id_ingreso AS id_ingreso, i.nombre AS nombre, i.monto AS monto, i.descripcion AS descripcion, i.fecha_registro AS fecha_registro, i.fk_id_usuario AS fk_id_usuario, i.fk_id_categoria_ingreso AS fk_id_categoria_ingreso'
        ' FROM ingreso i JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto) WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ?';

    return await db.rawQuery(
      consulta,
      [datosUsuario['id_usuario'], idPresupuesto]
    );
  }

  // Obtener lista egresos del usuario
  Future<List<Map<String, dynamic>>> obtenerEgresosTodos(String usuario, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario.isEmpty) {
      // Si el usuario no existe
      return [];
    }
    String consulta = 'SELECT e.id_egreso AS id_egreso, e.nombre AS nombre, e.monto AS monto, e.descripcion AS descripcion, e.fecha_registro AS fecha_registro, e.fk_id_usuario AS fk_id_usuario, e.fk_id_categoria_egreso AS fk_id_categoria_egreso'
        ' FROM egreso e JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto) WHERE e.fk_id_usuario = ? AND p.id_presupuesto = ?';

    return await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );
  }

  // Obtener top ingresos del usuario indicando cuantos elementos
  Future<List<Map<String, dynamic>>> obtenerTopIngresos(String usuario, int idPresupuesto, int numElementos) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario == null) {
      // Si el usuario no existe
      return [];
    }

    return await db.rawQuery(
        'SELECT i.id_ingreso AS id_ingreso, i.nombre AS nombre, i.monto AS monto, i.descripcion AS descripcion, i.fecha_registro AS fecha_registro, i.fk_id_usuario AS fk_id_usuario, i.fk_id_categoria_ingreso AS fk_id_categoria_ingreso'
            ' FROM ingreso i JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto)'
            ' WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ? ORDER BY i.monto DESC LIMIT ?',
      [datosUsuario['id_usuario'], idPresupuesto, numElementos]
    );
  }

  // Obtener top egresos del usuario indicando cuantos elementos
  Future<List<Map<String, dynamic>>> obtenerTopEgresos(String usuario, int idPresupuesto, int numElementos) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario.isEmpty) {
      // Si el usuario no existe
      return [];
    }

    return await db.rawQuery(
        'SELECT e.id_egreso AS id_egreso, e.nombre AS nombre, e.monto AS monto, e.descripcion AS descripcion, e.fecha_registro AS fecha_registro, e.fk_id_usuario AS fk_id_usuario, e.fk_id_categoria_egreso AS fk_id_categoria_egreso'
            ' FROM egreso e JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto)'
            ' WHERE e.fk_id_usuario = ? AND p.id_presupuesto = ? ORDER BY e.monto DESC LIMIT ?',
        [datosUsuario['id_usuario'], idPresupuesto, numElementos]
    );
  }

  // Obtener lista ingresos del usuario de una categoria
  Future<List<Map<String, dynamic>>> obtenerIngresosCategoria(String usuario, String categoria, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final id_cat = await obtenerIdCategoria('ingreso', categoria, idPresupuesto);

    if(datosUsuario.isEmpty || id_cat==null) {
      // Si el usuario no existe o la categoria no existe
      return [];
    }

    return await db.rawQuery(
      'SELECT i.id_ingreso AS id_ingreso, i.nombre AS nombre, i.monto AS monto, i.descripcion AS descripcion, i.fecha_registro AS fecha_registro, i.fk_id_usuario AS fk_id_usuario, i.fk_id_categoria_ingreso AS fk_id_categoria_ingreso'
          ' FROM ingreso i JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto)'
          ' WHERE i.fk_id_usuario = ? AND i.fk_id_categoria_ingreso = ? AND p.id_presupuesto = ?',
      [datosUsuario['id_usuario'], id_cat, idPresupuesto]
    );
  }

  // Obtener lista egresos del usuario de una categoria
  Future<List<Map<String, dynamic>>> obtenerEgresosCategoria(String usuario, String categoria, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final idCat = await obtenerIdCategoria('egreso', categoria, idPresupuesto);

    if(datosUsuario.isEmpty || idCat==null) {
      // Si el usuario no existe o la categoria no existe
      return [];
    }

    return await db.rawQuery(
        'SELECT e.id_egreso AS id_egreso, e.nombre AS nombre, e.monto AS monto, e.descripcion AS descripcion, e.fecha_registro AS fecha_registro, e.fk_id_usuario AS fk_id_usuario, e.fk_id_categoria_egreso AS fk_id_categoria_egreso'
            ' FROM egreso e JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto)'
            ' WHERE e.fk_id_usuario = ? AND e.fk_id_categoria_egreso = ? AND p.id_presupuesto = ?',
        [datosUsuario['id_usuario'], idCat, idPresupuesto]
    );
  }

  // Eliminar un ingreso de un usuario
  Future<bool> eliminarIngreso(int id_ingreso, String nombreUsuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(nombreUsuario);

    if(datosUsuario.isEmpty) {
      // No se encontro el usuario (no se realiza la eliminacion)
      return false;
    } else {
      try {
        await db.delete(
            'ingreso',
            where: 'id_ingreso = ? AND fk_id_usuario = ?',
            whereArgs: [
              id_ingreso,
              datosUsuario['id_usuario']
            ]
        );
        return true; // se completa operacion
      } catch (e) {
        return false; // no se realiza operacion
      }
    }
  }

  // Eliminar un ingreso de un usuario
  Future<bool> eliminarEgreso(int id_egreso, String nombreUsuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(nombreUsuario);

    if(datosUsuario.isEmpty) {
      // No se encontro el usuario (no se realiza la eliminacion)
      return false;
    } else {
      try {
        await db.delete(
            'egreso',
            where: 'id_egreso = ? AND fk_id_usuario = ?',
            whereArgs: [
              id_egreso,
              datosUsuario['id_usuario']
            ]
        );
        return true; // se completa operacion
      } catch (e) {
        return false; // no se realiza operacion
      }
    }
  }

  // Editar los datos de un ingreso
  Future<bool> editarIngreso(int idIngreso, int fkId_Usuario, String nombreIngreso, double montoIngreso, String descripcionIngreso, String categoria, int idPresupuesto) async {
    final db = await database;
    try {
      int cambios = await db.update(
          'ingreso',
          {
            'nombre': nombreIngreso,
            'monto': montoIngreso,
            'descripcion': descripcionIngreso,
            'fk_id_categoria_ingreso': await obtenerIdCategoria('ingreso', categoria, idPresupuesto) ?? -1
          },
        where: 'id_ingreso = ? AND fk_id_usuario = ?',
        whereArgs: [idIngreso, fkId_Usuario]
      );
      return cambios>0 ? true : false;
    } catch (e) {
      return false;
    }
  }

  // Editar los datos de un egreso
  Future<bool> editarEgreso(int idEgreso, int fkId_Usuario, String nombreEgreso, double montoEgreso, String descripcionEgreso, String categoria, int idPresupuesto) async {
    final db = await database;
    try {
      int cambios = await db.update(
          'egreso',
          {
            'nombre': nombreEgreso,
            'monto': montoEgreso,
            'descripcion': descripcionEgreso,
            'fk_id_categoria_egreso': await obtenerIdCategoria('egreso', categoria, idPresupuesto) ?? -1
          },
          where: 'id_egreso = ? AND fk_id_usuario = ?',
          whereArgs: [idEgreso, fkId_Usuario]
      );
      return cambios>0 ? true : false;
    } catch (e) {
      print("ERRROR: $e");
      return false;
    }
  }

  // Obtener la suma de los ingresos de un usuario
  Future<Decimal> sumarIngresosTodos(String usuario, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const String consulta = 'SELECT SUM(i.monto) AS suma'
            ' FROM ingreso i JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto) WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario'], idPresupuesto]);

        if(sumaTotal.isNotEmpty && sumaTotal.first['suma'] !=null) {
          return Decimal.parse(sumaTotal.first['suma'].toString());
        } else {
          return Decimal.parse('0.0'); // Operacion fallida
        }

      } catch (e) {
        return Decimal.parse('0.0'); // Operacion fallida
      }
    }
  }

  // Obtener la suma de los ingresos de un usuario
  Future<Decimal> sumarEgresosTodos(String usuario, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario.isEmpty) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const String consulta = 'SELECT SUM(e.monto) AS suma'
            ' FROM egreso e JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto) WHERE e.fk_id_usuario = ? AND p.id_presupuesto = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario'], idPresupuesto]);

        if(sumaTotal.isNotEmpty && sumaTotal.first['suma'] !=null) {
          return Decimal.parse(sumaTotal.first['suma'].toString());
        } else {
          return Decimal.parse('0.0'); // Operacion fallida
        }

      } catch (e) {
        return Decimal.parse('0.0'); // Operacion fallida
      }
    }
  }

  // Obtener la suma de los ingresos de un usuario de una categoria
  Future<Decimal> sumarIngresosCategoria(String categoria, String usuario, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final idCat = await obtenerIdCategoria('ingreso', categoria, idPresupuesto);

    if(datosUsuario.isEmpty || idCat==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const consulta = 'SELECT SUM(i.monto) AS suma'
            ' FROM ingreso i JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto)'
            ' WHERE i.fk_id_usuario = ? AND i.fk_id_categoria_ingreso = ? AND p.id_presupuesto = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario'], idCat, idPresupuesto]);

        if(sumaTotal.isNotEmpty && sumaTotal.first['suma'] !=null) {
          return Decimal.parse(sumaTotal.first['suma'].toString());
        } else {
          return Decimal.parse('0.0'); // Operacion fallida
        }

      } catch (e) {
        return Decimal.parse('0.0'); // Operacion fallida
      }
    }
  }

  // Obtener la suma de los ingresos de un usuario de una categoria
  Future<Decimal> sumarEgresosCategoria(String categoria, String usuario, int idPresupuesto) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final idCat = await obtenerIdCategoria('egreso', categoria, idPresupuesto);

    if(datosUsuario==null || idCat==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const consulta = 'SELECT SUM(e.monto) AS suma'
            ' FROM egreso e JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto)'
            ' WHERE e.fk_id_usuario = ? AND e.fk_id_categoria_egreso = ? AND p.id_presupuesto = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario'], idCat, idPresupuesto]);

        if(sumaTotal.isNotEmpty && sumaTotal.first['suma'] !=null) {
          return Decimal.parse(sumaTotal.first['suma'].toString());
        } else {
          return Decimal.parse('0.0'); // Operacion fallida
        }

      } catch (e) {
        return Decimal.parse('0.0'); // Operacion fallida
      }
    }
  }

  // Obtener sumatoria de los ingresos de un dia de la semana de un presupuesto
  Future<double> obtenerSumatoriaIngresosUnDiaPresupuesto(int indiceDia, int idPresupuesto, String nombreUsuario) async {
    /*
    0 -> domingo, 1 -> lunes, 2 -> martes, 3 -> miercoles, 4 ->jueves, 5 ->viernes, 6 -> sabado
     */
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = "SELECT SUM(i.monto) AS suma "
        "FROM ingreso i "
        "JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto) "
        "WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ? AND strftime('%w', substr(i.fecha_registro, 1, 10)) = ?";

    List<Map<String, dynamic>> resultado = await db.rawQuery(
      consulta,
      [datosUsuario['id_usuario'], idPresupuesto, indiceDia]
    );

    return resultado.first['suma'];
  }

  // Obtener sumatoria de los ingresos de los 7 dias de la semana de un presupuesto
  Future<Map<String, dynamic>> obtenerSumatoriaIngresosDiasSemanaPresupuesto(int idPresupuesto, String nombreUsuario) async {
    /*
    0 -> domingo, 1 -> lunes, 2 -> martes, 3 -> miercoles, 4 ->jueves, 5 ->viernes, 6 -> sabado
     */
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = "SELECT "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '0' THEN i.monto ELSE 0 END) AS domingo, "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '1' THEN i.monto ELSE 0 END) AS lunes, "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '2' THEN i.monto ELSE 0 END) AS martes, "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '3' THEN i.monto ELSE 0 END) AS miercoles, "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '4' THEN i.monto ELSE 0 END) AS jueves, "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '5' THEN i.monto ELSE 0 END) AS viernes, "
        "SUM(CASE WHEN strftime('%w', substr(i.fecha_registro, 1, 10)) = '6' THEN i.monto ELSE 0 END) AS sabado "
        "FROM ingreso i "
        "JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto) "
        "WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ?";

    List<Map<String, dynamic>> resultado = await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );

    return resultado.first;
  }

  // Obtener sumatoria de los egresos de los 7 dias de la semana de un presupuesto
  Future<Map<String, dynamic>> obtenerSumatoriaEgresosDiasSemanaPresupuesto(int idPresupuesto, String nombreUsuario) async {
    /*
    0 -> domingo, 1 -> lunes, 2 -> martes, 3 -> miercoles, 4 ->jueves, 5 ->viernes, 6 -> sabado
     */
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = "SELECT "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '0' THEN e.monto ELSE 0 END) AS domingo, "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '1' THEN e.monto ELSE 0 END) AS lunes, "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '2' THEN e.monto ELSE 0 END) AS martes, "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '3' THEN e.monto ELSE 0 END) AS miercoles, "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '4' THEN e.monto ELSE 0 END) AS jueves, "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '5' THEN e.monto ELSE 0 END) AS viernes, "
        "SUM(CASE WHEN strftime('%w', substr(e.fecha_registro, 1, 10)) = '6' THEN e.monto ELSE 0 END) AS sabado "
        "FROM egreso e "
        "JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto) "
        "WHERE e.fk_id_usuario = ? AND p.id_presupuesto = ?";

    List<Map<String, dynamic>> resultado = await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );

    return resultado.first;
  }

  // Obtener sumatoria de los ingresos de los 12 meses del anio de un presupuesto
  Future<Map<String, dynamic>> obtenerSumatoriaIngresosMesesPresupuesto(int idPresupuesto, String nombreUsuario) async {
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = "SELECT "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '01' THEN i.monto ELSE 0 END) AS enero, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '02' THEN i.monto ELSE 0 END) AS febrero, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '03' THEN i.monto ELSE 0 END) AS marzo, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '04' THEN i.monto ELSE 0 END) AS abril, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '05' THEN i.monto ELSE 0 END) AS mayo, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '06' THEN i.monto ELSE 0 END) AS junio, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '07' THEN i.monto ELSE 0 END) AS julio, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '08' THEN i.monto ELSE 0 END) AS agosto, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '09' THEN i.monto ELSE 0 END) AS septiembre, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '10' THEN i.monto ELSE 0 END) AS octubre, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '11' THEN i.monto ELSE 0 END) AS noviembre, "
        "SUM(CASE WHEN strftime('%m', substr(i.fecha_registro, 1, 10)) = '12' THEN i.monto ELSE 0 END) AS diciembre "
        "FROM ingreso i "
        "JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto) "
        "WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ?";

    List<Map<String, dynamic>> resultado = await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );

    return resultado.first;
  }

  // Obtener sumatoria de los egresos de los 12 meses del anio de un presupuesto
  Future<Map<String, dynamic>> obtenerSumatoriaEgresosMesesPresupuesto(int idPresupuesto, String nombreUsuario) async {
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = "SELECT "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '01' THEN e.monto ELSE 0 END) AS enero, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '02' THEN e.monto ELSE 0 END) AS febrero, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '03' THEN e.monto ELSE 0 END) AS marzo, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '04' THEN e.monto ELSE 0 END) AS abril, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '05' THEN e.monto ELSE 0 END) AS mayo, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '06' THEN e.monto ELSE 0 END) AS junio, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '07' THEN e.monto ELSE 0 END) AS julio, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '08' THEN e.monto ELSE 0 END) AS agosto, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '09' THEN e.monto ELSE 0 END) AS septiembre, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '10' THEN e.monto ELSE 0 END) AS octubre, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '11' THEN e.monto ELSE 0 END) AS noviembre, "
        "SUM(CASE WHEN strftime('%m', substr(e.fecha_registro, 1, 10)) = '12' THEN e.monto ELSE 0 END) AS diciembre "
        "FROM egreso e "
        "JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto) "
        "WHERE e.fk_id_usuario = ? AND p.id_presupuesto = ?";

    List<Map<String, dynamic>> resultado = await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );

    return resultado.first;
  }

  // Obtener todos los ingresos de un presupuesto y un usuario
  Future<List<Map<String, dynamic>>> obtenerListadoIngresosTodos(int idPresupuesto, String nombreUsuario) async {
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = """
        SELECT 
          i.id_ingreso AS id_ingreso, 
          i.nombre AS nombre, 
          i.monto AS monto, 
          i.descripcion AS descripcion, 
          i.fecha_registro AS fecha_registro, 
          i.fk_id_usuario AS fk_id_usuario, 
          ci.id_categoria AS id_categoria, 
          ci.nombre AS categoria 
        FROM ingreso i 
        JOIN categoria_ingreso ci ON (i.fk_id_categoria_ingreso = ci.id_categoria) 
        JOIN presupuesto p ON (ci.fk_id_presupuesto = p.id_presupuesto) 
        WHERE i.fk_id_usuario = ? AND p.id_presupuesto = ?
        """;

    return await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );
  }

  // Obtener todos los egresos de un presupuesto y un usuario
  Future<List<Map<String, dynamic>>> obtenerListadoEgresosTodos(int idPresupuesto, String nombreUsuario) async {
    final db = await database;
    final Map<String, dynamic> datosUsuario = await obtenerUsuario(nombreUsuario);

    String consulta = """
        SELECT
          e.id_egreso AS id_egreso, 
          e.nombre AS nombre, 
          e.monto AS monto, 
          e.descripcion AS descripcion, 
          e.fecha_registro AS fecha_registro, 
          e.fk_id_usuario AS fk_id_usuario, 
          ce.id_categoria AS id_categoria, 
          ce.nombre AS categoria 
        FROM egreso e 
        JOIN categoria_egreso ce ON (e.fk_id_categoria_egreso = ce.id_categoria) 
        JOIN presupuesto p ON (ce.fk_id_presupuesto = p.id_presupuesto) 
        WHERE e.fk_id_usuario = ? AND p.id_presupuesto = ?
        """;

    return await db.rawQuery(
        consulta,
        [datosUsuario['id_usuario'], idPresupuesto]
    );
  }


}