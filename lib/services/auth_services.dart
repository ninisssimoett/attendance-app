import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthServices() {
    if (!kIsWeb) { // only for android or ios => bukan utk web
      FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
        forceRecaptchaFlow: false,
      );
    }
  }

  // get current user
  User? get currentUser => _auth.currentUser;

  //auth state changes stream -> pertama buka disuru login, tapi abis itu ngga lg, krn udh nyimpen statenya
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //sign in with email and password tipe data: future function :SWRAP parameter: yg didalemnya
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async{
    // buat ngecek emailnya tu udah ada di database apa belum
    try {
      // kalo succes masuk ke database
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } catch (e) {
      // kalo error
      rethrow;
      
    }
  }
}