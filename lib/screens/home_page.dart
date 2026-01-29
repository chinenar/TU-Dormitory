import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../providers/dorm_provider.dart';
import '../screens/favorite_page.dart';
import '../screens/setting_page.dart';
import '../screens/search_page.dart';
import 'package:tu_dormitory/providers/dorm_page.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const HomePage({super.key, required this.onThemeChanged});

  // --- แก้ไข createState ---
  @override
  HomePageState createState() =>
      HomePageState(); // แบบใหม่: ใช้ชื่อ State ที่เป็น Public
  // ----------------------
}

// --- แก้ไขชื่อ State Class ---
class HomePageState extends State<HomePage> {
  // แบบใหม่: ทำให้เป็น Public
// --------------------------
  final Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

  int _selectedIndex = 0;
  final ScrollController categoryScrollController = ScrollController();
  final ScrollController _mainListScrollController = ScrollController();
  final PageStorageKey _homePageListKey =
      const PageStorageKey<String>('homePageListView');

  @override
  void dispose() {
    logger.d("Disposing HomePage controllers");
    categoryScrollController.dispose();
    _mainListScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      bool isTablet = screenWidth > 650;
      double iconSize = isTablet ? 33 : 32.5;
      double bottomNavIconSize = isTablet ? 30 : 24;

      final dormProvider = Provider.of<DormProvider>(context);
      final textTheme = Theme.of(context).textTheme;
      final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
      final Color hintColor = Theme.of(context).hintColor;
      final Color primaryColor = Theme.of(context).colorScheme.primary;
      final Color surfaceVariantColor =
          Theme.of(context).colorScheme.surfaceContainerHighest;

      return Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
                title: InkWell(
                  onTap: () {
                    logger.d("Search bar tapped, navigating to SearchPage");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: surfaceVariantColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('ค้นหาสถานที่',
                              style: TextStyle(color: hintColor)),
                        ),
                        Icon(Icons.search, color: primaryColor),
                      ],
                    ),
                  ),
                ),
                backgroundColor: backgroundColor,
                elevation: 0,
              )
            : null,
        body: _selectedIndex == 0
            ? _buildHomePage(dormProvider, iconSize, textTheme)
            : _selectedIndex == 1
                ? FavoritePage()
                : SettingPage(onThemeChanged: widget.onThemeChanged),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.grey[600],
          iconSize: bottomNavIconSize,
          backgroundColor: backgroundColor,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'รายการโปรด'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'ตั้งค่า'),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0 && _selectedIndex == 0) {
              logger.i(
                  "Tapped Home tab while on Home: Scrolling up and Resetting filters.");
              if (_mainListScrollController.hasClients) {
                _mainListScrollController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              }
              Provider.of<DormProvider>(context, listen: false).resetFilters();
            } else {
              if (index != _selectedIndex) {
                logger.d("Switched to tab index: $index");
                setState(() {
                  _selectedIndex = index;
                });
                if (index == 0) {
                  Provider.of<DormProvider>(context, listen: false)
                      .resetFilters();
                }
              }
            }
          },
        ),
      );
    });
  }

  Widget _buildHomePage(
      DormProvider dormProvider, double iconSize, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 15, bottom: 10),
          child: Text("หมวดหมู่",
              style: textTheme.titleMedium
                  ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Scrollbar(
              controller: categoryScrollController,
              thumbVisibility: true,
              thickness: 4.5,
              radius: const Radius.circular(10),
              child: ListView(
                controller: categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  _buildCategoryItem(
                      context, Icons.terrain, "หอพักนอก", iconSize),
                  _buildCategoryItem(
                      context, Icons.business, "คอนโด", iconSize),
                  _buildCategoryItem(
                      context, Icons.store, "ร้านสะดวกซื้อ", iconSize),
                  _buildCategoryItem(
                      context, Icons.restaurant, "ร้านอาหาร", iconSize),
                  _buildCategoryItem(
                      context, Icons.pool, "สระว่ายน้ำ", iconSize),
                  _buildCategoryItem(
                      context, Icons.fitness_center, "ฟิตเนส", iconSize),
                  _buildCategoryItem(
                      context, Icons.menu_book, "Co-working", iconSize),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("รายการหอพัก",
              style: textTheme.titleMedium
                  ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: dormProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : dormProvider.filteredDorms.isEmpty
                  ? const Center(child: Text("ไม่พบรายการหอพัก"))
                  : ListView.builder(
                      key: _homePageListKey,
                      controller: _mainListScrollController,
                      padding: const EdgeInsets.only(
                          bottom: 16.0, left: 8.0, right: 8.0),
                      itemCount: dormProvider.filteredDorms.length,
                      itemBuilder: (context, index) {
                        final dorm = dormProvider.filteredDorms[index];
                        return _buildDormCard(context, dorm, textTheme);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, IconData icon, String title, double iconSize) {
    final dormProvider = Provider.of<DormProvider>(context, listen: false);
    final Color buttonBackgroundColor = Colors.yellow;
    final Brightness currentBrightness = Theme.of(context).brightness;
    final Color textIconColor =
        (currentBrightness == Brightness.light) ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              /* ... onPressed เดิม ... */
              logger.d("Category button '$title' tapped.");
              Map<String, dynamic> shortcutFilters = {
                'minPrice': 0.0,
                'maxPrice': 20000.0,
                'selectedTypes': <String>[],
                'selectedFacilities': <String>[],
                'selectedBedTypes': <String>[],
                'selectedRoomFacilities': <String>[],
                'searchTerm': '',
              };
              String filterTitle = title;
              if (title == "ร้านสะดวกซื้อ") filterTitle = "ใกล้ร้านสะดวกซื้อ";
              if (title == "Co-working") filterTitle = "Co-working Space";
              switch (filterTitle) {
                case "หอพักนอก":
                  shortcutFilters['selectedTypes'].add("หอพักนอก");
                  break;
                case "คอนโด":
                  shortcutFilters['selectedTypes'].add("คอนโด");
                  break;
                case "ใกล้ร้านสะดวกซื้อ":
                  shortcutFilters['selectedFacilities'].add(filterTitle);
                  break;
                case "ร้านอาหาร":
                  shortcutFilters['selectedFacilities'].add("ร้านอาหาร");
                  break;
                case "สระว่ายน้ำ":
                  shortcutFilters['selectedFacilities'].add("สระว่ายน้ำ");
                  break;
                case "ฟิตเนส":
                  shortcutFilters['selectedFacilities'].add("ฟิตเนส");
                  break;
                case "Co-working Space":
                  shortcutFilters['selectedFacilities'].add(filterTitle);
                  break;
                default:
                  logger.w("Unhandled category button title: $title");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("ตัวกรอง '$title' ยังไม่รองรับ")));
                  return;
              }
              logger.i("Applying Shortcut Filters: $shortcutFilters");
              dormProvider.applyFilters(shortcutFilters);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(iconSize / 2.2),
              backgroundColor: buttonBackgroundColor,
              foregroundColor: textIconColor,
              elevation: 1.5,
            ),
            child: Icon(icon, size: iconSize * 0.9, color: textIconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                color: textIconColor,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDormCard(
      BuildContext context, Map<String, dynamic> dorm, TextTheme textTheme) {
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
        /* ... onTap เดิม ... */
        logger.d("Tapped on dorm: $name (ID: $dormId)");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DormPage(dorm: dorm),
          ),
        );
        if (dormId.isNotEmpty && dormId != 'ไม่มีชื่อ') {
          dormProvider.addRecentlyViewed(dormId);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: (image.isNotEmpty)
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, p) => p == null
                              ? child
                              : Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.0))),
                          errorBuilder: (context, e, s) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image_outlined,
                                  size: 40, color: Colors.grey[500])),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 40, color: Colors.grey[500])),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    // ***** แก้ไข Opacity *****
                    color: Colors.black.withAlpha(102), // ~40% opacity (0-255)
                    // ************************
                    shape: const CircleBorder(), elevation: 1.0,
                    child: InkWell(
                      onTap: () {
                        logger.d("Favorite button tapped for dorm ID: $dormId");
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
                            size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: cardTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(description,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: descriptionColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('$price ฿',
                      style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
