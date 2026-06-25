import 'package:concepts/Controller/controller.dart';
import 'package:concepts/Model/company_model.dart';
import 'package:concepts/Screens/dashboard_page.dart';
import 'package:concepts/Utils/api_helper.dart';
import 'package:concepts/Utils/const_helper.dart';
import 'package:concepts/Utils/loader.dart';
import 'package:concepts/Utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController txtUserName = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  Controller controller = Get.put(Controller());
  
  bool _obscurePassword = true;
  bool _isHovered = false;
  bool _isTermsAccepted = false;

  @override
  void initState() {
    super.initState();
    txtUserName.clear();
    txtPassword.clear();
  }

  @override
  void dispose() {
    txtUserName.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  // Method to show WebView dialog
  void _showWebViewDialog(String title, String url) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 20,
          backgroundColor: Colors.white,
          child: Container(
            width: Get.width * 0.9,
            height: Get.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xff2F5D7C),
                        fontSize: Get.width * 0.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade700,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                // WebView
                Expanded(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(const Color(0x00000000))
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onProgress: (int progress) {
                            // Update loading progress if needed
                          },
                          onPageStarted: (String url) {
                            // Page started loading
                          },
                          onPageFinished: (String url) {
                            // Page finished loading
                          },
                          onWebResourceError: (WebResourceError error) {
                            // Handle error
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to load page. Please try again.",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      ..loadRequest(Uri.parse(url)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    final GlobalKey<FormState> forgotFormKey = GlobalKey<FormState>();
    final TextEditingController txtForgotMobile = TextEditingController(
      text: txtUserName.text.length == 10 ? txtUserName.text : "",
    );
    final TextEditingController txtForgotEmail = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 20,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Container(
              width: Get.width * 1.9,
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.07,
                vertical: Get.height * 0.04,
              ),
              child: Form(
                key: forgotFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section with icon and header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff2F5D7C), Color(0xff4A8BB7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff2F5D7C).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Forgot Password",
                              style: TextStyle(
                                color: const Color(0xff121212),
                                fontSize: Get.width * 0.055,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Reset your account password",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: Get.width * 0.035,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Description with icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff2F5D7C).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xff2F5D7C).withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: const Color(0xff2F5D7C),
                            size: Get.width * 0.05,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Enter the below details to reset your password.",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: Get.width * 0.025,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Mobile Number Field
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        color: const Color(0xff121212),
                        fontSize: Get.width * 0.042,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: txtForgotMobile,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffF4F6FA),
                        counterText: '',
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.phone_android_outlined,
                            color: const Color(0xff2F5D7C).withOpacity(0.7),
                            size: Get.width * 0.055,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: const Color(0xff2F5D7C).withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        hintText: "Enter Mobile Number",
                        hintStyle: TextStyle(
                          color: const Color(0xff7C7C7C).withOpacity(0.7),
                          fontSize: Get.width * 0.04,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.02,
                          vertical: Get.height * 0.018,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the Mobile Number";
                        }
                        if (value.length < 10) {
                          return "Mobile number must be 10 digits";
                        }
                        if (value.length > 10) {
                          return "Mobile number cannot exceed 10 digits";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length > 10) {
                          txtForgotMobile.text = value.substring(0, 10);
                          txtForgotMobile.selection = TextSelection.fromPosition(
                            TextPosition(offset: txtForgotMobile.text.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    Text(
                      "Email Address",
                      style: TextStyle(
                        color: const Color(0xff121212),
                        fontSize: Get.width * 0.042,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: txtForgotEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffF4F6FA),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.mail_outline_rounded,
                            color: const Color(0xff2F5D7C).withOpacity(0.7),
                            size: Get.width * 0.055,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: const Color(0xff2F5D7C).withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        hintText: "Enter Email Address",
                        hintStyle: TextStyle(
                          color: const Color(0xff7C7C7C).withOpacity(0.7),
                          fontSize: Get.width * 0.04,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.02,
                          vertical: Get.height * 0.018,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the email address";
                        }
                        if (!GetUtils.isEmail(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: Get.width * 0.042,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff2F5D7C), Color(0xff4A8BB7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff2F5D7C).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (forgotFormKey.currentState!.validate()) {
                                  // Close keyboard
                                  FocusScope.of(context).unfocus();
                                  
                                  // Show progress loader
                                  Loader.showLoader(
                                    context,
                                    "Submitting...",
                                  );

                                  try {
                                    final response = await ApiHelper.apiHelper.forgotPassword(
                                      mobile: txtForgotMobile.text.trim(),
                                      email: txtForgotEmail.text.trim(),
                                    );

                                    // Hide loader
                                    if (mounted) {
                                      Loader.hideLoader(context);
                                    }

                                    if (response != null && response["success"] == true) {
                                      // Close dialog
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response["message"] ?? "Password reset details sent.",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: Colors.green.shade700,
                                          duration: const Duration(seconds: 3),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response?["message"] ?? "Failed to reset password. Please try again.",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: Colors.red.shade700,
                                          duration: const Duration(seconds: 3),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Loader.hideLoader(context);
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error: $e",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        backgroundColor: Colors.red.shade700,
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  vertical: Get.height * 0.018,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Get.width * 0.042,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: Get.width * 0.045,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Additional info text
                    Center(
                      child: Text(
                        "We'll send password reset instructions to your email",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: Get.width * 0.032,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F3FB),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xffF0F3FB),
                const Color(0xffE8EDF5),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.06,
                vertical: Get.height * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Logo with shimmer effect
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: Container(
                            height: Get.width / 3.5,
                            width: Get.width / 1.5,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Image.asset(
                              "assets/applogo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: Get.height * 0.04),
                  
                  // Welcome Text with gradient
                  Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xff2F5D7C), Color(0xff4A8BB7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
                          "Welcome to",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: Get.width * 0.065,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        "Building Solution",
                        style: TextStyle(
                          color: const Color(0xff121212),
                          fontWeight: FontWeight.w800,
                          fontSize: Get.width * 0.07,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: Get.height * 0.02),
                  
                  // Card with glass morphism effect
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 5,
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(Get.width * 0.07),
                      child: Form(
                        key: key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mobile Number Field
                            Text(
                              "Mobile Number",
                              style: TextStyle(
                                color: const Color(0xff121212),
                                fontSize: Get.width * 0.045,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.012),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff2F5D7C).withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: txtUserName,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                style: TextStyle(
                                  fontSize: Get.width * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffF4F6FA),
                                  counterText: '',
                                  prefixIcon: Icon(
                                    Icons.phone_android_outlined,
                                    color: const Color(0xff2F5D7C).withOpacity(0.6),
                                    size: Get.width * 0.06,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: const Color(0xff2F5D7C).withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Enter Mobile Number",
                                  hintStyle: TextStyle(
                                    color: const Color(0xff7C7C7C).withOpacity(0.7),
                                    fontSize: Get.width * 0.04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: Get.width * 0.04,
                                    vertical: Get.height * 0.02,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter the Mobile Number";
                                  }
                                  if (value.length < 10) {
                                    return "Mobile number must be 10 digits";
                                  }
                                  if (value.length > 10) {
                                    return "Mobile number cannot exceed 10 digits";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.length > 10) {
                                    txtUserName.text = value.substring(0, 10);
                                    txtUserName.selection = TextSelection.fromPosition(
                                      TextPosition(offset: txtUserName.text.length),
                                    );
                                  }
                                },
                              ),
                            ),
                            
                            SizedBox(height: Get.height * 0.025),
                            
                            // Password Field
                            Text(
                              "Password",
                              style: TextStyle(
                                color: const Color(0xff121212),
                                fontSize: Get.width * 0.045,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.012),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff2F5D7C).withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: txtPassword,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  fontSize: Get.width * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffF4F6FA),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: const Color(0xff2F5D7C).withOpacity(0.6),
                                    size: Get.width * 0.06,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword 
                                        ? Icons.visibility_off_outlined 
                                        : Icons.visibility_outlined,
                                      color: const Color(0xff2F5D7C).withOpacity(0.6),
                                      size: Get.width * 0.055,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: const Color(0xff2F5D7C).withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Enter Password",
                                  hintStyle: TextStyle(
                                    color: const Color(0xff7C7C7C).withOpacity(0.7),
                                    fontSize: Get.width * 0.04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: Get.width * 0.04,
                                    vertical: Get.height * 0.02,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter the password";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Get.height * 0.01,
                                    horizontal: Get.width * 0.02,
                                  ),
                                ),
                                child: Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    color: const Color(0xff2F5D7C),
                                    fontSize: Get.width * 0.038,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xff2F5D7C).withOpacity(0.3),
                                    decorationThickness: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: Get.height * 0.02),
                            
                            // Terms and Conditions Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _isTermsAccepted,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isTermsAccepted = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xff2F5D7C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    side: BorderSide(
                                      color: const Color(0xff2F5D7C).withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: Get.width * 0.02),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: Get.width * 0.035,
                                        height: 1.5,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "I agree to the ",
                                        ),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: TextStyle(
                                            color: const Color(0xff2F5D7C),
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _showWebViewDialog(
                                                'Terms & Conditions',
                                                'https://3concepts.in/privacy-policy/'
                                              );
                                            },
                                        ),
                                        const TextSpan(
                                          text: " and ",
                                        ),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: TextStyle(
                                            color: const Color(0xff2F5D7C),
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _showWebViewDialog(
                                                'Privacy Policy',
                                                'https://3concepts.in/privacy-policy/'
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: Get.height * 0.015),
                            
                            // Login Button with animation
                            MouseRegion(
                              onEnter: (_) => setState(() => _isHovered = true),
                              onExit: (_) => setState(() => _isHovered = false),
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(begin: 1, end: _isHovered ? 1.02 : 1),
                                duration: const Duration(milliseconds: 200),
                                builder: (context, double scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        // Check if terms are accepted
                                        if (!_isTermsAccepted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                "Please accept the Terms & Conditions and Privacy Policy",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              backgroundColor: Colors.orange.shade700,
                                              duration: const Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        
                                        if (key.currentState!.validate()) {
                                          Loader.showLoader(
                                            ConstHelper.navigatorKey.currentContext!,
                                            "Please wait...",
                                          );
                                          ApiHelper.apiHelper.getLogin(
                                            mobile: txtUserName.text,
                                            password: txtPassword.text,
                                            deviceID: "asdadaa",
                                          ).then((login) async {
                                            if (login["code"] == 200) {
                                              List companyImageList = login["image_url"];
                                              CompanyDataModel company = CompanyDataModel.fromJson(login["company"]);
                                              String token = login["data"]["token"];
                                              SharedPref.saveCompanyData(company);
                                              SharedPref.saveImagePath(companyImageList[0]["image_url"]);
                                              SharedPref.saveNoImagePath(companyImageList[1]["image_url"]);
                                              
                                              await SharedPref.saveLogin(true);
                                              await SharedPref.saveLoginToken(token);
                                              
                                              Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                              
                                              Get.offAll(
                                                const DashboardPage(),
                                                transition: Transition.fadeIn,
                                                duration: const Duration(milliseconds: 500),
                                              );
                                              ScaffoldMessenger.of(
                                                ConstHelper.navigatorKey.currentContext!
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    login["message"],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.green.shade700,
                                                  duration: const Duration(seconds: 2),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                              ScaffoldMessenger.of(
                                                ConstHelper.navigatorKey.currentContext!
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    login["message"],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.red.shade700,
                                                  duration: const Duration(seconds: 2),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xff2F5D7C), Color(0xff4A8BB7)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff2F5D7C).withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: Get.height * 0.02,
                                            horizontal: Get.width * 0.02,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Login",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: Get.width * 0.05,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              SizedBox(width: Get.width * 0.02),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: Get.width * 0.05,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            SizedBox(height: Get.height * 0.015),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
                                  child: Text(
                                    "Secure Login",
                                    style: TextStyle(
                                      color: Colors.grey.withOpacity(0.5),
                                      fontSize: Get.width * 0.035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}