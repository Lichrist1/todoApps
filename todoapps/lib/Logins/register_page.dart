import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil Daftar! Silakan Login."))
      );
      Navigator.pop(context);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController, 
              decoration: const InputDecoration(labelText: "Email", hintText: "user@example.com")
            ),
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(labelText: "Password", hintText: "min. 6 karakter"), 
              obscureText: true
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _signUp, child: const Text("Daftar")),
          ],
        ),
      ),
    );
  }
}