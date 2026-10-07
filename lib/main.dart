import 'package:flutter/material.dart';
import 'models/alumno.dart';
import 'screens/alumnos_admin_screen.dart';
import 'database/database_helper.dart';
import 'services/pdf_service.dart';
import 'services/notification_service.dart';
import 'screens/configuracion_screen.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.inicializar();
  await NotificationService.solicitarPermisos();
  await NotificationService.programarRecordatorio();
  final hora = await NotificationService.obtenerHoraRecordatorio();
  final minuto = await NotificationService.obtenerMinutoRecordatorio();

  await NotificationService.programarRecordatorio(hora: hora, minuto: minuto);

  NotificationService.alTocarNotificacion = () {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const GruposScreen()),
    );
  };

  runApp(const TransporteEscolarApp());
}

class TransporteEscolarApp extends StatelessWidget {
  const TransporteEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Transporte Escolar JAIXOT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 84, 12, 90),
        ),
        useMaterial3: true,
      ),
      //home: GruposScreen(),
      home: const SplashScreen(),
    );
  }
}

//pantalla uno: index
class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});

  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  final List<String> grupos = const ['PRIMARIA', 'SECUNDARIA', 'PREPARATORIA'];

  List<Alumno> alumnos = [];
  bool cargando = true;

  TimeOfDay horaRecordatorio = const TimeOfDay(hour: 12, minute: 0);

  final Set<int> alumnosSeleccionados = {};

  @override
  void initState() {
    super.initState();

    _cargarAlumnos();
    _cargarHoraRecordatorio();
  }

  Future<void> _cargarAlumnos() async {
    final alumnosGuardados = await DatabaseHelper.instance.obtenerAlumnos();

    if (!mounted) return;

    setState(() {
      alumnos = alumnosGuardados;
      cargando = false;
    });
  }

  Future<void> _cargarHoraRecordatorio() async {
    final hora = await NotificationService.obtenerHoraRecordatorio();
    final minuto = await NotificationService.obtenerMinutoRecordatorio();

    if (!mounted) return;

    setState(() {
      horaRecordatorio = TimeOfDay(hour: hora, minute: minuto);
    });
  }

  Future<void> _generarPdf() async {
    if (alumnosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay alumnos seleccionados para generar el reporte.',
          ),
        ),
      );

      return;
    }

    await PdfService.generarReporte(
      alumnos: alumnos,
      alumnosSeleccionados: alumnosSeleccionados,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transporte escolar JAIXOT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Ruta Zumpango - Reyes', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, index) {
                final grupo = grupos[index];

                final cantidad = alumnos
                    .where((alumno) => alumno.nivel == grupo)
                    .length;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.directions_bus,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    title: Text(
                      grupo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('$cantidad alumnos registrados'),
                    ),

                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlumnosScreen(
                            nivel: grupo,
                            alumnos: alumnos,
                            alumnosSeleccionados: alumnosSeleccionados,
                            onSeleccionCambio: (id, seleccionado) {
                              setState(() {
                                if (seleccionado) {
                                  alumnosSeleccionados.add(id);
                                } else {
                                  alumnosSeleccionados.remove(id);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _generarPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generar PDF'),
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlumnosAdminScreen(),
                ),
              );

              await _cargarAlumnos();
            },
            icon: const Icon(Icons.people),
            label: const Text('Administrar alumnos'),
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfiguracionScreen(),
                ),
              );

              await _cargarHoraRecordatorio();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configuración'),
          ),
        ],
      ),
    );
  }
}

// Pantalla dos: AlumnosScreen
class AlumnosScreen extends StatefulWidget {
  final String nivel;
  final List<Alumno> alumnos;

  final Set<int> alumnosSeleccionados;

  final void Function(int id, bool seleccionado) onSeleccionCambio;

  const AlumnosScreen({
    super.key,
    required this.nivel,
    required this.alumnos,
    required this.alumnosSeleccionados,
    required this.onSeleccionCambio,
  });

  @override
  State<AlumnosScreen> createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  //final Set<String> asistentes = {};

  @override
  Widget build(BuildContext context) {
    final alumnosDelNivel = widget.alumnos
        .where((alumno) => alumno.nivel == widget.nivel)
        .toList();

    final todosSeleccionados =
        alumnosDelNivel.isNotEmpty &&
        alumnosDelNivel.every(
          (alumno) =>
              alumno.id != null &&
              widget.alumnosSeleccionados.contains(alumno.id),
        );

    return Scaffold(
      appBar: AppBar(title: Text(widget.nivel)),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: alumnosDelNivel.length,

              itemBuilder: (context, index) {
                final alumno = alumnosDelNivel[index];

                final estaSeleccionado =
                    alumno.id != null &&
                    widget.alumnosSeleccionados.contains(alumno.id);

                return ListTile(
                  title: Text(alumno.nombre),

                  subtitle: Text(
                    'Dirección: ${alumno.direccion} | Grado: ${alumno.grado}',
                  ),

                  trailing: Checkbox(
                    value: estaSeleccionado,
                    onChanged: (valor) {
                      if (alumno.id == null) {
                        return;
                      }

                      widget.onSeleccionCambio(alumno.id!, valor == true);

                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    if (todosSeleccionados) {
                      for (final alumno in alumnosDelNivel) {
                        if (alumno.id != null) {
                          widget.onSeleccionCambio(alumno.id!, false);
                        }
                      }
                    } else {
                      for (final alumno in alumnosDelNivel) {
                        if (alumno.id != null) {
                          widget.onSeleccionCambio(alumno.id!, true);
                        }
                      }
                    }

                    setState(() {});
                  },

                  child: Text(
                    todosSeleccionados ? 'DESMARCAR TODOS' : 'MARCAR TODOS',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
