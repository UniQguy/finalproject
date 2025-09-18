import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String userEmail;
  final String userName;
  final String avatarUrl;
  final double walletBalance;
  final bool premium;
  final Map<String, dynamic> details;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.avatarUrl,
    required this.walletBalance,
    required this.premium,
    required this.details,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late String _email;

  String _generateRandomUsername() {
    // Simple Reddit-style random username generator
    const adjectives = ['Wise', 'Brave', 'Happy', 'Clever', 'Swift', 'Bold'];
    const nouns = ['Eagle', 'Lion', 'Tiger', 'Wolf', 'Falcon', 'Bear'];
    final rand = Random();
    final adjective = adjectives[rand.nextInt(adjectives.length)];
    final noun = nouns[rand.nextInt(nouns.length)];
    final number = rand.nextInt(9999);
    return '$adjective$noun$number';
  }

  String _generatePlaceholderEmail(String username) {
    return '${username.toLowerCase()}@example.com';
  }

  @override
  void initState() {
    super.initState();

    final username = widget.userName.trim().isEmpty ? _generateRandomUsername() : widget.userName;
    _nameController = TextEditingController(text: username);

    _email = widget.userEmail.trim().isEmpty ? _generatePlaceholderEmail(username) : widget.userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name updated to "${_nameController.text.trim()}"')),
    );
    // Optionally you can update state or inform a parent widget here...
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(title, style: GoogleFonts.poppins(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close", style: GoogleFonts.poppins(color: Colors.tealAccent))),
        ],
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key.toLowerCase()) {
      case 'referral code':
        return Icons.card_giftcard;
      case 'phone':
        return Icons.phone;
      case 'email verified':
        return Icons.verified_user;
      case '2fa enabled':
        return Icons.security;
      case 'joined':
        return Icons.calendar_today;
      case 'notifications':
        return Icons.notifications;
      case 'dark mode':
        return Icons.dark_mode;
      case 'language':
        return Icons.language;
      case 'currency':
        return Icons.attach_money;
      case 'time zone':
        return Icons.schedule;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 1,
        title: Text('Profile', style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
              backgroundImage: widget.avatarUrl.isNotEmpty ? NetworkImage(widget.avatarUrl) : null,
              child: widget.avatarUrl.isEmpty ? Icon(Icons.person, size: 64, color: Colors.tealAccent.withOpacity(0.5)) : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter your name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.tealAccent, size: 28),
                  tooltip: 'Save Name',
                  onPressed: _saveName,
                )
              ],
            ),
            Text(
              _email,
              style: GoogleFonts.poppins(fontSize: 16, color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoCard(
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet Balance',
                  value: '₹${widget.walletBalance.toStringAsFixed(2)}',
                  color: Colors.tealAccent,
                  onTap: () {
                    _showInfoDialog('Wallet Balance', 'Your spendable trading balance.');
                  },
                ),
                _InfoCard(
                  icon: widget.premium ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                  label: 'Membership',
                  value: widget.premium ? 'Active' : 'Inactive',
                  color: widget.premium ? Colors.amber : Colors.grey,
                  onTap: () {
                    _showInfoDialog(
                        'Membership',
                        widget.premium ? 'Premium access: All features unlocked.' : 'Upgrade to premium to access exclusive features.');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.details.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.details.length,
                separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black12),
                itemBuilder: (context, index) {
                  final key = widget.details.keys.elementAt(index);
                  final value = widget.details[key];
                  return ListTile(
                    leading: Icon(_getIconForKey(key), color: Colors.tealAccent),
                    title: Text(key, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(value.toString(), style: GoogleFonts.poppins(color: isDark ? Colors.white60 : Colors.black54)),
                    onTap: () {
                      _showInfoDialog(key, value.toString());
                    },
                  );
                },
              ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 3,
              ),
              onPressed: widget.onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Flexible(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF202020) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 6),
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
