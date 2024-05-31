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
      this.onBack});
  final String? title, subtitle;
  final bool? showDivider, canGoBack;
  final VoidCallback? onBack;
  final CrossAxisAlignment? textCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canGoBack == true) ...[
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
          const SizedBox(
            width: gap_m,
          ),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment:
                textCrossAxisAlignment ?? CrossAxisAlignment.start,
            children: [
              Text(
                title ?? "",
                style: GmpayTextStyles.headline6.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle ?? "",
                  style: GmpayTextStyles.subtitle2,
                ),
              if (showDivider ?? false) const Divider()
            ],
          ),
        ),
      ],
    );
  }
}
