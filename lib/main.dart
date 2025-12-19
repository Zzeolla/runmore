import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/provider/live_share_provider.dart';
import 'package:runmore/provider/user_provider.dart';
import 'package:runmore/screen/live_view_screen.dart';
import 'package:runmore/screen/login_screen.dart';
import 'package:runmore/screen/main_screen.dart';
import 'package:runmore/screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'provider/run_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await dotenv.load(fileName: ".env");

  final naver = FlutterNaverMap();
  await naver.init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
    onAuthFailed: (e) => debugPrint('NaverMap auth failed: $e'),
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final db = AppDatabase();

  runApp(
    WithForegroundTask(
      child: MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          ChangeNotifierProvider(create: (_) => RunProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => LiveShareProvider()),
        ],
        child: const RunmoreApp(),
      ),
    ),
  );
}

class RunmoreApp extends StatelessWidget {
  const RunmoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '런모아',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'NotoSansKR',
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/main' : (_) => const MainScreen(),
        '/login' : (_) => const LoginScreen(),
        '/view': (ctx) {
          final arg = ModalRoute.of(ctx)?.settings.arguments;
          return LiveViewScreen(initialShareCode: arg as String?);
        },
      },
    );
  }
}
