import 'package:get/get.dart';

class RoleController extends GetxController {
  var selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }
}
