import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final String userEmail;
  const ProfilePage({super.key, required this.userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final double _virtualWallet = 100000;

  final Map<String, String> accountDetails = {
    'Joined': 'January 2025',
    'Membership': 'Premium',
    'Referral Code': 'ABCD1234',
    'Phone': '+91 9876543210',
    'Email Verified': 'Yes',
    '2FA Enabled': 'Yes',
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
    _nameController = TextEditingController(text: "John Doe");
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

  Future<void> _pickNewAvatar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo editing coming soon!')),
    );
  }

  Future<void> _showDialogSheet(String title, String content) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(title,
                  style: GoogleFonts.barlow(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
            ),
            const SizedBox(height: 20),
            Text(content, style: GoogleFonts.barlow(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Logout',
            style: GoogleFonts.barlow(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text('Do you really want to sign out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel', style: GoogleFonts.barlow(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Logout', style: GoogleFonts.barlow(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm ?? false) context.go('/login');
  }

  Widget _buildInfoCard(
      {required IconData icon,
        required String label,
        required String value,
        required Color color,
        required VoidCallback onTap}) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? double.infinity : 240,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(label,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white70,
                  )),
              if (value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(value,
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: color,
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final scale = isDesktop ? 1.2 : width > 600 ? 1.0 : 0.95;

    final infoCards = [
      _buildInfoCard(
        icon: Icons.account_balance_wallet,
        label: "Wallet Balance",
        value: "₹${_virtualWallet.toStringAsFixed(2)}",
        color: Colors.tealAccent,
        onTap: () => _showDialogSheet("Wallet Balance",
            "Your virtual wallet provides trading funds to simulate investing with zero risk."),
      ),
      _buildInfoCard(
        icon: Icons.workspace_premium,
        label: "Membership",
        value: "${accountDetails['Membership']}",
        color: Colors.amberAccent,
        onTap: () => _showDialogSheet("Membership Level", "Premium membership: All features unlocked."),
      ),
      _buildInfoCard(
        icon: Icons.calendar_today,
        label: "Joined",
        value: "${accountDetails['Joined']}",
        color: Colors.purpleAccent,
        onTap: () => _showDialogSheet("Member Since", "You joined DemoTrader in January 2025."),
      ),
      _buildInfoCard(
        icon: Icons.history,
        label: "Trade History",
        value: "",
        color: Colors.lightBlueAccent,
        onTap: () => context.go('/trade_history'),
      ),
      _buildInfoCard(
        icon: Icons.bar_chart,
        label: "Reports & Tutorials",
        value: "",
        color: Colors.greenAccent,
        onTap: () => _showDialogSheet(
            "Reports & Tutorials",
            "Coming soon: Learn to invest, view your performance reports, and track improvements."),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.96),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () => context.go('/home'),
        ),
        title: ShaderMask(
          shaderCallback: (Rect bounds) => const LinearGradient(
            colors: [Colors.purpleAccent, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Profile',
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.bold,
              fontSize: 24 * scale,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? width * 0.18 : 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with edit button
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140 * scale,
                    height: 140 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.5),
                          blurRadius: 18,
                          spreadRadius: 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 62 * scale,
                    backgroundColor: Colors.deepPurple[700],
                    backgroundImage: const AssetImage('lib/assets/images/cyborg_hand_left.png'),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: _pickNewAvatar,
                        child: Container(
                          padding: EdgeInsets.all(8 * scale),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.7),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scale),

              // Editable Name & Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 350 : 250),
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.barlow(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.purpleAccent, size: 28 * scale),
                    tooltip: 'Save Name',
                    onPressed: _saveName,
                  ),
                ],
              ),
              Text(
                widget.userEmail,
                style: GoogleFonts.barlow(
                  color: Colors.white70,
                  fontSize: 14 * scale,
                ),
              ),

              SizedBox(height: 28 * scale),

              // Responsive info cards grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: infoCards,
                  );
                },
              ),

              SizedBox(height: 42 * scale),

              // Logout button
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text(
                  "Logout",
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.bold,
                    fontSize: 18 * scale,
                    color: Colors.redAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.redAccent, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 52 * scale, vertical: 16 * scale),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                onPressed: _confirmLogout,
              ),

              SizedBox(height: 22 * scale),
            ],
          ),
        ),
      ),
    );
  }
}
