import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// --- SettingPage Class (โค้ดส่วนใหญ่เหมือนเดิม) ---
class SettingPage extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingPage({super.key, required this.onThemeChanged});

  Widget _buildIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(8),
      child: Icon(icon, color: Colors.grey[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return ListView(
      children: [
        ListTile(
          leading: _buildIcon(Icons.dark_mode),
          title: Text("โหมดมืด"),
          trailing: DropdownButton<ThemeMode>(
            value: currentThemeMode,
            onChanged: (ThemeMode? newValue) {
              if (newValue != null) {
                onThemeChanged(newValue);
              }
            },
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text("ค่าเริ่มต้นระบบ"),
              ),
              DropdownMenuItem(value: ThemeMode.dark, child: Text("เปิด")),
              DropdownMenuItem(value: ThemeMode.light, child: Text("ปิด")),
            ],
          ),
        ),

        // Divider(),
        // ListTile(
        //   leading: _buildIcon(Icons.language),
        //   title: Text("ภาษา"),
        //   trailing: DropdownButton<String>(
        //     value: 'ไทย',
        //     onChanged: (String? newValue) {},
        //     items: const [
        //       DropdownMenuItem(value: "English", child: Text("English")),
        //       DropdownMenuItem(value: "ไทย", child: Text("ไทย")),
        //     ],
        //   ),
        // ),
        Divider(),
        ListTile(
          leading: _buildIcon(Icons.info),
          title: Text("เกี่ยวกับเรา"),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AboutUsPage())),
        ),
        ListTile(
          leading: _buildIcon(Icons.article),
          title: Text("ข้อกำหนดการให้บริการ"),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TermsOfServicePage()),
          ),
        ),
        Divider(),
        ListTile(
          leading: _buildIcon(Icons.star),
          title: Text("ให้คะแนนแอป"),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () =>
              launchUrl(Uri.parse('https://forms.gle/VwLaqYTSWYt4TSjTA')),
        ),
        ListTile(
          leading: _buildIcon(Icons.share),
          title: Text("แชร์แอป"),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () => Share.share(
            'https://drive.google.com/file/d/1PsbZlk1xoTQZXh3SW3kIbnvwbNvl7xk8/view?usp=sharing',
          ),
        ),
      ],
    );
  }
}

// --- หน้า About Us (ใส่เนื้อหาใหม่) ---
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Theme ปัจจุบันสำหรับ Text Styles
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("เกี่ยวกับเรา"),
        // (Optional) เพิ่ม style ให้ AppBar
        // backgroundColor: Theme.of(context).colorScheme.surface,
        // foregroundColor: Theme.of(context).colorScheme.onSurface,
        // elevation: 1,
      ),
      body: SingleChildScrollView(
        // ใช้ SingleChildScrollView เผื่อเนื้อหายาว
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ), // ปรับ Padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
          children: [
            // --- ส่วน Logo / Icon ---
            Center(
              child: Image.asset(
                'assets/logo.jpg', // <-- ตรวจสอบว่า path นี้ถูกต้อง และประกาศใน pubspec.yaml
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            // --- ชื่อแอปพลิเคชัน และ เวอร์ชัน ---
            Center(
              child: Text(
                "TU Dormitory", // <<< ใส่ชื่อแอปที่ถูกต้อง
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "เวอร์ชัน 1.0.0", // <<< ใส่เวอร์ชันแอป (อาจจะดึงจาก package_info)
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // --- ส่วน ภารกิจ/เกี่ยวกับแอป ---
            Text(
              "เกี่ยวกับแอปพลิเคชัน",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "แอปพลิเคชันนี้พัฒนาขึ้นเพื่อเป็นศูนย์กลางข้อมูลหอพักและที่พักอาศัยบริเวณรอบมหาวิทยาลัยธรรมศาสตร์ ศูนย์รังสิต ช่วยให้นักศึกษาและบุคลากรสามารถค้นหา เปรียบเทียบ และเข้าถึงข้อมูลที่พักที่ต้องการได้อย่างสะดวก รวดเร็ว และมีประสิทธิภาพ",
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ), // ปรับความสูงบรรทัด
            ),
            const SizedBox(height: 28),

            // --- ส่วน ผู้พัฒนา ---
            Text(
              "ทีมผู้พัฒนา",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "พัฒนาโดยกลุ่มนักศึกษา [คณะวิศวกรรมศาสตร์ สาขาคอมพิวเตอร์] มหาวิทยาลัยธรรมศาสตร์:", // <<< แก้ไขตามความเหมาะสม
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // ย่อหน้า
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• [จักรภัทร สมบัติเจริญเมือง 6510685024]",
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    "• [จิณณะ เต็งจิรธนาภา 6510685032]",
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    "• [ธนพล ประดิษฐ์ศิลป์ดี 6510685065]",
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    "• [พลกฤต กันยายน 6510615229]",
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    "• [ณัฐชนน สนองคุณ 6510615088]",
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- ส่วน ติดต่อ/ข้อเสนอแนะ ---
            Text(
              "ติดต่อและข้อเสนอแนะ",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "หากมีคำถาม ข้อเสนอแนะ หรือพบปัญหาการใช้งาน สามารถติดต่อได้ที่:",
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                // ***** ใส่อีเมลจริงของคุณ *****
                Text(
                  "[่jakapat.som@dome.tu.ac.th]",
                  style: textTheme.bodyMedium,
                ),
                // **************************
              ],
            ),
            const SizedBox(height: 40), // ระยะห่างล่างสุด
          ],
        ),
      ),
    );
  }
} // จบ AboutUsPage

// --- หน้า Terms of Service (โค้ดเดิม ใช้ Markdown) ---
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  // --- ใส่เนื้อหา Terms ที่นี่ (อย่าลืมแก้ส่วนที่เป็น Placeholder [ ]) ---
  final String termsContent = """
### **คำนำ**

ยินดีต้อนรับสู่แอปพลิเคชัน **[TU Dormitory]** ("แอปพลิเคชัน") ซึ่งดำเนินการโดย **[TU Dormitory Team]** ("พวกเรา")
ข้อกำหนดการให้บริการฉบับนี้ ("ข้อกำหนดฯ") เป็นข้อตกลงทางกฎหมายระหว่างคุณ ("ผู้ใช้") และพวกเรา
เกี่ยวกับการใช้งานแอปพลิเคชันและบริการที่เกี่ยวข้อง (รวมเรียกว่า "บริการ")
โปรดอ่านข้อกำหนดฯ นี้อย่างละเอียดก่อนใช้งานแอปพลิเคชัน การเข้าถึงหรือใช้งานแอปพลิเคชันถือว่าคุณยอมรับและตกลงที่จะผูกพันตามข้อกำหนดฯ หากคุณไม่ยอมรับข้อกำหนดฯ นี้ โปรดอย่าเข้าถึงหรือใช้งานแอปพลิเคชัน

### 1. ข้อมูลในแอปพลิเคชัน
- **วัตถุประสงค์**: แอปพลิเคชันนี้มีวัตถุประสงค์เพื่อรวบรวมและนำเสนอข้อมูลเกี่ยวกับหอพัก ที่พักอาศัย หรืออสังหาริมทรัพย์ที่เกี่ยวข้อง ("ข้อมูลหอพัก") เพื่ออำนวยความสะดวกแก่ผู้ใช้ในการค้นหาและเปรียบเทียบข้อมูลเบื้องต้น
- **แหล่งข้อมูล**: ข้อมูลหอพักที่แสดงในแอปพลิเคชันอาจรวบรวมมาจากข้อมูลสาธารณะจากเว็บไซต์ต่างๆ จึงอาจจะทำให้มีข้อมูลที่ตกหล่นหรือไม่ครบอยู่บ้าง
- **ความถูกต้องของข้อมูล**: เราพยายามอย่างเต็มที่เพื่อให้ข้อมูลหอพักมีความถูกต้องและเป็นปัจจุบันที่สุด อย่างไรก็ตาม เรา **ไม่รับประกัน** ความถูกต้อง ความสมบูรณ์ หรือความน่าเชื่อถือของข้อมูลหอพักทั้งหมด ข้อมูลต่างๆ เช่น ราคา, สิ่งอำนวยความสะดวก, ห้องว่าง, รูปภาพ, และรายละเอียดอื่นๆ อาจมีการเปลี่ยนแปลงได้ตลอดเวลาโดยไม่ต้องแจ้งให้ทราบล่วงหน้า
- **การตรวจสอบข้อมูล**: เราขอแนะนำให้ผู้ใช้ **ติดต่อและตรวจสอบข้อมูลโดยตรงกับเจ้าของหรือผู้จัดการหอพัก** ก่อนตัดสินใจทำสัญญาเช่าหรือธุรกรรมใดๆ ที่เกี่ยวข้อง เราจะไม่รับผิดชอบต่อความเสียหายหรือข้อผิดพลาดใดๆ ที่เกิดจากการเชื่อถือข้อมูลในแอปพลิเคชันโดยไม่มีการตรวจสอบเพิ่มเติม
- **รูปภาพและสื่อ**: รูปภาพหรือสื่ออื่นๆ ที่แสดงในแอปพลิเคชันมีวัตถุประสงค์เพื่อการอ้างอิงและอาจไม่ตรงกับสภาพจริงของหอพัก ณ ปัจจุบัน

### 2. การใช้งานแอปพลิเคชัน
- **สิทธิ์การใช้งาน**: เราให้สิทธิ์คุณในการใช้งานแอปพลิเคชันนี้เป็นการส่วนตัวและไม่ใช่เชิงพาณิชย์ ภายใต้ข้อกำหนดฯ นี้
- **ข้อห้าม**: คุณตกลงที่จะไม่: ใช้งานแอปพลิเคชันในทางที่ผิดกฎหมายหรือไม่เหมาะสม; คัดลอก, ดัดแปลง, แจกจ่าย, ขาย, หรือให้เช่าส่วนใดส่วนหนึ่งของแอปพลิเคชันหรือข้อมูลในแอปพลิเคชันโดยไม่ได้รับอนุญาต; พยายามเข้าถึงส่วนที่ไม่ได้รับอนุญาต; ใช้โปรแกรมอัตโนมัติในการเข้าถึงข้อมูล; กระทำการใดๆ ที่อาจรบกวนการทำงานของแอปพลิเคชัน

### 3. บัญชีผู้ใช้ (ถ้ามี)
- **การลงทะเบียน**: หากมีการลงทะเบียน คุณตกลงที่จะให้ข้อมูลที่ถูกต้องและรักษาข้อมูลบัญชีให้เป็นความลับ
- **ความรับผิดชอบ**: คุณเป็นผู้รับผิดชอบต่อกิจกรรมทั้งหมดภายใต้บัญชีของคุณ

### 4. ฟังก์ชันรายการโปรด/การบันทึกข้อมูล
- แอปพลิเคชันอาจมีฟังก์ชันให้คุณบันทึกรายการหอพักที่สนใจ ข้อมูลนี้มีเพื่อความสะดวกของคุณเท่านั้น

### 5. ทรัพย์สินทางปัญญา
- แอปพลิเคชันและเนื้อหาทั้งหมดเป็นทรัพย์สินของ **[TU Dormitory Team]** หรือผู้ให้อนุญาต และได้รับการคุ้มครองตามกฎหมาย

### 6. การเชื่อมโยงไปยังบริการของบุคคลที่สาม
- แอปพลิเคชันอาจมีการเชื่อมโยงไปยังบริการของบุคคลที่สาม เราไม่รับผิดชอบต่อเนื้อหาหรือการปฏิบัติของบริการเหล่านั้น

### 7. การปฏิเสธความรับผิดและการจำกัดความรับผิด
- แอปพลิเคชันนี้มีให้ "ตามสภาพ" โดยไม่มีการรับประกันใดๆ เราไม่รับประกันความถูกต้องหรือความต่อเนื่องของการทำงาน และจะไม่รับผิดต่อความเสียหายใดๆ ที่เกิดจากการใช้งานแอปพลิเคชันนี้

### 8. การเปลี่ยนแปลงข้อกำหนดฯ
- เราขอสงวนสิทธิ์ในการแก้ไขข้อกำหนดฯ นี้ได้ตลอดเวลา การใช้งานต่อไปถือเป็นการยอมรับการเปลี่ยนแปลง

### 9. การยกเลิกการให้บริการ
- เราอาจระงับหรือยุติการให้บริการได้ตลอดเวลา

### 10. ข้อมูลติดต่อ
หากมีคำถาม โปรดติดต่อเราที่: **[jakapat.som@dome.tu.ac.th]**

**วันที่แก้ไขล่าสุด:** [27/04/2025]
""";
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ข้อกำหนดการให้บริการ"), elevation: 1),
      // ใช้ Markdown Widget แสดงผล
      body: Markdown(
        data: termsContent, // เนื้อหา Terms
        padding: const EdgeInsets.all(16.0),
        selectable: true, // ให้ Copy ได้
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          // ปรับ Style Markdown (Optional)
          h3: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
      ),
    );
  }
}
