// ignore_for_file: use_build_context_synchronously
import 'package:miledrivers/components/MyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  late WebViewController controller;
  var isLoading;

  @override
  void initState() {
   setState(() {
      isLoading = LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.blue,
        size: 100,
      );
    });
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = null;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = null;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://osl.co.ke/about-us/privacy-policy/'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Privacy Policy',
        home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back),
                )
              ],
            ),
            backgroundColor: Color.fromRGBO(0, 96, 177, 1),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: const Drawer(child: MyDrawer()),
          body: Stack(
            children: [
              WebViewWidget(controller: controller),
              Center(
                child: isLoading,
              )
            ],
          ),
        ));
  }
}
