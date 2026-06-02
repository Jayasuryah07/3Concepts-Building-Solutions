import 'package:concepts/Screens/splash_page.dart';
import 'package:concepts/Utils/const_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void main()
{
  runApp(GetMaterialApp(
    navigatorKey: ConstHelper.navigatorKey,
    debugShowCheckedModeBanner: false,
    initialRoute: "splash",
    routes: {
      "splash":(p0) => SplashPage()
    },
  ));
}