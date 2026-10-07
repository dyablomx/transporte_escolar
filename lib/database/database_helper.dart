import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/alumno.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'transporte_escolar.db');

    return await openDatabase(path, version: 1, onCreate: _crearBaseDeDatos);
  }

  Future<void> _crearBaseDeDatos(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alumnos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        nivel TEXT NOT NULL,
        grado TEXT NOT NULL,
        direccion TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertarAlumno(Alumno alumno) async {
    final db = await database;

    return await db.insert('alumnos', {
      'nombre': alumno.nombre,
      'nivel': alumno.nivel,
      'grado': alumno.grado,
      'direccion': alumno.direccion,
    });
  }

  Future<List<Alumno>> obtenerAlumnos() async {
    final db = await database;

    final resultado = await db.query('alumnos', orderBy: 'nombre ASC');

    return resultado.map((fila) {
      return Alumno(
        id: fila['id'] as int,
        nombre: fila['nombre'] as String,
        nivel: fila['nivel'] as String,
        grado: fila['grado'] as String,
        direccion: fila['direccion'] as String,
      );
    }).toList();
  }

  Future<int> actualizarAlumno(Alumno alumno) async {
    final db = await database;

    return await db.update(
      'alumnos',
      {
        'nombre': alumno.nombre,
        'nivel': alumno.nivel,
        'grado': alumno.grado,
        'direccion': alumno.direccion,
      },
      where: 'id = ?',
      whereArgs: [alumno.id],
    );
  }

  Future<int> eliminarAlumno(int id) async {
    final db = await database;

    return await db.delete('alumnos', where: 'id = ?', whereArgs: [id]);
  }
}
