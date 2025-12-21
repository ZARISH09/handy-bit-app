import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_model.dart';
import 'service_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceCategory> _categories = [];
  List<ServiceProvider> _allProviders = [];
  List<ServiceProvider> _filteredProviders = [];
  bool _isLoading = true;
  Position? _currentPosition;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _fetchCategoriesAndProviders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterProviders(_searchController.text);
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchCategoriesAndProviders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch categories
      final categorySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();

      if (categorySnapshot.docs.isEmpty) {
        // Use default categories if Firestore is empty
        _categories = [
          ServiceCategory(
            id: 'cleaning',
            name: 'Cleaning',
            icon: '🧹',
            color: const Color(0xFFDBEAFE),
          ),
          ServiceCategory(
            id: 'plumbing',
            name: 'Plumbing',
            icon: '🔧',
            color: const Color(0xFFCFFAFE),
          ),
          ServiceCategory(
            id: 'electrical',
            name: 'Electrical',
            icon: '⚡',
            color: const Color(0xFFFEF3C7),
          ),
          ServiceCategory(
            id: 'painting',
            name: 'Painting',
            icon: '🎨',
            color: const Color(0xFFE9D5FF),
          ),
          ServiceCategory(
            id: 'moving',
            name: 'Moving',
            icon: '🚚',
            color: const Color(0xFFD1FAE5),
          ),
          ServiceCategory(
            id: 'repair',
            name: 'Repair',
            icon: '🔨',
            color: const Color(0xFFFED7AA),
          ),
        ];
      } else {
        _categories = categorySnapshot.docs.map((doc) {
          final data = doc.data();
          return ServiceCategory(
            id: doc.id,
            name: data['name'] ?? '',
            icon: data['icon'] ?? '🛠️',
            color: Color(int.parse(data['color'].replaceFirst('#', '0xff'))),
          );
        }).toList();
      }

      // Fetch service providers
      final providerSnapshot =
      await FirebaseFirestore.instance.collection('service_providers').get();
      _allProviders = providerSnapshot.docs.map((doc) {
        final data = doc.data();
        double distance = 0;
        if (_currentPosition != null &&
            data['location'] != null &&
            data['location']['lat'] != null &&
            data['location']['lng'] != null) {
          distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            data['location']['lat'],
            data['location']['lng'],
          ) /
              1000; // in km
        }
        return ServiceProvider(
          id: doc.id,
          name: data['name'] ?? 'No Name',
          profession: data['category'] ?? 'No Category',
          rating: (data['rating'] ?? 0).toDouble(),
          reviewCount: data['reviewCount'] ?? 0,
          price: (data['price'] ?? 0).toDouble(),
          image: data['image'] ?? '',
          isAvailable: data['availability'] ?? true,
          distance: double.parse(distance.toStringAsFixed(1)),
          description: data['description'] ?? '',
          services: List<String>.from(data['services'] ?? []),
        );
      }).toList();

      _filteredProviders = _allProviders;
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProviders(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProviders = _allProviders;
      });
      return;
    }

    setState(() {
      _filteredProviders = _allProviders.where((provider) {
        final lowerQuery = query.toLowerCase();
        return provider.name.toLowerCase().contains(lowerQuery) ||
            provider.profession.toLowerCase().contains(lowerQuery) ||
            provider.services.any(
                    (service) => service.toLowerCase().contains(lowerQuery));
      }).toList();
    });
  }

  void _sortProviders(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Rating':
          _filteredProviders.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Distance':
          _filteredProviders.sort((a, b) => a.distance.compareTo(b.distance));
          break;
        case 'Price':
          _filteredProviders.sort((a, b) => a.price.compareTo(b.price));
          break;
        default:
          _filteredProviders = List.from(_allProviders);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF06B6D4),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (_searchController.text.isEmpty) _buildFilters(),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildDefaultView()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'HB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT LOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      'San Francisco, CA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF06B6D4),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1E293B),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What help do you\nneed today?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontFamily: 'Poppins',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search for 'electrician'...",
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontFamily: 'Inter',
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Rating', 'Distance', 'Price'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _sortProviders(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF06B6D4)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF06B6D4)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(_categories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    return GestureDetector(
      onTap: () {
        _searchController.text = category.name;
        _filterProviders(category.name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getCategorySubtitle(category.name),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategorySubtitle(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cleaning':
        return 'Home & Office';
      case 'plumbing':
        return 'Leaks & Pipes';
      case 'electrical':
        return 'Wiring & Fixes';
      case 'painting':
        return 'Walls & Decor';
      case 'moving':
        return 'Pack & Shift';
      case 'repair':
        return 'General Fixes';
      case 'ac repair':
        return 'Cooling & Heating';
      case 'carpentry':
        return 'Wood & Furniture';
      default:
        return 'Professional Service';
    }
  }

  Widget _buildSearchResults() {
    if (_filteredProviders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 60,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        return _buildSearchResultCard(_filteredProviders[index]);
      },
    );
  }

  Widget _buildSearchResultCard(ServiceProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(provider: provider),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF06B6D4).withOpacity(0.1),
                  ),
                  child: provider.image.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      provider.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF06B6D4),
                          size: 35,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    color: Color(0xFF06B6D4),
                    size: 35,
                  ),
                ),
                if (provider.isAvailable)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.profession,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.rating.toString(),
                              style: const TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF64748B),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${provider.distance} km',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${provider.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06B6D4),
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text(
                  '/hour',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: const Color(0xFFF59E0B),
          size: 14,
        );
      }),
    );
  }
}