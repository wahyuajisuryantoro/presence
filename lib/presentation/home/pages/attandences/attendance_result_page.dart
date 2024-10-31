// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attandences/scanner_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_success_page.dart';

import 'face_detector_checkin_page.dart';

class AttendanceResultPage extends StatefulWidget {
  final bool isCheckin;
  final bool isMatch;
  final String attendanceType;
  const AttendanceResultPage({
    super.key,
    required this.isCheckin,
    required this.isMatch,
    required this.attendanceType,
  });

  @override
  State<AttendanceResultPage> createState() => _RecognitionResultPageState();
}

class _RecognitionResultPageState extends State<AttendanceResultPage> {
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      setState(() {});
    } on PlatformException catch (e) {
      if (e.code == 'IO_ERROR') {
        debugPrint(
            'A network error occurred trying to lookup the supplied coordinates: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      debugPrint('An unknown error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Proses Presensi - ${widget.attendanceType == 'None' ? 'Manual' : widget.attendanceType}',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isMatch ? Icons.check : Icons.close,
              size: 100,
              color: widget.isMatch ? Colors.green : Colors.red,
            ),
            Text(
              widget.isCheckin ? 'Checkin' : 'Checkout',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            widget.attendanceType == 'Face'
                ? Text(
                    widget.isMatch ? 'Wajah Cocok' : 'Wajah Tidak Cocok',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isMatch ? Colors.green : Colors.red,
                    ),
                  )
                : const SizedBox(),
            widget.attendanceType == 'QR'
                ? Text(
                    widget.isMatch ? 'QR Cocok' : 'QR Tidak Cocok',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isMatch ? Colors.green : Colors.red,
                    ),
                  )
                : const SizedBox(),
            widget.isCheckin && widget.isMatch
                ? BlocConsumer<CheckinAttendanceBloc, CheckinAttendanceState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        orElse: () {},
                        error: (message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
                        },
                        loaded: (responseModel) {
                          context.pushReplacement(const AttendanceSuccessPage(
                            status: 'Berhasil Checkin',
                          ));
                        },
                      );
                    },
                    builder: (context, state) {
                      return state.maybeWhen(
                        orElse: () {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Button.filled(
                              onPressed: () {
                                context.read<CheckinAttendanceBloc>().add(
                                      CheckinAttendanceEvent.checkin(
                                          latitude.toString(),
                                          longitude.toString()),
                                    );
                              },
                              label: 'Lanjutkan Checkin',
                            ),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  )
                : !widget.isCheckin && widget.isMatch
                    ? BlocConsumer<CheckoutAttendanceBloc,
                        CheckoutAttendanceState>(
                        listener: (context, state) {
                          state.maybeWhen(
                            orElse: () {},
                            error: (message) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                ),
                              );
                            },
                            loaded: (responseModel) {
                              context
                                  .pushReplacement(const AttendanceSuccessPage(
                                status: 'Berhasil Checkout',
                              ));
                            },
                          );
                        },
                        builder: (context, state) {
                          return state.maybeWhen(
                            orElse: () {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Button.filled(
                                  onPressed: () {
                                    context.read<CheckoutAttendanceBloc>().add(
                                          CheckoutAttendanceEvent.checkout(
                                              latitude.toString(),
                                              longitude.toString()),
                                        );
                                  },
                                  label: 'Lanjutkan Checkout',
                                ),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
            //coba lagi
            widget.attendanceType == 'Face'
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FaceDetectorCheckinPage(
                                    isCheckedIn: widget.isCheckin,
                                  )));
                    },
                    child: Text('Ambil Wajah Lagi'),
                  )
                : const SizedBox(),
            widget.attendanceType == 'QR'
                ? ElevatedButton(
                    onPressed: () {
                      context.pushReplacement(ScannerPage(isCheckin: true));
                    },
                    child: Text('Scan QR Code Lagi'),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
