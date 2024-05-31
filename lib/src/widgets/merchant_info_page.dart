import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:gmpay/assets/images.dart';
import 'package:gmpay/src/common/mounted_state.dart';
import 'package:gmpay/src/gmpay.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/busy.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:gmpay/src/widgets/simple_notification_message.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantInfoPage extends StatefulWidget {
  const MerchantInfoPage({super.key});

  @override
  State<MerchantInfoPage> createState() => _MerchantInfoPageState();
}

class _MerchantInfoPageState extends SafeState<MerchantInfoPage> {
  String? loading;
  ApiResponseMessage? apiResponseMessage;
  (String?, String?, String?, String?, String?)? info;

  @override
  void initState() {
    setState(() {
      loading = "Loading info please wait...";
    });

    Gmpay.instance.loadInfo().then((value) {
      if (value.$2 != null) {
        setState(() {
          apiResponseMessage = value.$2;
          loading = null;
        });
      } else if (value.$1 != null) {
        setState(() {
          info = (
            pick(value.$1, 'name').asStringOrNull(),
            pick(value.$1, 'email').asStringOrNull(),
            pick(value.$1, 'phone').asStringOrNull(),
            pick(value.$1, 'website').asStringOrNull(),
            pick(value.$1, 'description').asStringOrNull()
          );
          loading = null;
        });
      } else {
        setState(() {
          loading = null;
          apiResponseMessage = ApiResponseMessage(
              message:
                  "Cannot get information of your merchat , try again later",
              success: false);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(gap_s),
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.memory(
                    const Base64Decoder().convert(logo),
                    width: 140,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                    tooltip: "Close info window",
                  ),
                ],
              ),
            ),
          ),
          if (apiResponseMessage != null)
            SimpleNotificationMessage(
              message: apiResponseMessage!.message,
              type: apiResponseMessage!.success == true
                  ? SimpleNotificationMessageType.success
                  : SimpleNotificationMessageType.error,
              onClose: () {
                setState(() {
                  apiResponseMessage = null;
                });
              },
            ),
          if (loading != null)
            Center(
              child: Busy(
                message: loading,
              ),
            ),
          if (info != null) ...[
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
            if (info?.$1 != null) ...[
              ListTile(
                leading: Icon(
                  Icons.business_rounded,
                  size: 25,
                  color: GmpayWidgetTheme.light.primaryColor,
                ),
                title: const Text(
                  "Business Name",
                  style: GmpayTextStyles.subtitle1,
                ),
                subtitle: Text(
                  info!.$1!,
                  style: GmpayTextStyles.subtitle2,
                ),
              )
            ],
            if (info?.$5 != null) ...[
              ListTile(
                title: Text(
                  info!.$5!,
                  style: GmpayTextStyles.subtitle2,
                ),
              )
            ],
            if (info?.$3 != null) ...[
              ListTile(
                onTap: () {
                  try {
                    launchUrl(Uri.parse("tel:${info?.$3}"));
                  } catch (_) {}
                },
                leading: Icon(
                  Icons.phone_rounded,
                  size: 25,
                  color: GmpayWidgetTheme.light.primaryColor,
                ),
                title: const Text(
                  "Phone Number",
                  style: GmpayTextStyles.subtitle1,
                ),
                subtitle: Text(
                  info!.$3!,
                  style: GmpayTextStyles.subtitle2,
                ),
              )
            ],
            if (info?.$4 != null) ...[
              ListTile(
                onTap: () {
                  try {
                    launchUrl(Uri.parse("${info?.$4}"));
                  } catch (_) {}
                },
                leading: Icon(
                  Icons.web_rounded,
                  size: 25,
                  color: GmpayWidgetTheme.light.primaryColor,
                ),
                title: const Text(
                  "Website",
                  style: GmpayTextStyles.subtitle1,
                ),
                subtitle: Text(
                  info!.$4!,
                  style: GmpayTextStyles.subtitle2,
                ),
              )
            ],
            if (info?.$2 != null) ...[
              ListTile(
                onTap: () {
                  try {
                    launchUrl(Uri.parse(
                        "mailto:${info?.$2}?subject=Hello ${info?.$1}&body=Hello ${info?.$1}"));
                  } catch (_) {}
                },
                leading: Icon(
                  Icons.email_rounded,
                  size: 25,
                  color: GmpayWidgetTheme.light.primaryColor,
                ),
                title: const Text(
                  "Email",
                  style: GmpayTextStyles.subtitle1,
                ),
                subtitle: Text(
                  info!.$2!,
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
          ]
        ],
      ),
    );
  }
}
