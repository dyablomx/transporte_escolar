import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  TimeOfDay horaRecordatorio = const TimeOfDay(hour: 12, minute: 0);
  Future<void> _cargarHoraGuardada() async {
    final hora = await NotificationService.obtenerHoraRecordatorio();
    final minuto = await NotificationService.obtenerMinutoRecordatorio();

    if (!mounted) return;

    setState(() {
      horaRecordatorio = TimeOfDay(hour: hora, minute: minuto);
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarHoraGuardada();
  }

  Future<void> _seleccionarHora() async {
    final nuevaHora = await showTimePicker(
      context: context,
      initialTime: horaRecordatorio,
    );

    if (nuevaHora == null) {
      return;
    }

    setState(() {
      horaRecordatorio = nuevaHora;
    });

    await NotificationService.guardarHoraRecordatorio(
      hora: nuevaHora.hour,
      minuto: nuevaHora.minute,
    );

    await NotificationService.programarRecordatorio(
      hora: nuevaHora.hour,
      minuto: nuevaHora.minute,
    );

    //final horaGuardada = await NotificationService.obtenerHoraRecordatorio();

    //final minutoGuardado =
    //await NotificationService.obtenerMinutoRecordatorio();

    //print('Hora guardada: $horaGuardada:$minutoGuardado');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recordatorio configurado para las '
          '${nuevaHora.format(context)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recordatorio diario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Selecciona la hora en la que deseas recibir '
              'el recordatorio para llenar el formato diario.',
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Hora del recordatorio'),
              subtitle: Text(horaRecordatorio.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _seleccionarHora,
            ),
          ],
        ),
      ),
    );
  }
}
