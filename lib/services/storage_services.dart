import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/screen/home/widgets/photo_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    // ambil dari database -> realtime database
    databaseURL: 'https://attendance-app-975c1-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  // upload photo to firebase realtime database as Base64 (String)
  Future<String> uploadAttendancePhoto(String localPath, String photoType) async {
    try {
      // kalau sudah ter daftar n login
      final user = _auth.currentUser;
      // kalau tidak terdaftar
      if (user == null)throw Exception('User not authenticated');

      final file = File(localPath);

      // compress image to reduce size (important for realtime database)
      final compressBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: 70,
      );

      if (compressBytes == null) {
        throw Exception('Failed to compress image');
      }

      // convert to Base64
      final Base64Image = base64Encode(compressBytes);

      // create unique key
      final photokey = '${DateTime.now().millisecondsSinceEpoch}_$photoType'; //kumpulan dr tanggal, ada second, ada tipe fotonya

      // save to realtime database
      await _database
          .child('attendance_photos')
          .child(user.uid)
          .child(photokey)
          .set({
            'data': Base64Image,
            'timestamp': ServerValue.timestamp,
            'type': photoType,
          });

          // return the key as reference
          return photokey;
    } catch (e) {
      throw Exception('Failed to upload photo: $e'); 
    }
  }

  // get photo from firebase realtime database
  Future<String?> getPhotoBase64(String photokey) async {
    try {
      // mendapatkan
      final user = _auth.currentUser;
      if (user == null) return null; 

      final snapShot = await _database
          .child('attendance_photos')
          .child(user.uid)
          .child('data')
          .get();

        if (snapShot.exists) {  // kalo datanya ada maka kita akan jadikan semua snapshotnya jadi string
        return snapShot.value as String;
      }

    } catch (e) {
      return null;
    }
  }

  // delete photo from firebase realtime database
  Future<void> deletePhoto(String photokey) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      await _database
          .child('attendance photos')
          .child(user.uid)
          .child(photokey)
          .remove();

    } catch (e) {
      // ignore id doesn't exist
    }
  }
}
