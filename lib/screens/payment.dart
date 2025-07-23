import 'package:flutter/material.dart';

import '../colors/colors.dart';

class PaymentPage extends StatefulWidget {
  final String address;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const PaymentPage({
    super.key,
    required this.address,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool isCardSelected = true;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _cardNumberController.dispose();
    _upiController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _togglePaymentMethod(bool isCard) {
    setState(() {
      isCardSelected = isCard;
      _cardNumberController.clear();
      _upiController.clear();
      _expiryMonthController.clear();
      _expiryYearController.clear();
      _cvvController.clear();
    });
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing payment...'),
          backgroundColor: KGMS.primaryBlue,
        ),
      );
    }
  }

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
          'Payment',
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
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          'Address: ${widget.address}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: KGMS.primaryText,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Date: ${widget.selectedDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: KGMS.secondaryText,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Time: ${widget.selectedTime.format(context)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: KGMS.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Payment Method Selection
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                    color: KGMS.primaryText,
                  ),
                ),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isCardSelected,
                      onChanged: (value) => _togglePaymentMethod(true),
                      activeColor: KGMS.primaryBlue,
                    ),
                    Text(
                      'Card',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: KGMS.primaryText,
                      ),
                    ),
                    Radio<bool>(
                      value: false,
                      groupValue: isCardSelected,
                      onChanged: (value) => _togglePaymentMethod(false),
                      activeColor: KGMS.primaryBlue,
                    ),
                    Text(
                      'UPI',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: KGMS.primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Card or UPI Input Fields
                if (isCardSelected)
                  _buildCardFields(screenWidth, screenHeight)
                else
                  _buildUpiFields(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.04),

                // Pay Now Button
                Center(
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KGMS.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.3,
                      ),
                    ),
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: KGMS.kgmsWhite,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFields(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _cardNumberController,
          style: const TextStyle(color: KGMS.primaryText),
          decoration: InputDecoration(
            hintText: 'Enter Card Number',
            hintStyle: const TextStyle(color: KGMS.lightText),
            filled: true,
            fillColor: KGMS.surfaceGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: KGMS.secondaryText),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: KGMS.primaryBlue),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Card number is required';
            }
            if (value.length != 16) {
              return 'Enter a valid 16-digit card number';
            }
            return null;
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonthController,
                style: const TextStyle(color: KGMS.primaryText),
                decoration: InputDecoration(
                  hintText: 'MM',
                  hintStyle: const TextStyle(color: KGMS.lightText),
                  filled: true,
                  fillColor: KGMS.surfaceGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KGMS.secondaryText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KGMS.primaryBlue),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final month = int.tryParse(value);
                  if (month == null || month < 1 || month > 12) {
                    return 'Invalid month';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextFormField(
                controller: _expiryYearController,
                style: const TextStyle(color: KGMS.primaryText),
                decoration: InputDecoration(
                  hintText: 'YY',
                  hintStyle: const TextStyle(color: KGMS.lightText),
                  filled: true,
                  fillColor: KGMS.surfaceGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KGMS.secondaryText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KGMS.primaryBlue),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final year = int.tryParse(value);
                  if (year == null) {
                    return 'Invalid year';
                  }
                  final currentYear = DateTime.now().year % 100;
                  if (year < currentYear) {
                    return 'Card expired';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                style: const TextStyle(color: KGMS.primaryText),
                decoration: InputDecoration(
                  hintText: 'CVV',
                  hintStyle: const TextStyle(color: KGMS.lightText),
                  filled: true,
                  fillColor: KGMS.surfaceGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KGMS.secondaryText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KGMS.primaryBlue),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length != 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpiFields(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _upiController,
          style: const TextStyle(color: KGMS.primaryText),
          decoration: InputDecoration(
            hintText: 'Enter UPI ID (e.g. user@paytm)',
            hintStyle: const TextStyle(color: KGMS.lightText),
            filled: true,
            fillColor: KGMS.surfaceGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: KGMS.secondaryText),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: KGMS.primaryBlue),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'UPI ID is required';
            }
            if (!value.contains('@') || value.length < 5) {
              return 'Enter a valid UPI ID (e.g. user@paytm)';
            }
            return null;
          },
        ),
      ],
    );
  }
}
