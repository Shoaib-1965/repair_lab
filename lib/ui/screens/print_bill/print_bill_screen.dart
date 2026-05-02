import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/repair_job.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

  Future<void> _captureAndShare() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary =
          _billKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Share would be implemented here with share_plus package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screenshot captured! Share feature coming soon'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printViaBluetooth() async {
    try {
      setState(() => _isLoading = true);

      // Bluetooth print implementation would go here
      // Using bluetooth_print package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth printer integration coming soon'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bill Preview
            RepaintBoundary(
              key: _billKey,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Text(
                      AppConstants.labName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      AppConstants.labTagline,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Colors.black,
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
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              AppDateUtils.formatDateShort(DateTime.now()),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Bill',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              billNumber,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 1,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    // Customer Info
                    _buildBillRow('Customer', job.customerName),
                    _buildBillRow('Phone', job.customerPhone),
                    if (job.customerCNIC != null)
                      _buildBillRow('CNIC', job.customerCNIC!),
                    Container(
                      height: 1,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    // Device Info
                    _buildBillRow('Device', job.mobileModel),
                    _buildBillMultilineRow('Issue', job.issueDescription),
                    Container(
                      height: 1,
                      color: Colors.black,
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
                      height: 1,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    // Notes
                    Text(
                      'NOTES',
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    ...AppConstants.billNotes.map((note) {
                      return Text(
                        note,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      );
                    }),
                    Container(
                      height: 1,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    // Contacts
                    Text(
                      '${AppConstants.owner1Name}: ${AppConstants.owner1Phone}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${AppConstants.owner2Name}: ${AppConstants.owner2Phone}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: 1,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    // Thank You
                    Text(
                      'Thank You!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _printViaBluetooth,
                    icon: const Icon(Icons.print),
                    label: const Text('Print via Bluetooth'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _captureAndShare,
                    icon: const Icon(Icons.share),
                    label: const Text('Share as Screenshot'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
