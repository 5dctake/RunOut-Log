import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runout_log/providers/records_provider.dart';
import 'package:runout_log/services/purchase_service.dart';
import 'package:runout_log/utils/constants.dart';
import 'package:runout_log/utils/l10n.dart';
import 'package:runout_log/widgets/hud_components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(L10n.s(ref, 'settings_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CleanCard(
              title: L10n.s(ref, 'language'),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      ref, 
                      '日本語', 
                      Language.jp, 
                      language == Language.jp
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLanguageOption(
                      ref, 
                      'ENGLISH', 
                      Language.en, 
                      language == Language.en
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CleanCard(
              title: 'Premium',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10n.s(ref, 'remove_ads'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              L10n.s(ref, 'remove_ads_desc'),
                              style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (ref.watch(adFreeProvider))
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          L10n.s(ref, 'purchased'),
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        AppButton(
                          label: L10n.s(ref, 'remove_ads'),
                          onPressed: () async {
                            await PurchaseService().buyAdFree(ref);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Purchase successful!')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => PurchaseService().restorePurchase(ref),
                          child: Text(L10n.s(ref, 'restore_purchase')),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CleanCard(
              title: 'アプリ情報',
              child: Column(
                children: [
                  _buildInfoRow(Icons.info_outline, 'VERSION', '2.0.0 (Ad-Enabled)'),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.verified_user_outlined, 'STATUS', 'BETA / TEST ADS'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CleanCard(
              title: 'メンテナンス',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.s(ref, 'purge_warning'),
                    style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: L10n.s(ref, 'reset_all'),
                    onPressed: () => _confirmPurge(context, ref),
                    color: Colors.redAccent,
                    isSecondary: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'RUNOUT LOG © 2026',
                style: TextStyle(
                  color: AppColors.textDim.withValues(alpha: 0.5),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(WidgetRef ref, String label, Language lang, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(languageProvider.notifier).state = lang,
      child: StatusIndicator(isSelected: isSelected, label: label),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _confirmPurge(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(L10n.s(ref, 'purge')),
        content: Text(L10n.s(ref, 'confirm_purge')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ref.watch(languageProvider) == Language.jp ? 'キャンセル' : 'CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              ref.watch(languageProvider) == Language.jp ? '削除する' : 'DELETE',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recordsProvider.notifier).clearRecords();
    }
  }
}
