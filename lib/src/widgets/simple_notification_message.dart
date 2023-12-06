import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/text_theme.dart';

enum SimpleNotificationMessageType { success, error, warning, info }

class SimpleNotificationMessage extends StatelessWidget {
  const SimpleNotificationMessage(
      {super.key, this.icon, this.message, this.type});

  final IconData? icon;
  final String? message;
  final SimpleNotificationMessageType? type;

  List<Color> _getColor() {
    switch (type) {
      case SimpleNotificationMessageType.success:
        return [Colors.green.shade900, Colors.green.shade50];
      case SimpleNotificationMessageType.error:
        return [Colors.red.shade900, Colors.red.shade50];
      case SimpleNotificationMessageType.warning:
        return [Colors.orange.shade900, Colors.orange.shade50];
      case SimpleNotificationMessageType.info:
        return [Colors.blue.shade900, Colors.blue.shade50];
      default:
        return [Colors.green.shade900, Colors.green.shade50];
    }
  }

  @override
  Widget build(BuildContext context) {
    var color = _getColor();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color[1],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon ?? Icons.shield,
                size: 45,
                color: color[0],
              ),
            ),
            Expanded(
                child: Text(
              message ?? "",
              textAlign: TextAlign.justify,
              style: GmpayTextStyles.body2.copyWith(color: color[0]),
            ))
          ],
        ),
      ),
    );
  }
}
