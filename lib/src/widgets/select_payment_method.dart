import 'dart:io';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/app_provider.dart';
import 'package:gmpay/src/common/constants.dart';
import 'package:gmpay/src/common/mounted_state.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/gmpay_header.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SelectPaymentMethod extends StatefulWidget {
  const SelectPaymentMethod({
    super.key,
    this.isWithdraw = false,
  });

  final bool? isWithdraw;

  @override
  State<SelectPaymentMethod> createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends SafeState<SelectPaymentMethod> {
  final methodFormKey = GlobalKey<FormBuilderState>();
  int? selectedMethod;
  List<PaymentMethod>? methods;

  @override
  void initState() {
    super.initState();
    (widget.isWithdraw == true
            ? Gmpay.instance.loadWithdrawMethods()
            : Gmpay.instance.loadPaymentMethods())
        .then((value) {
      if (mounted) {
        setState(() {
          if (value.$1 != null) {
            methods = pick(value.$1)
                .asListOrEmpty((p0) => p0.asMapOrEmpty())
                .map((e) => (
                      pick(e, 'methodName').asStringOrNull(),
                      pick(e, 'optionName').asStringOrNull(),
                      pick(e, 'description').asStringOrNull(),
                      pick(e, 'extraFields').asListOrEmpty(
                        (p0) => p0.asMapOrEmpty(),
                      ),
                      pick(e, 'otpMethod').asStringOrNull(),
                      pick(e, 'module').asStringOrNull(),
                      pick(e, 'image').asStringOrNull(),
                      pick(e, 'instructions').asStringOrNull(),
                    ))
                .toList();
          }
        });
      }
    }).catchError(handleError);
  }

  handleError(dynamic e) {
    if (e is SocketException) {
      // setState(() {
      //   apiResponseMessage = ApiResponseMessage(
      //       message:
      //           "Sorry we could not connect to our server, kindly check if you have an active internet access and try again",
      //       success: false);
      // });
      // } else if (e is ApiResponseMessage) {
      //   setState(() {
      //     apiResponseMessage = e;
      //   });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(gapS),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: gapXs, bottom: gapM),
          child: SectionTitle(
            title: "Unified Payments",
            subtitle:
                "Select Your Preferred ${widget.isWithdraw == true ? "Withdrawing" : "Payment"} Method to continue",
            trailing: getMerchantInfoButton(context),
          ),
        ),
        FormBuilder(
          key: methodFormKey,
          initialValue: {
            'selectedMethod': selectedMethod,
          },
          child: Column(
            children: [
              FormBuilderField(
                name: 'selectedMethod',
                validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required()]),
                builder: (field) {
                  return Column(
                    children: methods == null
                        ? [
                            buildPlaceholder(),
                            buildPlaceholder(),
                            buildPlaceholder(),
                            buildPlaceholder(),
                            buildPlaceholder(),
                          ]
                        : methods!.map((e) {
                            var selected =
                                methods!.indexOf(e) == selectedMethod;
                            return Material(
                              color: selected
                                  ? Colors.green.shade50
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(gapS),
                              child: ListTile(
                                leading: e.$7 != null
                                    ? Image.asset('assets/${e.$7}',
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                        package: 'gmpay')
                                    : const Icon(
                                        Icons.payment,
                                        size: 30,
                                      ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: gapXs, horizontal: gapS),
                                selected: selected,
                                onTap: () {
                                  // field.didChange(methods!.indexOf(e));
                                  // setState(() {
                                  //   selectedMethod = methods!.indexOf(e);
                                  // });

                                  AppProvider.instance.method = e;
                                  WoltModalSheet.of(context)
                                      .showPageWithId("payment_form");

                                  // if (widget.onSelectPaymentMethod != null) {

                                  // }
                                },
                                title: Text(
                                  "${e.$2}",
                                  style: GmpayTextStyles.body1.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: e.$3 != null
                                    ? Text(
                                        e.$3!,
                                        textAlign: TextAlign.justify,
                                        style: GmpayTextStyles.subtitle2
                                            .copyWith(
                                                fontWeight: FontWeight.w300),
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildPlaceholder() {
    return ListTile(
        leading: Shimmer(
          color: shimmerColor,
          child: const SizedBox(
            width: 30,
            height: 30,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: gapXs, horizontal: gapS),
        title: Shimmer(
            color: shimmerColor,
            child: const Text(
              "",
            )),
        subtitle: Shimmer(
            color: shimmerColor,
            child: Text(
              "",
              textAlign: TextAlign.justify,
              style: GmpayTextStyles.subtitle2
                  .copyWith(fontWeight: FontWeight.w300),
            )));
  }
}
