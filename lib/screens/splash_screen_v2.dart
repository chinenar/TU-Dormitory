import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:logger/logger.dart'; // <-- 1. Import Logger
import '../providers/dorm_provider.dart'; // ตรวจสอบ path ให้ถูกต้อง
import 'home_page.dart'; // ตรวจสอบ path ให้ถูกต้อง

class SplashScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const SplashScreen({super.key, required this.onThemeChanged});

  // --- 2. แก้ไข createState ให้ return State Class ที่เป็น public ---
  @override
  SplashScreenState createState() => SplashScreenState();
  // --------------------------------------------------------
}

// --- 3. แก้ไขชื่อ State Class ให้เป็น public (เอา _ ออก) ---
class SplashScreenState extends State<SplashScreen> {
// --------------------------------------------------

  // --- 4. สร้าง Logger Instance ---
  final Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));
  // -----------------------------

  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startLoadingAnimationAndNavigation();
  }

  Future<void> _startLoadingAnimationAndNavigation() async {
    logger
        .i("SplashScreen: Starting loading, animation, and navigation setup.");

    // 1. เริ่ม Animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        logger.d("SplashScreen: Setting logo opacity to 1.0");
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // 2. กำหนดเวลาแสดงผลขั้นต่ำ
    final minimumDisplayTime = Future.delayed(const Duration(seconds: 3));
    logger.d("SplashScreen: Minimum display time set for 3 seconds.");

    // 3. เริ่มโหลดข้อมูล Dorm
    logger.d("SplashScreen: Starting initial dorm data load from provider.");
    final dataLoading = Provider.of<DormProvider>(context, listen: false)
        .loadInitialDorms() // Provider ควร handle loading state และ error logging ภายใน
        .catchError((error, stackTrace) {
      // <-- เพิ่ม stackTrace
      // --- 5. เปลี่ยน print เป็น logger.e ---
      logger.e("Error loading initial dorms in SplashScreen",
          error: error, stackTrace: stackTrace);
      // -------------------------------------
      return;
    });

    // 4. รอทั้งสองอย่าง
    logger.d(
        "SplashScreen: Waiting for minimum display time and data loading...");
    await Future.wait([minimumDisplayTime, dataLoading]);
    logger.i("SplashScreen: Minimum display time and data loading complete.");

    // 5. นำทาง
    if (mounted) {
      logger.i("SplashScreen: Navigating to HomePage.");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(onThemeChanged: widget.onThemeChanged),
        ),
      );
    } else {
      logger.w("SplashScreen: Widget unmounted before navigation could occur.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ UI จากเวอร์ชันเก่า
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _opacity,
              child: Image.asset(
                'assets/logo.jpg',
                height: 150,
                fit: BoxFit.contain,
                // เพิ่ม errorBuilder ให้ Image.asset ด้วยก็ดี
                errorBuilder: (context, error, stackTrace) {
                  logger.w("SplashScreen: Failed to load logo asset.",
                      error: error, stackTrace: stackTrace);
                  return const Icon(Icons.broken_image,
                      size: 80,
                      color: Colors.grey); // แสดง Icon แทนถ้าโหลดไม่ได้
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "----LOADING----",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
