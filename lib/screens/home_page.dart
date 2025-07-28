import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/screens/products_screen.dart';
import 'package:kgms_user/screens/profile_screen.dart';
import 'package:kgms_user/screens/settings_screen.dart';
import 'package:kgms_user/screens/services.dart';
import 'package:kgms_user/providers/auth_state.dart';
import '../colors/colors.dart';
import 'booking_screen.dart';
import 'home_page_content.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  String selectedCategory = "ALL";
  final List<String> categories = [
    "ALL",
    "Category 1",
    "Category 2",
    "Category 3",
  ];

  void _onCategorySelected(int index) {
    String selectedCategory = categories[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductsScreen(selectedCategory: selectedCategory),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    HomePageContent(onCategorySelected: _onCategorySelected),
    const ProfilePage(),
    ProductsScreen(selectedCategory: selectedCategory),
    const BookingsPage(),
    const ServicesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider);
    String ownerName = "User";
    String? profileImage;

    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final user = userModel.data![0].user;
      ownerName = user?.name ?? "User";
      profileImage = user?.profileImage?.isNotEmpty == true
          ? user!.profileImage![0]
          : null;
    }

    return Scaffold(
      backgroundColor: KGMS.kgmsWhite,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: KGMS.kgmsWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  if (profileImage != null)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: KGMS.primaryBlue, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(profileImage),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: KGMS.primaryBlue, width: 2),
                      ),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage("assets/gomedlogo.png"),
                      ),
                    ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'Welcome,\n$ownerName',
                    style: const TextStyle(
                      color: KGMS.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: KGMS.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: KGMS.primaryBlue,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: KGMS.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
