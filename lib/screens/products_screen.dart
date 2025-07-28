import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/product.dart';
import 'package:kgms_user/providers/products.dart';
import 'package:kgms_user/screens/cart_screen.dart';
import 'package:kgms_user/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:kgms_user/screens/products_details.dart";
import '../colors/colors.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String selectedCategory;
  const ProductsScreen({super.key, required this.selectedCategory});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends ConsumerState<ProductsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  int cartItemCount = 0;
  bool _isInitialized = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
  try {
    final productState = ref.read(productProvider);

    // Only fetch if data hasn't been loaded yet
    if (productState.data == null || productState.data!.isEmpty) {
      await ref.read(productProvider.notifier).fetchProducts();
    }

    if (mounted) {
      _setupCategories();
    }
  } catch (e) {
    debugPrint('Error initializing product data: $e');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load products. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _refreshData() async {
  try {
    ref.read(productProvider.notifier).reset(); // Force re-fetch
    await ref.read(productProvider.notifier).fetchProducts();

    if (mounted) {
      _setupCategories(); // Rebuild categories/tabs after refresh
    }
  } catch (e) {
    debugPrint('Error refreshing products: $e');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to refresh products."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  void _setupCategories() {
    final productState = ref.read(productProvider);

    if (productState.data != null) {
      setState(() {
        _categories = ["ALL"];
        _categories.addAll(
          productState.data!
              .map((p) => p.categoryName)
              .whereType<String>()
              .toSet()
              .toList(),
        );

        _initializeTabController();
        _isInitialized = true;
      });
    }
  }

  void _initializeTabController() {
    _tabController?.dispose();

    int initialIndex = _categories.indexOf(widget.selectedCategory);
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItemCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cartItems = prefs.getStringList('cartItems') ?? [];
      if (mounted) {
        setState(() {
          cartItemCount = cartItems.length;
        });
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Error loading cart item count: $e');

      // Set default value and continue gracefully
      if (mounted) {
        setState(() {
          cartItemCount = 0;
        });
      }
    }
  }

  void _updateCartCount() {
    _loadCartItemCount();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _tabController == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 5),
          _buildTabBar(),
         Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map(
                (category) {
                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: _buildCategoryContent(category, _updateCartCount),
                  );
                },
              ).toList(),
            ),
          ),

        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      ),
      title: _buildSearchBar(),
      actions: [_buildCartButton()],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: KGMS.primaryBlue),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: "Search Products",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: KGMS.secondaryText),
              onPressed: _clearSearch,
            ),
          const Icon(Icons.mic_rounded, color: KGMS.secondaryText),
          const Icon(Icons.camera_alt_rounded, color: KGMS.secondaryText),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
                _updateCartCount();
              },
            ),
          ),
          if (cartItemCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KGMS.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '$cartItemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: KGMS.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: KGMS.primaryGreen,
        indicatorWeight: 3,
        labelColor: KGMS.primaryBlue,
        unselectedLabelColor: KGMS.secondaryText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        isScrollable: true,
        tabs: _categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  Widget _buildCategoryContent(String category, VoidCallback updateCartCount) {
    final productState = ref.watch(productProvider);
    final allProducts = productState.data ?? [];

    final filteredProducts = allProducts.where((p) {
      final matchesCategory = category == "ALL" || p.categoryName == category;
      final isTopLevel = p.parentId == null;
      return matchesCategory && isTopLevel;
    }).toList();

    final searchedProducts = filteredProducts
        .where(
          (p) =>
              _searchQuery.isEmpty ||
              (p.productName?.toLowerCase().contains(_searchQuery) ?? false) ||
              (p.categoryName?.toLowerCase().contains(_searchQuery) ?? false),
        )
        .toList();

    if (searchedProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: KGMS.secondaryText),
        ),
      );
    }

    return Container(
      color: KGMS.kgmsWhite,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: searchedProducts.length,
        itemBuilder: (context, index) =>
            _buildProductCard(searchedProducts[index], updateCartCount),
      ),
    );
  }

  Widget _buildProductCard(Data product, VoidCallback updateCartCount) {
    return FutureBuilder<List<String>>(
      future: _getCartItems(),
      builder: (context, snapshot) {
        String cartItemKey = "${product.productId}_${product.distributorId}";
        bool isInCart =
            snapshot.hasData && snapshot.data!.contains(cartItemKey);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
          child: InkWell(
            onTap: () => _navigateToProductDetails(product, updateCartCount),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.white, KGMS.lightBlue.withValues(alpha: 0.3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: KGMS.primaryBlue.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(product, constraints.maxHeight * 0.45),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildProductInfo(product)),
                              _buildAddToCartButton(
                                product,
                                isInCart,
                                updateCartCount,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Data product, [double? height]) {
    final imageHeight = height ?? 120.0;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Stack(
        children: [
          Image.network(
            (product.productImages?.isNotEmpty ?? false)
                ? product.productImages!.first
                : '',
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: imageHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [KGMS.lightBlue, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 40,
                color: KGMS.primaryBlue,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: KGMS.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.categoryName ?? 'KGMS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Data product) {
    String truncatedName = _truncateText(product.productName ?? '', 15);
    String truncatedDescription = _truncateText(
      product.productDescription ?? '',
      20,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          truncatedName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: KGMS.primaryText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1.0),
        Text(
          truncatedDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: KGMS.secondaryText, fontSize: 10),
        ),
        const SizedBox(height: 3),
        if (product.price != null)
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //   decoration: BoxDecoration(
          //     color: KGMS.primaryGreen.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Text(
          //     "₹${(product.price! * 1.10).toStringAsFixed(2)}",
          //     style: const TextStyle(
          //       color: KGMS.primaryGreen,
          //       fontWeight: FontWeight.bold,
          //       fontSize: 12,
          //     ),
          //   ),
          // ),
           Text(
              "₹${(product.price! * 1.10).toStringAsFixed(2)}",
              style: const TextStyle(
                color: KGMS.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.inventory_2_rounded,
              size: 12,
              color: KGMS.primaryBlue,
            ),
            const SizedBox(width: 4),
            Text(
              "Qty: ${product.quantity ?? 0}",
              style: const TextStyle(
                color: KGMS.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //   Widget _buildAddToCartButton(Data product, bool isInCart, VoidCallback updateCartCount) {
  //   return SizedBox(
  //     height: 32, // Fixed smaller height
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: isInCart ? Colors.orange : const Color(0xFF1BA4CA),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  //         padding: const EdgeInsets.symmetric(horizontal: 8),
  //       ),
  //       onPressed: () => _handleCartButtonPress(product, isInCart, updateCartCount),
  //       child: Text(
  //         isInCart ? "Go to Cart" : "Add to Cart",
  //         style: const TextStyle(color: Colors.white, fontSize: 11),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildAddToCartButton(
    Data product,
    bool isInCart,
    VoidCallback updateCartCount,
  ) {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isInCart
              ? [Colors.orange, Colors.deepOrange]
              : [KGMS.kgmsTeal, KGMS.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (isInCart ? Colors.orange : KGMS.primaryBlue).withValues(
              alpha: 0.3,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: () =>
            _handleCartButtonPress(product, isInCart, updateCartCount),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isInCart
                  ? Icons.shopping_cart_checkout_rounded
                  : Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              isInCart ? "Go to Cart" : "Add to Cart",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
  }

  Future<void> _navigateToProductDetails(
    Data product,
    VoidCallback updateCartCount,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductsDetails(product: product, updateCartCount: updateCartCount),
      ),
    );
    updateCartCount();
  }

  Future<void> _handleCartButtonPress(
    Data product,
    bool isInCart,
    VoidCallback updateCartCount,
  ) async {
    if (isInCart) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      updateCartCount();
    } else {
      await _addToCart(product.productId!, product.distributorId!);
      updateCartCount();
    }
  }

  Future<List<String>> _getCartItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('cartItems') ?? [];
    } catch (e) {
      // Log error for debugging
      debugPrint('Error getting cart items: $e');

      // Return empty list as fallback
      return [];
    }
  }

  Future<void> _addToCart(String productId, String distributorId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cartItems = prefs.getStringList('cartItems') ?? [];

      String cartItemKey = "${productId}_$distributorId";

      if (!cartItems.contains(cartItemKey)) {
        cartItems.add(cartItemKey);
        await prefs.setStringList('cartItems', cartItems);

        if (mounted) {
          setState(() {
            cartItemCount = cartItems.length;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Item added to cart"),
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: KGMS.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Error adding item to cart: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error adding item to cart. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
