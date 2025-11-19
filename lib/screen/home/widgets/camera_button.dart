import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraButton extends StatelessWidget {
  final Function(String imagePath) onImageCaptured;
  final String buttonText;

  const CameraButton({super.key, required this.onImageCaptured, required this.buttonText});

  Future<void> _takePhoto(BuildContext context) async {
    try { // try = otomatis dijalankan kalau dia diterima
      // request camera permission
      final status = await Permission.camera.request();

      // membuat kondisi = ada 3
      // not allow
      if (status.isDenied) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera Permission is required, to take a photos'),
              backgroundColor: Colors.orange,
              )
          );
        }
        return;
      }

      // => dont allow, ada remind dibawah kyk gini
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission denied. Please enable in setting.'),
              backgroundColor: Colors.red,
              // agar pergi ke setting
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            )
          );
        }
        return;
      }

      // jika dia menggunakan foto
      final ImagePicker picker = ImagePicker(); // imagePicker -> library dr pubspec.yaml
      final XFile? photo = await picker.pickImage( // file yang ada/yang berhubungan dgn aplikasi
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70, // compressed image -> 70px => semakin HD semakin penuh database
      );

      // kalo berhasil mengcapture foto => success
      if ((photo != null)) {
        onImageCaptured(photo.path);
      }

      
    } catch (e) {
      // kalau camera error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _takePhoto(context),
      icon: Icon(Icons.camera_alt),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        )
      ),
    );
  }
}