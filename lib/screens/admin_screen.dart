import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final roll = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  // IMPORTANT:
  // This screen is a local admin gate only.
  // It does NOT publish to the public data source.
  // See README_SETUP.md for the free publishing workflow.
  //
  // Replace these values in your private copy if you want a local
  // convenience gate. Do not publish real passwords inside an APK.
  static const adminRoll = 'ADMIN001';
  static const adminPassword = 'CHANGE-ME';

  @override
  void dispose() {
    roll.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (roll.text.trim() == adminRoll &&
        password.text == adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('admin_local_gate', true);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admin gate accepted. Publishing is done through the free workflow described in README_SETUP.md.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid roll number or password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      child: Icon(Icons.admin_panel_settings, size: 34),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Admin Login',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: roll,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: login,
                        child: const Text('LOGIN'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Publishing is intentionally kept outside the student APK so no private publishing credential is exposed in the app.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
