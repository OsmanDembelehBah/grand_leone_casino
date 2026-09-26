import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginEmailController = TextEditingController(text: 'osman@grandleone.com');
  final _loginPassController = TextEditingController(text: 'password123');

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPassController = TextEditingController();
  String _selectedRole = 'Floor Staff';
  String _selectedAvatar = '👨‍💼';

  final List<String> _avatars = ['👨‍💼', '👩‍💼', '🧑‍💻', '👨‍🍳', '🤵', '🦸‍♂️'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _submitLogin() {
    if (_loginEmailController.text.isEmpty || _loginPassController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    widget.onLoginSuccess({
      'name': 'Alhaji Osman Bah',
      'email': _loginEmailController.text,
      'role': 'Casino Manager',
      'avatar': '👨‍💼',
      'shift': 'Night Shift',
    });
  }

  void _submitRegister() {
    if (_regNameController.text.isEmpty || _regEmailController.text.isEmpty || _regPassController.text.isEmpty) {
      _showError('Please fill in all registration fields');
      return;
    }

    widget.onLoginSuccess({
      'name': _regNameController.text.trim(),
      'email': _regEmailController.text.trim(),
      'role': _selectedRole,
      'avatar': _selectedAvatar,
      'shift': 'Day Shift',
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Brand Icon & Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.casino, size: 48, color: AppTheme.accentOrange),
              ),
              const SizedBox(height: 12),
              const Text(
                'GRAND LEONE',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const Text(
                'Beverage & Floor Operations',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 30),

              // Sign In / Register Tab Toggle
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Register Staff'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email Address', style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        TextField(
          controller: _loginEmailController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDecoration(Icons.email_outlined, 'Enter email'),
        ),
        const SizedBox(height: 16),
        const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPassController,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDecoration(Icons.lock_outline, 'Enter password'),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('LOG IN TO SHIFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Avatar', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _avatars.map((avatar) {
              final isSelected = _selectedAvatar == avatar;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = avatar),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentOrange : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(avatar, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Full Name', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          TextField(
            controller: _regNameController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: _inputDecoration(Icons.person_outline, 'Staff full name'),
          ),
          const SizedBox(height: 10),
          const Text('Role', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            dropdownColor: AppTheme.primaryNavy,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: _inputDecoration(Icons.badge_outlined, ''),
            items: ['Floor Staff', 'Bar Tender', 'Casino Supervisor', 'Manager']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),
          const SizedBox(height: 10),
          const Text('Email Address', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          TextField(
            controller: _regEmailController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: _inputDecoration(Icons.email_outlined, 'Staff email'),
          ),
          const SizedBox(height: 10),
          const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          TextField(
            controller: _regPassController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: _inputDecoration(Icons.lock_outline, 'Set password'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _submitRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('REGISTER & LOG IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white60, size: 18),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}
