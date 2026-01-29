// search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dorm_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late DormProvider _dormProvider;

  // --- อัปเดต List ตัวเลือกตามที่ระบุ ---
  // (ยังคงแนะนำให้จัดกลุ่มตามความเหมาะสมใน UI แต่ใช้ List ตามที่คุณต้องการ)

  // เก็บประเภทที่พักที่ต้องการให้เลือกได้
  final List<String> types = [
    // 'หอพักนอก', 'คอนโด', 'หอพักใน', 'บ้านเช่า' // ตัวอย่างเดิม
    // <<< ใส่ประเภทที่ต้องการให้เลือกได้จริง เช่น:
    'หอพักนอก',
    'คอนโด'
    // ...
  ];

  // เก็บสิ่งอำนวยความสะดวก "ส่วนกลาง" ที่ต้องการให้เลือกได้
  final List<String> facilities = [
    'ฟิตเนส',
    'สระว่ายน้ำ',
    'ที่จอดรถ',
    'มีระบบ keycard',
    'ร้านซัก-รีด',
    'Co-working Space',
    'ร้านอาหาร',
    'ลิฟต์',
    'รปภ.',
    'CCTV',
    'ATM',
    'ใกล้ร้านสะดวกซื้อ',
    'มีระบบสแกนลายนิ้วมือ',
    'เครื่องซักผ้าอบผ้า',
    'ตู้แลกเหรียญ',
    'รถตู้รับส่ง',
    'ร้านทำผม',
  ];

  // เก็บประเภทเตียงที่ต้องการให้เลือกได้
  final List<String> bedTypes = [
    'เตียงเดี่ยว',
    'เตียงคู่',
    'เตียงนอน', // ตรวจสอบความหมาย
  ];

  // เก็บสิ่งอำนวยความสะดวก "ในห้อง" ที่ต้องการให้เลือกได้
  final List<String> roomFacilities = [
    'เครื่องปรับอากาศ',
    'เครื่องทำน้ำอุ่น',
    'ทีวี',
    'ตู้เย็น',
    'มีห้องครัว',
    'ไมโครเวฟ',
    'ประตู digital lock',
    'ซิงค์ล้างจาน',
    'ตู้เสื้อผ้า',
    'โต๊ะทำงาน',
    'อินเทอร์เน็ต (WIFI)',
  ];
  // ------------------------------------------------

  @override
  void initState() {
    /* ... initState เดิม ... */
    super.initState();
    _dormProvider = Provider.of<DormProvider>(context, listen: false);
    _searchController = TextEditingController(text: _dormProvider.uiSearchTerm);
    _searchController.addListener(_onSearchChanged);
    _dormProvider.addListener(_onProviderUpdate);
  }

  void _onSearchChanged() {
    _dormProvider.updateUISearchTerm(_searchController.text);
  }

  void _onProviderUpdate() {
    /* ... _onProviderUpdate เดิม ... */
    if (mounted) {
      if (_searchController.text != _dormProvider.uiSearchTerm) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _searchController.text != _dormProvider.uiSearchTerm) {
            _searchController.text = _dormProvider.uiSearchTerm;
          }
        });
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    /* ... dispose เดิม ... */
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _dormProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // ค่าปัจจุบัน
    final currentMinPrice = _dormProvider.uiMinPrice;
    final currentMaxPrice = _dormProvider.uiMaxPrice;
    final currentSelectedTypes = _dormProvider.uiSelectedTypes;
    final currentSelectedFacilities = _dormProvider.uiSelectedFacilities;
    final currentSelectedBedTypes = _dormProvider.uiSelectedBedTypes;
    final currentSelectedRoomFacilities =
        _dormProvider.uiSelectedRoomFacilities;

    return Scaffold(
      appBar: AppBar(
        /* ... AppBar เดิม ... */
        title: const Text('ตัวกรองค้นหา'),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        elevation: theme.appBarTheme.elevation ?? 1.0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "รีเซ็ตตัวกรอง",
              onPressed: _dormProvider.resetSearchPageFilters)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 ช่องค้นหา
              TextField(
                /* ... TextField เดิม ... */
                controller: _searchController,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อหอพัก...',
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(Icons.search,
                        color: theme.iconTheme.color?.withAlpha(178)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: colorScheme.outline.withAlpha(128))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: colorScheme.outline.withAlpha(128))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 1.5)),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 12.0)),
              ),
              const SizedBox(height: 24),

              // 🔹 ช่วงราคา
              Text('ช่วงราคา',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              RangeSlider(
                /* ... RangeSlider เดิม ... */
                values: RangeValues(currentMinPrice, currentMaxPrice),
                min: 0,
                max: 20000,
                divisions: 40,
                labels: RangeLabels('${currentMinPrice.toInt()} ฿',
                    '${currentMaxPrice.toInt()} ฿'),
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.primary.withAlpha(77),
                onChanged: (RangeValues values) {
                  setState(() {
                    _dormProvider.updateUIPriceRange(values.start, values.end);
                  });
                },
              ),
              const SizedBox(height: 16),

              // 🔹 ส่วน Filter อื่นๆ (ใช้ List ที่อัปเดตแล้ว)
              // แสดง Section ต่อเมื่อ List ตัวเลือกไม่ว่าง
              if (types.isNotEmpty)
                _buildFilterSection('ประเภทที่พัก', types, currentSelectedTypes,
                    _dormProvider.uiSelectedTypes),
              if (facilities.isNotEmpty)
                _buildFilterSection(
                    'สิ่งอำนวยความสะดวก',
                    facilities,
                    currentSelectedFacilities,
                    _dormProvider.uiSelectedFacilities),
              if (bedTypes.isNotEmpty)
                _buildFilterSection('ประเภทเตียง', bedTypes,
                    currentSelectedBedTypes, _dormProvider.uiSelectedBedTypes),
              if (roomFacilities.isNotEmpty)
                _buildFilterSection(
                    'สิ่งอำนวยความสะดวกในห้อง',
                    roomFacilities,
                    currentSelectedRoomFacilities,
                    _dormProvider.uiSelectedRoomFacilities),

              const SizedBox(height: 30),

              // 🔹 ปุ่ม "ใช้ตัวกรอง" และ "รีเซ็ต" ด้านล่าง
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      /* ... ปุ่ม ใช้ตัวกรอง เดิม ... */
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 60.0),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          elevation: 2.0),
                      onPressed: () {
                        _dormProvider.applyFiltersFromUIState();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: const Text('ใช้ตัวกรอง',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      /* ... ปุ่ม Reset เดิม ... */
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 40.0),
                        foregroundColor: colorScheme.onSurface.withAlpha(178),
                      ),
                      onPressed: _dormProvider.resetSearchPageFilters,
                      child: const Text('รีเซ็ตตัวกรอง',
                          style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget สำหรับสร้างส่วน Filter Section (ChoiceChip) ---
  Widget _buildFilterSection(String title, List<String> options,
      List<String> currentSelectedOptions, List<String> providerTargetList) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      /* ... โค้ดเดิม ... */
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
          child: Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: options.map((option) {
            final isSelected = currentSelectedOptions.contains(option);
            final chipBackgroundColor = isSelected
                ? colorScheme.primaryContainer.withAlpha(153)
                : colorScheme.surfaceContainerHighest;
            final chipLabelColor = isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant;
            final chipBorderColor = isSelected
                ? colorScheme.primary.withAlpha(128)
                : colorScheme.outline.withAlpha(77);
            final chipCheckmarkColor = colorScheme.onPrimaryContainer;

            return ChoiceChip(
              /* ... ChoiceChip เดิม ... */
              label: Text(option,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: chipLabelColor)),
              selected: isSelected,
              selectedColor: chipBackgroundColor,
              backgroundColor: chipBackgroundColor,
              checkmarkColor: chipCheckmarkColor,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: chipBorderColor)),
              onSelected: (selected) {
                setState(() {
                  _dormProvider.updateUISelection(
                      providerTargetList, option, selected);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
