import 'package:flutter/material.dart';
import 'package:velitt/widgets/bottom_navbar.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<List<bool>> taskCompletion = [
    [true, true, true, false, false, false, false], // Drink 1 Gallon Water
    [false, false, false, false, false, false, false], // 2 45 Minutes Workouts
    [false, false, true, false, false, false, false], // Follow a Velitt Recipe
    [true, false, false, false, false, false, false], // Read for 20 Minutes
    [true, false, true, false, false, false, false], // Take a progress Picture
  ];

  String weeklyThoughts = '';

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
                'Velitt Challenges',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              ..._buildTasks(),
              const SizedBox(height: 32),
              const Text(
                'Weekly Thoughts',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    weeklyThoughts = value;
                  });
                },
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your weekly thoughts here..',
                  fillColor: Colors.grey[800],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Progress Images',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              // Progress images logic to be implemented here
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Save changes logic
                },
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31E24),
                ),
              ),
              const Spacer(),
              BottomNavBar(
                currentIndex: 3, // Assuming Challenges is the 4th item
                onTap: (index) {
                  // Handle navigation
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTasks() {
    List<String> taskNames = [
      'Drink 1 Gallon Water',
      '2 45 Minutes Workouts',
      'Follow a Velitt Recipe',
      'Read for 20 Minutes',
      'Take a progress Picture'
    ];

    List<Widget> taskWidgets = [];
    for (int i = 0; i < taskNames.length; i++) {
      taskWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskNames[i],
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return Checkbox(
                  value: taskCompletion[i][index],
                  onChanged: (value) {
                    setState(() {
                      taskCompletion[i][index] = value!;
                    });
                  },
                  activeColor: const Color(0xFFE31E24),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    return taskWidgets;
  }
}