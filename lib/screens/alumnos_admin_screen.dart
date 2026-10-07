import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/alumno.dart';
import 'agregar_alumno_screen.dart';

class AlumnosAdminScreen extends StatefulWidget {
  const AlumnosAdminScreen({super.key});

  @override
  State<AlumnosAdminScreen> createState() => _AlumnosAdminScreenState();
}

class _AlumnosAdminScreenState extends State<AlumnosAdminScreen> {
  List<Alumno> alumnos = [];

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  Future<void> _cargarAlumnos() async {
    final alumnosGuardados = await DatabaseHelper.instance.obtenerAlumnos();

    if (!mounted) return;

    setState(() {
      alumnos = alumnosGuardados;
    });
  }

  Future<void> _agregarAlumno() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarAlumnoScreen()),
    );

    if (resultado == true) {
      await _cargarAlumnos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar alumnos')),

      body: alumnos.isEmpty
          ? const Center(child: Text('No hay alumnos registrados.'))
          : ListView.builder(
              itemCount: alumnos.length,
              itemBuilder: (context, index) {
                final alumno = alumnos[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(alumno.nombre.substring(0, 1).toUpperCase()),
                  ),

                  title: Text(alumno.nombre),

                  subtitle: Text(
                    '${alumno.nivel} · ${alumno.grado}\n'
                    '${alumno.direccion}',
                  ),

                  isThreeLine: true,

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AgregarAlumnoScreen(alumno: alumno),
                            ),
                          );

                          if (resultado == true) {
                            await _cargarAlumnos();
                          }
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Eliminar alumno'),
                                content: Text(
                                  '¿Deseas eliminar a ${alumno.nombre}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('CANCELAR'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('ELIMINAR'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmar != true) {
                            return;
                          }

                          await DatabaseHelper.instance.eliminarAlumno(
                            alumno.id!,
                          );

                          await _cargarAlumnos();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _agregarAlumno,
        child: const Icon(Icons.add),
      ),
    );
  }
}
