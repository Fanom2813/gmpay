import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/section_title.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(gap_s),
      children: [
        const Icon(Icons.check_circle_rounded, size: 150, color: Colors.white),
        Padding(
            padding: const EdgeInsets.only(top: gap_xs, bottom: gap_m),
            child: SectionTitle(
                textCrossAxisAlignment: CrossAxisAlignment.center,
                textColor: GmpayWidgetTheme.light.colorScheme.onPrimary,
                title: "Transaction In Progress",
                subtitle: "Your transaction is being processed")),
        const SizedBox(
          height: gap_l,
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: gap_s, horizontal: gap_s),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: GmpayWidgetTheme.light.colorScheme.onPrimary,
                foregroundColor: GmpayWidgetTheme.light.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(gap_s)),
              ),
              onPressed: () {
                if (onDone != null) onDone!();
              },
              child: const Text("Finish")),
        ),
      ],
    );
  }
}
