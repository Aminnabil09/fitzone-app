import 'dart:io';

void main() {
  final files = [
    'lib/screens/wishlist_screen.dart',
    'lib/screens/payment_methods_screen.dart',
    'lib/screens/order_history_screen.dart',
    'lib/screens/delivery_address_screen.dart',
    'lib/screens/login_screen.dart',
    'lib/screens/splash_screen.dart',
  ];

  for (var path in files) {
    var file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();

    // Replace generic Colors.white
    content = content.replaceAll(
        'color: Colors.white,', 'color: AppTheme.textColor,');
    content = content.replaceAll(
        'color: Colors.white)', 'color: AppTheme.textColor)');
    content = content.replaceAll(
        'color: Colors.white.', 'color: AppTheme.textColor.');

    // Replace variations like Colors.white24
    content = content.replaceAll(
        'Colors.white24', 'AppTheme.textColor.withOpacity(0.24)');
    content = content.replaceAll(
        'Colors.white54', 'AppTheme.textColor.withOpacity(0.54)');
    content = content.replaceAll(
        'Colors.white10', 'AppTheme.textColor.withOpacity(0.1)');
    content = content.replaceAll(
        'Colors.white12', 'AppTheme.textColor.withOpacity(0.12)');
    content = content.replaceAll(
        'Colors.white38', 'AppTheme.textColor.withOpacity(0.38)');

    // Remove Invalid consts
    content = content.replaceAll('const Icon(Icons', 'Icon(Icons');

    // Add imports if missing
    if (!content.contains('package:google_fonts/google_fonts.dart')) {
      // do nothing
    }

    if (!content.contains('AppTheme')) {
      content = "import '../utils/app_theme.dart';\n$content";
    }
    if (!content.contains('ThemeService')) {
      content = "import '../services/theme_service.dart';\n$content";
    }

    // Add Listenable.merge if missing and it's a top level screen
    if (content.contains('listenable: LocaleService(),')) {
      content = content.replaceAll('listenable: LocaleService(),',
          'listenable: Listenable.merge([LocaleService(), ThemeService()]),');
    }

    file.writeAsStringSync(content);
  }
}
