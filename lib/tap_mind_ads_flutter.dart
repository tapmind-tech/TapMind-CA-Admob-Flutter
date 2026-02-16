
import 'tap_mind_ads_flutter_platform_interface.dart';

class TapMindAdsFlutter {
  Future<String?> getPlatformVersion() {
    return TapMindAdsFlutterPlatform.instance.getPlatformVersion();
  }
}
