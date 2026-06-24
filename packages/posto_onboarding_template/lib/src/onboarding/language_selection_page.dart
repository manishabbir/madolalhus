import 'package:flutter/material.dart';
import '../core/localization/app_localization.dart';
import '../modules/business_module_template.dart';
import '../services/locale_state.dart';
import 'business_type_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  final List<BusinessModuleTemplate> modules;
  final String orgName;
  final String fullName;
  final String phone;
  final String email;
  final String password;

  const LanguageSelectionPage({
    super.key,
    required this.modules,
    required this.orgName,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.language,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.get('language_selection'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.get('select_language'),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                _LanguageCard(
                  title: l10n.get('language_en'),
                  subtitle: 'English',
                  icon: Icons.translate,
                  onTap: () => _selectLanguage(context, 'en'),
                ),
                const SizedBox(height: 16),
                _LanguageCard(
                  title: l10n.get('language_ur'),
                  subtitle: 'اردو',
                  icon: Icons.translate,
                  onTap: () => _selectLanguage(context, 'ur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    LocaleState().setLocale(Locale(languageCode));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessTypePage(
          modules: modules,
          orgName: orgName,
          fullName: fullName,
          phone: phone,
          email: email,
          password: password,
          language: languageCode,
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
