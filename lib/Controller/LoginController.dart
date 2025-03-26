import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng hủy bỏ đăng nhập

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra người dùng có trong Firestore không
        final docRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          // Nếu người dùng chưa có trong Firestore, tạo mới thông tin người dùng
          await docRef.set({
            'name': 'User_${Random().nextInt(10000)}', // Tạo tên ngẫu nhiên
            'email': user.email,
            'scores': {
              'easy': [],
              'medium': [],
              'hard': [],
            },
          });
        }
      }

      return user;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Kiểm tra người dùng đã đăng nhập hay chưa
  Stream<User?> get userStream => _auth.authStateChanges();
}
