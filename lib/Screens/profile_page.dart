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
    initProfilePage();
  }

  Future<void> initProfilePage() async {
    await getToken();
    await controller.getProfile();
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
    nameController.text = controller.profileData.value.name ?? "";
    mobileController.text = controller.profileData.value.mobile ?? "";
    emailController.text = controller.profileData.value.email ?? "";
    setState(() {
      isEdit = true;
    });
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name is required",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (mobileController.text.trim().isEmpty) {
      Get.snackbar("Error", "Mobile number is required",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      Dio dio = Dio();

      Map<String, dynamic> fields = {
        "_method": "PUT",
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

      FormData formData = FormData.fromMap(fields);

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

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Profile Updated Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await controller.getProfile();
        setState(() {
          isEdit = false;
          imageFile = null;
        });
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
        title: const Text("Sign Out",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to sign out?"),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Sign Out",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.black87 : Colors.grey.shade600,
        fontWeight: enabled ? FontWeight.normal : FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xffF4F6FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showOld = false;
    bool showNew = false;
    bool showConfirm = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff2F5D7C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xff2F5D7C),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff121212),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your old password and create a new one",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Old Password Field
                    TextField(
                      controller: oldPasswordController,
                      obscureText: !showOld,
                      decoration: InputDecoration(
                        hintText: "Old Password",
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: Color(0xff2F5D7C)),
                        filled: true,
                        fillColor: const Color(0xffF4F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showOld ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () =>
                              setDialogState(() => showOld = !showOld),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // New Password Field
                    TextField(
                      controller: newPasswordController,
                      obscureText: !showNew,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: Color(0xff2F5D7C)),
                        filled: true,
                        fillColor: const Color(0xffF4F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showNew ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () =>
                              setDialogState(() => showNew = !showNew),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirm,
                      decoration: InputDecoration(
                        hintText: "Confirm New Password",
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded,
                            color: Color(0xff2F5D7C)),
                        filled: true,
                        fillColor: const Color(0xffF4F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirm ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () =>
                              setDialogState(() => showConfirm = !showConfirm),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final oldPw = oldPasswordController.text.trim();
                              final newPw = newPasswordController.text.trim();
                              final confirmPw = confirmPasswordController.text.trim();

                              if (oldPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
                                Get.snackbar(
                                  "Error",
                                  "All fields are required",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              if (newPw != confirmPw) {
                                Get.snackbar(
                                  "Error",
                                  "New passwords do not match",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              if (newPw.length < 6) {
                                Get.snackbar(
                                  "Error",
                                  "New password must be at least 6 characters",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              Navigator.pop(context);
                              await changePassword(
                                oldPassword: oldPw,
                                newPassword: newPw,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2F5D7C),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Update Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    setState(() => isLoading = true);
    try {
      Dio dio = Dio();
      Map<String, dynamic> fields = {
        "mobile": controller.profileData.value.mobile ?? "",
        "old_password": oldPassword,
        "new_password": newPassword,
      };
      FormData formData = FormData.fromMap(fields);

      Response response = await dio.post(
        ApiConst.changePassword,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Password changed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response.data["message"]?.toString() ?? "Failed to change password",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        "Error",
        e.response?.data['message']?.toString() ?? e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteProfile() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text(
            "Are you sure you want to delete your profile? This action is permanent and cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                Dio dio = Dio();
                Response response = await dio.delete(
                  ApiConst.deleteProfile,
                  options: Options(
                    headers: {
                      "Authorization": "Bearer $token",
                      "Accept": "application/json",
                    },
                  ),
                );
                setState(() => isLoading = false);
                if (response.statusCode == 200 || response.statusCode == 204) {
                  Get.snackbar(
                    "Profile Deleted",
                    "Your profile has been deleted successfully.",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  Get.offAll(() => const LoginPage());
                } else {
                  Get.snackbar("Error", "Failed to delete profile",
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
              } catch (e) {
                setState(() => isLoading = false);
                Get.snackbar("Error", e.toString(),
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.bottomIndex.value = 0;
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xff2F5D7C),
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xffF4F6FA),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Profile Settings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff121212),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profile Image
            GestureDetector(
              onTap: isEdit ? pickImage : null,
              child: Stack(
                children: [
                  Obx(() {
                    final image = controller.profileData.value.userImage;
                    final baseUrl = controller.imagePath.value;
                    final fullUrl = (image != null &&
                            image.isNotEmpty &&
                            baseUrl.isNotEmpty)
                        ? "$baseUrl$image"
                        : null;

                    ImageProvider imgProvider;
                    if (imageFile != null) {
                      imgProvider = FileImage(imageFile!);
                    } else if (fullUrl != null) {
                      imgProvider = NetworkImage(fullUrl);
                    } else if (controller.noImagePath.value.isNotEmpty) {
                      imgProvider = NetworkImage(controller.noImagePath.value);
                    } else {
                      imgProvider =
                          const NetworkImage("https://via.placeholder.com/150");
                    }

                    return CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imgProvider,
                    );
                  }),
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
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── View Mode ──
            if (!isEdit) ...[
              Obx(
                () => Text(
                  controller.profileData.value.name ?? "---",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(
                  () => Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff2F5D7C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SvgPicture.asset(
                              "assets/profile/call.svg",
                              height: 22,
                              width: 22,
                              color: const Color(0xff2F5D7C),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Phone Number",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.profileData.value.mobile ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff121212),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff2F5D7C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SvgPicture.asset(
                              "assets/profile/email.svg",
                              height: 22,
                              width: 22,
                              color: const Color(0xff2F5D7C),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email Address",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.profileData.value.email ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff121212),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: openEditMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2F5D7C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: showChangePasswordDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2F5D7C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.lock_reset_rounded,
                          color: Colors.white, size: 20),
                      label: const Text(
                        "Change Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Delete Account Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: deleteProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: Colors.redAccent),
                  label: const Text(
                    "Delete Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ]

            // ── Edit Mode ──
            else ...[
              textField(
                controller: nameController,
                hint: "Full Name",
                suffixIcon: const Icon(Icons.person_outline_rounded,
                    color: Color(0xff2F5D7C)),
              ),
              const SizedBox(height: 15),
              textField(
                controller: mobileController,
                hint: "Mobile Number",
                enabled: false,
                suffixIcon: const Icon(Icons.lock_outline_rounded,
                    color: Colors.grey, size: 20),
              ),
              const SizedBox(height: 15),
              textField(
                controller: emailController,
                hint: "Email Address",
                keyboardType: TextInputType.emailAddress,
                suffixIcon: const Icon(Icons.email_outlined,
                    color: Color(0xff2F5D7C)),
              ),
              const SizedBox(height: 30),

              // Update and Cancel Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                isEdit = false;
                                imageFile = null;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2F5D7C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Update Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}