import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/repair_job.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' hide TextDirection;

// 58mm thermal printer: 58mm width, ~164 dots/line at 8 dots/mm
// In logical pixels at ~2.625 dp/mm => 58mm * 2.625 ≈ 152 dp
// We use a slightly larger value for screen readability: 210 dp
const double _kThermalWidth = 210.0;

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
    job = ModalRoute.of(context)?.settings.arguments as RepairJob? ??
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

  // ─── Capture & Share bill image (WhatsApp / any app) ───────────────────────
  Future<void> _captureAndShareImage() async {
    try {
      setState(() => _isLoading = true);

      // Wait for the current frame to be fully painted before capturing.
      await WidgetsBinding.instance.endOfFrame;

      if (!mounted) return;

      final boundary =
          _billKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find RepaintBoundary. Try again.');
      }

      // Capture at high resolution for crisp sharing.
      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to encode image.');

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temp directory.
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'JTC_Bill_${billNumber.replaceAll('-', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Open share sheet — user can pick WhatsApp or any app.
      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Repair Bill – $billNumber',
        text: '🔧 *${AppConstants.labFullName}*\n'
            'Bill: $billNumber\n'
            'Customer: ${job.customerName}\n'
            'Amount: PKR ${job.repairPrice}',
      );

      if (!mounted) return;
      final msg = result.status == ShareResultStatus.success
          ? 'Bill shared successfully ✅'
          : result.status == ShareResultStatus.dismissed
              ? 'Share cancelled'
              : 'Bill image ready 📷';
      ScaffoldMessenger.of(context) // ignore: use_build_context_synchronously
          .showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context) // ignore: use_build_context_synchronously
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Print Bill placeholder (Bluetooth printing via share) ─────────────────
  // Note: actual Bluetooth printing is handled by the share sheet above.
  void _onPrintPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '💡 Tip: Share the bill image and choose your Bluetooth printer app.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _calculateReadyTime(DateTime received, String estimatedTime) {
    DateTime readyTime = received;
    String formattedTime(DateTime time) {
      final hour =
          time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour < 12 ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    }

    if (estimatedTime == '1 Hour') {
      readyTime = received.add(const Duration(hours: 1));
      return formattedTime(readyTime);
    } else if (estimatedTime == '2 Hours') {
      readyTime = received.add(const Duration(hours: 2));
      return formattedTime(readyTime);
    } else if (estimatedTime == '3 Hours') {
      readyTime = received.add(const Duration(hours: 3));
      return formattedTime(readyTime);
    } else if (estimatedTime == 'Same Day') {
      return 'Today by 8:00 PM';
    } else if (estimatedTime == 'Tomorrow') {
      readyTime = received.add(const Duration(days: 1));
      return '${DateFormat('EEEE').format(readyTime)} ${formattedTime(readyTime)}';
    } else if (estimatedTime == 'Day After Tomorrow') {
      readyTime = received.add(const Duration(days: 2));
      return '${DateFormat('EEEE').format(readyTime)} ${formattedTime(readyTime)}';
    } else if (estimatedTime == '2 Days') {
      readyTime = received.add(const Duration(days: 2));
      return formattedTime(readyTime);
    } else if (estimatedTime == '1 Week') {
      readyTime = received.add(const Duration(days: 7));
      return '${DateFormat('EEEE').format(readyTime)} ${formattedTime(readyTime)}';
    }
    return estimatedTime;
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: Text(
          'Bill Preview',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // ── Thermal Receipt Label ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Text(
                  '58mm Thermal Receipt Preview',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── The Receipt itself ───────────────────────────────────────────
            Center(
              child: RepaintBoundary(
                key: _billKey,
                child: Container(
                  width: _kThermalWidth,
                  // Slight paper-curl shadow for realism
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF7), // thermal paper off-white
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(6, 0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── SHOP NAME ─────────────────────────────────────────
                      Text(
                        'جنید ٹیلی کام ریپئرنگ لیب',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'AA Sameer Qamri Regular',
                          fontFamilyFallback: [
                            'Jameel Noori Nastaleeq',
                            'Noto Nastaliq Urdu'
                          ],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mobile Repair Specialist',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 7.5,
                          color: const Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppConstants.owner1Name}: ${AppConstants.owner1Phone}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 7.5,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Text(
                        '${AppConstants.owner2Name}: ${AppConstants.owner2Phone}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 7.5,
                          color: const Color(0xFF333333),
                        ),
                      ),

                      const SizedBox(height: 6),
                      _thermalDashedLine(),
                      const SizedBox(height: 5),

                      // ── BILL META ─────────────────────────────────────────
                      _thermalRow('Bill No.', billNumber, bold: true),
                      _thermalRow(
                        'Date',
                        AppDateUtils.formatDateShort(DateTime.now()),
                      ),

                      const SizedBox(height: 5),
                      _thermalDashedLine(),
                      const SizedBox(height: 5),

                      // ── CUSTOMER ──────────────────────────────────────────
                      _thermalSectionLabel('CUSTOMER DETAILS'),
                      const SizedBox(height: 3),
                      _thermalRow('Name', job.customerName),
                      _thermalRow('Phone', job.customerPhone),
                      if (job.customerCNIC != null &&
                          job.customerCNIC!.isNotEmpty)
                        _thermalRow('CNIC', job.customerCNIC!),

                      const SizedBox(height: 5),
                      _thermalDashedLine(),
                      const SizedBox(height: 5),

                      // ── DEVICE ────────────────────────────────────────────
                      _thermalSectionLabel('DEVICE INFO'),
                      const SizedBox(height: 3),
                      _thermalRow('Model', job.mobileModel),
                      const SizedBox(height: 3),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Issue:',
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          job.issueDescription,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 7.5,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 5),
                      _thermalDashedLine(),
                      const SizedBox(height: 5),

                      // ── REPAIR DETAILS ────────────────────────────────────
                      _thermalSectionLabel('REPAIR DETAILS'),
                      const SizedBox(height: 3),
                      _thermalRow(
                          'Received', AppDateUtils.formatTime(job.receivedAt)),
                      _thermalRow(
                          'Ready By',
                          _calculateReadyTime(
                              job.receivedAt, job.estimatedTime)),
                      const SizedBox(height: 4),

                      // Amount Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL AMOUNT',
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'PKR ${job.repairPrice}',
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),
                      _thermalDashedLine(),
                      const SizedBox(height: 5),

                      // ── TERMS & CONDITIONS ────────────────────────────────
                      _thermalSectionLabel('TERMS & CONDITIONS'),
                      const SizedBox(height: 3),
                      ...AppConstants.billNotes.map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            note,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 6.8,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      _thermalDashedLine(),
                      const SizedBox(height: 6),

                      // ── FOOTER ────────────────────────────────────────────
                      Text(
                        'نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'AA Sameer Qamri Regular',
                          fontFamilyFallback: [
                            'Jameel Noori Nastaleeq',
                            'Noto Nastaliq Urdu'
                          ],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Action Buttons ───────────────────────────────────────────────
            _actionButton(
              icon: Icons.print_rounded,
              label: 'Print via Bluetooth',
              color: const Color(0xFF1A73E8),
              onPressed: _isLoading ? null : _onPrintPressed,
            ),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.share_rounded,
              label: 'Share Bill on WhatsApp',
              color: const Color(0xFF25D366),
              onPressed: _isLoading ? null : _captureAndShareImage,
            ),
            const SizedBox(height: 14),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: CircularProgressIndicator(color: Colors.white54),
              ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ─── Thermal UI Helpers ──────────────────────────────────────────────────────

  Widget _thermalDashedLine() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        '- - - - - - - - - - - - - - - - - - - - - - - -',
        style: GoogleFonts.sourceCodePro(
          fontSize: 6.5,
          color: const Color(0xFF888888),
          letterSpacing: 0,
        ),
        overflow: TextOverflow.clip,
        maxLines: 1,
      ),
    );
  }

  Widget _thermalSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.sourceCodePro(
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1A1A),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _thermalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sourceCodePro(
              fontSize: 7.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF555555),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.sourceCodePro(
                fontSize: 7.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
