import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class DormProvider with ChangeNotifier {
  // --- สร้าง Logger Instance (แก้ไข printTime) ---
  final Logger logger = Logger(
      printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none, // <-- ใช้ DateTimeFormat.none
  ));
  // ----------------------------------------------

  List<Map<String, dynamic>> dormList = [];
  List<Map<String, dynamic>> filteredDorms = [];
  List<String> favoriteDorms = [];
  List<String> recentlyViewedDorms = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // State Filter UI
  String uiSearchTerm = '';
  double uiMinPrice = 0;
  double uiMaxPrice = 20000;
  List<String> uiSelectedTypes = [];
  List<String> uiSelectedFacilities = [];
  List<String> uiSelectedBedTypes = [];
  List<String> uiSelectedRoomFacilities = [];

  // Keys for SharedPreferences
  static const String _favKey = 'favoriteDormIds';
  static const String _recentKey = 'recentlyViewedDormIds';

  Future<void> loadInitialData() async {
    await _loadListsFromPrefs();
    await loadInitialDorms();
  }

  Future<void> _loadListsFromPrefs() async {
    logger.i("Loading Favorite/Recent lists from SharedPreferences...");
    try {
      final prefs = await SharedPreferences.getInstance();
      favoriteDorms = prefs.getStringList(_favKey) ?? [];
      recentlyViewedDorms = prefs.getStringList(_recentKey) ?? [];
      logger.i(
          "Loaded Favorites: ${favoriteDorms.length}, Recents: ${recentlyViewedDorms.length}");
    } catch (e, stackTrace) {
      logger.e("Error loading lists from SharedPreferences",
          error: e, stackTrace: stackTrace);
      favoriteDorms = [];
      recentlyViewedDorms = [];
    }
  }

  Future<void> _saveFavoriteList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favKey, favoriteDorms);
      logger.d("Saved Favorites: ${favoriteDorms.length}");
    } catch (e, stackTrace) {
      logger.e("Error saving favorite list", error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _saveRecentList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentKey, recentlyViewedDorms);
      logger.d("Saved Recents: ${recentlyViewedDorms.length}");
    } catch (e, stackTrace) {
      logger.e("Error saving recent list", error: e, stackTrace: stackTrace);
    }
  }

  // --- แก้ไข If Statement ให้มี Block ---
  void updateUISearchTerm(String value) {
    if (uiSearchTerm != value) {
      uiSearchTerm = value;
    }
  }

  void updateUIPriceRange(double min, double max) {
    uiMinPrice = min;
    uiMaxPrice = max;
  }

  void updateUISelection(
      List<String> targetList, String option, bool isSelected) {
    if (isSelected && !targetList.contains(option)) {
      targetList.add(option);
    } else if (!isSelected && targetList.contains(option)) {
      targetList.remove(option);
    }
  }

  void resetSearchPageFilters() {
    bool changed = uiSearchTerm.isNotEmpty ||
        uiMinPrice != 0 ||
        uiMaxPrice != 20000 ||
        uiSelectedTypes.isNotEmpty ||
        uiSelectedFacilities.isNotEmpty ||
        uiSelectedBedTypes.isNotEmpty ||
        uiSelectedRoomFacilities.isNotEmpty;
    uiSearchTerm = '';
    uiMinPrice = 0;
    uiMaxPrice = 20000;
    uiSelectedTypes.clear();
    uiSelectedFacilities.clear();
    uiSelectedBedTypes.clear();
    uiSelectedRoomFacilities.clear();
    if (changed) {
      notifyListeners();
    }
  }
  // -------------------------------------

  void applyFiltersFromUIState() {
    final filters = {
      'minPrice': uiMinPrice,
      'maxPrice': uiMaxPrice,
      'selectedTypes': List<String>.from(uiSelectedTypes),
      'selectedFacilities': List<String>.from(uiSelectedFacilities),
      'selectedBedTypes': List<String>.from(uiSelectedBedTypes),
      'selectedRoomFacilities': List<String>.from(uiSelectedRoomFacilities),
      'searchTerm': uiSearchTerm.trim(),
    };
    applyFilters(filters);
  }

  void _sortDormsByPopularity(List<Map<String, dynamic>> listToSort) {
    listToSort.sort((a, b) => (b['favoriteCount'] as int? ?? 0)
        .compareTo(a['favoriteCount'] as int? ?? 0));
  }

  Future<void> loadInitialDorms() async {
    // --- แก้ไข If Statement ให้มี Block ---
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    // -------------------------------------
    logger.i("Loading initial dorms from Firestore...");
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('dorms').get();
      dormList = snapshot.docs.map((doc) {
        final data = doc.data();
        // ... (โค้ด map data เหมือนเดิม) ...
        dynamic imageData = data['image'];
        String firstImageUrl = '';
        List<String> imageUrls = [];
        if (imageData is List &&
            imageData.isNotEmpty &&
            imageData.first is String)
          firstImageUrl = imageData.first;
        else if (imageData is String) firstImageUrl = imageData;
        if (imageData is String)
          imageUrls = [imageData];
        else if (imageData is List)
          imageUrls = List<String>.from(imageData.map((e) => e.toString()));
        List<String> basicInfoList = (data['basic_info'] is List)
            ? List<String>.from(data['basic_info'].map((e) => e.toString()))
            : [];
        List<String> contactList = (data['contact'] is List)
            ? List<String>.from(data['contact'].map((e) => e.toString()))
            : [];
        List<String> facilitiesList =
            List<String>.from(data['facilities'] ?? []);
        return {
          "id": doc.id,
          "name": data['name'] ?? '',
          "price": data['price']?.toString() ?? '',
          "type": data['type'] ?? '',
          "facilities": facilitiesList,
          "image": firstImageUrl,
          "images": imageUrls,
          "description": data['description'] ?? '',
          "basic_info": basicInfoList,
          "contact": contactList,
          "map": data['map'] ?? '',
          "favoriteCount": data['favoriteCount'] ?? 0,
        };
      }).toList();
      _sortDormsByPopularity(dormList);
      applyFiltersFromUIState();
      logger.i("Finished loading ${dormList.length} dorms.");
    } catch (e, stackTrace) {
      logger.e("Error loading dorms from Firestore",
          error: e, stackTrace: stackTrace);
      dormList = [];
      filteredDorms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters(Map<String, dynamic> filters) {
    logger.d("Applying filters in Provider: $filters");
    filteredDorms = dormList.where((dorm) {
      // --- แก้ไข If Statement ให้มี Block ---
      // Price Filter
      String priceString = dorm["price"]?.toString() ?? '';
      List<int> prices = priceString
          .split('-')
          .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
          .toList();
      int minDormPrice = prices.isNotEmpty ? prices.first : 0;
      int maxDormPrice = prices.length > 1 ? prices.last : minDormPrice;
      double filterMinPriceDouble = filters["minPrice"] as double? ?? 0.0;
      double filterMaxPriceDouble = filters["maxPrice"] as double? ?? 20000.0;
      int filterMinPrice = filterMinPriceDouble.toInt();
      int filterMaxPrice = filterMaxPriceDouble.toInt();
      bool priceMatch =
          maxDormPrice >= filterMinPrice && minDormPrice <= filterMaxPrice;
      if (!priceMatch) {
        return false;
      }

      // Type Filter
      String dormType = dorm["type"]?.toString() ?? '';
      List<String> selectedTypes =
          filters["selectedTypes"] as List<String>? ?? [];
      bool typeMatch =
          selectedTypes.isEmpty || selectedTypes.contains(dormType);
      if (!typeMatch) {
        return false;
      }

      // Combined Amenity Filter
      List<String> selectedFacilities =
          filters["selectedFacilities"] as List<String>? ?? [];
      List<String> selectedBedTypes =
          filters["selectedBedTypes"] as List<String>? ?? [];
      List<String> selectedRoomFacilities =
          filters["selectedRoomFacilities"] as List<String>? ?? [];
      List<String> allSelectedAmenities = [
        ...selectedFacilities,
        ...selectedBedTypes,
        ...selectedRoomFacilities
      ];
      if (allSelectedAmenities.isNotEmpty) {
        List<String> dormFacilities =
            List<String>.from(dorm["facilities"] ?? []);
        bool amenitiesMatch =
            allSelectedAmenities.every((req) => dormFacilities.contains(req));
        if (!amenitiesMatch) {
          return false;
        }
      }

      // Search Term Filter
      String searchTerm =
          filters['searchTerm']?.toString().toLowerCase().trim() ?? '';
      if (searchTerm.isNotEmpty) {
        String dormName = dorm['name']?.toString().toLowerCase() ?? '';
        bool nameMatch = dormName.contains(searchTerm);
        if (!nameMatch) {
          return false;
        }
      }
      // -------------------------------------
      return true;
    }).toList();
    _sortDormsByPopularity(filteredDorms);
    logger.i("Filtering complete. ${filteredDorms.length} dorms match.");
    notifyListeners();
  }

  void resetFilters() {
    logger.i("Resetting filters...");
    resetSearchPageFilters();
    applyFiltersFromUIState();
  }

  void toggleFavorite(String dormId) async {
    logger.d("Toggling favorite for dorm ID: $dormId");
    try {
      final dormIndex = dormList.indexWhere((d) => d['id'] == dormId);
      final filteredIndex = filteredDorms.indexWhere((d) => d['id'] == dormId);
      // --- แก้ไข If Statement ให้มี Block ---
      if (dormIndex == -1) {
        logger.w("Dorm ID not found in dormList: $dormId");
        return;
      }
      // -------------------------------------
      final ref = FirebaseFirestore.instance.collection('dorms').doc(dormId);
      int change = 0;
      int currentCount = dormList[dormIndex]['favoriteCount'] ?? 0;
      String action;
      if (favoriteDorms.contains(dormId)) {
        favoriteDorms.remove(dormId);
        change = -1;
        dormList[dormIndex]['favoriteCount'] =
            (currentCount > 0) ? currentCount - 1 : 0;
        action = "Removed";
      } else {
        favoriteDorms.add(dormId);
        change = 1;
        dormList[dormIndex]['favoriteCount'] = currentCount + 1;
        action = "Added";
      }
      logger.d(
          "Action: $action, New local count: ${dormList[dormIndex]['favoriteCount']}");
      try {
        await ref.update({'favoriteCount': FieldValue.increment(change)});
        logger.d("Firestore favoriteCount updated successfully.");
      } catch (fsError, stackTrace) {
        logger.e("Firestore update error",
            error: fsError, stackTrace: stackTrace);
        // --- แก้ไข If Statement ให้มี Block ---
        if (change == 1) {
          favoriteDorms.remove(dormId);
          dormList[dormIndex]['favoriteCount'] = currentCount;
        } else if (change == -1) {
          favoriteDorms.add(dormId);
          dormList[dormIndex]['favoriteCount'] = currentCount;
        }
        if (filteredIndex != -1) {
          filteredDorms[filteredIndex]['favoriteCount'] =
              dormList[dormIndex]['favoriteCount'];
        }
        // -------------------------------------
        notifyListeners();
        return;
      }
      // --- แก้ไข If Statement ให้มี Block ---
      if (filteredIndex != -1) {
        filteredDorms[filteredIndex]['favoriteCount'] =
            dormList[dormIndex]['favoriteCount'];
      }
      // -------------------------------------
      await _saveFavoriteList();
      notifyListeners();
    } catch (e, stackTrace) {
      logger.e("Error toggling favorite", error: e, stackTrace: stackTrace);
    }
  }

  void addRecentlyViewed(String dormId) async {
    // --- แก้ไข If Statement ให้มี Block ---
    if (dormId.isEmpty) {
      logger.w("Attempted to add empty dormId to recently viewed.");
      return;
    }
    // -------------------------------------
    logger.d("Adding dorm ID to recently viewed: $dormId");
    recentlyViewedDorms.remove(dormId);
    recentlyViewedDorms.insert(0, dormId);
    // --- แก้ไข If Statement ให้มี Block ---
    if (recentlyViewedDorms.length > 5) {
      recentlyViewedDorms.removeLast();
    }
    // -------------------------------------
    await _saveRecentList();
    notifyListeners();
  }
}
