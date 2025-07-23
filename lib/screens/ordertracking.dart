import 'package:flutter/material.dart';

import '../colors/colors.dart';

class OrderTrackingPage extends StatefulWidget {
  final int currentStep;

  const OrderTrackingPage({super.key, required this.currentStep});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String orderStatus;
    switch (widget.currentStep) {
      case 1:
        orderStatus = "Booked...";
        break;
      case 2:
        orderStatus = "In Progress...";
        break;
      case 3:
      default:
        orderStatus = "Completed...";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KGMS.kgmsWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KGMS.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Tracking',
          style: TextStyle(color: KGMS.primaryText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: KGMS.primaryText),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      backgroundColor: KGMS.surfaceGrey,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order is $orderStatus',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: KGMS.primaryText,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Step Progress Bar
            Row(
              children: [
                _buildStep(screenWidth, screenHeight, 1, "Booked",
                    widget.currentStep >= 1),
                _buildStepDivider(screenWidth, widget.currentStep >= 2),
                _buildStep(screenWidth, screenHeight, 2, "In Progress",
                    widget.currentStep >= 2),
                _buildStepDivider(screenWidth, widget.currentStep >= 3),
                _buildStep(screenWidth, screenHeight, 3, "Completed",
                    widget.currentStep >= 3),
              ],
            ),

            SizedBox(height: screenHeight * 0.04),

            // Order Details Card
            Card(
              color: KGMS.cardBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order # 2116191623',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: KGMS.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Service Name',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: KGMS.primaryText,
                      ),
                    ),
                    Text(
                      'Add-On',
                      style: TextStyle(
                        color: KGMS.primaryBlue,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    Text(
                      'Date Time',
                      style: TextStyle(
                        color: KGMS.secondaryText,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹ 500',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: KGMS.primaryText,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Lorem ipsum dolor sit amet consectetur. Fusce dui consectetur aenean pellentesque tincidunt.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: KGMS.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Leave a Review Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Leave a review functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KGMS.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.2,
                  ),
                ),
                child: Text(
                  'Leave a Review',
                  style: TextStyle(
                    color: KGMS.primaryText,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(double screenWidth, double screenHeight, int step,
      String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.1,
          height: screenHeight * 0.01,
          color: isActive ? KGMS.primaryBlue : KGMS.lightText,
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? KGMS.primaryBlue : KGMS.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(double screenWidth, bool isActive) {
    return Expanded(
      child: Container(
        height: screenWidth * 0.005,
        color: isActive ? KGMS.primaryBlue : KGMS.lightText,
      ),
    );
  }
}
