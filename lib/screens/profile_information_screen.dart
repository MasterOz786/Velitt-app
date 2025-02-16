import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:velitt/state/member_state.dart';

class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MemberState memberState = Provider.of<MemberState>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header Section
          Container(
            height: 320,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Profile Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 50), // Spacer
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        // Use the profileImage from memberState; fall back to a placeholder.
                        backgroundImage: NetworkImage(
                          memberState.profileImage ??
                              'https://via.placeholder.com/160',
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE31E24),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 24),
                            onPressed: () {
                              // Add edit profile picture functionality here.
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    memberState.memberName ??
                        '${memberState.firstName ?? ''} ${memberState.lastName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Details Section
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'First Name',
                      hint: 'Enter first name',
                      value: memberState.firstName ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Middle Name',
                      hint: 'Enter middle name',
                      value: memberState.middleName ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Last Name',
                      hint: 'Enter last name',
                      value: memberState.lastName ?? '',
                    ),
                    const SizedBox(height: 20),

                    // Contact Information Section
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Telephone',
                      hint: 'Enter telephone number',
                      value: memberState.telephone ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Mobile',
                      hint: 'Enter mobile number',
                      value: memberState.mobile ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Email',
                      hint: 'Enter email address',
                      value: memberState.memberEmail ?? '',
                    ),
                    const SizedBox(height: 20),

                    // Additional Information Section
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDatePickerField(
                      label: 'Date of Birth',
                      value: memberState.dateOfBirth ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildDatePickerField(
                      label: 'Agreement Effective Date',
                      value: memberState.agreementEffectiveDate ?? '',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Notes',
                      hint: 'Enter any notes',
                      maxLines: 4,
                      value: memberState.notes ?? '',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
          BottomNavBar(
            currentIndex: 4, // Profile screen index
            onTap: (index) {
              // Handle navigation based on index.
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/dashboard');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/profile');
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  /// Build a text field with a pre-filled value.
  Widget _buildTextField({
    required String label,
    required String hint,
    String? value,
    int maxLines = 1,
  }) {
    // Creating a new controller on every build is acceptable for display purposes.
    final controller = TextEditingController(text: value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Build a date picker field with a pre-filled value.
  Widget _buildDatePickerField({
    required String label,
    String? value,
  }) {
    final controller = TextEditingController(text: value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFE31E24)),
          ),
          onTap: () {
            // Add date picker functionality here if needed.
          },
        ),
      ],
    );
  }
}
