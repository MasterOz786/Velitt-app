import 'package:flutter/material.dart';
import 'package:velitt/widgets/bottom_navbar.dart';

class MemberVideosScreen extends StatefulWidget {
  const MemberVideosScreen({super.key});

  @override
  State<MemberVideosScreen> createState() => _MemberVideosScreenState();
}

class _MemberVideosScreenState extends State<MemberVideosScreen> {
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1: 
        Navigator.pushNamed(context, '/member_dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Velitt',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Videos',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ejaz Uddin',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 4, // Change as needed
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Image.network(
                            'https://placekitten.com/800/400', // Placeholder for video thumbnail
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Fresh & Fruity Mango & Pancetta salad',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              BottomNavBar(currentIndex: 2, onTap: _handleNavigation),
            ],
          ),
        ),
      ),
    );
  }
}