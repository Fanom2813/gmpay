import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'gmpay_method_channel.dart';

abstract class GmpayPlatform extends PlatformInterface {
  /// Constructs a GmpayPlatform.
  GmpayPlatform() : super(token: _token);

  static final Object _token = Object();

  static GmpayPlatform _instance = MethodChannelGmpay();

  /// The default instance of [GmpayPlatform] to use.
  ///
  /// Defaults to [MethodChannelGmpay].
  static GmpayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GmpayPlatform] when
  /// they register themselves.
  static set instance(GmpayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
