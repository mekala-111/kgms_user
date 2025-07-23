import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController phoneController = TextEditingController(
    text: "+91",
  );
  final TextEditingController otpController = TextEditingController();
  bool isKeyboardVisible = false;
  bool isLoading = false; // To control loading state
  int countdown = 0; // Countdown timer for OTP
  Timer? _timer; // Timer object (nullable)
  String lastPhoneNumber = ""; // Store the last sent phone number

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the screen is disposed
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void startOtpCountdown() {
    setState(() {
      countdown = 60; // Start countdown at 60 seconds
    });

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (countdown > 0) {
            countdown--;
          } else {
            _timer?.cancel();
          }
        });
      } else {
        timer.cancel(); // Clean up if widget disposed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final authState = ref.watch(loadingProvider);
    // final authNotifier = ref.read(userProvider.notifier);

    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/kiitm_final_out.jpg', // Replace with your asset path
                  fit: BoxFit.contain,
                  width:
                      MediaQuery.of(context).size.width *
                      0.8, // Adjust width as needed
                ),
              ),
              const SizedBox(height: 100),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F4FD), // Changed to KGMS blue light
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(200),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Phone Number'),
                        _buildTextField(
                          hintText: 'Enter your phone number',
                          controller: phoneController,
                          isPhoneField: true, // Mark it as a phone field
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('OTP'),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                hintText: 'Enter OTP',
                                controller: otpController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Consumer(
                              builder: (context, ref, child) {
                                final phoneAuthNotifier = ref.watch(
                                  userProvider.notifier,
                                );
                                // final loader = ref.watch(loadingProvider);

                                return ElevatedButton(
                                  onPressed: (countdown > 0)
                                      ? null
                                      : () async {
                                          // Capture context-dependent objects before async operations
                                          final scaffoldMessenger =
                                              ScaffoldMessenger.of(context);

                                          String phoneNumber = phoneController
                                              .text
                                              .trim();
                                          bool isValid =
                                              phoneNumber.startsWith("+91") &&
                                              phoneNumber.length == 13 &&
                                              RegExp(r'^[6-9]\d{9}$').hasMatch(
                                                phoneNumber.substring(3),
                                              );

                                          if (isValid) {
                                            // Save the phone number when sending OTP
                                            setState(() {
                                              lastPhoneNumber = phoneNumber;
                                            });
                                            // Attempt to send the OTP
                                            await phoneAuthNotifier
                                                .verifyPhoneNumber(
                                                  phoneNumber,
                                                  ref,
                                                  context,
                                                );

                                            // Check if widget is still mounted
                                            if (mounted) {
                                              startOtpCountdown(); // Start the countdown
                                            }
                                          } else {
                                            // Use captured scaffoldMessenger
                                            scaffoldMessenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please enter a valid 10-digit phone number.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF00BCD4,
                                    ), // Changed to KGMS teal
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: //isLoading
                                      //? //const CircularProgressIndicator(color: Colors.white):
                                      Text(
                                        countdown > 0
                                            ? '$countdown sec'
                                            : (lastPhoneNumber ==
                                                      phoneController.text
                                                          .trim()
                                                  ? 'Resend OTP'
                                                  : 'Send OTP'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // OTP Verification Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    // Capture context-dependent objects before async operations
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    String smsCode = otpController.text.trim();
                                    if (smsCode.isNotEmpty) {
                                      setState(() {
                                        isLoading = true; // Start loading
                                      });
                                      // Verify the OTP
                                      try {
                                        await ref
                                            .read(userProvider.notifier)
                                            .signInWithPhoneNumber(
                                              smsCode,
                                              ref,
                                              context,
                                            );

                                        // Check if widget is still mounted
                                        if (!mounted) return;

                                        // ✅ Stop the Timer
                                        _timer?.cancel();

                                        // Show success message using captured scaffoldMessenger
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "OTP Verified Successfully!",
                                            ),
                                            backgroundColor: Color(0xFF34A853),
                                          ), // Changed to KGMS green
                                        );

                                        /*// Navigate to HomePage
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => const HomePage()),
                                  // );*/
                                      } on FirebaseAuthException catch (e) {
                                        if (!mounted) return;

                                        setState(() {
                                          isLoading = false;
                                        });

                                        String errorMessage =
                                            'Verification failed. Please try again.';
                                        if (e.code ==
                                            'invalid-verification-code') {
                                          errorMessage =
                                              'The OTP you entered is incorrect.';
                                        } else if (e.code ==
                                            'session-expired') {
                                          errorMessage =
                                              'OTP session expired. Please request a new one.';
                                        }

                                        // Use captured scaffoldMessenger
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(errorMessage),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } catch (e, stackTrace) {
                                        if (!mounted) return;

                                        setState(() {
                                          isLoading =
                                              false; // Stop loading if there was an error
                                        });

                                        FirebaseCrashlytics.instance
                                            .recordError(
                                              e,
                                              stackTrace,
                                              reason: 'OTP verification error',
                                            );
                                        // Show error message using captured scaffoldMessenger
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "An error occurred: $e",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      // Use captured scaffoldMessenger
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter the OTP.",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoading
                                  ? Colors.grey
                                  : const Color(
                                      0xFF1B73E8,
                                    ), // Changed to KGMS blue
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B73E8), // Changed to KGMS blue
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool isPhoneField = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (isPhoneField) {
          if (!value.startsWith("+91")) {
            phoneController.text = "+91";
            phoneController.selection = TextSelection.fromPosition(
              TextPosition(offset: phoneController.text.length),
            );
          }
          // Reset OTP state if the user enters a new phone number
          if (value.trim() != lastPhoneNumber) {
            setState(() {
              countdown = 0; // Reset timer
            });
          }
        }
      },
    );
  }
}
