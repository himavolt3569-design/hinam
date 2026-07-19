import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/verification/data/datasources/ride_verification_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';
import 'package:hinam/features/hinam_ride/verification/data/repositories/ride_verification_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';
import 'package:hinam/shared/providers/storage_providers.dart';

final rideVerificationDatasourceProvider =
    Provider<RideVerificationRemoteDatasource>(
      (ref) => RideVerificationRemoteDatasource(ref.read(firestoreProvider)),
    );

final rideVerificationRepositoryProvider = Provider<RideVerificationRepository>(
  (ref) =>
      RideVerificationRepository(ref.read(rideVerificationDatasourceProvider)),
);

final submitVerificationControllerProvider =
    AsyncNotifierProvider<SubmitVerificationController, void>(
      SubmitVerificationController.new,
    );

class SubmitVerificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required VerificationSubjectType subjectType,
    required String subjectId,
    required Map<String, File> documents,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final storageService = ref.read(storageServiceProvider);
      final documentUrls = <String, String>{};

      for (final entry in documents.entries) {
        documentUrls[entry.key] = await storageService.uploadFile(
          path: '$subjectId/ride_verifications/${entry.key}',
          file: entry.value,
        );
      }

      final request = VerificationRequestModel(
        id: '',
        subjectType: subjectType,
        subjectId: subjectId,
        documentUrls: documentUrls,
        status: VerificationStatus.pending,
        createdAt: Timestamp.now(),
      );

      await ref
          .read(rideVerificationRepositoryProvider)
          .submitVerification(request);
    });
  }
}
