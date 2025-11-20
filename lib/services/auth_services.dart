// file ini yang meng handle login n register
// melakukan autentifikasi => mengenalkan firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthServices() {
    if (!kIsWeb) { // only for android or ios => bukan utk web
      FirebaseAuth.instance.setSettings(
        // memastikan kalo kita bukan robot -> captcha
        appVerificationDisabledForTesting: true,
        forceRecaptchaFlow: false,
        
      );
    }
  }

  // get current user -> welcome,ninis!
  User? get currentUser => _auth.currentUser;

  //auth state changes stream -> pertama buka disuru login, tapi abis itu ngga lg, krn udh nyimpen statenya
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //sign in with email and password tipe data: future function :SWRAP parameter: yg didalemnya
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async{
    // async => buat ngecek email dan passwordnya tu udah ada di database apa belum
    // frontend dan backend kita bekerja sama
    try {
      // kalo succes masuk ke database
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } catch (e) {
      // kalo error
      rethrow; // halaman login or register dimunculkan lagi
    }
  }

  // register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
    } catch (e) {
      if (e is FirebaseAuthException)  { //kalo error berasal dr firebase
        if (e.code == 'operation-not-allowed') {
          throw 'Email/Password sign up is not enable. Please enable on firebase console';
        }
      }
      rethrow;
    }
  }

  // sign out
  Future<void> signOut () async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}