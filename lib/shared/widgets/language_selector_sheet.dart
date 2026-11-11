import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/localization/app_locale.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final String currentLocaleCode;
  final ValueChanged<SupportedLanguage> onSelect;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLocaleCode,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentLocaleCode,
    required ValueChanged<SupportedLanguage> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LanguageSelectorSheet(
        currentLocaleCode: currentLocaleCode,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.bottomSheetBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate, color: AppColors.primaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Select Language',
                      style: AppTypography.headlineSM(),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle),
          Expanded(
            child: ListView.separated(
              itemCount: AppLocales.all.length,
              separatorBuilder: (context, _) => const Divider(
                height: 1,
                color: AppColors.borderSubtle,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final lang = AppLocales.all[index];
                final isSelected = lang.code.toLowerCase() == currentLocaleCode.toLowerCase();

                return ListTile(
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    lang.nativeName,
                    style: AppTypography.bodyMD(
                      color: isSelected ? AppColors.primaryContainer : AppColors.onSurface,
                    ).copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${lang.name}${lang.isRtl ? ' (RTL)' : ''}',
                    style: AppTypography.labelSM(),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryContainer,
                        )
                      : null,
                  onTap: () {
                    onSelect(lang);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
