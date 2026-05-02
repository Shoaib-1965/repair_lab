import 'package:url_launcher/url_launcher.dart';

class WhatsAppUtils {
  // Format: 92XXXXXXXXXX (Pakistan country code)
  static String _formatPKNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) phone = '92${phone.substring(1)}';
    return phone;
  }

  static Future<void> sendRepairDoneMessage({
    required String customerPhone,
    required String customerName,
    required String deviceModel,
  }) async {
    final number = _formatPKNumber(customerPhone);
    final message = Uri.encodeComponent(
      'Assalam o Alaikum $customerName! ✅\n\n'
      'Your *$deviceModel* is ready for pickup.\n\n'
      'Please visit JTC Lab at your convenience.\n\n'
      'For queries:\n'
      '📞 Usman: 0345-7599995\n'
      '📞 Saad: 0345-7701965\n\n'
      'Thank you for choosing JTC Lab! 🙏',
    );
    final uri = Uri.parse('https://wa.me/$number?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> sendIssueFoundMessage({
    required String customerPhone,
    required String customerName,
    required String deviceModel,
    required String issueNote,
  }) async {
    final number = _formatPKNumber(customerPhone);
    final message = Uri.encodeComponent(
      'Assalam o Alaikum $customerName!\n\n'
      'During repair of your *$deviceModel*, we found an additional issue:\n\n'
      '⚠️ *$issueNote*\n\n'
      'Please contact us to discuss:\n'
      '📞 Usman: 0345-7599995\n'
      '📞 Saad: 0345-7701965\n\n'
      'JTC Repair Lab',
    );
    final uri = Uri.parse('https://wa.me/$number?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
