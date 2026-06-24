import 'package:flutter/material.dart';
import '../core/localization/app_localization.dart';
import '../modules/business_module_template.dart';
import '../widgets/custom_button.dart';
import 'operator_selection_page.dart';

class BusinessTypePage extends StatefulWidget {
  final List<BusinessModuleTemplate> modules;
  final String orgName;
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String language;

  const BusinessTypePage({
    super.key,
    required this.modules,
    required this.orgName,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    this.language = 'en',
  });

  @override
  State<BusinessTypePage> createState() => _BusinessTypePageState();
}

class _BusinessTypePageState extends State<BusinessTypePage> {
  String? _selectedType;

  void _handleContinue() {
    if (_selectedType == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OperatorSelectionPage(
          modules: widget.modules,
          orgName: widget.orgName,
          fullName: widget.fullName,
          phone: widget.phone,
          email: widget.email,
          password: widget.password,
          language: widget.language,
          businessType: _selectedType!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final modules = widget.modules.isEmpty
        ? DefaultBusinessModules.all()
        : widget.modules;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.get('module_selection')),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.store, size: 64, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              l10n.get('select_module'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.get('select_module_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ...modules.map(_buildModuleCard),
            const SizedBox(height: 20),
            CustomButton(
              text: l10n.get('continue_setup'),
              isLoading: false,
              icon: Icons.arrow_forward,
              onPressed: _selectedType != null ? _handleContinue : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BusinessModuleTemplate module) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == module.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = module.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
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
            children: [
              Icon(
                module.icon,
                size: 32,
                color: isSelected ? theme.primaryColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.primaryColor : Colors.black87,
                      ),
                    ),
                    Text(
                      module.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
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
      ),
    );
  }
}
