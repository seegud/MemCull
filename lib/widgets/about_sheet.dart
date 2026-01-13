import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import 'location_config_screen.dart';

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool isLbsExpanded = false;
    return StatefulBuilder(
      builder: (context, setModalState) {
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
            child: Column(
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
                    l10n.aboutTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAboutItem(
                    CupertinoIcons.info,
                    l10n.currentVersion,
                    "V1.0.0 (V34)",
                    "https://memcull.seegood.top/changelog.html",
                  ),
                  _buildAboutItem(
                    CupertinoIcons.arrow_2_circlepath,
                    l10n.checkNewVersion,
                    null,
                    "https://gitee.com/seegoooood/mem-cull/releases",
                  ),
                  _buildAboutItem(
                    CupertinoIcons.question_circle,
                    l10n.faq,
                    null,
                    "https://memcull.seegood.top/FAQ.html",
                  ),
                  _buildAboutItem(
                    CupertinoIcons.shield,
                    l10n.privacyPolicy,
                    null,
                    "https://memcull.seegood.top/privacy-and-terms.html",
                  ),
                  _buildAboutItem(
                    CupertinoIcons.person,
                    l10n.developerName,
                    null,
                    "https://seegood.top",
                  ),
                  _buildAboutItem(
                    CupertinoIcons.heart,
                    l10n.donateDeveloper,
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                        children: [
                          TextSpan(text: l10n.donateDescFree),
                          TextSpan(
                            text: l10n.donateDescFreeHighlight,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          TextSpan(text: l10n.donateDescLbs),
                          TextSpan(
                            text: l10n.donateDescLbsHighlight,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          TextSpan(text: l10n.donateDescHelp),
                          TextSpan(text: l10n.donateDescHelpHighlight),
                          TextSpan(
                            text: l10n.donateDescThanks,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          TextSpan(
                            text: l10n.donateDescThanksHighlight,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    "https://supportme.seegood.top/",
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 10),
                  // 具体位置显示项
                  StatefulBuilder(
                    builder: (context, setLocalState) => InkWell(
                      onTap: () {
                        setLocalState(() {
                          isLbsExpanded = !isLbsExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(CupertinoIcons.location_circle,
                                    color: Colors.white54, size: 20),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n.locationDisplay,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 300),
                                  turns: isLbsExpanded ? 0.5 : 0,
                                  child: const Icon(
                                    CupertinoIcons.chevron_down,
                                    color: Colors.white24,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox(width: double.infinity),
                              secondChild: Padding(
                                padding:
                                    const EdgeInsets.only(left: 36, top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.locationDisplayDesc,
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                const LocationConfigScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            l10n.goToConfig,
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            CupertinoIcons.chevron_right,
                                            color: Colors.blueAccent,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: isLbsExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildAboutItem(
                    CupertinoIcons.sparkles,
                    l10n.thanks,
                    null,
                    "https://memcull.seegood.top/thanks.html",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      );
    }

  Widget _buildAboutItem(
    IconData icon,
    String label,
    dynamic value,
    String? url, {
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? (url != null ? () => launchUrl(Uri.parse(url)) : null),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor ?? Colors.white54, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 4),
                    if (value is String)
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      )
                    else if (value is Widget)
                      value,
                  ],
                ],
              ),
            ),
            if (url != null)
              const Icon(
                CupertinoIcons.chevron_forward,
                color: Colors.white24,
                size: 12,
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAboutSheet(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const AboutSheet(),
  );
}
