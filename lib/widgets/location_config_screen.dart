import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class LocationConfigScreen extends StatefulWidget {
  const LocationConfigScreen({super.key});

  @override
  State<LocationConfigScreen> createState() => _LocationConfigScreenState();
}

class _LocationConfigScreenState extends State<LocationConfigScreen> {
  late TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _keyController = TextEditingController(text: settings.amapKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _saveKey() {
    final settings = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    settings.setAmapKey(_keyController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.configSaved),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.locationDisplay,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.amapKeyHint,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _keyController,
              placeholder: l10n.amapKeyHint,
              placeholderStyle: const TextStyle(color: Colors.white24),
              style: const TextStyle(color: Colors.white),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              onChanged: (_) => _saveKey(),
            ),
            const SizedBox(height: 40),
            Text(
              l10n.amapConfigGuide,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildGuideStep(
              '1',
              l10n.amapStep1Title,
              l10n.amapStep1Desc,
              url: 'https://lbs.amap.com/',
            ),
            _buildGuideStep(
              '2',
              l10n.amapStep2Title,
              l10n.amapStep2Desc,
            ),
            _buildGuideStep(
              '3',
              l10n.amapStep3Title,
              l10n.amapStep3Desc,
            ),
            _buildGuideStep(
              '4',
              l10n.amapStep4Title,
              l10n.amapStep4Desc,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.info_circle, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.amapServiceNotice,
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(String step, String title, String description, {String? url}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
                ),
                if (url != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse(url)),
                    child: Text(
                      l10n.goNow,
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
