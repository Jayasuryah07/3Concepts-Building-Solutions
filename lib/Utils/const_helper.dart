import 'package:flutter/cupertino.dart';

class ConstHelper{
  ConstHelper._();
  static ConstHelper constHelper = ConstHelper._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String googleMapsApiKey = "AIzaSyATD2nO9BGYVgmKvBrJQjgY1W8rbZWUJyA"; // Replace with your key
}  