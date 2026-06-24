import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static final _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_name': 'Posto POS',
      'language_selection': 'Language Selection',
      'select_language': 'Select your preferred language to continue',
      'language_en': 'English',
      'language_ur': 'Urdu',
      'module_selection': 'Module Selection',
      'select_module': 'Select Your Business Module',
      'select_module_subtitle': 'Choose one business module to get started',
      'module_subtitle':
          'Choose the module that best fits your business. You can add more later.',
      'create_workspace': 'Create Workspace',
      'workspace_ready': 'Your workspace is ready.',
      'welcome_org': 'Welcome to',
      'dashboard': 'Dashboard',
      'welcome': 'Welcome',
      'sign_out': 'Sign Out',
      'settings': 'Settings',
      'coming_soon': 'Coming soon',
      'error_prefix': 'Error:',
      'loading_workspace': 'Loading your workspace...',
      'select_workspace': 'Select your workspace',
      'choose_organization': 'Choose an organization to continue',
      'no_organizations_found': 'No organizations found',
      'sign_out_and_try_again': 'Sign out and try again',
      'create_your_workspace': 'Create Your Workspace',
      'setup_organization': 'Set up your organization to get started',
      'org_name': 'Organization Name',
      'org_name_hint': 'e.g. My Store, Joe\'s Restaurant',
      'org_name_required': 'Organization name is required',
      'org_name_min_length': 'Name must be at least 2 characters',
      'admin_account': 'Admin Account',
      'your_full_name': 'Your Full Name',
      'full_name_hint': 'Enter your full name',
      'full_name_required': 'Full name is required',
      'full_name_min_length': 'Name must be at least 2 characters',
      'phone': 'Phone Number',
      'phone_hint': 'e.g. +92 300 1234567',
      'phone_required': 'Phone number is required',
      'phone_invalid': 'Please enter a valid phone number',
      'email': 'Email',
      'email_hint': 'Enter your email',
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'password': 'Password',
      'password_hint': 'Create a password',
      'password_required': 'Password is required',
      'password_min_length': 'Password must be at least 8 characters',
      'password_uppercase': 'Must contain an uppercase letter',
      'password_lowercase': 'Must contain a lowercase letter',
      'password_digit': 'Must contain a number',
      'confirm_password': 'Confirm Password',
      'confirm_password_hint': 'Re-enter your password',
      'confirm_password_required': 'Please confirm your password',
      'passwords_do_not_match': 'Passwords do not match',
      'agree_to_terms': 'I agree to the Terms & Conditions and Privacy Policy',
      'already_have_account': 'Already have an account?',
      'sign_in': 'Sign In',
      'terms_of_service':
          'By creating a workspace, you agree to our Terms of Service',
      'restaurant': 'Restaurant & Cafe',
      'retail': 'Retail & Fashion',
      'grocery': 'Grocery & Supermarket',
      'pharmacy': 'Health & Beauty / Pharmacy',
      'general': 'General / Other',
      'restaurant_desc': 'Food, beverages, desserts',
      'retail_desc': 'Clothing, accessories, footwear',
      'grocery_desc': 'Food items, vegetables, household',
      'pharmacy_desc': 'Medicine, supplements, cosmetics',
      'general_desc': 'Mixed items, gifts, services',
      'empty_dashboard_title': 'Workspace ready',
      'empty_dashboard_subtitle':
          'Your onboarding shell is connected. Add business modules to start using POS, inventory, orders, or reporting.',
      'add_first_module': 'Add your first business module',
      'role': 'Role',
      'login_title': 'Sign in to your account',
      'forgot_password': 'Forgot Password?',
      'forgot_password_enter_email': 'Please enter your email address first',
      'forgot_password_invalid': 'Please enter a valid email address',
      'forgot_password_sent':
          'Password reset link sent to \$email. Check your inbox.',
      'forgot_password_error': 'Unable to send reset email. Please try again.',
      'login_button': 'Sign In',
      'create_account': 'Create Account',
      'need_help': 'Need help? Contact your administrator',
      'remember_me': 'Remember Me',
      'no_account': 'Don\'t have an account?',
      'reset_password_title': 'Reset Password',
      'reset_password_subtitle': 'Enter your new password below',
      'new_password': 'New Password',
      'new_password_hint': 'Enter new password',
      'reset_password_button': 'Reset Password',
      'back_to_login': 'Back to Login',
      'password_reset_success': 'Password reset successfully',
      'operator_selection': 'Operator Setup',
      'operator_selection_subtitle': 'How will you operate this workspace?',
      'solo_operator': 'Solo Operator',
      'solo_operator_desc':
          'I will run this business by myself. No additional staff accounts needed right now.',
      'multi_operator': 'Multi-Operator',
      'multi_operator_desc':
          'I will have multiple staff members (cashiers, waiters, managers) using this system.',
      'continue_setup': 'Continue',
      'contact_support': 'Contact Support',
      'contact_delay_message':
          'Thank you for reaching out. Please note there may be a slight delay in our response. We apologize for any inconvenience and appreciate your patience.',
      'copied_phone': 'Phone number copied',
      'copied_email': 'Email copied',
    },
    'ur': {
      'app_name': 'پوسٹو POS',
      'language_selection': 'زبان کا انتخاب',
      'select_language': 'جاری رکھنے کے لیے اپنی پسندیدہ زبان منتخب کریں',
      'language_en': 'English',
      'language_ur': 'اردو',
      'module_selection': 'ماڈیول کا انتخاب',
      'select_module': 'اپنا بزنس ماڈیول منتخب کریں',
      'select_module_subtitle': 'شروعات کے لیے ایک بزنس ماڈیول منتخب کریں',
      'module_subtitle':
          'وہ ماڈیول منتخب کریں جو آپ کے بزنس سے بہترین مطابقت رکھتا ہے۔ بعد میں مزید شامل کر سکتے ہیں۔',
      'create_workspace': 'ورک سپیس بنائیں',
      'workspace_ready': 'آپ کا ورک سپیس تیار ہے۔',
      'welcome_org': 'خوش آمدید',
      'dashboard': 'ڈیش بورڈ',
      'welcome': 'خوش آمدید',
      'sign_out': 'لاگ آؤٹ',
      'settings': 'سیٹنگز',
      'coming_soon': 'جلد آرہا ہے',
      'error_prefix': 'خرابی:',
      'loading_workspace': 'آپ کا ورک سپیس لوڈ ہو رہا ہے...',
      'select_workspace': 'اپنا ورک سپیس منتخب کریں',
      'choose_organization': 'جاری رکھنے کے لیے کوئی تنظیم منتخب کریں',
      'no_organizations_found': 'کوئی تنظیم نہیں ملی',
      'sign_out_and_try_again': 'لاگ آؤٹ کریں اور دوبارہ کوشش کریں',
      'create_your_workspace': 'اپنا ورک سپیس بنائیں',
      'setup_organization': 'شروعات کے لیے اپنی تنظیم سیٹ اپ کریں',
      'org_name': 'تنظیم کا نام',
      'org_name_hint': 'مثال: می اسٹور، جو کا ریسٹورنٹ',
      'org_name_required': 'تنظیم کا نام درکار ہے',
      'org_name_min_length': 'نام کم از کم 2 حروف کا ہونا چاہیے',
      'admin_account': 'ایڈمن اکاؤنٹ',
      'your_full_name': 'آپ کا پورا نام',
      'full_name_hint': 'اپنا پورا نام داخل کریں',
      'full_name_required': 'پورا نام درکار ہے',
      'full_name_min_length': 'نام کم از کم 2 حروف کا ہونا چاہیے',
      'phone': 'فون نمبر',
      'phone_hint': 'مثال: +92 300 1234567',
      'phone_required': 'فون نمبر درکار ہے',
      'phone_invalid': 'براہ کرم درست فون نمبر داخل کریں',
      'email': 'ای میل',
      'email_hint': 'اپنا ای میل داخل کریں',
      'email_required': 'ای میل درکار ہے',
      'email_invalid': 'براہ کرم درست ای میل داخل کریں',
      'password': 'پاسورڈ',
      'password_hint': 'پاسورڈ بنائیں',
      'password_required': 'پاسورڈ درکار ہے',
      'password_min_length': 'پاسورڈ کم از کم 8 حروف کا ہونا چاہیے',
      'password_uppercase': 'بڑا حرف ہونا ضروری ہے',
      'password_lowercase': 'چھوٹا حرف ہونا ضروری ہے',
      'password_digit': 'نمبر ہونا ضروری ہے',
      'confirm_password': 'پاسورڈ کی تصدیق',
      'confirm_password_hint': 'پاسورڈ دوبارہ داخل کریں',
      'confirm_password_required': 'براہ کرم پاسورڈ کی تصدیق کریں',
      'passwords_do_not_match': 'پاسورڈز میل نہیں کھاتے',
      'agree_to_terms':
          'میں شرائط و ضوابط اور رازداری کی پالیسی سے اتفاق کرتا ہوں',
      'already_have_account': 'پہلے سے اکاؤنٹ ہے؟',
      'sign_in': 'سائن ان',
      'terms_of_service':
          'ورک سپیس بناتے ہوئے آپ ہماری سروس کی شرائط سے اتفاق کرتے ہیں',
      'restaurant': 'ریسٹورنٹ اور کافی',
      'retail': 'ریٹیل اور فیشن',
      'grocery': 'گروسری اور سپر مارکیٹ',
      'pharmacy': 'صحت و خوبصورتی / فارمیسی',
      'general': 'جنرل / دیگر',
      'restaurant_desc': 'فوڈ، مشروبات، ڈیزرٹس',
      'retail_desc': 'کپڑے، ایکسسریز، جوتے',
      'grocery_desc': 'فوڈ آئٹمز، سبزیاں، ہوم یوز',
      'pharmacy_desc': 'دوائی، سپلیمنٹس، کاسمیٹکس',
      'general_desc': 'میکسڈ آئٹمز، گیفٹس، سروسز',
      'empty_dashboard_title': 'ورک سپیس تیار',
      'empty_dashboard_subtitle':
          'آپ کا آن بورڈنگ شیل منسلک ہے۔ POS، انوینٹری، آرڈرز یا رپورٹنگ شروع کرنے کے لیے بزنس ماڈیول شامل کریں۔',
      'add_first_module': 'اپنا پہلا بزنس ماڈیول شامل کریں',
      'role': 'کردار',
      'login_title': 'اپنے اکاؤنٹ میں سائن ان کریں',
      'forgot_password': 'پاسورڈ بھول گئے؟',
      'forgot_password_enter_email': 'پہلے اپنا ای میل ایڈریس داخل کریں',
      'forgot_password_invalid': 'براہ کرم درست ای میل ایڈریس داخل کریں',
      'forgot_password_sent':
          'پاسورڈ ری سیٹ لنک \$email پر بھیج دیا گیا۔ اپنا ان باکس چیک کریں۔',
      'forgot_password_error':
          'ری سیٹ ای میل بھیجنے میں ناکامی۔ دوبارہ کوشش کریں۔',
      'login_button': 'سائن ان',
      'create_account': 'اکاؤنٹ بنائیں',
      'need_help': 'مدد چاہیے؟ اپنے ایڈمنسٹریٹر سے رابطہ کریں',
      'remember_me': 'مجھے یاد رکھیں',
      'no_account': 'اکاؤنٹ نہیں ہے؟',
      'reset_password_title': 'پاسورڈ ری سیٹ کریں',
      'reset_password_subtitle': 'نیا پاسورڈ نیچے داخل کریں',
      'new_password': 'نیا پاسورڈ',
      'new_password_hint': 'نیا پاسورڈ داخل کریں',
      'reset_password_button': 'پاسورڈ ری سیٹ کریں',
      'back_to_login': 'لاگ ان پر واٹ کریں',
      'password_reset_success': 'پاسورڈ کامیابی سے ری سیٹ ہو گیا',
      'operator_selection': 'آپریٹر سیٹ اپ',
      'operator_selection_subtitle': 'آپ اس ورک سپیس کو کیسے چلائیں گے؟',
      'solo_operator': 'سولو آپریٹر',
      'solo_operator_desc':
          'میں خود بزنس چلاؤں گا۔ فی الحال اضافی سٹاف کی ضرورت نہیں۔',
      'multi_operator': 'ملٹی آپریٹر',
      'multi_operator_desc':
          'میرے پاس متعدد سٹاف ممبرز (کیشیئرز، ویٹرز، مینیجرز) ہوں گے جو یہ سسٹم استعمال کریں گے۔',
      'continue_setup': 'جاری رکھیں',
      'contact_support': 'سپورٹ سے رابطہ کریں',
      'contact_delay_message':
          'رابطہ کرنے کا شکریہ۔ براہ کرم نوٹ کریں کہ ہمارے جواب میں معمولی تاخیر ہو سکتی ہے۔ ہم کسی بھی تکلیف کے لیے معذرت خواہ ہیں اور آپ کے صبر کی تعریف کرتے ہیں۔',
      'copied_phone': 'فون نمبر کاپی ہو گیا',
      'copied_email': 'ای میل کاپی ہو گئی',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ur'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
