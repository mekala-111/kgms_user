import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/product.dart';
import 'package:kgms_user/providers/products.dart';
import 'package:kgms_user/screens/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors/colors.dart';

class ProductsDetails extends ConsumerStatefulWidget {
  final Data product;
  final VoidCallback updateCartCount;

  const ProductsDetails({
    super.key,
    required this.product,
    required this.updateCartCount,
  });

  @override
  ConsumerState<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends ConsumerState<ProductsDetails> {
  int _currentImageIndex = 0;
  bool _isInCart = false;
  List<Data> similarProducts = [];

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
  }

  @override
  void didUpdateWidget(covariant ProductsDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.productId != widget.product.productId) {
      _checkCartStatus();
      _filterSimilarProducts();
    }
  }

  Future<void> _checkCartStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartItems = prefs.getStringList('cartItems') ?? [];

      final cartKey =
          "${widget.product.productId}_${widget.product.distributorId}";

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isInCart = cartItems.contains(cartKey);
        });
      }
    } catch (e) {
      // Handle error silently or log it
      debugPrint('Error checking cart status: $e');
    }
  }

  Future<void> _addToCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartItems = prefs.getStringList('cartItems') ?? [];

      final cartKey =
          "${widget.product.productId}_${widget.product.distributorId}";

      if (!cartItems.contains(cartKey)) {
        cartItems.add(cartKey);
        await prefs.setStringList('cartItems', cartItems);

        // Check if widget is still mounted before using BuildContext
        if (mounted) {
          setState(() {
            _isInCart = true;
          });

          widget.updateCartCount();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item added in cart"),
              duration: Duration(seconds: 2),
              backgroundColor: KGMS.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      // Handle error and show feedback only if widget is mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add item to cart"),
            duration: Duration(seconds: 2),
            backgroundColor: KGMS.errorRed,
          ),
        );
      }
      debugPrint('Error adding to cart: $e');
    }
  }

  void _filterSimilarProducts() {
    final allProducts = ref.read(productProvider).data ?? [];
    final currentCategory = widget.product.categoryName?.trim().toLowerCase();

    final filtered = allProducts
        .where(
          (p) =>
              p.productId != widget.product.productId &&
              p.categoryName?.trim().toLowerCase() == currentCategory,
        )
        .toList();

    // Check if widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        similarProducts = filtered;
      });
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _navigateToProduct(Data product) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsDetails(
          product: product,
          updateCartCount: widget.updateCartCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    if (productState is AsyncLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: KGMS.primaryBlue)),
      );
    }

    if (productState is AsyncError) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Failed to load products",
            style: TextStyle(color: KGMS.errorRed),
          ),
        ),
      );
    }

    final allProducts = productState.data ?? [];

    if (similarProducts.isEmpty && allProducts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filterSimilarProducts();
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KGMS.kgmsTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KGMS.kgmsWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.productName ?? 'Product Name',
          style: const TextStyle(color: KGMS.kgmsWhite),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: KGMS.kgmsWhite),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: KGMS.kgmsWhite),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: KGMS.kgmsWhite),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: KGMS.surfaceGrey,
      body: ListView(
        children: [
          Container(
            height: 300,
            color: KGMS.cardBackground,
            child:
                widget.product.productImages != null &&
                    widget.product.productImages!.isNotEmpty
                ? Image.network(
                    widget.product.productImages![_currentImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image,
                      size: 120,
                      color: KGMS.lightText,
                    ),
                  )
                : const Center(
                    child: Text(
                      'No IMAGE',
                      style: TextStyle(color: KGMS.secondaryText),
                    ),
                  ),
          ),
          _buildHorizontalProductImages(widget.product.productImages),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: KGMS.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.productName ?? 'Product Title',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.star, color: KGMS.warningOrange),
                            Text(
                              '4.5',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: KGMS.primaryText,
                              ),
                            ),
                            Text(
                              '(150 ratings)',
                              style: TextStyle(color: KGMS.secondaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.price != null
                              ? '₹${(widget.product.price! * 1.10).toStringAsFixed(2)}'
                              : 'Price not available',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.productDescription ?? 'Description',
                          style: const TextStyle(color: KGMS.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: KGMS.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About the item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.productDescription ??
                              'Detailed description goes here. Replace with actual description.',
                          style: const TextStyle(color: KGMS.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        Table(
                          children: [
                            TableRow(
                              children: [
                                const Text(
                                  'Brand',
                                  style: TextStyle(color: KGMS.primaryText),
                                ),
                                Text(
                                  widget.product.categoryName ?? 'Brand Name',
                                  style: const TextStyle(
                                    color: KGMS.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(color: KGMS.primaryText),
                                ),
                                Text(
                                  widget.product.categoryName ?? 'Category',
                                  style: const TextStyle(
                                    color: KGMS.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const Text(
                                  'Distributor',
                                  style: TextStyle(color: KGMS.primaryText),
                                ),
                                Text(
                                  widget.product.productName ?? 'Distributor',
                                  style: const TextStyle(
                                    color: KGMS.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: KGMS.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Reviews',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.star, color: KGMS.warningOrange),
                            Text(
                              '4.5',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: KGMS.primaryText,
                              ),
                            ),
                            Text(
                              '(150 ratings)',
                              style: TextStyle(color: KGMS.secondaryText),
                            ),
                          ],
                        ),
                        _buildRatingBar('5 star', 80),
                        _buildRatingBar('4 star', 50),
                        _buildRatingBar('3 star', 10),
                        _buildRatingBar('2 star', 5),
                        _buildRatingBar('1 star', 5),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Similar Products',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: KGMS.primaryText,
                  ),
                ),
                _buildHorizontalProductList(similarProducts),
                const SizedBox(height: 16),
                const Text(
                  'Frequently Bought Together',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: KGMS.primaryText,
                  ),
                ),
                _buildHorizontalbookedProductList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _isInCart ? _navigateToCart : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isInCart
                            ? KGMS.warningOrange
                            : KGMS.kgmsTeal,
                        minimumSize: const Size(150, 50),
                      ),
                      child: Text(
                        _isInCart ? 'Go to Cart' : 'Add to Cart',
                        style: const TextStyle(
                          color: KGMS.kgmsWhite,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: KGMS.primaryText)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: KGMS.surfaceGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(
                KGMS.warningOrange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value', style: const TextStyle(color: KGMS.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(List<Data> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No similar products found",
          style: TextStyle(color: KGMS.secondaryText),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => _navigateToProduct(product),
            child: Container(
              width: 150,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: KGMS.cardBackground,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: KGMS.secondaryText.withValues(alpha: 0.3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  product.productImages != null &&
                          product.productImages!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Image.network(
                            product.productImages![0],
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 100,
                                  color: KGMS.surfaceGrey,
                                  child: const Icon(
                                    Icons.image,
                                    color: KGMS.lightText,
                                  ),
                                ),
                          ),
                        )
                      : Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            color: KGMS.surfaceGrey,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.image, color: KGMS.lightText),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product.productName ?? "Product",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: KGMS.primaryText),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      product.price != null
                          ? '₹${(product.price! + product.price! * 0.10).toStringAsFixed(2)}'
                          : 'Price N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: KGMS.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalbookedProductList() {
    return Container(
      height: 200,
      color: KGMS.surfaceGrey,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KGMS.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Product $index',
                style: const TextStyle(color: KGMS.primaryText),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductImages(List<String>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No images available",
            style: TextStyle(color: KGMS.secondaryText),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentImageIndex == index
                      ? KGMS.primaryBlue
                      : KGMS.lightText,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, color: KGMS.lightText),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
