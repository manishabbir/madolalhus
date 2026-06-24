import 'package:flutter/material.dart';
import '../core/localization/app_localization.dart';
import '../modules/business_module_template.dart';
import '../onboarding/language_selection_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  final List<BusinessModuleTemplate> modules;

  const SignUpPage({super.key, this.modules = const []});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _orgNameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectionPage(
          modules: widget.modules.isEmpty
              ? DefaultBusinessModules.all()
              : widget.modules,
          orgName: _orgNameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      ),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.store, size: 64, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    l10n.get('create_your_workspace'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.get('setup_organization'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorMessage!)),
                          GestureDetector(
                            onTap: () => setState(() => _errorMessage = null),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                  CustomTextField(
                    controller: _orgNameController,
                    label: l10n.get('org_name'),
                    hint: l10n.get('org_name_hint'),
                    prefixIcon: Icons.business,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.get('org_name_required');
                      }
                      if (value.trim().length < 2) {
                        return l10n.get('org_name_min_length');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l10n.get('admin_account')),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _fullNameController,
                    label: l10n.get('your_full_name'),
                    hint: l10n.get('full_name_hint'),
                    prefixIcon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.get('full_name_required');
                      }
                      if (value.trim().length < 2) {
                        return l10n.get('full_name_min_length');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: l10n.get('phone'),
                    hint: l10n.get('phone_hint'),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.get('phone_required');
                      }
                      if (value.trim().length < 10) {
                        return l10n.get('phone_invalid');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _emailController,
                    label: l10n.get('email'),
                    hint: l10n.get('email_hint'),
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.get('email_required');
                      }
                      if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                      ).hasMatch(value.trim())) {
                        return l10n.get('email_invalid');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    label: l10n.get('password'),
                    hint: l10n.get('password_hint'),
                    prefixIcon: Icons.lock_outlined,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.get('password_required');
                      }
                      if (value.length < 8) {
                        return l10n.get('password_min_length');
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return l10n.get('password_uppercase');
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return l10n.get('password_lowercase');
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return l10n.get('password_digit');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: l10n.get('confirm_password'),
                    hint: l10n.get('confirm_password_hint'),
                    prefixIcon: Icons.lock_outlined,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.get('confirm_password_required');
                      }
                      if (value != _passwordController.text) {
                        return l10n.get('passwords_do_not_match');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) =>
                            setState(() => _agreeToTerms = value ?? false),
                        activeColor: theme.primaryColor,
                      ),
                      Expanded(child: Text(l10n.get('agree_to_terms'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: l10n.get('create_workspace'),
                    isLoading: _isLoading,
                    icon: Icons.add_business,
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.get('already_have_account')),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(l10n.get('sign_in')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.get('terms_of_service'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
