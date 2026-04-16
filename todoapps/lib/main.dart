import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Logins/login_page.dart';
import 'home_page.dart';
import 'package:get/get.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ganti dengan URL dan Anon Key dari Dashboard Supabase kamu
  await Supabase.initialize(
    url: 'https://ykngepmhhdllhczdpqwx.supabase.co', 
    anonKey: 'sb_publishable_51MagfVCx-dnEu64htfhgg_H6bQibw2', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 // main.dart

@override
Widget build(BuildContext context) {
  // Ganti 'MaterialApp' menjadi 'GetMaterialApp'
  return GetMaterialApp( 
    debugShowCheckedModeBanner: false,
    title: 'Todo Supabase',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true, // Opsional: agar tampilan lebih modern
    ),
    // Cek sesi: Jika user sudah login, langsung ke HomePage
    home: Supabase.instance.client.auth.currentSession == null 
          ? const LoginPage() 
          : HomePage(), // Pastikan 'const' di sini sudah dihapus
  );
}
}