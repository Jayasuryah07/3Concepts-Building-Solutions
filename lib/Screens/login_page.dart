import 'package:concepts/Controller/controller.dart';
import 'package:concepts/Model/company_model.dart';
import 'package:concepts/Screens/dashboard_page.dart';
import 'package:concepts/Utils/api_helper.dart';
import 'package:concepts/Utils/const_helper.dart';
import 'package:concepts/Utils/loader.dart';
import 'package:concepts/Utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    txtUserName.clear();
    txtPassword.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xffF0F3FB),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Get.width/10,),
              Center(
                child: Container(
                  height: Get.width/4,
                  width: Get.width/1,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Image.asset("assets/applogo.png",fit: BoxFit.contain,),
                ),
              ),
              SizedBox(height: Get.width/10,),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: Text("Welcome to",style: TextStyle(color: Color(0xff121212),fontWeight: FontWeight.w500,fontSize: 20),textAlign: TextAlign.center,)),
                        Center(child: Text("Brief Solution Login Now!",style: TextStyle(color: Color(0xff121212),fontWeight: FontWeight.w500,fontSize: 20),textAlign: TextAlign.center,)),
                        SizedBox(height: Get.width/10,),
                        Text("User Name",style: TextStyle(color: Color(0xff121212),fontSize: 18,fontWeight: FontWeight.w400),),
                        SizedBox(height: Get.width/30,),
                        TextFormField(
                          controller: txtUserName,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF4F6FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none
                            ),
                            hintText: "Enter Username",
                            hintStyle: TextStyle(color: Color(0xff7C7C7C),fontSize: 16,fontWeight: FontWeight.w500)
                          ),
                          validator: (value) {
                            if(value!.isEmpty)
                              {
                                return "Please enter the username";
                              }
                            return null;
                          },
                        ),
                        SizedBox(height: Get.width/20,),
                        Text("Password",style: TextStyle(color: Color(0xff121212),fontSize: 18,fontWeight: FontWeight.w400),),
                        SizedBox(height: Get.width/30,),
                        TextFormField(
                          controller: txtPassword,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffF4F6FA),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none
                              ),
                              hintText: "Enter Password",
                              hintStyle: TextStyle(color: Color(0xff7C7C7C),fontSize: 16,fontWeight: FontWeight.w500)
                          ),
                          validator: (value) {
                            if(value!.isEmpty)
                            {
                              return "Please enter the password";
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () {

                          }, child: Text("Forgot Password",style: TextStyle(color: Color(0xff2F5D7C)),)),
                        ),
                        SizedBox(height: Get.width/30,),
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            if(key.currentState!.validate())
                              {
                                Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Please wait...");
                                ApiHelper.apiHelper.getLogin(
                                    mobile: txtUserName.text,
                                    password: txtPassword.text,
                                    deviceID: "asdadaa").then((login) async {
                                      // print("");
                                  if(login["code"] == 200)
                                    {
                                      List companyImageList = login["image_url"];
                                      // print("TTTTTTT ${login["data"]["token"].length}");

                                      // print("555555555 ${token.length}");

                                      CompanyDataModel company = CompanyDataModel.fromJson(login["company"]);
                                      String token = login["data"]["token"];
                                      SharedPref.saveCompanyData(company);
                                      SharedPref.saveImagePath(companyImageList[0]["image_url"]);
                                      SharedPref.saveNoImagePath(companyImageList[1]["image_url"]);

                                      await SharedPref.saveLogin(true);
                                      await SharedPref.saveLoginToken(token);

                                      Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);

                                      Get.offAll(DashboardPage(),transition: Transition.fadeIn);
                                      ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(login["message"],style: TextStyle(color: Colors.white),),backgroundColor: Colors.green,duration: Duration(seconds: 2),));
                                    }
                                  else
                                    {
                                      Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                      print("EEEEEEEEEEEEEE ${login["message"]}");
                                      ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(login["message"],style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,duration: Duration(seconds: 2),));
                                    }

                                    },);

                                // Get.to(DashboardPage(),transition: Transition.fadeIn);
                              }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff2F5D7C),
                              borderRadius: BorderRadius.circular(30)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Center(child: Text("Login",style: TextStyle(color: Color(0xffFFFFFF),fontSize: 18,fontWeight: FontWeight.w500),)),
                            ),
                          ),
                        ),
                        SizedBox(height: Get.width/30,),
                        Center(child: Text("or",style: TextStyle(color: Color(0xff121212),fontWeight: FontWeight.w400,fontSize: 16),)),
                        SizedBox(height: Get.width/30,),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xffF4F6FA),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/google.svg",height: Get.width/12,width: Get.width/12,fit: BoxFit.cover,),
                                SizedBox(width: Get.width/20,),
                                Text("Sign up with google",style: TextStyle(color: Color(0xff121212),fontSize: 14,fontWeight: FontWeight.w400),)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Get.width/20,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    ));
  }
}
