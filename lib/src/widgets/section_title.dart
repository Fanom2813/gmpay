import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/text_theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, this.title, this.subtitle, this.showDivider});
  final String? title, subtitle;
  final bool? showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
