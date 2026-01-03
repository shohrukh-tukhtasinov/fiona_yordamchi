import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/optimized_home_page.dart';
import 'presentation/pages/info_page.dart';
import 'presentation/state/transaction_view_model.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/services/hive_service.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Hive
  await HiveService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        repository: TransactionRepositoryImpl(),
      ),
      child: MaterialApp(
        title: 'Fiona Yordamchi (Beta)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const OptimizedHomePage(),
      ),
    );
  }
}
