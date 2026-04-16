import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_page.dart';
import '../home_page.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (!mounted) return;
      // Navigasi ke Home (Tanpa kata const)
      Get.offAll(() => HomePage());
      
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController, 
              decoration: const InputDecoration(labelText: "Email", hintText: "budi@gmail.com")
            ),
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(labelText: "Password", hintText: "min. 6 karakter"), 
              obscureText: true
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _signIn, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text("Belum punya akun? Daftar di sini"),
            )
          ],
        ),
      ),
    );
  }
}