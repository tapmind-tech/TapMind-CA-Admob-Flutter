import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  // Run the app with error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log to console for debugging
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String error = "";
  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  
  // Native Ad
  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;
  
  // Ad Unit IDs
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7450680965442270/1794874535';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2967653914154128/8115509682';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  
  String get _nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7450680965442270/8599544313';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2967653914154128/4841838453';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay initialization slightly to ensure widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
     Future.delayed(const Duration(seconds: 2), () {
      _loadBannerAd();
      _loadNativeAd();
     });
    });
  }
  
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          error = 'Failed to load a banner ad :: Reason : ${err.message}';
          debugPrint('Failed to load a banner ad: ${err.message}');
          setState(() {});
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }
  
  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: _nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isNativeAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          error = 'Failed to load a native ad :: Reason : ${err.message}';
          debugPrint('Failed to load a native ad: ${err.message}');
          setState(() {
            _isNativeAdReady = false;
          });
          ad.dispose();
        },
        onAdClicked: (_) {
          debugPrint('Native ad clicked');
        },
        onAdImpression: (_) {
          debugPrint('Native ad impression');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    _nativeAd?.load();
  }
  
  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _bannerAd = null;
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapMind Flutter 1',
      home: Scaffold(
        appBar: AppBar(title: const Text('TapMind Flutter')),
        body: SafeArea(
          child: Column(
            children: [
              if(error.isNotEmpty)
              Expanded(child: Center(child: Text(error))),
              // Native Ad
              if (_isNativeAdReady && _nativeAd != null)
                Container(
                  margin: const EdgeInsets.all(16.0),
                  height: 300,
                  child: AdWidget(ad: _nativeAd!),
                ),
              // Spacer
              const Spacer(),
              // Banner Ad at the bottom
              if (_isBannerAdReady && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
