import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/alumno.dart';

class PdfService {
  static const String responsable = 'Belen Velasco';
  static Future<void> generarReporte({
    required List<Alumno> alumnos,
    required Set<int> alumnosSeleccionados,
  }) async {
    final pdf = pw.Document();

    final niveles = ['PRIMARIA', 'SECUNDARIA', 'PREPARATORIA'];

    final ahora = DateTime.now();

    final fecha =
        '${ahora.day.toString().padLeft(2, '0')}/'
        '${ahora.month.toString().padLeft(2, '0')}/'
        '${ahora.year}';

    for (final nivel in niveles) {
      final alumnosDelNivel = alumnos
          .where(
            (alumno) =>
                alumno.nivel == nivel &&
                alumno.id != null &&
                alumnosSeleccionados.contains(alumno.id),
          )
          .toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(35),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Center(
                  child: pw.Text(
                    'TRANSPORTE ESCOLAR JAIXOT',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 6),

                pw.Center(
                  child: pw.Text(
                    'RUTA ZUMPANGO - REYES',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 15),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Fecha: $fecha',
                      style: const pw.TextStyle(fontSize: 11),
                    ),

                    pw.Text(
                      'Nivel: $nivel',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Línea divisoria
                pw.Divider(),

                pw.SizedBox(height: 15),

                if (alumnosDelNivel.isEmpty)
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 40),
                      child: pw.Text(
                        'No hay alumnos programados '
                        'para transporte.',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                else
                  pw.TableHelper.fromTextArray(
                    headers: ['ALUMNO', 'GRADO', 'DIRECCIÓN'],
                    data: alumnosDelNivel.map((alumno) {
                      return [alumno.nombre, alumno.grado, alumno.direccion];
                    }).toList(),
                    border: pw.TableBorder.all(width: 0.8),
                    headerStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    cellPadding: const pw.EdgeInsets.all(7),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1.2),
                      2: const pw.FlexColumnWidth(3),
                    },
                  ),

                pw.SizedBox(height: 20),

                pw.Divider(),

                pw.SizedBox(height: 10),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total: ${alumnosDelNivel.length} '
                    'alumno${alumnosDelNivel.length == 1 ? '' : 's'}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 25),

                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Asistente de transporte',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.SizedBox(height: 18),

                      pw.Text(
                        responsable,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    //await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Lista de asistencia Ruta Zumpango - Reyes.pdf',
    );
  }
}
