import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/repair_provider.dart';
import 'providers/borrow_provider.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/new_job/new_job_screen.dart';
import 'ui/screens/job_detail/job_detail_screen.dart';
import 'ui/screens/print_bill/print_bill_screen.dart';
import 'ui/screens/borrow_list/borrow_list_screen.dart';

class JTCApp extends StatelessWidget {
  const JTCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RepairProvider()),
        ChangeNotifierProvider(create: (_) => BorrowProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JTC Repair Lab',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/new-job': (context) => const NewJobScreen(),
          '/job-detail': (context) => const JobDetailScreen(),
          '/print-bill': (context) => const PrintBillScreen(),
          '/borrow-list': (context) => const BorrowListScreen(),
        },
      ),
    );
  }
}
