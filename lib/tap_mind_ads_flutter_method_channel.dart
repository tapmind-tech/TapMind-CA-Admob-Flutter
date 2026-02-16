import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tap_mind_ads_flutter_platform_interface.dart';

/// An implementation of [TapMindAdsFlutterPlatform] that uses method channels.
class MethodChannelTapMindAdsFlutter extends TapMindAdsFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tap_mind_ads_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
