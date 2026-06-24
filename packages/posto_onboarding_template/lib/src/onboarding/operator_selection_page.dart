import 'package:flutter/material.dart';
import '../core/localization/app_localization.dart';
import '../modules/business_module_template.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class OperatorSelectionPage extends StatefulWidget {
  final List<BusinessModuleTemplate> modules;
  final String orgName;
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String language;
  final String businessType;

  const OperatorSelectionPage({
    super.key,
    required this.modules,
    required this.orgName,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.language,
    required this.businessType,
  });

  @override
  State<OperatorSelectionPage> createState() => _OperatorSelectionPageState();
}

class _OperatorSelectionPageState extends State<OperatorSelectionPage> {
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isSolo = true;

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUpWithEmail(
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;

      if (response.session == null) {
        await _authService.signInWithEmail(
          email: widget.email,
          password: widget.password,
        );
      }

      if (!mounted) return;

      await _authService.createOrganizationAfterSignUp(
        name: widget.orgName,
        businessType: widget.businessType,
        language: widget.language,
      );

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.get('welcome_org')} ${widget.orgName}! ${l10n.get('workspace_ready')}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.get('error_prefix')} $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.get('operator_selection')),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Icon(Icons.group, size: 64, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              l10n.get('operator_selection'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('operator_selection_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            _buildOperatorCard(
              context,
              icon: Icons.person,
              title: l10n.get('solo_operator'),
              description: l10n.get('solo_operator_desc'),
              isSelected: _isSolo,
              onTap: () => setState(() => _isSolo = true),
            ),
            const SizedBox(height: 12),
            _buildOperatorCard(
              context,
              icon: Icons.people,
              title: l10n.get('multi_operator'),
              description: l10n.get('multi_operator_desc'),
              isSelected: !_isSolo,
              onTap: () => setState(() => _isSolo = false),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: l10n.get('continue_setup'),
              isLoading: _isLoading,
              icon: Icons.arrow_forward,
              onPressed: _isLoading ? null : _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? theme.primaryColor : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? theme.primaryColor : Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
