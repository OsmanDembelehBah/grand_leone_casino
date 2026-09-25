import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'achmed@grandleone.com');
  final TextEditingController _passwordController = TextEditingController(text: '1234');
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final staff = await DBHelper().authenticateStaff(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (staff != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation(currentStaff: staff)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Email or Password'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Fallback navigation in case DB fails during development
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(currentStaff: {
              'name': 'Achmed Thronka',
              'role': 'Manager / Bartender',
              'email': _emailController.text,
              'photoUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'
            }),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 20)],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  errorBuilder: (_, __, ___) => const Icon(Icons.casino, size: 50, color: Colors.deepOrange),
                ),
              ),
              const SizedBox(height: 18),
              const Text('GRAND LEONE CASINO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Text('Bar & VIP Lounge Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 36),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Staff Email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.deepOrange),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Staff PIN / Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepOrange),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('SIGN IN TO SYSTEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
