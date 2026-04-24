import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'controllers/app_controller.dart';
import 'views/home_view.dart';
import 'views/habit_detail_view.dart';
import 'views/data_report_view.dart';
import 'views/create_task_view.dart';
import 'views/profile_view.dart';
import 'Logins/login_page.dart';
import 'Logins/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('id_ID', null);
  
  await Supabase.initialize(
    url: 'https://ykngepmhhdllhczdpqwx.supabase.co',
    anonKey: 'sb_publishable_51MagfVCx-dnEu64htfhgg_H6bQibw2',
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primaryColor: Color(0xFF623EFA),
        scaffoldBackgroundColor: Color(0xFFF3F0FF),
        useMaterial3: true,
      ),
      home: Supabase.instance.client.auth.currentSession == null
          ? LoginPage()
          : MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late AppController c;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    c = Get.put(AppController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(),
          HabitDetailView(),
          DataReportView(),
          ProfileView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CreateTaskView());
        },
        backgroundColor: Color(0xFF623EFA),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.grid_view_rounded, 0),
              _buildNavItem(Icons.calendar_month_rounded, 1),
              SizedBox(width: 40),
              _buildNavItem(Icons.fact_check_outlined, 2),
              _buildNavItem(Icons.person_outline, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _currentIndex == index ? Color(0xFF623EFA) : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}