import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/repository/common_firebase_storage.dart';
import 'package:whatsapp_ui/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_ui/models/user_model.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

import '../../../common/util/utils.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class AuthRepository {
  FirebaseAuth? auth;
  FirebaseFirestore? firestore;

  AuthRepository({this.auth, this.firestore});

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore!.collection('users').doc(auth?.currentUser?.uid).get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromJson(userData.data()!);
    }
    return user;
  }

  Future<void> signInPhoneNumber(
      String phoneNuumber, BuildContext context) async {
    try {
      await auth!.verifyPhoneNumber(
        phoneNumber: phoneNuumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth!.signInWithCredential(credential);
        },
        verificationFailed: (e) {},
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationID: verificationId,
                ),
              ));
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(content: e.message ?? "", context: context);
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationID,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: userOTP);
      await auth!.signInWithCredential(credential);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserInformationScreen(),
          ));
    } on FirebaseException catch (e) {
      showSnackBar(content: e.message ?? "", context: context);
    }
  }

  void saveUserToFirestore(
      {required String name,
      required File? profilePic,
      required ProviderRef ref,
      required BuildContext context}) async {
    try {
      String uid = auth!.currentUser!.uid;
      String photoUrl =
          'https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png';
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase('profilePic/$uid', profilePic);
      }
      var user = UserModel(
          name: name,
          uid: uid,
          profilePic: photoUrl,
          isOnline: true,
          phoneNumber: auth?.currentUser?.phoneNumber ?? "",
          groupId: []);

      await firestore!.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileLayoutScreen(),
          ),
          (route) => false);
    } catch (e) {
      showSnackBar(content: e.toString(), context: context);
    }
  }
}
