
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkntalk/presentation/activity/activity_page.dart';
import 'package:walkntalk/presentation/auth/pages/login.dart';
import 'package:walkntalk/presentation/profile/pages/edit_profile_page.dart';
import 'package:walkntalk/presentation/profile/pages/profile_page.dart';
import 'package:walkntalk/presentation/search/pages/search_screen.dart';
import 'package:walkntalk/providers/profile_image_provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Logout the user
  void _logout() async {
    try {
      //todo: make proper file and do that  function there
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyLogin()), // Navigate to login page
      );
    } catch (e) {
      //todo: create  separate reusable widget so it could be used anywhere
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _editProfile() async {
    // Navigate to the Profile Edit page
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileEditPage()),
    );
    setState(() {}); // Refresh after editing profile
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = [
      HomeScreen(logoutFunction: _logout), // Pass logout function to HomeScreen
      SearchScreen(),
      ActivityScreen(),
      ProfilePage(
        onEdit: _editProfile,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      body: MultiProvider(
        providers: [
          //add providers here if u want to use them within project
          ChangeNotifierProvider(create: (_) => ProfileImageProvider()
           // todo: always load bug   ..loadProfileImage()
          ),
        ],
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      //todo: attempt to store routes  in separate file
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback logoutFunction;

  const HomeScreen({Key? key, required this.logoutFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home'),
        actions: [
          IconButton(
          icon: const Icon(Icons.logout),
          onPressed: logoutFunction,
        ),
          ///todo: use this icon after u figure out condition to  stop always load issue
          // CircleAvatar(
          //   radius: 20,
          //   backgroundImage: Provider.of<ProfileImageProvider>(context, listen: true).profileImageUrl != null
          //       ? Provider.of<ProfileImageProvider>(context, listen: true).profileImageUrl!.contains('http://') || Provider.of<ProfileImageProvider>(context, listen: true).profileImageUrl!.contains('https://') == true? NetworkImage(Provider.of<ProfileImageProvider>(context, listen: true).profileImageUrl.toString()) as ImageProvider<Object> : FileImage(File(Provider.of<ProfileImageProvider>(context, listen: true).profileImageUrl!))
          //       : null,
          //   backgroundColor: Colors.white12,
          //   child: Provider.of<ProfileImageProvider>(context).profileImageUrl == null
          //       ? Text(
          //     (FirebaseAuth.instance.currentUser?.displayName?.substring(0, 1) ?? 'U').toUpperCase(),
          //     style: const TextStyle(fontSize: 40, color: Colors.white),
          //   )
          //       : null,
          // ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Home Screen!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    ));
  }
}
