class AppConstants {
  // Lab Info
  static const String labName = 'JTC Lab';
  static const String labFullName = 'JTC Repair Lab';
  static const String owner1Name = 'Usman';
  static const String owner1Phone = '0345-7599995';
  static const String owner2Name = 'Saad';
  static const String owner2Phone = '0345-7701965';
  static const String labTagline = 'Professional Mobile Repair Management';
  static const String billPrefix = 'JTC';

  // Bill Footer Notes
  static const List<String> billNotes = [
    '• Device checked thoroughly before and after repair.',
    '• Customer responsible for personal data backup.',
    '• 15 days warranty on replaced parts only.',
  ];

  // Pre-built Issue Tags
  static const List<String> issueTags = [
    'Screen Broken',
    'Battery Issue',
    'Charging Port',
    'Speaker Issue',
    'Mic Issue',
    'Back Glass',
    'Water Damage',
    'Software Issue',
    'Hanging / Lag',
    'Camera Issue',
    'Touch Issue',
    'Power Button',
    'Volume Button',
    'SIM Not Working',
    'Network Issue',
    'Overheating',
    'Face ID / Fingerprint',
    'Headphone Jack',
    'Vibration Issue',
    'WiFi Issue',
  ];

  // Estimated Time Quick-Select
  static const List<String> timeOptions = [
    '1 Hour',
    '2 Hours',
    '3 Hours',
    'Same Day',
    'Tomorrow',
    '2 Days',
    '1 Week',
  ];

  // Colors (Hex codes as int)
  static const int primaryColor = 0xFF1A73E8; // Deep Blue
  static const int secondaryColor = 0xFF00B4D8; // Soft Teal
  static const int successColor = 0xFF2ECC71; // Green
  static const int warningColor = 0xFFF39C12; // Orange
  static const int errorColor = 0xFFE74C3C; // Red
  static const int bgColor = 0xFFF8FAFF; // Barely blue-white
  static const int textPrimary = 0xFF1A1A2E; // Near black
  static const int textSecondary = 0xFF6B7280; // Gray
  static const int cardBgColor = 0xFFF8FAFF; // Card background
  static const int fillColor = 0xFFF0F4FF; // Input fill color
}
