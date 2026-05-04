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
    required double price,
  }) async {
    final number = _formatPKNumber(customerPhone);
    final message = Uri.encodeComponent(
      'Assalam o Alaikum $customerName Sahab! 🙏\n\n'
      'Aap ka $deviceModel repair ho gaya hai. ✅\n'
      'Aap JTC Lab se kabhi bhi le sakte hain.\n\n'
      'Bill Amount: PKR ${price.toStringAsFixed(0)}\n\n'
      'Shukriya JTC Lab choose karne ka! 💙\n\n'
      '📞 Usman: 0345-7599995\n'
      '📞 Saad: 0345-7595781\n'
      '📍 نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ',
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
      'Assalam o Alaikum $customerName! 👋\n\n'
      'Aap ke $deviceModel ki repair ke dauran ek aur masla mila hai:\n\n'
      '⚠️ $issueNote\n\n'
      'Meherbani karke humse rabta karein:\n'
      '📞 Usman: 0345-7599995\n'
      '📞 Saad: 0345-7595781\n\n'
      'JTC Repair Lab\n'
      'نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ',
    );
    final uri = Uri.parse('https://wa.me/$number?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
