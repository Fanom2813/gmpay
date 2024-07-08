import 'package:flutter/material.dart';
import 'package:gmpay/src/common/app_provider.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class FailedPage extends StatelessWidget {
  const FailedPage({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(gap_s),
      children: [
        const Icon(Icons.error_rounded, size: 150, color: Colors.white),
        Padding(
            padding: const EdgeInsets.only(top: gap_xs, bottom: gap_m),
            child: SectionTitle(
                textCrossAxisAlignment: CrossAxisAlignment.center,
                textColor: GmpayWidgetTheme.light.colorScheme.onError,
                title: "Transaction Failed",
                subtitle:
                    "Try again later or contact your merchant for more information reason : ${AppProvider.instance.apiResponseMessage?.message}")),
        const SizedBox(
          height: gap_l,
        ),
        TextButton(
            onPressed: () {
              if (AppProvider.instance.prevPage != null) {
                WoltModalSheet.of(context)
                    .showPageWithId(AppProvider.instance.prevPage!);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: GmpayWidgetTheme.light.colorScheme.onError,
            ),
            child: const Text("Retry")),
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: gap_s, horizontal: gap_s),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: GmpayWidgetTheme.light.colorScheme.onError,
                foregroundColor: GmpayWidgetTheme.light.colorScheme.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(gap_s)),
              ),
              onPressed: () {
                if (onDone != null) {
                  onDone!();
                }
              },
              child: const Text("Finish")),
        ),
      ],
    );
  }
}
