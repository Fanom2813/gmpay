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
      padding: const EdgeInsets.all(gapS),
      children: [
        const Icon(Icons.check_circle_rounded, size: 150, color: Colors.white),
        Padding(
            padding: const EdgeInsets.only(top: gapXs, bottom: gapM),
            child: SectionTitle(
                textCrossAxisAlignment: CrossAxisAlignment.center,
                textColor: GmpayWidgetTheme.light.colorScheme.onPrimary,
                title: "Transaction In Progress",
                subtitle: "Your transaction is being processed")),
        const SizedBox(
          height: gapL,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: gapS, horizontal: gapS),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: GmpayWidgetTheme.light.colorScheme.onPrimary,
                foregroundColor: GmpayWidgetTheme.light.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(gapS)),
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
