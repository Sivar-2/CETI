// No imports needed
import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final replacements = {
    'AppColors.deepBlack': 'AppColors.background',
    'AppColors.surfaceDark': 'AppColors.surface',
    'AppColors.cardDark': 'AppColors.card',
    'AppColors.modalDark': 'AppColors.modal',
    'AppColors.gold': 'AppColors.primary',
    'AppColors.goldLight': 'AppColors.primaryLight',
    'AppColors.goldDim': 'AppColors.primaryDim',
    'AppColors.goldGradient': 'AppColors.primaryGradient',
    'AppColors.goldVertical': 'AppColors.primaryGradient',
    'AppColors.amberGlow': 'AppColors.primaryGradient',
    'AppColors.borderWhite': 'AppColors.border',
    'AppColors.amber': 'AppColors.warning',
    'GoogleFonts.dmSans': 'GoogleFonts.plusJakartaSans',
  };

  for (final file in files) {
    if (file.path.contains('app_colors.dart')) continue; // Skip the definitions file
    
    String content = await file.readAsString();
    bool changed = false;

    replacements.forEach((oldText, newText) {
      if (content.contains(oldText)) {
        content = content.replaceAll(oldText, newText);
        changed = true;
      }
    });

    if (changed) {
      await file.writeAsString(content);
      print('Updated ${file.path}');
    }
  }
}
