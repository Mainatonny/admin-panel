import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isAdminLogin = false; // Track login mode (Admin/User)

  Future<void> _login(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('fill_all_fields')),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isAdminLogin) {
        await auth.adminLogin(identifier, password); // Admin login
      } else {
        await auth.userLogin(identifier, password); // User login
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('login_successful'))),
      );

      Navigator.pushReplacementNamed(
          context, '/dashboard'); // Navigate after login
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('login_failed') +
                    ': $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).translate('app_title'),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Toggle switch for Admin/User mode
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context).translate('login_as_user')),
                Switch(
                  value: _isAdminLogin,
                  onChanged: (value) {
                    setState(() {
                      _isAdminLogin = value;
                      _identifierController
                          .clear(); // Clear field when toggling
                      _passwordController.clear();
                    });
                  },
                ),
                Text(AppLocalizations.of(context).translate('login_as_admin')),
              ],
            ),
            const SizedBox(height: 20),

            // Input field for username/userID
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                labelText: _isAdminLogin
                    ? AppLocalizations.of(context).translate('admin_username')
                    : AppLocalizations.of(context).translate('user_id'),
                prefixIcon: const Icon(Icons.person),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),

            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('password'),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text(
                        AppLocalizations.of(context).translate('login_button')),
                  ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                AppLocalizations.of(context).translate('create_account'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
