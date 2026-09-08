// lib/pages/view_profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';
import '../colors.dart';

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final UserProfileController profile =
  Get.find<UserProfileController>();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final user = profile.currentUser.value!;
    firstNameCtrl = TextEditingController(text: user.firstName);
    lastNameCtrl = TextEditingController(text: user.lastName);
    phoneCtrl = TextEditingController(text: user.phone);
    addressCtrl = TextEditingController(text: user.address);
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View profile'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _field('First name', firstNameCtrl),
            _field('Last name', lastNameCtrl),
            _field('Phone', phoneCtrl,
                keyboardType: TextInputType.phone),
            _field('Address', addressCtrl,
                keyboardType: TextInputType.streetAddress),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: saving ? null : _save,
              child: saving
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController ctrl, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await profile.updateProfile(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        address: addressCtrl.text.trim(),
      );
      Get.snackbar('Updated', 'Profile updated');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => saving = false);
    }
  }
}
