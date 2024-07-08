import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:gmpay/src/common/app_provider.dart';
import 'package:gmpay/src/common/mounted_state.dart';
import 'package:gmpay/src/gmpay.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:gmpay/src/widgets/simple_notification_message.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class MerchantInfoPage extends StatefulWidget {
  const MerchantInfoPage({super.key});

  @override
  State<MerchantInfoPage> createState() => _MerchantInfoPageState();
}

class _MerchantInfoPageState extends SafeState<MerchantInfoPage> {
  String? loading;
  final colorOpacity = 1.0;
  final duration = const Duration(seconds: 2);
  (String?, String?, String?, String?, String?)? info;

  @override
  void initState() {
    Gmpay.instance.loadInfo().then((value) {
      if (value.$2 != null) {
        setState(() {
          loading = null;
        });

        AppProvider.instance.apiResponseMessage = value.$2;
        if (mounted) {
          WoltModalSheet.of(context).showPageWithId("failed_page");
        }
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
        });

        AppProvider.instance.apiResponseMessage = ApiResponseMessage(
            message:
                "Cannot get information of your merchant , try again later",
            success: false);

        if (mounted) {
          WoltModalSheet.of(context).showPageWithId("failed_page");
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(gap_s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
              onPressed: () {
                WoltModalSheet.of(context).showPageWithId("payment_methods");
              },
              icon: const Icon(Icons.arrow_back)),
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
          ListTile(
            title: Shimmer(
                enabled: info == null || info?.$5 == null,
                colorOpacity: colorOpacity,
                color: shimmerColor,
                duration: duration,
                child: Text(
                  info?.$5 ?? '',
                  style: GmpayTextStyles.subtitle2,
                )),
          ),
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
            subtitle: Shimmer(
              colorOpacity: colorOpacity,
              color: shimmerColor,
              duration: duration,
              enabled: info == null || info?.$1 == null,
              child: Text(
                info?.$1 ?? '',
                style: GmpayTextStyles.subtitle2,
              ),
            ),
          ),
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
            subtitle: Shimmer(
                enabled: info == null || info?.$3 == null,
                colorOpacity: colorOpacity,
                color: shimmerColor,
                duration: duration,
                child: Text(
                  info?.$3 ?? '',
                  style: GmpayTextStyles.subtitle2,
                )),
          ),
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
            subtitle: Shimmer(
                enabled: info == null || info?.$4 == null,
                colorOpacity: colorOpacity,
                color: shimmerColor,
                duration: duration,
                child: Text(
                  info?.$4 ?? '',
                  style: GmpayTextStyles.subtitle2,
                )),
          ),
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
            subtitle: Shimmer(
                enabled: info == null || info?.$2 == null,
                colorOpacity: colorOpacity,
                color: shimmerColor,
                duration: duration,
                child: Text(
                  info?.$2 ?? '',
                  style: GmpayTextStyles.subtitle2,
                )),
          ),
          const Padding(
            padding: EdgeInsets.only(top: gap_xs),
            child: Text(
              'Tap to send email',
              textAlign: TextAlign.center,
              style: GmpayTextStyles.overline,
            ),
          ),
        ],
      ),
    );
  }
}
