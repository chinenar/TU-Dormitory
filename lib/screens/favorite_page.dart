import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dorm_provider.dart';
import '../providers/dorm_page.dart'; // Adjust the path if necessary

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dormProvider = Provider.of<DormProvider>(context);
    final List<String> favoriteDormIds = dormProvider.favoriteDorms;
    final List<String> recentlyViewedDormIds = dormProvider.recentlyViewedDorms;

    // --- สร้าง List ข้อมูลหอพัก ---
    final List<Map<String, dynamic>> favoriteDormData = favoriteDormIds
        .map((id) => dormProvider.dormList.firstWhere(
              (dorm) => dorm['id'] == id,
              orElse: () => <String, dynamic>{},
            ))
        .where((dormMap) => dormMap.isNotEmpty)
        .toList();

    final List<Map<String, dynamic>> recentlyViewedData = recentlyViewedDormIds
        .map((id) => dormProvider.dormList.firstWhere(
              (dorm) => dorm['id'] == id,
              orElse: () => <String, dynamic>{},
            ))
        .where((dormMap) => dormMap.isNotEmpty)
        .toList();
    // -----------------------------

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme; // ดึง ColorScheme

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการโปรด & ล่าสุด"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            colorScheme.surface,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ??
            colorScheme.onSurface,
        elevation: Theme.of(context).appBarTheme.elevation ?? 1.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- หอพักที่เข้าชมเร็ว ๆ นี้ -----
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text("เข้าชมล่าสุด",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            recentlyViewedData.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text("ยังไม่มีหอพักที่เข้าชม",
                        style: textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[600])),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentlyViewedData.length,
                    itemBuilder: (context, index) {
                      final dorm = recentlyViewedData[index];
                      return _buildDormCard(context, dorm, textTheme,
                          isRecentlyViewed: true);
                    },
                  ),

            const SizedBox(height: 20),

            // ----- หอพักที่คุณชอบ -----
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text("รายการโปรด",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            favoriteDormData.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text("ยังไม่มีหอพักในรายการโปรด",
                        style: textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[600])),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoriteDormData.length,
                    itemBuilder: (context, index) {
                      final dorm = favoriteDormData[index];
                      return _buildDormCard(context, dorm, textTheme,
                          isRecentlyViewed: false);
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- _confirmDelete (เหมือนเดิม) ---
  void _confirmDelete(BuildContext context, String dormId, String dormName) {
    final dormProvider = Provider.of<DormProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text('ต้องการลบ "$dormName" ออกจากรายการโปรดหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                dormProvider.toggleFavorite(dormId);
                Navigator.pop(context);
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- Widget สำหรับสร้าง Card (แก้ไข Opacity) ---
  Widget _buildDormCard(
      BuildContext context, Map<String, dynamic> dorm, TextTheme textTheme,
      {required bool isRecentlyViewed}) {
    final dormProvider = Provider.of<DormProvider>(context, listen: false);
    final dormId = dorm["id"]?.toString() ?? dorm["name"]?.toString() ?? '';
    final name = dorm["name"]?.toString() ?? 'ไม่มีชื่อ';
    final isFavorite = dormProvider.favoriteDorms.contains(dormId);
    final image = dorm["image"]?.toString() ?? '';
    final description = dorm["description"]?.toString() ?? 'ไม่มีคำอธิบาย';
    final price = dorm["price"]?.toString() ?? '-';
    final Color favoriteIconColor = isFavorite ? Colors.red : Colors.white;
    final Brightness currentBrightness = Theme.of(context).brightness;
    final Color cardTextColor =
        (currentBrightness == Brightness.light) ? Colors.black87 : Colors.white;
    final Color descriptionColor = (currentBrightness == Brightness.light)
        ? Colors.black54
        : Colors.grey[300]!;

    return GestureDetector(
      onTap: () {
        if (dormId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DormPage(dorm: dorm),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: (image.isNotEmpty)
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (ctx, child, p) => p == null
                              ? child
                              : Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0),
                                  ),
                                ),
                          errorBuilder: (ctx, e, s) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image_outlined,
                                size: 40, color: Colors.grey[500]),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 40, color: Colors.grey[500]),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cardTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: descriptionColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$price ฿',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: isRecentlyViewed
                  ? Material(
                      color: Colors.black.withAlpha(102),
                      shape: const CircleBorder(),
                      elevation: 1.0,
                      child: InkWell(
                        onTap: () {
                          if (dormId.isNotEmpty && dormId != 'ไม่มีชื่อ') {
                            dormProvider.toggleFavorite(dormId);
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: favoriteIconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      tooltip: 'ลบออกจากรายการโปรด',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withAlpha(77),
                        padding: const EdgeInsets.all(6.0),
                      ),
                      onPressed: () {
                        if (dormId.isNotEmpty && dormId != 'ไม่มีชื่อ') {
                          _confirmDelete(context, dormId, name);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
