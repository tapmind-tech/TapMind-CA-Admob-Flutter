import 'package:flutter/material.dart';
import 'package:flutter_tapmind_demo/ad_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TapMind Flutter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CommonAdButton(title: 'Banner Ad'),
            SizedBox(height: 16),
            CommonAdButton(title: 'Native Ad'),
            SizedBox(height: 16),
            CommonAdButton(title: 'Interstitial Ad'),
            SizedBox(height: 16),
            CommonAdButton(title: 'Rewarded Ad'),
          ],
        ),
      ),
    );
  }
}

class CommonAdButton extends StatelessWidget {
  final String title;

  const CommonAdButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.black45),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdScreen(adType: title)),
            );
          },
          child: Center(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
