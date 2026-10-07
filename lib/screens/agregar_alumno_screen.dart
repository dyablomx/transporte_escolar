import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/alumno.dart';

class AgregarAlumnoScreen extends StatefulWidget {
  final Alumno? alumno;

  const AgregarAlumnoScreen({super.key, this.alumno});

  @override
  State<AgregarAlumnoScreen> createState() => _AgregarAlumnoScreenState();
}

class _AgregarAlumnoScreenState extends State<AgregarAlumnoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _gradoController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final alumno = widget.alumno;

    if (alumno != null) {
      _nombreController.text = alumno.nombre;
      _gradoController.text = alumno.grado;
      _direccionController.text = alumno.direccion;

      _nivelSeleccionado = alumno.nivel;
    }
  }

  String _nivelSeleccionado = 'PRIMARIA';

  @override
  void dispose() {
    _nombreController.dispose();
    _gradoController.dispose();
    _direccionController.dispose();

    super.dispose();
  }

  Future<void> _guardarAlumno() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final alumno = Alumno(
      id: widget.alumno?.id,
      nombre: _nombreController.text.trim(),
      nivel: _nivelSeleccionado,
      grado: _gradoController.text.trim(),
      direccion: _direccionController.text.trim(),
    );

    if (widget.alumno == null) {
      await DatabaseHelper.instance.insertarAlumno(alumno);
    } else {
      await DatabaseHelper.instance.actualizarAlumno(alumno);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alumno == null ? 'Agregar alumno' : 'Editar alumno'),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del alumno',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Escribe el nombre del alumno';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _nivelSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Nivel',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'PRIMARIA', child: Text('PRIMARIA')),
                DropdownMenuItem(
                  value: 'SECUNDARIA',
                  child: Text('SECUNDARIA'),
                ),
                DropdownMenuItem(
                  value: 'PREPARATORIA',
                  child: Text('PREPARATORIA'),
                ),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _nivelSeleccionado = valor;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _gradoController,
              decoration: const InputDecoration(
                labelText: 'Grado',
                hintText: 'Ejemplo: 6°',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Escribe el grado';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _direccionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Escribe la dirección';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _guardarAlumno,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.alumno == null ? 'GUARDAR ALUMNO' : 'GUARDAR CAMBIOS',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
