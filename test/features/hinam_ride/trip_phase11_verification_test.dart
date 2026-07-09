import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinam/features/hinam_ride/trip/data/datasources/ride_trip_remote_datasource.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late RideTripRemoteDatasource datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = RideTripRemoteDatasource(firestore);
  });

  Future<String> seedRide({String? driverId}) async {
    final ref = await firestore.collection('rides').add({
      'passengerId': 'passenger-1',
      'driverId': driverId,
      'status': driverId == null ? 'requested' : 'matched',
      'suggestedFare': 100.0,
      'agreedFare': null,
      'createdAt': Timestamp.now(),
    });
    return ref.id;
  }

  Future<String> seedOffer(
    String rideId, {
    required String driverId,
    String status = 'pending',
  }) async {
    final ref = await firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .add({
          'driverId': driverId,
          'offerAmount': 100.0,
          'status': status,
          'createdAt': Timestamp.now(),
        });
    return ref.id;
  }

  test('accepting a valid pending offer matches the ride', () async {
    final rideId = await seedRide();
    final offerId = await seedOffer(rideId, driverId: 'driver-a');

    await datasource.acceptOffer(
      rideId: rideId,
      offerId: offerId,
      driverId: 'driver-a',
    );

    final ride = await firestore.collection('rides').doc(rideId).get();
    expect(ride.data()!['driverId'], 'driver-a');
    expect(ride.data()!['status'], 'matched');
    expect(ride.data()!['agreedFare'], 100.0);
    expect(ride.data()!['acceptedOfferId'], offerId);

    final offer = await firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .doc(offerId)
        .get();
    expect(offer.data()!['status'], 'accepted');
  });

  test(
    'rejects acceptance when the ride is already matched with someone else',
    () async {
      final rideId = await seedRide(driverId: 'driver-a');
      final offerId = await seedOffer(rideId, driverId: 'driver-b');

      await expectLater(
        datasource.acceptOffer(
          rideId: rideId,
          offerId: offerId,
          driverId: 'driver-b',
        ),
        throwsA(anything),
      );

      final ride = await firestore.collection('rides').doc(rideId).get();
      expect(ride.data()!['driverId'], 'driver-a');
    },
  );

  test(
    'rejects acceptance of an offer that is no longer pending (already expired)',
    () async {
      final rideId = await seedRide();
      final offerId = await seedOffer(
        rideId,
        driverId: 'driver-a',
        status: 'expired',
      );

      await expectLater(
        datasource.acceptOffer(
          rideId: rideId,
          offerId: offerId,
          driverId: 'driver-a',
        ),
        throwsA(anything),
      );

      final ride = await firestore.collection('rides').doc(rideId).get();
      expect(ride.data()!['driverId'], isNull);
    },
  );

  test('rejects acceptance of an offer that was not made to the caller', () async {
    final rideId = await seedRide();
    final offerId = await seedOffer(rideId, driverId: 'driver-a');

    await expectLater(
      datasource.acceptOffer(
        rideId: rideId,
        offerId: offerId,
        driverId: 'driver-b',
      ),
      throwsA(anything),
    );

    final ride = await firestore.collection('rides').doc(rideId).get();
    expect(ride.data()!['driverId'], isNull);
  });
}
