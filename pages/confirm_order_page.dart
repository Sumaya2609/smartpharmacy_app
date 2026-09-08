// lib/pages/confirm_order_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';
import '../colors.dart';
import 'payment_page.dart';

class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  late TextEditingController addressCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    final profile = Get.find<UserProfileController>();
    final user = profile.currentUser.value!;
    addressCtrl = TextEditingController(text: user.address);
    phoneCtrl = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm address'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _editableRow(
              label: 'Address',
              controller: addressCtrl,
            ),
            const SizedBox(height: 12),
            _editableRow(
              label: 'Phone',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _saveAndContinue,
              child: const Text('Continue to payment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editableRow({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    final profile = Get.find<UserProfileController>();
    final user = profile.currentUser.value!;
    await profile.updateProfile(
      firstName: user.firstName,
      lastName: user.lastName,
      phone: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
    );
    Get.to(() => const PaymentPage());
  }
}
