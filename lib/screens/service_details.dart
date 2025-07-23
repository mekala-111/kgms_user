import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kgms_user/model/service.dart';
import '../colors/colors.dart';
import 'bookingstagepage.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Data service;
  final String productId;

  const ServiceDetailsPage({
    super.key,
    required this.service,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KGMS.kgmsWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KGMS.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Services',
          style: TextStyle(color: KGMS.primaryText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: KGMS.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: KGMS.surfaceGrey,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
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
                        service.name!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                          color: KGMS.primaryText,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                color: KGMS.warningOrange,
                                size: screenWidth * 0.04,
                              ),
                            ),
                          ),
                          Text(
                            ' (30)',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: KGMS.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '₹ ${service.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: KGMS.primaryText,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Details: ${service.details ?? "N/A"}',
                        style: TextStyle(
                          color: KGMS.primaryBlue,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Service Images Grid
              Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenWidth * 0.02,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: (screenWidth - screenWidth * 0.18) / 2,
                    height: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: KGMS.surfaceGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: KGMS.secondaryText.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Book Service Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingStagePage(
                          serviceId: service.sId!,
                          productId: productId,
                          serviceAmount: service.price,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KGMS.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                  child: Text(
                    'Book Service',
                    style: TextStyle(
                      color: KGMS.kgmsWhite,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Share Section
              Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                  color: KGMS.primaryText,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.facebook,
                      color: KGMS.primaryBlue,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.twitter,
                      color: KGMS.kgmsTeal,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.linked_camera,
                      color: KGMS.errorRed,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Reviews & Ratings Section
              Text(
                'Reviews & Ratings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: KGMS.primaryText,
                ),
              ),
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: KGMS.warningOrange,
                        size: screenWidth * 0.04,
                      ),
                    ),
                  ),
                  Text(
                    ' (30)',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: KGMS.secondaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildReviewFilterButtons(screenWidth),
              SizedBox(height: screenHeight * 0.02),

              // Review Cards
              ...List.generate(
                4,
                (index) => _buildReviewCard(screenWidth, screenHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewFilterButtons(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: KGMS.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Latest',
            style: TextStyle(
              color: KGMS.primaryText,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: KGMS.surfaceGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Ratings',
            style: TextStyle(
              color: KGMS.primaryText,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: KGMS.cardBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: KGMS.secondaryText.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.08,
            backgroundColor: KGMS.surfaceGrey,
            child: Icon(
              Icons.person,
              color: KGMS.secondaryText,
              size: screenWidth * 0.08,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    color: KGMS.primaryText,
                  ),
                ),
                Text(
                  'Verified Customer',
                  style: TextStyle(
                    color: KGMS.secondaryText,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: KGMS.warningOrange,
                      size: screenWidth * 0.035,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Lorem ipsum dolor sit amet consectetur. Duis diam suspendisse tristique pellentesque orci tristique id in felis.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: KGMS.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
