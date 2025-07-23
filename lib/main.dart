import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/screens/Login_screen.dart';
import 'package:kgms_user/screens/booking_screen.dart';
import 'package:kgms_user/screens/home_page.dart';
import 'package:kgms_user/screens/profile_screen.dart';
import 'package:kgms_user/screens/services.dart';
import 'package:kgms_user/screens/settings_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'dart:math';

final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fixed: Removed unused 'app' variable
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Restrict orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      // Wrap your app with ProviderScope
      child: MyApp(),
    ),
  );
}

String generateOtp() {
  final random = Random();
  return (100000 + random.nextInt(900000)).toString(); // 6-digit
}

String generatebookingOtp() {
  final random = Random();
  // Generate a 4-digit number between 1000 and 9999
  int otp = 1000 + random.nextInt(9000);
  return otp.toString();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged.map(
      (list) => list.first,
    );

    _connectivityStream.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;

      globalMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            isConnected ? '✅ Back online' : '🚫 No internet connection',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: globalMessengerKey,
      routes: {
        '/': (context) {
          return Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(userProvider);

              // Extract access token
              final accessToken = authState.data?.isNotEmpty == true
                  ? authState.data![0].accessToken
                  : null;

              if (accessToken != null && accessToken.isNotEmpty) {
                return const HomePage();
              }

              return FutureBuilder(
                future: ref.read(userProvider.notifier).tryAutoLogin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // If auto-login is successful, navigate to the home page, else show login screen
                  if (snapshot.hasData && snapshot.data == true) {
                    return const HomePage();
                  } else {
                    return const LoginScreen();
                  }
                },
              );
            },
          );
        },

        "booking_screen": (context) => const BookingsPage(),
        // "bookingstagepage":(context)=>const BookingStagePage(),
        //"home_page_content":(context)=>const HomePageContent(),
        "home_page": (context) => const HomePage(),
        "login_screen": (context) => const LoginScreen(),
        // "products_screen":(context)=>const ProductsScreen(),
        "profile_screen": (context) => const ProfilePage(),
        "settings_screen": (context) => const SettingsPage(),
        "services": (context) => const ServicesPage(),
        //"payment":(context)=>const PaymentPage()
        // "service_details":(context)=>const ServiceDetailsPage(),
        //"ordertracking":(context)=>const OrderTrackingPage(),
      },
    );
  }
}
