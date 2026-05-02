import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/repair_job.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PrintBillScreen extends StatefulWidget {
  const PrintBillScreen({super.key});

  @override
  State<PrintBillScreen> createState() => _PrintBillScreenState();
}

class _PrintBillScreenState extends State<PrintBillScreen> {
  late RepairJob job;
  String billNumber = '';
  bool _isLoading = false;
  final GlobalKey _billKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    job =
        ModalRoute.of(context)?.settings.arguments as RepairJob? ??
        RepairJob(
          id: '',
          customerName: '',
          customerPhone: '',
          mobileModel: '',
          issueDescription: '',
          repairPrice: 0,
          estimatedTime: '',
          receivedAt: DateTime.now(),
          status: 'pending',
          issueTags: [],
        );
    _initBillNumber();
  }

  Future<void> _initBillNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBillNumber = prefs.getInt('lastBillNumber') ?? 0;
    final nextNumber = lastBillNumber + 1;
    setState(() {
      billNumber =
          '${AppConstants.billPrefix}-${nextNumber.toString().padLeft(3, '0')}';
    });
    await prefs.setInt('lastBillNumber', nextNumber);
  }

  Future<void> _captureAndSharePNG() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary =
          _billKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'JTC_Bill_${billNumber.replaceAll('-', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'JTC Lab - Repair Bill');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill shared as PNG! ✅'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndSharePDF() async {
    try {
      setState(() => _isLoading = true);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // Urdu Header
                pw.Text(
                  'جُنید ٹیلی کام ریپیئرنگ لیب',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),

                // English Name
                pw.Text(
                  AppConstants.labFullName,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 12),

                // Contact Info
                pw.Text(
                  '${AppConstants.owner1Name}: ${AppConstants.owner1Phone}',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '${AppConstants.owner2Name}: ${AppConstants.owner2Phone}',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 12),

                // Divider
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Date & Bill Number
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Date',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          AppDateUtils.formatDateShort(DateTime.now()),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Bill',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          billNumber,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Customer Info
                _buildPDFRow('Customer', job.customerName),
                _buildPDFRow('Phone', job.customerPhone),
                if (job.customerCNIC != null)
                  _buildPDFRow('CNIC', job.customerCNIC!),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Device Info
                _buildPDFRow('Device', job.mobileModel),
                pw.Text(
                  'Issue:',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  job.issueDescription,
                  style: const pw.TextStyle(fontSize: 9),
                  maxLines: 3,
                ),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Repair Details
                _buildPDFRow('Estimate', 'Rs. ${job.repairPrice}'),
                _buildPDFRow('Time', job.estimatedTime),
                _buildPDFRow(
                  'Received',
                  AppDateUtils.formatTime(job.receivedAt),
                ),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Notes
                pw.Text(
                  'NOTES',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...AppConstants.billNotes.map((note) {
                  return pw.Text(
                    note,
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  );
                }),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Urdu Address
                pw.Text(
                  'نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),

                pw.SizedBox(height: 12),
                pw.Text(
                  'Thank You! 💙',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save PDF to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'JTC_Bill_${billNumber.replaceAll('-', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'JTC Lab - Repair Bill');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill shared as PDF! 📄'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printBill() async {
    try {
      setState(() => _isLoading = true);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          pdf.addPage(
            pw.Page(
              pageFormat: format,
              build: (pw.Context context) {
                return pw.Column(
                  children: [
                    // Urdu Header
                    pw.Text(
                      'جُنید ٹیلی کام ریپیئرنگ لیب',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    // English Name
                    pw.Text(
                      AppConstants.labFullName,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 12),

                    // Contact Info
                    pw.Text(
                      '${AppConstants.owner1Name}: ${AppConstants.owner1Phone}',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      '${AppConstants.owner2Name}: ${AppConstants.owner2Phone}',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 12),

                    // Divider
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 8),

                    // Date & Bill Number
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Date',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              AppDateUtils.formatDateShort(DateTime.now()),
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Bill',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              billNumber,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 8),

                    // Customer Info
                    _buildPDFRow('Customer', job.customerName),
                    _buildPDFRow('Phone', job.customerPhone),
                    if (job.customerCNIC != null)
                      _buildPDFRow('CNIC', job.customerCNIC!),

                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 8),

                    // Device Info
                    _buildPDFRow('Device', job.mobileModel),
                    pw.Text(
                      'Issue:',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      job.issueDescription,
                      style: const pw.TextStyle(fontSize: 9),
                      maxLines: 3,
                    ),

                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 8),

                    // Repair Details
                    _buildPDFRow('Estimate', 'Rs. ${job.repairPrice}'),
                    _buildPDFRow('Time', job.estimatedTime),
                    _buildPDFRow(
                      'Received',
                      AppDateUtils.formatTime(job.receivedAt),
                    ),

                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 8),

                    // Notes
                    pw.Text(
                      'NOTES',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    ...AppConstants.billNotes.map((note) {
                      return pw.Text(
                        note,
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      );
                    }),

                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 8),

                    // Urdu Address
                    pw.Text(
                      'نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 10),
                    ),

                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Thank You! 💙',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
          return await pdf.save();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error printing: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Preview & Share'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bill Preview Card
            Card(
              elevation: 8,
              shadowColor: Colors.blue.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: RepaintBoundary(
                key: _billKey,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Urdu Header - جُنید ٹیلی کام ریپیئرنگ لیب
                      Text(
                        'جُنید ٹیلی کام ریپیئرنگ لیب',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoNastaliqUrdu(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // English Name
                      Text(
                        AppConstants.labFullName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Contact Info
                      Text(
                        '${AppConstants.owner1Name}: ${AppConstants.owner1Phone}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 9),
                      ),
                      Text(
                        '${AppConstants.owner2Name}: ${AppConstants.owner2Phone}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 9),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        height: 1.5,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      // Date & Bill Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                AppDateUtils.formatDateShort(DateTime.now()),
                                style: GoogleFonts.poppins(fontSize: 8),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Bill',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                billNumber,
                                style: GoogleFonts.poppins(fontSize: 8),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Container(
                        height: 1.5,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      // Customer Info
                      _buildBillRow('Customer', job.customerName),
                      _buildBillRow('Phone', job.customerPhone),
                      if (job.customerCNIC != null)
                        _buildBillRow('CNIC', job.customerCNIC!),

                      Container(
                        height: 1.5,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      // Device Info
                      _buildBillRow('Device', job.mobileModel),
                      _buildBillMultilineRow('Issue', job.issueDescription),

                      Container(
                        height: 1.5,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      // Repair Details
                      _buildBillRow('Estimate', 'Rs. ${job.repairPrice}'),
                      _buildBillRow('Time', job.estimatedTime),
                      _buildBillRow(
                        'Received',
                        AppDateUtils.formatTime(job.receivedAt),
                      ),

                      Container(
                        height: 1.5,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      // Notes
                      Text(
                        'NOTES',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      ...AppConstants.billNotes.map((note) {
                        return Text(
                          note,
                          style: GoogleFonts.poppins(fontSize: 7),
                          textAlign: TextAlign.center,
                        );
                      }),

                      Container(
                        height: 1.5,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      // Urdu Address - نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ
                      Text(
                        'نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoNastaliqUrdu(fontSize: 10),
                      ),
                      const SizedBox(height: 10),

                      // Thank You
                      Text(
                        'Thank You! 💙',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  // Print Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _printBill,
                    icon: const Icon(Icons.print),
                    label: const Text('Print Bill'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Share as PNG Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _captureAndSharePNG,
                    icon: const Icon(Icons.image),
                    label: const Text('Share as PNG Image'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Share as PDF Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _generateAndSharePDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Share as PDF'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Done Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 8),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillMultilineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 8),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
