import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../widgets/animated_in_view.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final double _virtualCash = 100000;

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double scale = 1.0;
    if (width < mobileBreakpoint) {
      scale = 0.95;
    } else if (width < tabletBreakpoint) {
      scale = 1.1;
    } else {
      scale = 1.3;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          color: Colors.purpleAccent,
          tooltip: 'Back',
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.purpleAccent, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Settings',
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.bold,
              fontSize: 26 * scale,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > tabletBreakpoint;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? constraints.maxWidth * 0.18 : 20,
            vertical: 30,
          ),
          children: [
            AnimatedInView(
              index: 0,
              child: _glassCard(
                child: _buildWalletTile(context, scale),
                borderColor: Colors.purpleAccent,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.16),
                    Colors.tealAccent.withOpacity(0.11)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 28),
              ),
            ),
            SizedBox(height: 30),
            AnimatedInView(
              index: 1,
              child: _glassCard(
                child: SettingsSection(
                  label: "Account Settings",
                  icon: Icons.person_outline,
                  options: [
                    SettingOption(
                      icon: Icons.manage_accounts_outlined,
                      label: 'Profile',
                      onTap: () => context.go('/profile'),
                    ),
                    SettingOption(
                      icon: Icons.lock_outlined,
                      label: 'Security',
                      onTap: () => _showInfoPopup(context,
                          "Security",
                          "For demo: Your password is securely stored with encryption. Two-factor authentication is enabled by default."),
                    ),
                    SettingOption(
                      icon: Icons.notifications_active_outlined,
                      label: 'Notifications',
                      onTap: () => context.go('/settings/notifications'),
                    ),
                  ],
                ),
                borderColor: Colors.purpleAccent,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
            ),
            SizedBox(height: 30),
            AnimatedInView(
              index: 2,
              child: _glassCard(
                child: SettingsSection(
                  label: "App Preferences",
                  icon: Icons.settings_applications_outlined,
                  options: [
                    SettingOption(
                      icon: Icons.palette_outlined,
                      label: 'Appearance',
                      onTap: () => context.go('/settings/appearance'),
                    ),
                    SettingOption(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      onTap: () =>
                          _showInfoPopup(context, 'Language', 'English (default)'),
                    ),
                    SettingOption(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Data & Privacy',
                      onTap: () => _showInfoPopup(
                          context,
                          'Data & Privacy',
                          'No personal data leaves your device. DemoTrader is committed to privacy.'),
                    ),
                  ],
                ),
                borderColor: Colors.tealAccent,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
            ),
            SizedBox(height: 40),
            AnimatedInView(
              index: 3,
              child: _glassCard(
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.barlow(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * scale,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.redAccent, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                    ),
                  ),
                ),
                borderColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            SizedBox(height: isDesktop ? 60 : 30),
          ],
        );
      }),
    );
  }

  Widget _glassCard({
    required Widget child,
    required EdgeInsetsGeometry padding,
    required Color borderColor,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: const [Colors.white10, Colors.white12],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  Widget _buildWalletTile(BuildContext context, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(14 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16 * scale,
                    spreadRadius: 1,
                    color: Colors.purpleAccent.withOpacity(0.1),
                  ),
                ],
              ),
              child: Icon(Icons.account_balance_wallet,
                  color: Colors.tealAccent, size: 36 * scale),
            ),
            SizedBox(width: 18 * scale),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Virtual Wallet',
                  style: GoogleFonts.barlow(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 18 * scale),
                ),
                Text(
                  '₹${_virtualCash.toStringAsFixed(2)}',
                  style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                      fontSize: 28 * scale,
                      color: Colors.tealAccent,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                            blurRadius: 8,
                            color: Colors.tealAccent.withOpacity(0.5),
                            offset: const Offset(0, 2))
                      ]),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 14 * scale),
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.purpleAccent, size: 16 * scale),
            SizedBox(width: 6 * scale),
            Expanded(
              child: Text(
                "Use your ₹1,00,000 virtual cash to simulate pro trading. Profit/loss adds to your wallet's balance. No real bank link.",
                style: GoogleFonts.barlow(
                  color: Colors.white54,
                  fontSize: 13 * scale,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget SettingsSection({
    required String label,
    required IconData icon,
    required List<SettingOption> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.purpleAccent, Colors.tealAccent],
              ).createShader(bounds),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.barlow(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...options
            .map((opt) => ListTile(
          leading: Icon(opt.icon, color: Colors.purpleAccent),
          title: Text(opt.label,
              style: GoogleFonts.barlow(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.chevron_right, color: Colors.tealAccent),
          onTap: opt.onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          visualDensity: VisualDensity.compact,
          minLeadingWidth: 5,
        ))
            .toList(),
      ],
    );
  }

  static Future<void> _showInfoPopup(BuildContext context, String title, String info) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.purpleAccent, Colors.tealAccent],
          ).createShader(bounds),
          child: Text(title,
              style: GoogleFonts.barlow(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        content: SingleChildScrollView(
          child: Text(info,
              style: GoogleFonts.barlow(
                color: Colors.white70,
              )),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("OK", style: GoogleFonts.barlow(color: Colors.purpleAccent))),
        ],
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Logout', style: GoogleFonts.barlow(color: Colors.purpleAccent)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.barlow(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Logout', style: GoogleFonts.barlow(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      // Add logout logic here
      context.go('/login');
    }
  }
}

class SettingOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  SettingOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Gradient? gradient;

  const _GlassCard({
    Key? key,
    required this.child,
    required this.padding,
    required this.borderColor,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: const [Colors.white10, Colors.white12],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.17),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
