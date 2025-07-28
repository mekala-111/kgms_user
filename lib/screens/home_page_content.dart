import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/service.dart';
import 'package:kgms_user/providers/product_services.dart';
import 'package:kgms_user/providers/products.dart';
import 'package:kgms_user/providers/getservice.dart';
import 'package:kgms_user/screens/products_screen.dart';
import 'package:kgms_user/screens/service_details.dart';

import '../colors/colors.dart';

class HomePageContent extends ConsumerStatefulWidget {
  final Function(int) onCategorySelected;

  const HomePageContent({super.key, required this.onCategorySelected});

  @override
  HomePageContentState createState() => HomePageContentState();
}

class HomePageContentState extends ConsumerState<HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  late String productId;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _scrollController.animateTo(
          100.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
      ref.read(serviceProvider.notifier).getSevices();
      ref.read(productserviceprovider.notifier).getproductSevices();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final productState = ref.watch(productProvider);
    final serviceState = ref.watch(serviceProvider);

    // Get categories from products
    List<String> categories =
        productState.data
            ?.map((product) => product.categoryName)
            .whereType<String>()
            .toSet()
            .toList() ??
        [];

    // Apply search filtering
    List<String> filteredCategories = categories
        .where(
          (category) =>
              category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    // Filter services based on search query
    List<Data> filteredServices =
        serviceState.data
            ?.where(
              (service) => service.name!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList() ??
        [];

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            SizedBox(height: screenHeight * 0.02),
            if (filteredCategories.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    color: KGMS.primaryBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'KGMS Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KGMS.primaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildCategoryList(filteredCategories),
              SizedBox(height: screenHeight * 0.02),
            ],
            const Row(
              children: [
                Icon(
                  Icons.handyman_rounded,
                  color: KGMS.primaryGreen,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Featured Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: KGMS.primaryText,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            filteredServices.isNotEmpty
                ? _buildFeaturedServices(
                    screenWidth,
                    screenHeight,
                    filteredServices,
                    ref
                  )
                : const Center(
                    child: Text(
                      "No services available",
                      style: TextStyle(color: KGMS.secondaryText),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [KGMS.lightBlue, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: KGMS.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search for services',
          hintStyle: const TextStyle(color: KGMS.secondaryText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: const Icon(Icons.search_rounded, color: KGMS.primaryBlue),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildCategoryList(List<String> categories) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductsScreen(selectedCategory: categories[index]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [KGMS.primaryBlue, KGMS.kgmsTeal],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: KGMS.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedServices(
    double screenWidth,
    double screenHeight,
    List<Data> services,
    WidgetRef ref,
  ) {
    return SizedBox(
      height: screenHeight * 0.6,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: ServiceCard(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              service: services[index],
              ref: ref,
            ),
          );
        },
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.service,
    required this.ref,

  });

  final double screenWidth;
  final double screenHeight;
  final Data service;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
     String servicedetails = _truncateText(service.details ?? "no description", 30);
    return Container(
      height: screenHeight * 0.2,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, KGMS.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KGMS.primaryBlue.withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: KGMS.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KGMS.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    service.name ?? 'Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: KGMS.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Star rating
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '4.8 (120+ reviews)',
                  style: TextStyle(color: KGMS.secondaryText, fontSize: 12),
                ),
              ],
            ),

            // Service details
            Text(
              servicedetails,
              style: const TextStyle(
                color: KGMS.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Price and book button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: KGMS.primaryGreen,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    service.price != null ? '₹${service.price}' : 'Price N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
               child: ElevatedButton(
              onPressed: () {
                _showProductSelectionDialog(context, service,ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),

              )

              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showProductSelectionDialog(BuildContext context, Data service,WidgetRef ref) {
  final productData = ref.read(productserviceprovider).data ?? [];

  // Filter product data by matching productIds
  final matchingProducts = productData
      .where((product) => service.productIds?.contains(product.productId) ?? false)
      .toList();

  String? selectedProductId = matchingProducts.isNotEmpty
      ? matchingProducts.first.productId
      : null;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Product"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: matchingProducts.map((product) {
                  return RadioListTile<String>(
                    title: Text(product.productName ?? "Unnamed Product"),
                    value: product.productId ?? "",
                    groupValue: selectedProductId,
                    onChanged: (value) {
                      setState(() {
                        selectedProductId = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedProductId != null) {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailsPage(
                          service: service,
                          productId: selectedProductId!,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Book"),
              ),
            ],
          );
        },
      );
    },
  );
}

  String _truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
  }
}
