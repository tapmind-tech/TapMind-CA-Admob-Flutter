import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdScreen extends StatefulWidget {
  final String adType;
  const AdScreen({super.key, required this.adType});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  String error = "";

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Native Ad
  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;

  // Rewarded Ad
  RewardedAd? _rewardedAd;

  // Track if a full-screen ad has been shown to avoid flicker during pop
  bool _adShown = false;

  // Ad Unit IDs (Banner & Native from original code)
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2967653914154128/5364787835';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2967653914154128/8115509682';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2967653914154128/8222410102';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2967653914154128/4841838453';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Using test IDs for Interstitial and Rewarded as standard fallback
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2967653914154128/2324998439';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2967653914154128/4199404618';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2967653914154128/7823225012';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void initState() {
    super.initState();
    // Load ads as soon as the screen initializes
    if (widget.adType == 'Banner Ad') {
      _loadBannerAd();
    } else if (widget.adType == 'Native Ad') {
      _loadNativeAd();
    } else if (widget.adType == 'Interstitial Ad') {
      _loadInterstitialAd();
    } else if (widget.adType == 'Rewarded Ad') {
      _loadRewardedAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          if (mounted) {
            setState(() {
              error = 'Failed to load a banner ad :: Reason : ${err.message}';
              _isBannerAdReady = false;
            });
          }
          debugPrint('Failed to load a banner ad: ${err.message}');
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
          if (mounted) {
            setState(() {
              _isNativeAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          if (mounted) {
            setState(() {
              error = 'Failed to load a native ad :: Reason : ${err.message}';
              _isNativeAdReady = false;
            });
          }
          debugPrint('Failed to load a native ad: ${err.message}');
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

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              if (mounted) Navigator.pop(context);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitialAd = null;
              if (mounted) Navigator.pop(context);
            },
          );
          _interstitialAd = ad;
          if (mounted) {
            _adShown = true;
            _interstitialAd!.show();
          }
        },
        onAdFailedToLoad: (err) {
          if (mounted) {
            setState(() {
              error =
                  'Failed to load an interstitial ad :: Reason : ${err.message}';
            });
          }
          debugPrint('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              if (mounted) Navigator.pop(context);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _rewardedAd = null;
              if (mounted) Navigator.pop(context);
            },
          );
          _rewardedAd = ad;
          if (mounted) {
            _adShown = true;
            _rewardedAd!.show(
              onUserEarnedReward: (ad, reward) {
                debugPrint(
                  'User earned reward: ${reward.amount} ${reward.type}',
                );
              },
            );
          }
        },
        onAdFailedToLoad: (err) {
          if (mounted) {
            setState(() {
              error = 'Failed to load a rewarded ad :: Reason : ${err.message}';
            });
          }
          debugPrint('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void _disposeAllAds() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _nativeAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }

  @override
  void dispose() {
    _disposeAllAds();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adType),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _disposeAllAds();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (error.isNotEmpty) Expanded(child: Center(child: Text(error))),

            if ((widget.adType == 'Interstitial Ad' ||
                    widget.adType == 'Rewarded Ad') &&
                error.isEmpty &&
                !_adShown)
              const Expanded(child: Center(child: CircularProgressIndicator())),

            // Native Ad
            if (widget.adType == 'Native Ad' &&
                _isNativeAdReady &&
                _nativeAd != null)
              Container(
                margin: const EdgeInsets.all(16.0),
                height: 300,
                child: AdWidget(ad: _nativeAd!),
              ),
            // Spacer
            if (widget.adType == 'Banner Ad') const Spacer(),
            // Banner Ad at the bottom
            if (widget.adType == 'Banner Ad' &&
                _isBannerAdReady &&
                _bannerAd != null)
              Container(
                margin: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
