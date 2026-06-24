import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/locale_state.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  late final StreamSubscription<AuthState> _authSubscription;
  @override
  void initState() {
    super.initState();
    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChange,
    );
    _checkFirstLaunch();
    _handlePasswordRecovery();
  }

  Future<void> _checkFirstLaunch() async {
    final localeState = LocaleState();
    await localeState.load();
    if (!mounted) return;

    if (!localeState.hasLocale) {
      // First launch — redirect to language selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const _FirstLaunchLanguagePage()),
        );
      });
    } else {
      _checkAuthState();
    }
  }

  Future<void> _handlePasswordRecovery() async {
    final uri = Uri.base;
    final params = uri.queryParameters;

    final hasError =
        params.containsKey('error') && params['error'] == 'access_denied';
    final isRecoveryType = params['type'] == 'recovery';

    if (uri.hasFragment && (hasError || isRecoveryType)) {
      final fragment = uri.fragment;
      final fragmentParams = Uri.splitQueryString(fragment);

      final recoveryType = fragmentParams['type'] ?? params['type'];
      final hasRecoveryError =
          fragmentParams['error'] == 'access_denied' ||
          fragmentParams['error_code'] == 'otp_expired';

      if (recoveryType == 'recovery' || hasRecoveryError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/reset-password');
          }
        });
        return;
      }
    }

    if (isRecoveryType && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/reset-password');
      });
    }
  }

  void _handleAuthStateChange(AuthState state) {
    if (state.event == AuthChangeEvent.passwordRecovery) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/reset-password');
        }
      });
    }
  }

  Future<void> _checkAuthState() async {
    final route = _authService.getInitialRoute();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 64, color: const Color(0xFF2563EB)),
            const SizedBox(height: 16),
            const Text(
              'Posto POS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _FirstLaunchLanguagePage extends StatelessWidget {
  const _FirstLaunchLanguagePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Icon(Icons.store, size: 80, color: theme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Posto POS',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select your preferred language to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                _LanguageOption(
                  title: 'English',
                  subtitle: 'English',
                  icon: Icons.translate,
                  onTap: () => _selectLanguage(context, 'en'),
                ),
                const SizedBox(height: 16),
                _LanguageOption(
                  title: 'Urdu',
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

  void _selectLanguage(BuildContext context, String languageCode) async {
    await LocaleState().setLocale(Locale(languageCode));
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LanguageOption({
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

extension AuthRoute on AuthService {
  String getInitialRoute() {
    if (!isAuthenticated) return '/login';
    return '/loading';
  }
}
