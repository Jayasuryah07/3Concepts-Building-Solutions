import 'dart:io';

import 'package:concepts/Controller/controller.dart';
import 'package:concepts/Screens/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide MultipartFile, Response, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/api_const.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Controller controller = Get.put(Controller());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? imageFile;
  bool isEdit = false;
  bool isLoading = false;
  String token = "";

  @override
  void initState() {
    super.initState();
    getToken();
    controller.getCompanyData();
    controller.getCompanyImage();
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("loginToken") ?? "";
    print("TOKEN ===== $token");
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void openEditMode() {
    nameController.text = controller.companyData.value.companyName ?? "";
    mobileController.text = controller.companyData.value.companyMobileNo ?? "";
    emailController.text = controller.companyData.value.companyEmail ?? "";
    setState(() {
      isEdit = true;
    });
  }

  Future<void> updateProfile() async {

    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name required hai",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (mobileController.text.trim().isEmpty) {
      Get.snackbar("Error", "Mobile required hai",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      Dio dio = Dio();

      // ✅ KEY FIX: Laravel PUT + multipart fix
      // dio.put ke bajaye dio.post use karo
      // aur "_method": "PUT" field add karo (Laravel method spoofing)
      Map<String, dynamic> fields = {
        "_method": "PUT",                          // ✅ Laravel spoofing
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "email": emailController.text.trim(),
      };

      if (imageFile != null) {
        fields["user_image"] = await MultipartFile.fromFile(
          imageFile!.path,
          filename: imageFile!.path.split('/').last,
        );
      }

      print("=== SENDING DATA ===");
      print("name: ${fields['name']}");
      print("mobile: ${fields['mobile']}");
      print("email: ${fields['email']}");

      FormData formData = FormData.fromMap(fields);

      // ✅ dio.post use karo (PUT nahi)
      Response response = await dio.post(
        ApiConst.updateProfile,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.data}");

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Profile Updated Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await controller.getCompanyData();
        setState(() => isEdit = false);
      } else {
        Get.snackbar("Error", response.data.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }

    } on DioException catch (e) {
      setState(() => isLoading = false);
      print("ERROR: ${e.response?.data}");
      Get.snackbar(
        "Error",
        e.response?.data['message']?.toString() ?? e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Kya aap sign out karna chahte hain?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.to(LoginPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          if (!isEdit)
            IconButton(
              onPressed: signOut,
              icon: const Icon(Icons.logout),
              tooltip: "Sign Out",
            ),
        ],
      ),

      body: Obx(
            () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              GestureDetector(
                onTap: isEdit ? pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : NetworkImage(
                        controller.companyData.value.companyLogo == null ||
                            controller.companyData.value.companyLogo!.isEmpty
                            ? controller.noCompanyImage.value
                            : "${controller.companyImage.value}${controller.companyData.value.companyLogo}",
                      ) as ImageProvider,
                    ),
                    if (isEdit)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xff2F5D7C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── View Mode ──
              if (!isEdit) ...[

                Text(
                  controller.companyData.value.companyName ?? "---",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset("assets/profile/call.svg",
                              height: 24, width: 24, color: const Color(0xff2F5D7C)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(controller.companyData.value.companyMobileNo ?? "")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SvgPicture.asset("assets/profile/email.svg",
                              height: 24, width: 24, color: const Color(0xff2F5D7C)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(controller.companyData.value.companyEmail ?? "")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset("assets/area.svg",
                              height: 24, width: 24, color: const Color(0xff2F5D7C)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(controller.companyData.value.companyPlace ?? "")),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: openEditMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2F5D7C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                  ),
                ),

              ]

              // ── Edit Mode ──
              else ...[

                textField(controller: nameController, hint: "Name"),
                const SizedBox(height: 15),

                textField(
                  controller: mobileController,
                  hint: "Mobile",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),

                textField(
                  controller: emailController,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2F5D7C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Update Profile",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEdit = false;
                        imageFile = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}