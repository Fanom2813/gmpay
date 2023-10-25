
import 'gmpay_platform_interface.dart';

class Gmpay {
  Future<String?> getPlatformVersion() {
    return GmpayPlatform.instance.getPlatformVersion();
  }
}
