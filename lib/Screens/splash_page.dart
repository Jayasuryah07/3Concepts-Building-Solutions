import 'dart:async';

import 'package:concepts/Screens/dashboard_page.dart';
import 'package:concepts/Screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Utils/shared_pref.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin()
  async{
    bool login = await SharedPref.isLoggedIn()??false;
    Timer(Duration(seconds: 3), () async {
      if(login == true)
      {
        Get.offAll(DashboardPage());
      }
      else
      {
        Get.offAll(LoginPage());
      }
      // Get.offAll(LoginPage());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/applogo.png"), context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("WELCOME TO",style: TextStyle(color: Color(0xff2D3290),fontSize: 25,fontWeight: FontWeight.bold),),
            SizedBox(height: Get.width/50,),
            Center(
              child: SizedBox(
                  width: Get.width/1.5,
                  height: Get.width/1.5,
                  // color: ConstHelper.transparent,
                  child: Image.asset("assets/applogo.png",fit: BoxFit.contain,)),
            ),
          ],
        ),
      ),
    );
  }
}
