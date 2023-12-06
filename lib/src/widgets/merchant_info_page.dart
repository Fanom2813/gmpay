import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:gmpay/src/widgets/simple_notification_message.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantInfoPage extends StatelessWidget {
  const MerchantInfoPage({super.key, this.merchantData, this.onBack});
  final Map<String, dynamic>? merchantData;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return merchantData != null
        ? Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded)),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: SimpleNotificationMessage(
                icon: Icons.info_outline_rounded,
                type: SimpleNotificationMessageType.info,
                message:
                    "You can use this information to contact your merchant for more information about your transactions",
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: gap_l),
              child: SectionTitle(
                title: "Merchant Details",
                showDivider: true,
              ),
            ),
            if (merchantData!['businessName'] != null) ...[
              ListTile(
                leading: Icon(
                  Icons.business_rounded,
                  size: 30,
                  color: GmpayWidgetTheme.light.primaryColor,
                ),
                title: const Text(
                  "Business Name",
                  style: GmpayTextStyles.subtitle1,
                ),
                subtitle: Text(
                  merchantData!['businessName'],
                  style: GmpayTextStyles.subtitle2,
                ),
              )
            ],
            if (merchantData!['user']['email'] != null) ...[
              ListTile(
                onTap: () {
                  try {
                    launchUrl(Uri.parse(
                        "mailto:${merchantData!['user']['email']}?subject=Hello ${merchantData!['businessName']}&body=Hello ${merchantData!['businessName']}"));
                  } catch (_) {}
                },
                leading: Icon(
                  Icons.email_rounded,
                  size: 30,
                  color: GmpayWidgetTheme.light.primaryColor,
                ),
                title: const Text(
                  "Email",
                  style: GmpayTextStyles.subtitle1,
                ),
                subtitle: Text(
                  merchantData!['user']['email'],
                  style: GmpayTextStyles.subtitle2,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: gap_xs),
                child: Text(
                  'Tap to send email',
                  textAlign: TextAlign.center,
                  style: GmpayTextStyles.overline,
                ),
              )
            ],
          ])
        : const SimpleNotificationMessage(
            icon: Icons.dangerous,
            type: SimpleNotificationMessageType.error,
            message: "Could not load merchant details",
          );
  }
}
