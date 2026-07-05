import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';

void main() {
  group('VerificationStatus', () {
    test('fromValue maps known values correctly', () {
      expect(
        VerificationStatus.fromValue('pending'),
        VerificationStatus.pending,
      );
      expect(
        VerificationStatus.fromValue('approved'),
        VerificationStatus.approved,
      );
      expect(
        VerificationStatus.fromValue('rejected'),
        VerificationStatus.rejected,
      );
    });

    test('fromValue falls back to pending for unknown values', () {
      expect(VerificationStatus.fromValue('unknown'), VerificationStatus.pending);
    });
  });

  group('RideDriverModel', () {
    final dateOfBirth = DateTime(1995, 5, 20);
    final createdAt = Timestamp.now();

    final model = RideDriverModel(
      uid: 'uid-1',
      fullName: 'Sita Gurung',
      phoneNumber: '+9779800000000',
      gender: 'female',
      dateOfBirth: dateOfBirth,
      vehicleType: 'scooter',
      vehiclePlate: 'Ba 3 Pa 5678',
      licenseNumber: 'DL-1234567',
      verificationStatus: VerificationStatus.pending,
      isOnline: false,
      ratingAvg: 0,
      totalRides: 0,
      createdAt: createdAt,
    );

    test('toMap serializes verificationStatus as its string name', () {
      final map = model.toMap();

      expect(map['verificationStatus'], 'pending');
      expect(map['uid'], 'uid-1');
      expect(map['dateOfBirth'], Timestamp.fromDate(dateOfBirth));
    });

    test('fromMap round-trips correctly', () {
      final restored = RideDriverModel.fromMap(model.toMap());

      expect(restored.uid, model.uid);
      expect(restored.fullName, model.fullName);
      expect(restored.phoneNumber, model.phoneNumber);
      expect(restored.gender, model.gender);
      expect(restored.dateOfBirth, dateOfBirth);
      expect(restored.vehicleType, model.vehicleType);
      expect(restored.vehiclePlate, model.vehiclePlate);
      expect(restored.licenseNumber, model.licenseNumber);
      expect(restored.verificationStatus, VerificationStatus.pending);
      expect(restored.isOnline, false);
      expect(restored.ratingAvg, 0);
      expect(restored.totalRides, 0);
    });

    test('fromMap defaults missing fields safely', () {
      final restored = RideDriverModel.fromMap({});

      expect(restored.uid, '');
      expect(restored.fullName, '');
      expect(restored.verificationStatus, VerificationStatus.pending);
      expect(restored.isOnline, false);
      expect(restored.ratingAvg, 0.0);
      expect(restored.totalRides, 0);
    });
  });
}
