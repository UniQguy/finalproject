import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final String? avatarUrl;
  final bool premium;
  final double walletBalance;
  final String displayName;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.email,
    required this.displayName,
    required this.walletBalance,
    required this.premium,
    this.avatarUrl,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Simulate updating name (replace with DB/firestore in real app)
  void _saveName() {
    setState(() {
      // Save to database here as needed!
      _editing = false;
    });
    // Show snackbar for demo
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated!')));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final accent = Colors.deepPurpleAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.barlow(fontWeight: FontWeight.bold)),
        backgroundColor: accent,
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: widget.onLogout, tooltip: 'Logout'),
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: widget.avatarUrl?.isNotEmpty == true
                  ? NetworkImage(widget.avatarUrl!)
                  : AssetImage('assets/images/avatar_placeholder.png') as ImageProvider,
            ),
            const SizedBox(height: 18),
            if (_editing)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveName(),
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: accent),
                    onPressed: _saveName,
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _nameController.text,
                    style: GoogleFonts.barlow(
                        fontSize: 26, fontWeight: FontWeight.w800, color: accent),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 22, color: accent),
                    onPressed: () => setState(() => _editing = true),
                    tooltip: 'Edit Name',
                  )
                ],
              ),
            const SizedBox(height: 8),
            Text(widget.email, style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.premium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text('Premium', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                if (widget.premium) const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '₹${widget.walletBalance.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  children: [
                    _infoRow('Member Since', 'October 2025', accent, textColor),
                    _infoRow('Status', widget.premium ? 'Premium' : 'Regular', accent, textColor),
                    _infoRow('App Version', '1.0.0', accent, textColor),
                    _infoRow('Theme', isDark ? 'Dark' : 'Light', accent, textColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Account Settings'),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                elevation: 4,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color accent, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: accent))),
          Expanded(
              child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w500, color: textColor))),
        ],
      ),
    );
  }
}
