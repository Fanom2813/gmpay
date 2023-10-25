import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'gmpay_platform_interface.dart';

/// An implementation of [GmpayPlatform] that uses method channels.
class MethodChannelGmpay extends GmpayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('gmpay');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
