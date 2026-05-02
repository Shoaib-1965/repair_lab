class AppConstants {
  // Lab Info
  static const String labName = 'JTC Lab';
  static const String labFullName = 'JTC Repair Lab';
  static const String labNameUrdu = 'جُنید ٹیلی کام ریپیئرنگ لیب';
  static const String addressUrdu = 'نزد ڈھول سکندر، محلہ گڑھ، چنیوٹ';
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

  // Mobile Models for Auto-Suggestion
  static const List<String> mobileModels = [
    // Samsung Galaxy A Series
    'Samsung Galaxy A05', 'Samsung Galaxy A05s', 'Samsung Galaxy A14', 'Samsung Galaxy A15',
    'Samsung Galaxy A24', 'Samsung Galaxy A25', 'Samsung Galaxy A34', 'Samsung Galaxy A35',
    'Samsung Galaxy A54', 'Samsung Galaxy A55', 'Samsung Galaxy A74',
    // Samsung Galaxy S Series
    'Samsung Galaxy S23', 'Samsung Galaxy S23+', 'Samsung Galaxy S23 Ultra',
    'Samsung Galaxy S24', 'Samsung Galaxy S24+', 'Samsung Galaxy S24 Ultra',
    'Samsung Galaxy S25', 'Samsung Galaxy S25+', 'Samsung Galaxy S25 Ultra',
    // Samsung Galaxy M / F Series
    'Samsung Galaxy M14', 'Samsung Galaxy M34', 'Samsung Galaxy M54',
    'Samsung Galaxy F14', 'Samsung Galaxy F54',
    // Samsung Galaxy Z
    'Samsung Galaxy Z Flip 5', 'Samsung Galaxy Z Fold 5',
    'Samsung Galaxy Z Flip 6', 'Samsung Galaxy Z Fold 6',

    // iPhone
    'iPhone 11', 'iPhone 11 Pro', 'iPhone 11 Pro Max',
    'iPhone 12', 'iPhone 12 Mini', 'iPhone 12 Pro', 'iPhone 12 Pro Max',
    'iPhone 13', 'iPhone 13 Mini', 'iPhone 13 Pro', 'iPhone 13 Pro Max',
    'iPhone 14', 'iPhone 14 Plus', 'iPhone 14 Pro', 'iPhone 14 Pro Max',
    'iPhone 15', 'iPhone 15 Plus', 'iPhone 15 Pro', 'iPhone 15 Pro Max',
    'iPhone 16', 'iPhone 16 Plus', 'iPhone 16 Pro', 'iPhone 16 Pro Max',
    'iPhone SE (2nd Gen)', 'iPhone SE (3rd Gen)',

    // Xiaomi / Redmi
    'Redmi 12', 'Redmi 12C', 'Redmi 13', 'Redmi 13C',
    'Redmi Note 12', 'Redmi Note 12 Pro', 'Redmi Note 12 Pro+',
    'Redmi Note 13', 'Redmi Note 13 Pro', 'Redmi Note 13 Pro+',
    'Redmi Note 14', 'Redmi Note 14 Pro', 'Redmi Note 14 Pro+',
    'POCO X5', 'POCO X5 Pro', 'POCO X6', 'POCO X6 Pro',
    'POCO M5', 'POCO M6 Pro', 'POCO F5', 'POCO F6',
    'Xiaomi 13', 'Xiaomi 13T', 'Xiaomi 14', 'Xiaomi 14T',

    // OPPO
    'OPPO A17', 'OPPO A17k', 'OPPO A38', 'OPPO A58', 'OPPO A78', 'OPPO A98',
    'OPPO A3', 'OPPO A3 Pro',
    'OPPO Reno 8', 'OPPO Reno 8 Pro', 'OPPO Reno 10', 'OPPO Reno 10 Pro',
    'OPPO Reno 11', 'OPPO Reno 11 Pro', 'OPPO Reno 12', 'OPPO Reno 12 Pro',
    'OPPO F23', 'OPPO F25 Pro', 'OPPO F27 Pro',
    'OPPO Find X6 Pro', 'OPPO Find X7 Ultra',

    // Vivo
    'Vivo Y02', 'Vivo Y16', 'Vivo Y22', 'Vivo Y35', 'Vivo Y36', 'Vivo Y100',
    'Vivo Y200', 'Vivo Y300',
    'Vivo V25', 'Vivo V27', 'Vivo V29', 'Vivo V30', 'Vivo V40',
    'Vivo T1', 'Vivo T2 Pro', 'Vivo T3',
    'Vivo X100', 'Vivo X200',

    // Realme
    'Realme C30', 'Realme C33', 'Realme C53', 'Realme C55', 'Realme C67',
    'Realme 11', 'Realme 11 Pro', 'Realme 12', 'Realme 12 Pro',
    'Realme Narzo 60', 'Realme Narzo 70',
    'Realme GT 5', 'Realme GT 6',

    // Tecno
    'Tecno Spark 10', 'Tecno Spark 10 Pro', 'Tecno Spark 20', 'Tecno Spark 20 Pro',
    'Tecno Spark 30', 'Tecno Spark Go 2024',
    'Tecno Camon 20', 'Tecno Camon 20 Pro', 'Tecno Camon 30', 'Tecno Camon 30 Pro',
    'Tecno Pop 7 Pro', 'Tecno Pop 8', 'Tecno Pop 9',
    'Tecno Pova 5', 'Tecno Pova 6',
    'Tecno Phantom V Fold', 'Tecno Phantom V Flip',

    // Infinix
    'Infinix Hot 30', 'Infinix Hot 30i', 'Infinix Hot 40', 'Infinix Hot 40 Pro',
    'Infinix Hot 50', 'Infinix Hot 50 Pro',
    'Infinix Note 30', 'Infinix Note 30 Pro', 'Infinix Note 40', 'Infinix Note 40 Pro',
    'Infinix Smart 8', 'Infinix Smart 8 Plus', 'Infinix Smart 9',
    'Infinix Zero 30', 'Infinix Zero 40',
    'Infinix GT 10 Pro', 'Infinix GT 20 Pro',

    // OnePlus
    'OnePlus Nord CE 3', 'OnePlus Nord CE 4', 'OnePlus Nord 3', 'OnePlus Nord 4',
    'OnePlus 11', 'OnePlus 11R', 'OnePlus 12', 'OnePlus 12R',
    'OnePlus 13', 'OnePlus 13R',

    // Motorola
    'Motorola Moto G54', 'Motorola Moto G84', 'Motorola Moto G Power 2024',
    'Motorola Edge 40', 'Motorola Edge 50', 'Motorola Edge 50 Pro',
    'Motorola Razr 40', 'Motorola Razr 40 Ultra',

    // Nokia
    'Nokia G21', 'Nokia G42', 'Nokia C32', 'Nokia C22',
    'Nokia X30', 'Nokia 105', 'Nokia 110',

    // Google Pixel
    'Google Pixel 7', 'Google Pixel 7a', 'Google Pixel 7 Pro',
    'Google Pixel 8', 'Google Pixel 8a', 'Google Pixel 8 Pro',
    'Google Pixel 9', 'Google Pixel 9 Pro',

    // Honor
    'Honor X7b', 'Honor X8b', 'Honor X9b',
    'Honor 90', 'Honor 200', 'Honor Magic 6 Pro',

    // Huawei
    'Huawei Nova 11', 'Huawei Nova 12', 'Huawei P60 Pro',
    'Huawei Mate 60 Pro',

    // Itel
    'Itel A60', 'Itel A60s', 'Itel P55', 'Itel P55+',
    'Itel S23', 'Itel S24',

    // Nothing
    'Nothing Phone (1)', 'Nothing Phone (2)', 'Nothing Phone (2a)',

    // ZTE / Nubia
    'ZTE Blade A54', 'ZTE Blade V50',
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
