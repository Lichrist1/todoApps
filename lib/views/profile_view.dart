import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/app_controller.dart';

class ProfileView extends StatelessWidget {
  final AppController c = Get.find();
  final user = Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF623EFA),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF623EFA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email?.split('@').first ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    title: 'Statistics',
                    subtitle: 'View your progress',
                    onTap: () => c.currentIndex.value = 2,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage reminders',
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Notifications feature coming soon',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.palette,
                    title: 'Theme',
                    subtitle: 'Light/Dark mode',
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Theme feature coming soon',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out from account',
                    onTap: () => _confirmLogout(),
                    iconColor: Colors.red,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF623EFA),
    Color textColor = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        c.logout();
      },
    );
  }
}
