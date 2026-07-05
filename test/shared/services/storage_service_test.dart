import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinam/shared/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  late MockFirebaseStorage storage;
  late MockReference reference;
  late StorageService service;

  setUp(() {
    storage = MockFirebaseStorage();
    reference = MockReference();
    service = StorageService(storage);
    when(() => storage.ref(any())).thenReturn(reference);
  });

  group('uploadFile', () {
    test('uploads to the given path and returns the download URL', () async {
      final file = File('sample.jpg');
      final uploadTask = MockUploadTask();
      final snapshot = MockTaskSnapshot();

      when(() => reference.putFile(file)).thenAnswer((_) => uploadTask);
      when(() => uploadTask.snapshotEvents)
          .thenAnswer((_) => Stream.value(snapshot));
      when(() => snapshot.ref).thenReturn(reference);
      when(() => reference.getDownloadURL()).thenAnswer(
        (_) async => 'https://storage.example.com/ride_verifications/uid1/sample.jpg',
      );

      final url = await service.uploadFile(
        path: 'ride_verifications/uid1/sample.jpg',
        file: file,
      );

      expect(
        url,
        'https://storage.example.com/ride_verifications/uid1/sample.jpg',
      );
      verify(() => storage.ref('ride_verifications/uid1/sample.jpg')).called(1);
      verify(() => reference.putFile(file)).called(1);
    });
  });

  group('getDownloadUrl', () {
    test('returns the download URL for the given path', () async {
      when(() => reference.getDownloadURL()).thenAnswer(
        (_) async => 'https://storage.example.com/ride_verifications/uid1/existing.jpg',
      );

      final url = await service.getDownloadUrl(
        'ride_verifications/uid1/existing.jpg',
      );

      expect(
        url,
        'https://storage.example.com/ride_verifications/uid1/existing.jpg',
      );
      verify(() => storage.ref('ride_verifications/uid1/existing.jpg')).called(1);
    });
  });
}
