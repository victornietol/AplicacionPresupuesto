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

          // tabla categoria egresos
          await txn.execute('''
            CREATE TABLE categoria_egreso (
              id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE
            )
          ''');

          // tabla categoria ingresos
          await txn.execute('''
            CREATE TABLE categoria_ingreso (
              id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE
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
              FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
              FOREIGN KEY (fk_id_categoria_ingreso) REFERENCES categoria_ingreso(id_categoria) ON DELETE CASCADE
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
              FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
              FOREIGN KEY (fk_id_categoria_egreso) REFERENCES categoria_egreso(id_categoria) ON DELETE CASCADE
            )
          ''');

          // Insertar usuario generico
          await txn.insert('usuario',
              {'nombre':'generico',
                'password': 'generico',
                'fecha_registro': DateTime.now().toIso8601String()
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

  // Obtener id de la categoria ingreso
  Future<int?> obtenerIdCategoria(String tipo, String categoria) async {
    final db = await database;

    final datosCategoria = await db.query(
        'categoria_$tipo',
        where: 'nombre = ?',
        whereArgs: [categoria],
        columns: ['id_categoria']
    );

    if(datosCategoria.isNotEmpty) {
      return datosCategoria[0]['id_categoria'] as int?;
    } else {
      return null; // no se encontro categoria
    }
  }

  // Obtener el listado de categorias
  Future<List<Map<String, dynamic>>> obtenerCategorias(String tipo) async {
    final db = await database;
    if(tipo=='ingreso') {
      return db.query('categoria_ingreso');
    } else if(tipo=='egreso') {
      return db.query('categoria_egreso');
    } else {
      return []; // Categoria incorrecta
    }
  }

  // Insertar categoria
  Future<bool> insertarCategoria(String nombre, String tipo) async {
    final db = await database;
    int insercion = 0;

    if(tipo=='ingreso') {
      insercion = await db.insert(
          'categoria_ingreso', // tabla
          {'nombre': nombre} // campo
      );
    } else if(tipo=='egreso') {
      insercion = await db.insert(
          'categoria_egreso', // tabla
          {'nombre': nombre} // campo
      );
    } else {
      return false; // No se realizo insercion
    }
    return insercion>0 ? true : false;
  }

  // Eliminar categoria
  Future<bool> eliminarCategoria(String nombre, String tipo) async {
    final db = await database;
    int eliminacion = 0;

    if(tipo=='ingreso') {
      eliminacion = await db.delete('categoria_ingreso', where: 'nombre = ?', whereArgs: [nombre]);
    } else if(tipo=='egreso') {
      eliminacion = await db.delete('categoria_egreso', where: 'nombre = ?', whereArgs: [nombre]);
    } else {
      return false; // No se realizo insercion
    }
    return eliminacion>0 ? true : false;
  }

  // Obtener lista ingresos del usuario
  Future<List<Map<String, dynamic>>> obtenerIngresosTodos(String usuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario == null) {
      // Si el usuario no existe
      return [];
    }

    return await db.query(
      'ingreso',
      where: 'fk_id_usuario = ?',
      whereArgs: [datosUsuario['id_usuario']]
    );
  }

  // Obtener lista egresos del usuario
  Future<List<Map<String, dynamic>>> obtenerEgresosTodos(String usuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario == null) {
      // Si el usuario no existe
      return [];
    }

    return await db.query(
        'egreso',
        where: 'fk_id_usuario = ?',
        whereArgs: [datosUsuario['id_usuario']]
    );
  }

  // Obtener top ingresos del usuario indicando cuantos elementos
  Future<List<Map<String, dynamic>>> obtenerTopIngresos(String usuario, int numElementos) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario == null) {
      // Si el usuario no existe
      return [];
    }

    return await db.rawQuery(
        'SELECT * FROM ingreso WHERE fk_id_usuario = ? ORDER BY monto DESC LIMIT ?',
      [datosUsuario['id_usuario'], numElementos]
    );
  }

  // Obtener top egresos del usuario indicando cuantos elementos
  Future<List<Map<String, dynamic>>> obtenerTopEgresos(String usuario, int numElementos) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario == null) {
      // Si el usuario no existe
      return [];
    }

    return await db.rawQuery(
        'SELECT * FROM egreso WHERE fk_id_usuario = ? ORDER BY monto DESC LIMIT ?',
        [datosUsuario['id_usuario'], numElementos]
    );
  }

  // Obtener lista ingresos del usuario de una categoria
  Future<List<Map<String, dynamic>>> obtenerIngresosCategoria(String usuario, String categoria) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final id_cat = await obtenerIdCategoria('ingreso', categoria);

    if(datosUsuario==null || id_cat==null) {
      // Si el usuario no existe o la categoria no existe
      return [];
    }

    return await db.query(
        'ingreso',
        where: 'fk_id_usuario = ? AND fk_id_categoria_ingreso = ?',
        whereArgs: [
          datosUsuario['id_usuario'],
          id_cat
        ]
    );
  }

  // Obtener lista egresos del usuario de una categoria
  Future<List<Map<String, dynamic>>> obtenerEgresosCategoria(String usuario, String categoria) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final idCat = await obtenerIdCategoria('egreso', categoria);

    if(datosUsuario==null || idCat==null) {
      // Si el usuario no existe o la categoria no existe
      return [];
    }

    return await db.query(
        'egreso',
        where: 'fk_id_usuario = ? AND fk_id_categoria_egreso = ?',
        whereArgs: [
          datosUsuario['id_usuario'],
          idCat
        ]
    );
  }

  // Eliminar un ingreso de un usuario
  Future<bool> eliminarIngreso(int id_ingreso, String nombreUsuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(nombreUsuario);

    if(datosUsuario==null) {
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

    if(datosUsuario==null) {
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
  Future<bool> editarIngreso(int idIngreso, int fkId_Usuario, String nombreIngreso, double montoIngreso, String descripcionIngreso, String categoria) async {
    final db = await database;
    try {
      int cambios = await db.update(
          'ingreso',
          {
            'nombre': nombreIngreso,
            'monto': montoIngreso,
            'descripcion': descripcionIngreso,
            'fk_id_categoria_ingreso': await obtenerIdCategoria('ingreso', categoria) ?? -1
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
  Future<bool> editarEgreso(int idEgreso, int fkId_Usuario, String nombreEgreso, double montoEgreso, String descripcionEgreso, String categoria) async {
    final db = await database;
    try {
      int cambios = await db.update(
          'egreso',
          {
            'nombre': nombreEgreso,
            'monto': montoEgreso,
            'descripcion': descripcionEgreso,
            'fk_id_categoria_egreso': await obtenerIdCategoria('egreso', categoria) ?? -1
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
  Future<Decimal> sumarIngresosTodos(String usuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const consulta = 'SELECT SUM(monto) AS suma FROM ingreso WHERE fk_id_usuario = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario']]);

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
  Future<Decimal> sumarEgresosTodos(String usuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);

    if(datosUsuario==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const consulta = 'SELECT SUM(monto) AS suma FROM egreso WHERE fk_id_usuario = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario']]);

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
  Future<Decimal> sumarIngresosCategoria(String categoria, String usuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final idCat = await obtenerIdCategoria('ingreso', categoria);

    if(datosUsuario==null || idCat==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const consulta = 'SELECT SUM(monto) AS suma FROM ingreso WHERE fk_id_usuario = ? AND fk_id_categoria_ingreso = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario'], idCat]);

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
  Future<Decimal> sumarEgresosCategoria(String categoria, String usuario) async {
    final db = await database;
    final datosUsuario = await obtenerUsuario(usuario);
    final idCat = await obtenerIdCategoria('egreso', categoria);

    if(datosUsuario==null || idCat==null) {
      return Decimal.parse('0.0'); // El usuario no existe
    } else {
      try {
        const consulta = 'SELECT SUM(monto) AS suma FROM egreso WHERE fk_id_usuario = ? AND fk_id_categoria_egreso = ?';
        final List<Map<String, dynamic>> sumaTotal = await db.rawQuery(consulta, [datosUsuario['id_usuario'], idCat]);

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

}