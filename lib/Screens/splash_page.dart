import 'dart:async';

import 'package:concepts/Screens/dashboard_page.dart';
import 'package:concepts/Screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart'; // 1. Import the video player package

import '../Utils/shared_pref.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _videoController;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideoAndLogin();
  }

  void initializeVideoAndLogin() async {
    // 2. Set up the video player controller using your asset file
    _videoController = VideoPlayerController.asset("assets/logo.mp4");

    try {
      await _videoController.initialize();
      setState(() {
        _isControllerInitialized = true;
      });
      _videoController.play(); // Auto-start the video playback
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }

    // 3. Check login state
    bool login = await SharedPref.isLoggedIn() ?? false;

    // 4. Change timer to 10 seconds to let the full video play out
    Timer(const Duration(seconds: 10), () async {
      if (login == true) {
        Get.offAll(DashboardPage());
      } else {
        Get.offAll(LoginPage());
      }
    });
  }

  @override
  void dispose() {
    // 5. CRUCIAL: Always dispose your controller to avoid memory leaks
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "WELCOME TO",
              style: TextStyle(
                color: Color(0xff2D3290),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Get.width / 50),
            Center(
              child: SizedBox(
                width: Get.width / 0.5,
                height: Get.width / 1.5,
                // 6. Replace Image.asset with VideoPlayer conditional check
                child: _isControllerInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2D3290)),
                        ), // Displays a loader while video is loading
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}