import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
        // tabla usuario
        await db.execute('''
          CREATE TABLE usuario (
            id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            password TEXT NOT NULL,
            fecha_registro TEXT NOT NULL
          )
        ''');

        // tabla categoria egresos
        await db.execute('''
          CREATE TABLE categoria_egreso (
            id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL
          )
        ''');

        // tabla categoria ingresos
        await db.execute('''
          CREATE TABLE categoria_ingreso (
            id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL
          )
        ''');

        // tabla ingreso
        await db.execute('''
          CREATE TABLE ingreso (
            id_ingreso INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            monto REAL NOT NULL,
            descripcion TEXT NULL,
            fecha_registro TEXT NOT NULL,
            fk_id_usuario INTEGER,
            fk_id_categoria_ingreso INTEGER,
            FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
            FOREIGN KEY (fk_id_categoria) REFERENCES categoria_ingreso(id_categoria) ON DELETE CASCADE
          )
        ''');

        // tabla egresos
        await db.execute('''
          CREATE TABLE egreso (
            id_egreso INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            monto REAL NOT NULL,
            descripcion TEXT NULL,
            fecha_registro TEXT NOT NULL,
            fk_id_usuario INTEGER,
            fk_id_categoria_egreso INTEGER,
            FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
            FOREIGN KEY (fk_id_categoria) REFERENCES categoria_egreso(id_categoria) ON DELETE CASCADE
          )
        ''');

        // Valores iniciales
        List<Map<String, dynamic>> ingresos = [
          {'nombre': 'ingreso fijo'},
          {'nombre': 'ingreso variable'}
        ];

        List<Map<String, dynamic>> egresos = [
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

        // Inserciones de valores iniciales
        await db.transaction((txn) async {
          // Insertar usuario generico
          await txn.insert('usuario',
              {'nombre':'generico',
                'password': 'generico',
                'fecha_registro': DateTime.now().toIso8601String()
              }
          );

          // Insertar categorias ingresos
          for(var ingreso in ingresos) {
            await txn.insert('ingreso', ingreso);
          }

          // Insertar categorias egresos
          for(var egreso in egresos) {
            await txn.insert('egreso', egreso);
          }
        });
      }
    );
  }

  // Insertar ingreso


}