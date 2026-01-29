import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import '../providers/dorm_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DormPage extends StatefulWidget {
  final Map<String, dynamic> dorm;

  const DormPage({super.key, required this.dorm});

  @override
  State<DormPage> createState() => _DormPageState();
}

class _DormPageState extends State<DormPage> {
  final PageController _pageController = PageController();

  late List<String> images;

  // Define the yellow color to use consistently throughout the page
  static const Color highlightColor = Colors.amber;

  // Facility icons map remains the same
  final Map<String, IconData> facilityIcons = {
    'ฟิตเนส': Icons.fitness_center,
    'สระว่ายน้ำ': Icons.pool,
    'ที่จอดรถ': Icons.local_parking,
    'เครื่องปรับอากาศ': MdiIcons.airConditioner,
    'เครื่องทำน้ำอุ่น': MdiIcons.waterBoiler,
    'มีระบบ keycard': FontAwesomeIcons.idCard,
    'อินเทอร์เน็ต (WIFI)': Icons.wifi,
    'ร้านซัก-รีด': Icons.local_laundry_service,
    'Co-working Space': MdiIcons.bookshelf,
    'ซิงค์ล้างจาน': FontAwesomeIcons.sink,
    'เตียงเดี่ยว': Icons.hotel,
    'เตียงคู่': Icons.bed,
    'ร้านอาหาร': Icons.restaurant,
    'ตู้เย็น': MdiIcons.fridge,
    'มีห้องครัว': Icons.kitchen,
    'ตู้เสื้อผ้า': MdiIcons.wardrobe,
    'ไมโครเวฟ': Icons.microwave_rounded,
    'ประตู digital lock': Icons.dialpad,
    'ทีวี': Icons.tv,
    'ร้านทำผม': FontAwesomeIcons.scissors,
    'ลิฟต์': MdiIcons.elevator,
    'โต๊ะทำงาน': MdiIcons.desk,
    'รปภ.': Icons.security,
    'CCTV': MdiIcons.cctv,
    'ATM': Icons.atm,
    'ใกล้ร้านสะดวกซื้อ': Icons.store,
    'มีระบบสแกนลายนิ้วมือ': Icons.fingerprint,
    'เครื่องซักผ้าอบผ้า': Icons.local_laundry_service,
    'ตู้แลกเหรียญ': FontAwesomeIcons.coins,
    'รถตู้รับส่ง': Icons.directions_bus,
    'เตียงนอน': Icons.bed,
  };

  @override
  void initState() {
    super.initState();
    final dynamic imageData = widget.dorm['images'];
    if (imageData is List) {
      images = imageData.whereType<String>().toList();
    } else {
      images = [];
    }
  }

  bool _isUrl(String text) {
    if (text.isEmpty) return false;
    final urlPattern = r'^(http|https):\/\/[^\s$.?#].[^\s]*$';
    final result = RegExp(urlPattern, caseSensitive: false).firstMatch(text);
    return result != null;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final facilities =
        (widget.dorm['facilities'] as List?)?.whereType<String>().toList() ??
            [];
    final basicInfo =
        (widget.dorm['basic_info'] as List?)?.whereType<String>().toList() ??
            [];
    final contact =
        (widget.dorm['contact'] as List?)?.whereType<String>().toList() ?? [];
    final mapLink = widget.dorm['map'] as String? ?? '';
    final dormProvider = Provider.of<DormProvider>(context);
    final dormName = widget.dorm['name'] as String? ?? 'Unknown Dorm';
    final dormId =
        widget.dorm['id'] as String? ?? ''; // Ensure you have the dorm ID
    bool isFavorite = dormProvider.favoriteDorms.contains(dormId);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  if (dormId.isNotEmpty) {
                    // Use dormId instead of dormName
                    dormProvider.toggleFavorite(dormId);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 80, // Height of the bottom price bar + padding
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image Gallery ---
                  _buildImageGallery(context, images),

                  // --- Main Content Padding ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Dorm Name ---
                        Text(
                          dormName,
                          style: textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // --- Description ---
                        Text(
                          widget.dorm['description'] as String? ??
                              'No description available.',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),

                        // --- Facilities Section ---
                        _buildSectionTitle(context, 'สิ่งอำนวยความสะดวก',
                            Icons.star_outline), // Changed Icon
                        const SizedBox(height: 8), // Kept reduced space
                        _buildFacilitiesGrid(context, facilities),
                        const SizedBox(height: 24),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 24),

                        // --- Basic Info Section ---
                        _buildSectionTitle(
                            context, 'ข้อมูลพื้นฐาน', Icons.info_outline),
                        const SizedBox(height: 8), // Kept reduced space
                        _buildInfoList(context, basicInfo),
                        const SizedBox(height: 24),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 24),

                        // --- Contact Section ---
                        _buildSectionTitle(
                            context, 'ติดต่อ', Icons.contact_phone_outlined),
                        const SizedBox(height: 8), // Kept reduced space
                        _buildInfoList(context, contact, isContact: true),
                        const SizedBox(height: 24),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 24),

                        // --- Map Section ---
                        _buildSectionTitle(context, 'ตำแหน่งที่ตั้งและรีวิว',
                            Icons.map_outlined),
                        const SizedBox(height: 8), // Kept reduced space
                        if (mapLink.isNotEmpty && _isUrl(mapLink))
                          ListTile(
                            leading: Icon(Icons.location_on_outlined,
                                color: highlightColor), // Changed Color
                            title: const Text(
                              'ดูบน Google Maps และอ่านรีวิว',
                              style: TextStyle(
                                color: Colors.blue, // Keep map link blue
                              ),
                            ),
                            onTap: () => _launchURL(mapLink),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          )
                        else
                          Padding(
                            // Add padding for consistency if no map
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              ' ไม่มีข้อมูลแผนที่',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Sticky Bottom Price Bar ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPriceBar(context),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Image Gallery ---
  Widget _buildImageGallery(BuildContext context, List<String> imageList) {
    if (imageList.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey[300],
        child: Center(
            child: Icon(Icons.hide_image_outlined,
                size: 60, color: Colors.grey[500])),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              return Image.network(
                imageList[index],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image_outlined,
                        size: 50, color: Colors.grey[400]),
                  );
                },
              );
            },
          ),
          if (imageList.length > 1)
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: imageList.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: highlightColor, // Changed Color
                    dotColor: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Helper Widget: Section Title ---
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: highlightColor, size: 24), // Changed Color
        const SizedBox(width: 10),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // --- Helper Widget: Facilities Grid ---
  Widget _buildFacilitiesGrid(BuildContext context, List<String> facilities) {
    if (facilities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          ' ไม่มีข้อมูลสิ่งอำนวยความสะดวก',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 160).floor().clamp(2, 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 3 / 1.1,
      ),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        final icon = facilityIcons[facility] ??
            Icons.star; // Default to star if not found

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300), // Outline border
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, color: highlightColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  facility,
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widget: Info List (for Basic Info & Contact) ---
  Widget _buildInfoList(BuildContext context, List<String> infoItems,
      {bool isContact = false}) {
    if (infoItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          ' ไม่มีข้อมูล',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, // Kept zero padding
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        final info = infoItems[index];
        final bool isLink = isContact && _isUrl(info);

        IconData leadingIcon = Icons.chevron_right; // Default for basic info
        if (isContact) {
          if (info.contains('@') || info.toLowerCase().contains('email')) {
            leadingIcon = Icons.email_outlined;
          } else if (info.toLowerCase().contains('line') ||
              info.toLowerCase().contains('id:')) {
            leadingIcon = Icons.chat_bubble_outline;
          } else if (info.contains(RegExp(r'[0-9\-\+]{8,}'))) {
            leadingIcon = Icons.phone_outlined;
          } else if (isLink) {
            leadingIcon = Icons.link;
          } else {
            leadingIcon = Icons.person_outline;
          }
        }

        return ListTile(
          leading: Icon(leadingIcon,
              color: isContact
                  ? highlightColor // Changed Color for contact items
                  : Colors.grey.shade600, // Keep basic info icons grey
              size: 20),
          title: isLink
              ? InkWell(
                  onTap: () => _launchURL(info),
                  child: Text(
                    info,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.blue.shade700, // Keep links blue
                    ),
                  ),
                )
              : Text(info, style: textTheme.bodyLarge),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          dense: true,
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 40,
        endIndent: 10,
        color: Colors.grey.shade300,
      ),
    );
  }

  // --- Helper Widget: Bottom Price Bar ---
  Widget _buildBottomPriceBar(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final price = widget.dorm['price'] ?? 'N/A';

    return Material(
      elevation: 8.0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ราคาเริ่มต้น',
              style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(width: 10),
            Text(
              '$price ฿',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.green[700], // Changed Color
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / เดือน',
              style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
