import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_glassy_card.dart';
import '../widgets/animated_in_view.dart';

/// Ultra-professional, dynamic, eye-catching ProfilePage with Edit option near avatar and polished Logout button.
class ProfilePage extends StatefulWidget {
  final String userEmail; // Logged-in user's email

  const ProfilePage({super.key, required this.userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Mock user data (extendable)
  final Map<String, String> accountDetails = {
    'Joined': 'January 2023',
    'Membership': 'Premium',
    'Referral Code': 'ABCD1234',
    'Phone': '+91 9876543210',
    'Email Verified': 'Yes',
    'Two-Factor Authentication': 'Enabled',
  };

  final Map<String, String> preferences = {
    'Notifications': 'Enabled',
    'Dark Mode': 'On',
    'Language': 'English',
    'Currency': 'INR',
    'Time Zone': 'GMT+5:30',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'John Doe');

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name updated to "${_nameController.text.trim()}"')),
    );
  }

  void _logout() {
    // Add your logout logic here, e.g., call AuthProvider.logout()
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey,
      appBar: AppBar(
        backgroundColor:
        isDark ? Colors.grey?.withOpacity(0.8) : Colors.grey?.withOpacity(0.9),
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.barlow(
            color: isDark ? Colors.purpleAccent : Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
            letterSpacing: 1.4,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.purpleAccent : Colors.deepPurple),
          onPressed: () => context.go('/home'), // Navigate back to homepage
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 26 * scale),
          children: [
            AnimatedInView(
              index: 0,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60 * scale,
                        backgroundColor:
                        isDark ? Colors.deepPurple.shade500 : Colors.deepPurple.shade300,
                        backgroundImage: const AssetImage('lib/assets/images/profile_placeholder.png'),
                        child: Semantics(label: 'User Avatar'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Edit Avatar tapped')));
                          },
                          child: Container(
                            padding: EdgeInsets.all(6 * scale),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.black : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 20 * scale,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48 * scale),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(
                                fontSize: 28 * scale,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: isDark ? Colors.purpleAccent : Colors.deepPurple)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: (isDark ? Colors.purpleAccent : Colors.deepPurple)
                                          .withOpacity(0.7))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: isDark ? Colors.purpleAccent : Colors.deepPurple, width: 2)),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 6 * scale),
                              hintText: 'Set up your name',
                              hintStyle: TextStyle(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check_circle_outline,
                              color: isDark ? Colors.purpleAccent : Colors.deepPurple,
                              size: 28 * scale),
                          tooltip: 'Save Name',
                          onPressed: _saveName,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    widget.userEmail,
                    style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
            SizedBox(height: 38 * scale),
            AnimatedInView(
              index: 1,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20 * scale),
                padding: EdgeInsets.symmetric(vertical: 22 * scale, horizontal: 28 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...accountDetails.entries
                        .map((entry) => _buildDetailRow(entry.key, entry.value, scale, isDark))
                        .toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36 * scale),
            AnimatedInView(
              index: 2,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20 * scale),
                padding: EdgeInsets.symmetric(vertical: 22 * scale, horizontal: 28 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...preferences.entries
                        .map((entry) => _buildDetailRow(entry.key, entry.value, scale, isDark))
                        .toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50 * scale),
            Center(
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 36 * scale, vertical: 16 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  side: const BorderSide(color: Colors.redAccent, width: 2),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18 * scale,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double scale, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16 * scale,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16 * scale,
              color: isDark ? Colors.white : Colors.black87,
            ),
          )
        ],
      ),
    );
  }
}
