import 'package:flutter_test/flutter_test.dart';
import 'package:gmpay/gmpay.dart';
import 'package:gmpay/gmpay_platform_interface.dart';
import 'package:gmpay/gmpay_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGmpayPlatform
    with MockPlatformInterfaceMixin
    implements GmpayPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GmpayPlatform initialPlatform = GmpayPlatform.instance;

  test('$MethodChannelGmpay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGmpay>());
  });

  test('getPlatformVersion', () async {
    Gmpay gmpayPlugin = Gmpay();
    MockGmpayPlatform fakePlatform = MockGmpayPlatform();
    GmpayPlatform.instance = fakePlatform;

    expect(await gmpayPlugin.getPlatformVersion(), '42');
  });
}
