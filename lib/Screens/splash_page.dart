import 'dart:async';

import 'package:concepts/Screens/dashboard_page.dart';
import 'package:concepts/Screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../Utils/shared_pref.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  bool _isControllerInitialized = false;
  bool _isNavigating = false;
  bool _hasNavigated = false;
  bool _isInCall = false;
  bool _videoStartedPlaying = false;
  bool _isInitializing = false;
  double _currentVolume = 1.0;
  Timer? _navigationTimer;
  Timer? _videoCheckTimer;
  int _retryCount = 0;
  static const int maxRetries = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeVideoAndLogin();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      bool wasInCall = _isInCall;
      _isInCall = false;
      _updateVolume();
      
      // If call just ended and video wasn't playing, try to play
      if (wasInCall && _isControllerInitialized && !_hasNavigated) {
        debugPrint('📞 Call ended - resuming video');
        _forcePlayVideo();
      }
      
      // Restart video if needed
      if (_isControllerInitialized && !_videoStartedPlaying && !_hasNavigated) {
        _forcePlayVideo();
      }
    } else if (state == AppLifecycleState.inactive) {
      // App is going to background or call is active
      _isInCall = true;
      _updateVolume();
      debugPrint('📞 Call detected - video muted');
    }
  }

  void _updateVolume() {
    if (!_isControllerInitialized) return;
    
    double targetVolume = _isInCall ? 0.0 : 1.0;
    
    if (_currentVolume != targetVolume) {
      try {
        _videoController.setVolume(targetVolume);
        _currentVolume = targetVolume;
        debugPrint(_isInCall ? '🔇 Muted (call active)' : '🔊 Volume restored');
      } catch (e) {
        debugPrint('Error updating volume: $e');
      }
    }
  }

  void initializeVideoAndLogin() async {
    if (_isNavigating || _isInitializing || _hasNavigated) return;
    _isInitializing = true;

    try {
      // Initialize video controller
      _videoController = VideoPlayerController.asset("assets/logo.mp4");
      await _videoController.initialize();
      
      if (mounted && !_hasNavigated) {
        setState(() {
          _isControllerInitialized = true;
          _isInitializing = false;
        });
        
        // Set initial volume
        _currentVolume = 1.0;
        _updateVolume();
        
        // Start video playback
        _forcePlayVideo();
      }
    } catch (e) {
      debugPrint("❌ Error initializing video player: $e");
      _isInitializing = false;
      _handleError();
    }

    // Start 3-second fallback timer
    _startNavigationFallback();
    
    // Check login state in background
    _checkLoginAndNavigate();
  }

  void _forcePlayVideo() {
    if (!_isControllerInitialized || _isNavigating || _hasNavigated) return;
    
    try {
      _videoController.setLooping(false);
      _videoController.play();
      
      // Check if video actually started playing
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_hasNavigated) {
          if (_videoController.value.isPlaying) {
            _videoStartedPlaying = true;
            _navigationTimer?.cancel();
            debugPrint('✅ Video is playing');
          } else {
            debugPrint('⚠️ Video is NOT playing');
            if (_isInCall) {
              _videoStartedPlaying = false;
            }
          }
        }
      });
      
      // Add listener for video end
      _videoController.removeListener(_videoListener);
      _videoController.addListener(_videoListener);
      
      // Start playback check
      _startVideoPlaybackCheck();
      
    } catch (e) {
      debugPrint('❌ Error playing video: $e');
      _handleError();
    }
  }

  void _startNavigationFallback() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated && !_isNavigating && mounted) {
        // During call: navigate if video didn't start playing
        if (_isInCall) {
          if (!_videoStartedPlaying || !_videoController.value.isPlaying) {
            debugPrint('📞 In call - video not playing, navigating after 3 seconds');
            _navigateToNextScreen();
          } else {
            debugPrint('📞 In call - video is playing, continuing');
          }
        } else {
          // Normal: navigate only if video never started
          if (!_videoStartedPlaying) {
            debugPrint('⏱️ 3-second fallback - video never started, navigating');
            _navigateToNextScreen();
          }
        }
      }
    });
  }

  void _startVideoPlaybackCheck() {
    _videoCheckTimer?.cancel();
    _videoCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isNavigating || _hasNavigated) {
        timer.cancel();
        return;
      }
      
      if (_isControllerInitialized) {
        // Check if video ended
        if (_videoController.value.position >= _videoController.value.duration && 
            _videoController.value.duration > Duration.zero) {
          timer.cancel();
          _navigationTimer?.cancel();
          debugPrint('🎬 Video ended - navigating');
          _navigateToNextScreen();
          return;
        }
        
        // If not in call and video stopped, try to restart
        if (!_isInCall && !_videoController.value.isPlaying && _videoStartedPlaying) {
          debugPrint('🔄 Video stopped, restarting...');
          try {
            _videoController.play();
          } catch (e) {
            debugPrint('Failed to restart: $e');
          }
        }
      }
    });
  }

  void _videoListener() {
    if (!_isControllerInitialized || _isNavigating || _hasNavigated) return;
    
    // If video ended
    if (_videoController.value.position >= _videoController.value.duration && 
        _videoController.value.duration > Duration.zero) {
      _videoCheckTimer?.cancel();
      _navigationTimer?.cancel();
      debugPrint('🎬 Video ended (listener) - navigating');
      _navigateToNextScreen();
      return;
    }
    
    // If video started playing and we haven't marked it
    if (_videoController.value.isPlaying && !_videoStartedPlaying) {
      _videoStartedPlaying = true;
      _navigationTimer?.cancel();
      debugPrint('✅ Video started playing (listener)');
    }
  }

  void _checkLoginAndNavigate() async {
    try {
      bool login = await SharedPref.isLoggedIn() ?? false;
      debugPrint('Login status: $login');
    } catch (e) {
      debugPrint('Error checking login: $e');
    }
  }

  void _handleError() {
    if (_retryCount < maxRetries && !_isNavigating && !_hasNavigated) {
      _retryCount++;
      debugPrint('🔄 Retry $_retryCount/$maxRetries');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isNavigating && !_hasNavigated) {
          _isInitializing = false;
          initializeVideoAndLogin();
        }
      });
    } else if (!_isNavigating && !_hasNavigated) {
      debugPrint('❌ Max retries - navigating');
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    if (_isNavigating || _hasNavigated) return;
    _isNavigating = true;
    _hasNavigated = true;
    
    // Clean up timers
    _navigationTimer?.cancel();
    _videoCheckTimer?.cancel();
    
    // Clean up video
    try {
      _videoController.removeListener(_videoListener);
      await _videoController.pause();
    } catch (e) {
      debugPrint('Error cleaning up: $e');
    }
    
    // Check login and navigate
    bool login = await SharedPref.isLoggedIn() ?? false;
    if (mounted) {
      debugPrint('🚀 Navigating to: ${login ? "Dashboard" : "Login"}');
      Get.offAll(() => login ? const DashboardPage() : const LoginPage());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigationTimer?.cancel();
    _videoCheckTimer?.cancel();
    try {
      _videoController.removeListener(_videoListener);
      _videoController.dispose();
    } catch (e) {
      debugPrint('Error disposing: $e');
    }
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
                child: _isControllerInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2D3290)),
                        ),
                      ),
              ),
            ),
            // Show call status indicator
            if (_isInCall && _isControllerInitialized)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                
              ),
          ],
        ),
      ),
    );
  }
}