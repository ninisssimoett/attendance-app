import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/screen/home/widgets/attendance_card.dart';
import 'package:attendance_app/screen/home/widgets/profile_card.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/firestore_service.dart';
import 'package:attendance_app/services/storage_services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthServices _authServices = AuthServices();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageServices _storageServices = StorageServices();
  AttendanceRecord? _todayRecord;
  bool _isLoading= false;


  @override
  void initState() {
    super.initState();
    _listenToTodayRecord();
  }

  // mendengarkan semua hal yg terjadi di homescreen ->attendance record
  void _listenToTodayRecord() {
    final user = _authServices.currentUser;
    if (user != null) {
      _firestoreService.getTodayRecordStream(user.uid).listen((record) {
        // masih aktif 
        if (mounted) setState(() => _todayRecord = record);
      });
    }
  }

  // utk check in
  Future<void> _CheckIn({String? photoPath}) async {
    final user = _authServices.currentUser;
    // kalo user tidak ada di database
    if (user == null) return null;

    setState(() => _isLoading = true);

    // percobaan utk take photo ketika check in
    try {
      String? photoKey;
      if (photoPath != null) {
        photoKey = await _storageServices.uploadAttendancePhoto(photoPath, 'CheckIn');
      }

      final now = DateTime.now();
      final record = AttendanceRecord(
        id: '',
        userId: user.uid,
        checkInTime: now,
        date: DateTime(now.year, now.month, now.day),
        checkInPhotoPath: photoKey,
      );

      await _firestoreService.createAttendanceRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              photoPath != null ? 'Check in successfully with photo!' : 'Check in successfully',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          )
        );
      }
    } catch (e) {
      // kalau tidak berhasil check in
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checkhing in: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // check out
  Future<void> _checkOut({String? photoPath}) async {
    if (_todayRecord == null) return;

    setState(() => _isLoading = true);

    try {
      String? photoKey;
      if (photoPath != null) {
        photoKey = await _storageServices.uploadAttendancePhoto(photoPath, 'checkout');}

        final updateRecord = AttendanceRecord(
          id: _todayRecord!.id,
          userId: _todayRecord!.userId,
          checkInTime: _todayRecord!.checkInTime,
          checkOutTime: DateTime.now(),
          date: _todayRecord!.date,
          checkInPhotoPath: _todayRecord!.checkInPhotoPath,
          checkOutPhotoPath: photoKey,
        );

        await _firestoreService.uploadAttendanceRecord(updateRecord);

        // ketika proses check out success sampai snackbar nya
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(photoPath != null ? 'Checked Out successfully with photo' : 'Check Out succesfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            )
          );
        }
     
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error checking out: ${e.toString()}'
            ),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance Tracker'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // history screen 
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
             // todo: go to history screen
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async => await _authServices.signOut(),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.grey[50]!,
            ],
            // 0.3 ketika dia berenti ditengah -> ukuran stop gradiasi
            stops: [0, 0, 0.3]
          )
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileCard(),
              SizedBox(height: 24),
              AttendanceCard(todayRecord: _todayRecord),
              SizedBox(height: 24),
              // section great job
              
            ],
          ),
        ),
      ),
    );
  }
}