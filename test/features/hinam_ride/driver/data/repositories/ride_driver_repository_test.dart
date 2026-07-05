import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinam/features/hinam_ride/driver/data/datasources/ride_driver_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';
import 'package:hinam/features/hinam_ride/driver/data/repositories/ride_driver_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRideDriverRemoteDatasource extends Mock
    implements RideDriverRemoteDatasource {}

RideDriverModel _buildDriver({String uid = 'uid-1'}) {
  return RideDriverModel(
    uid: uid,
    fullName: 'Sita Gurung',
    phoneNumber: '+9779800000000',
    gender: 'female',
    dateOfBirth: DateTime(1995, 5, 20),
    vehicleType: 'scooter',
    vehiclePlate: 'Ba 3 Pa 5678',
    licenseNumber: 'DL-1234567',
    verificationStatus: VerificationStatus.pending,
    isOnline: false,
    ratingAvg: 0,
    totalRides: 0,
    createdAt: Timestamp.now(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_buildDriver(uid: 'fallback'));
  });

  late MockRideDriverRemoteDatasource datasource;
  late RideDriverRepository repository;

  setUp(() {
    datasource = MockRideDriverRemoteDatasource();
    repository = RideDriverRepository(datasource);
  });

  test('driverExists delegates to the datasource', () async {
    when(() => datasource.driverExists('uid-1')).thenAnswer((_) async => true);

    final result = await repository.driverExists('uid-1');

    expect(result, true);
    verify(() => datasource.driverExists('uid-1')).called(1);
  });

  test('createDriver delegates to the datasource', () async {
    final driver = _buildDriver();
    when(() => datasource.createDriver(driver)).thenAnswer((_) async {});

    await repository.createDriver(driver);

    verify(() => datasource.createDriver(driver)).called(1);
  });

  test('getDriver delegates to the datasource', () async {
    final driver = _buildDriver();
    when(() => datasource.getDriver('uid-1')).thenAnswer((_) async => driver);

    final result = await repository.getDriver('uid-1');

    expect(result, driver);
    verify(() => datasource.getDriver('uid-1')).called(1);
  });

  test('getDriver returns null when the datasource returns null', () async {
    when(() => datasource.getDriver('uid-2')).thenAnswer((_) async => null);

    final result = await repository.getDriver('uid-2');

    expect(result, isNull);
  });
}
