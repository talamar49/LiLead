import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // final themeMode = ref.watch(themeModeProvider); // Temporarily disabled
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Theme option temporarily disabled - keeping light theme as default
          // ListTile(
          //   leading: const Icon(Icons.brightness_6),
          //   title: Text(l10n.theme),
          //   subtitle: Text(_getThemeModeLabel(context, themeMode)),
          //   onTap: () => _showThemeDialog(context, ref, themeMode),
          // ),
          // const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLocaleLabel(context, locale)),
            onTap: () => _showLanguageDialog(context, ref, locale),
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  String _getLocaleLabel(BuildContext context, Locale locale) {
    final l10n = AppLocalizations.of(context)!;
    if (locale.languageCode == 'en') {
      return l10n.languageEnglish;
    } else if (locale.languageCode == 'he') {
      return l10n.languageHebrew;
    }
    return locale.languageCode;
  }

  Future<void> _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectTheme),
        children: [
          _buildDialogOption(
            context,
            l10n.themeSystem,
            currentMode == ThemeMode.system,
            () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
          _buildDialogOption(
            context,
            l10n.themeLight,
            currentMode == ThemeMode.light,
            () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          _buildDialogOption(
            context,
            l10n.themeDark,
            currentMode == ThemeMode.dark,
            () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context, WidgetRef ref, Locale currentLocale) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: [
          _buildDialogOption(
            context,
            l10n.languageEnglish,
            currentLocale.languageCode == 'en',
            () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
          _buildDialogOption(
            context,
            l10n.languageHebrew,
            currentLocale.languageCode == 'he',
            () => ref.read(localeProvider.notifier).setLocale(const Locale('he')),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? Colors.white : theme.primaryColor;
    
    return SimpleDialogOption(
      onPressed: () {
        onTap();
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : (isDark ? Colors.white70 : null),
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          if (isSelected)
            Icon(Icons.check, color: selectedColor),
        ],
      ),
    );
  }
}
