import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

Future<void> showSettingsSheet(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const SettingsSheet(),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.settings,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                CupertinoIcons.device_phone_portrait,
                l10n.closeVibration,
                l10n.closeVibrationDesc,
                settings.isVibrationDisabled,
                (value) => settings.setVibrationDisabled(value),
              ),
              _buildSettingItem(
                context,
                CupertinoIcons.arrow_up_down,
                l10n.reverseSwipe,
                l10n.reverseSwipeDesc,
                settings.isSwipeReversed,
                (value) => settings.setSwipeReversed(value),
              ),
              _buildSettingItem(
                context,
                CupertinoIcons.arrow_up_to_line,
                l10n.topBarCollapsible,
                l10n.topBarCollapsibleDesc,
                settings.isTopBarCollapsible,
                (value) => settings.setTopBarCollapsible(value),
              ),
              const SizedBox(height: 12),
              _buildLanguageItem(context, settings, l10n),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    String currentLanguageText;
    if (settings.locale == null) {
      currentLanguageText = l10n.languageAuto;
    } else if (settings.locale!.languageCode == 'en') {
      currentLanguageText = l10n.languageEn;
    } else if (settings.locale!.languageCode == 'zh') {
      if (settings.locale!.countryCode == 'HK') {
        currentLanguageText = l10n.languageZhHk;
      } else if (settings.locale!.countryCode == 'TW') {
        currentLanguageText = l10n.languageZhTw;
      } else {
        currentLanguageText = l10n.languageZhCn;
      }
    } else {
      currentLanguageText = l10n.languageAuto;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(CupertinoIcons.globe, color: Colors.white.withOpacity(0.7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showLanguagePicker(context, settings, l10n),
            child: Row(
              children: [
                Text(
                  currentLanguageText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
        ),
        child: CupertinoActionSheet(
          title: Text(
            l10n.language,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            _buildLanguageAction(context, settings, null, l10n.languageAuto),
            _buildLanguageAction(context, settings, const Locale('zh'), l10n.languageZhCn),
            _buildLanguageAction(context, settings, const Locale('zh', 'HK'), l10n.languageZhHk),
            _buildLanguageAction(context, settings, const Locale('zh', 'TW'), l10n.languageZhTw),
            _buildLanguageAction(context, settings, const Locale('en'), l10n.languageEn),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageAction(BuildContext context, SettingsProvider settings, Locale? locale, String title) {
    final isSelected = settings.locale == locale || 
                      (settings.locale?.toString() == locale?.toString());
                      
    return CupertinoActionSheetAction(
      onPressed: () {
        settings.setLocale(locale);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 18,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final settings = context.read<SettingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: (newValue) {
              if (!settings.isVibrationDisabled) {
                HapticFeedback.lightImpact();
              }
              onChanged(newValue);
            },
            activeColor: Colors.white,
            trackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
