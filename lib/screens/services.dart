import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/providers/product_services.dart';
import 'package:kgms_user/providers/getservice.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/screens/mybookedservices.dart';
import 'package:kgms_user/screens/service_details.dart';
import 'package:kgms_user/model/service.dart' as service_model;
import 'package:kgms_user/model/getservices.dart' as product_model;
import '../colors/colors.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends ConsumerState<ServicesPage> {
  @override

void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final productState = ref.read(productserviceprovider);
    final serviceState = ref.read(serviceProvider);

    if (productState.data == null || productState.data!.isEmpty) {
      ref.read(productserviceprovider.notifier).getproductSevices();
    }
    if (serviceState.data == null || serviceState.data!.isEmpty) {
      ref.read(serviceProvider.notifier).getSevices();
    }
  });
}


  Future<void> _loadProducts() async {
  ref.read(productserviceprovider.notifier).reset();
  ref.read(serviceProvider.notifier).reset();

  await ref.read(productserviceprovider.notifier).getproductSevices();
  await ref.read(serviceProvider.notifier).getSevices();
}

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productserviceprovider);
    final serviceState = ref.watch(serviceProvider);
    final isLoading = ref.watch(loadingProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
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
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
              ),
              child: Icon(
                Icons.room_service_rounded,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              'Services',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: screenWidth * 0.02),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KGMS.primaryGreen, KGMS.kgmsTeal],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyServicesPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: screenWidth * 0.045,
              ),
              label: Text(
                "My Services",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.03,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.01,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: KGMS.kgmsWhite,
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          color: KGMS.primaryBlue,
          backgroundColor: Colors.white,
          child:
              isLoading ||
                  productState.data == null ||
                  serviceState.data == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: KGMS.primaryBlue,
                    strokeWidth: 3,
                  ),
                )
              : Builder(
                  builder: (context) {
                    final filteredProducts = productState.data!.where((
                      product,
                    ) {
                      return serviceState.data!.any(
                        (service) =>
                            service.productIds!.contains(product.productId),
                      );
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState(screenWidth, screenHeight);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final productServices = serviceState.data!
                            .where(
                              (service) => service.productIds!.contains(
                                product.productId,
                              ),
                            )
                            .toList();

                        return ProductCard(
                          product: product,
                          services: productServices,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: KGMS.lightBlue,
                borderRadius: BorderRadius.circular(screenWidth * 0.125),
              ),
              child: Icon(
                Icons.room_service_outlined,
                size: screenWidth * 0.15,
                color: KGMS.primaryBlue,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'No Services Available',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: KGMS.primaryText,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'No services are currently available for any products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: KGMS.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final product_model.Data product;
  final List<service_model.Data> services;
  final double screenWidth;
  final double screenHeight;

  const ProductCard({
    super.key,
    required this.product,
    required this.services,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.0375),
      ),
      elevation: 3,
      shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.0375),
          gradient: LinearGradient(
            colors: [Colors.white, KGMS.lightBlue.withValues(alpha: 0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: KGMS.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: KGMS.primaryBlue,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName ?? 'Unnamed Product',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: KGMS.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.03,
                            ),
                          ),
                          child: Text(
                            '${services.length} Services Available',
                            style: TextStyle(
                              color: KGMS.primaryGreen,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              ...services.map(
                (service) => ServiceItem(
                  service: service,
                  productId: product.productId ?? '',
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final service_model.Data service;
  final String productId;
  final double screenWidth;
  final double screenHeight;

  const ServiceItem({
    super.key,
    required this.service,
    required this.productId,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.0075),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KGMS.lightGreen, Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: KGMS.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: KGMS.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        leading: Container(
          padding: EdgeInsets.all(screenWidth * 0.02),
          decoration: BoxDecoration(
            color: KGMS.primaryGreen,
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
          ),
          child: Icon(
            Icons.room_service_rounded,
            color: Colors.white,
            size: screenWidth * 0.05,
          ),
        ),
        title: Text(
          service.name ?? 'Unnamed Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: KGMS.primaryText,
            fontSize: screenWidth * 0.04,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                Icon(
                  Icons.currency_rupee_rounded,
                  size: screenWidth * 0.04,
                  color: KGMS.primaryGreen,
                ),
                Flexible(
                  child: Text(
                    "Price: ₹${service.price}",
                    style: TextStyle(
                      color: KGMS.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                // Constrain the stars to prevent overflow
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      4,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: screenWidth * 0.035,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.007),
                Flexible(
                  flex: 3,
                  child: Text(
                    '4.8 (120+ reviews)',
                    style: TextStyle(
                      color: KGMS.secondaryText,
                      fontSize: screenWidth * 0.03,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.0625),
            boxShadow: [
              BoxShadow(
                color: KGMS.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: screenWidth * 0.05,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(
                    service: service,
                    productId: productId,
                  ),
                ),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.0625),
              ),
              minimumSize: Size(screenWidth * 0.1, screenWidth * 0.1),
            ),
          ),
        ),
      ),
    );
  }
}
