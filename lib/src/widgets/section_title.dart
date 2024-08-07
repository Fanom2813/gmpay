import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(
      {super.key,
      this.title,
      this.subtitle,
      this.showDivider,
      this.canGoBack,
      this.textCrossAxisAlignment,
      this.imageAsset,
      this.textColor,
      this.trailing,
      this.onBack});
  final String? title, subtitle;
  final bool? showDivider, canGoBack;
  final VoidCallback? onBack;
  final CrossAxisAlignment? textCrossAxisAlignment;
  final String? imageAsset;

  final Color? textColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (canGoBack == true) ...[
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
          const SizedBox(
            width: gapXs,
          ),
        ],
        if (imageAsset != null) ...[
          Image.asset(
            'assets/$imageAsset',
            width: 50,
            height: 50,
            package: 'gmpay',
          ),
          const SizedBox(
            width: gapXs,
          ),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment:
                textCrossAxisAlignment ?? CrossAxisAlignment.start,
            children: [
              Text(
                title ?? "",
                style: GmpayTextStyles.headline6
                    .copyWith(fontWeight: FontWeight.w700, color: textColor),
              ),
              if (subtitle != null)
                Text(
                  subtitle ?? "",
                  style: GmpayTextStyles.subtitle2.copyWith(color: textColor),
                ),
              if (showDivider ?? false) const Divider()
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
