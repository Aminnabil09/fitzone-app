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

    // Add imports if they physically aren't there
    if (!content.contains("import '../utils/app_theme.dart';") &&
        !content
            .contains("import 'package:fitzone_app/utils/app_theme.dart';")) {
      content = "import '../utils/app_theme.dart';\n$content";
    }
    if (!content.contains("import '../services/theme_service.dart';") &&
        !content.contains(
            "import 'package:fitzone_app/services/theme_service.dart';")) {
      content = "import '../services/theme_service.dart';\n$content";
    }

    file.writeAsStringSync(content);
  }
}
