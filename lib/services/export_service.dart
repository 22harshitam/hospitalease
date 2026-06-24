import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';

class ExportService {
  static Future<void> generateAppointmentPdf(Appointment appointment) async {
    final pdf = pw.Document();

    final doctor = appointment.doctor;
    final patient = appointment.patientDetails;
    final dateStr = DateFormat('EEEE, d MMM yyyy').format(appointment.date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('HospitalEasy Appointment Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Token: ${appointment.token}', style: pw.TextStyle(fontSize: 18, color: PdfColors.blue700)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),
                
                pw.Text('Doctor Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text('Name: ${doctor.name}'),
                pw.Text('Specialization: ${doctor.specialization}'),
                pw.Text('Experience: ${doctor.experience}'),
                pw.Text('Consultation Fee: INR ${doctor.consultationFee}'),
                
                pw.SizedBox(height: 24),
                
                pw.Text('Appointment Schedule', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text('Date: $dateStr'),
                pw.Text('Time: ${appointment.timeSlot}'),
                pw.Text('Status: ${appointment.status}'),
                
                pw.SizedBox(height: 24),
                
                pw.Text('Patient Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text('Name: ${patient.name}'),
                pw.Text('Age: ${patient.age}'),
                pw.Text('Phone: ${patient.phone}'),
                if (patient.email != null && patient.email!.isNotEmpty) pw.Text('Email: ${patient.email}'),
                if (patient.symptoms != null && patient.symptoms!.isNotEmpty) pw.Text('Symptoms: ${patient.symptoms}'),
                
                pw.Spacer(),
                pw.Center(
                  child: pw.Text('Thank you for choosing HospitalEasy.', style: const pw.TextStyle(color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Appointment_${appointment.token}.pdf',
    );
  }

  static Future<void> shareToken(Appointment appointment) async {
    final doctor = appointment.doctor;
    final dateStr = DateFormat('EEE, d MMM').format(appointment.date);
    
    final message = '''
HospitalEasy Appointment Confirmed!
----------------------------------
Doctor: ${doctor.name} (${doctor.specialization})
Date: $dateStr at ${appointment.timeSlot}
Token: ${appointment.token}

Patient: ${appointment.patientDetails.name}
----------------------------------
Please show this token at the reception.
''';

    await Share.share(message, subject: 'My Appointment Token: ${appointment.token}');
  }
}
