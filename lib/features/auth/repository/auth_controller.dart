import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_ui/models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthController {
  AuthRepository? authRepository;
  final ProviderRef ref;
  AuthController({required this.authRepository, required this.ref});

  void signInWithPhoneNumber(BuildContext context, String phoneNumber) {
    authRepository?.signInPhoneNumber(phoneNumber, context);
  }

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository?.getCurrentUserData();
    return user;
  }

  void verifyOTP(BuildContext context, String verificationId, String userOtp) {
    authRepository?.verifyOTP(
        context: context, verificationID: verificationId, userOTP: userOtp);
  }

  void saveDataToFirestore(
      BuildContext context, String name, File? profilePic) {
    authRepository!.saveUserToFirestore(
        name: name, profilePic: profilePic, ref: ref, context: context);
  }
}
