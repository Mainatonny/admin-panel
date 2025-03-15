import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/input_field.dart';
import '../l10n/app_localizations.dart'; // Import localization

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color primaryColor = Color(0xFF2A2D3E);
  static const Color secondaryColor = Color(0xFF246AFD);
  static const Color accentColor = Color(0xFFFD8762);
  static const Color backgroundLight = Color(0xFFF8F9FE);

  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController(); // User ID input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Register using AuthProvider
      await Provider.of<AuthProvider>(context, listen: false).register(
        _userIdController.text, // User-defined ID
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('registration_successful')),
        ),
      );

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context).translate('registration_failed')}: ${e.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          AppLocalizations.of(context).translate('create_account'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundLight, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildInputField(
                  controller: _userIdController,
                  label: AppLocalizations.of(context).translate('user_id'),
                  icon: Icons.account_circle,
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context).translate('required_field')
                      : null,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _nameController,
                  label: AppLocalizations.of(context).translate('full_name'),
                  icon: Icons.person,
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context).translate('required_field')
                      : null,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _emailController,
                  label: AppLocalizations.of(context).translate('email'),
                  icon: Icons.email,
                  validator: (v) {
                    if (v!.isEmpty)
                      return AppLocalizations.of(context)
                          .translate('required_field');
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) {
                      return AppLocalizations.of(context)
                          .translate('invalid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context).translate('password'),
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (v) => v!.length < 6
                      ? AppLocalizations.of(context)
                          .translate('min_6_characters')
                      : null,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _confirmPasswordController,
                  label: AppLocalizations.of(context)
                      .translate('confirm_password'),
                  icon: Icons.lock_reset,
                  obscureText: true,
                  validator: (v) => v != _passwordController.text || v!.isEmpty
                      ? AppLocalizations.of(context)
                          .translate('passwords_must_match')
                      : null,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: secondaryColor))
                    : _buildGradientButton(
                        text: AppLocalizations.of(context)
                            .translate('create_account'),
                        colors: [secondaryColor, accentColor],
                        onPressed: _submit,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return InputField(
      controller: controller,
      label: label,
      icon: icon,
      obscureText: obscureText,
      validator: validator,
      labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)),
      iconColor: secondaryColor,
      borderColor: Colors.grey[400]!,
      focusedBorderColor: secondaryColor,
    );
  }

  Widget _buildGradientButton({
    required String text,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
