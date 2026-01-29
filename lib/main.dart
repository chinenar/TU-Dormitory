import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'providers/dorm_provider.dart';
import 'screens/splash_screen_v2.dart';
import 'firebase_options.dart';

// Initialize logger (แก้ไข printTime)
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50, //ปรับเพิ่มถ้าข้อความยาว
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Anonymous Auth (เปลี่ยนชื่อตัวแปร) ---
  final FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    // <-- ใช้ auth
    logger.i("No user signed in. Attempting Anonymous sign-in...");
    try {
      UserCredential userCredential =
          await auth.signInAnonymously(); // <-- ใช้ auth
      logger.i("Anonymous Sign-In SUCCESS! UID: ${userCredential.user?.uid}");
    } catch (e, stackTrace) {
      // <-- เพิ่ม stackTrace
      logger.e("Anonymous Sign-In FAILED",
          error: e, stackTrace: stackTrace); // <-- เพิ่ม stackTrace
    }
  } else {
    logger.i(
        "User already signed in (likely Anonymous). UID: ${auth.currentUser?.uid}"); // <-- ใช้ auth
  }
  // ---------------------------------

  runApp(
    ChangeNotifierProvider(
      create: (context) => DormProvider()..loadInitialData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // --- แก้ไข createState ---
  @override
  MyAppState createState() => MyAppState(); // <-- ใช้ชื่อ State ที่เป็น Public
  // ----------------------
}

// --- แก้ไขชื่อ State Class ---
class MyAppState extends State<MyApp> {
  // <-- ทำให้เป็น Public
// --------------------------
  ThemeMode _themeMode = ThemeMode.system;
  bool _isThemeLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? themeString = prefs.getString('appThemeMode');
      ThemeMode loadedMode;
      switch (themeString) {
        case 'light':
          loadedMode = ThemeMode.light;
          break;
        case 'dark':
          loadedMode = ThemeMode.dark;
          break;
        case 'system': // จัดการ system โดยตรง
        default: // ครอบคลุม null และค่าอื่นๆ ที่ไม่รู้จัก
          loadedMode = ThemeMode.system;
      }
      if (mounted) {
        setState(() {
          _themeMode = loadedMode;
          _isThemeLoading = false;
        });
      }
    } catch (e, stackTrace) {
      logger.e("Error loading theme mode", error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isThemeLoading = false;
        });
      }
    }
  }

  void _toggleTheme(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    setState(() {
      _themeMode = mode;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      await prefs.setString('appThemeMode', themeString);
    } catch (e, stackTrace) {
      logger.e("Error saving theme mode", error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isThemeLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: SplashScreen(onThemeChanged: _toggleTheme),
    );
  }
}
