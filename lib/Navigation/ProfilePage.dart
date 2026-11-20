
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_guard/screens/LoginScreen.dart';
import 'package:provider/provider.dart';

import '../app/color/app_colors.dart';
import '../app/theme/theme_provaider.dart';
import '../utils/Utils.dart';

/// Picks colors from your AppColors depending on the current theme.
class _Palette {
  const _Palette(this.isDark);

  final bool isDark;

  Color get bg => isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get text => isDark ? AppColors.darkText : AppColors.lightText;
  Color get muted => AppColors.secondaryText;
}

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoggingOut = false;

  _Palette get _p => _Palette(Theme.of(context).brightness == Brightness.dark);

  String getInitials(String name) {
    if (name.trim().isEmpty) return 'U';

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return name.trim()[0].toUpperCase();
  }

  Future<void> logout() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    } catch (e) {
      if (!mounted) return;

      Utels.failToset('Logout failed. Please try again.');
      debugPrint('Logout Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  void showLogoutDialog() {
    final p = _p;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: p.muted),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancel', style: TextStyle(color: p.muted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: p.bg,
        body: Center(
          child: Text(
            'Please login first.',
            style: TextStyle(color: p.text),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: p.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: p.text),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final data = snapshot.data?.data() ?? {};

            final String firstName = (data['firstName'] ?? '').toString();
            final String lastName = (data['lastName'] ?? '').toString();

            String name = (data['fullName'] ?? '').toString().trim();
            if (name.isEmpty) name = (user.displayName ?? '').trim();
            if (name.isEmpty) name = '$firstName $lastName'.trim();

            final String email = (data['email'] ?? user.email ?? '').toString();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // Profile Avatar
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      getInitials(name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    name.isEmpty ? 'User' : name,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Email
                  Text(
                    email,
                    style: TextStyle(color: p.muted, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  // Account Information
                  _sectionTitle('Account Information'),

                  const SizedBox(height: 12),

                  _profileCard(
                    icon: Icons.person_outline,
                    title: 'First Name',
                    value: firstName,
                  ),

                  _profileCard(
                    icon: Icons.person_outline,
                    title: 'Last Name',
                    value: lastName,
                  ),

                  _profileCard(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    value: email,
                  ),

                  _profileCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Account Status',
                    value: user.emailVerified ? 'Verified' : 'Not Verified',
                  ),

                  const SizedBox(height: 25),

                  _sectionTitle('Settings'),

                  const SizedBox(height: 12),

                  _darkModeItem(),

                  // There is no Edit Profile screen in this project yet.
                  _menuItem(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () {
                      Utels.failToset('Edit Profile is coming soon.');
                    },
                  ),

                  _menuItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Utels.failToset(
                        'Change Password feature is coming soon.',
                      );
                    },
                  ),

                  _menuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),

                  const SizedBox(height: 25),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: isLoggingOut ? null : showLogoutDialog,
                      icon: isLoggingOut
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.logout),
                      label: Text(
                        isLoggingOut ? 'Logging out...' : 'Logout',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'Clarity Guard v1.0.0',
                    style: TextStyle(color: p.muted, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: _p.text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final p = _p;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: p.muted, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? 'Not available' : value,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dark mode switch. The choice is saved by ThemeProvider.
  Widget _darkModeItem() {
    final p = _p;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: p.border),
      ),
      child: SwitchListTile(
        secondary: const Icon(
          Icons.dark_mode_outlined,
          color: AppColors.secondary,
        ),
        title: Text('Dark Mode', style: TextStyle(color: p.text)),
        value: p.isDark,
        activeTrackColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onChanged: (value) {
          context.read<ThemeProvider>().setDarkMode(value);
        },
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final p = _p;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: p.border),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(title, style: TextStyle(color: p.text)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: p.muted,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}