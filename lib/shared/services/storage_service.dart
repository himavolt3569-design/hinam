import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage;

  StorageService(this.storage);

  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    final ref = storage.ref(path);
    final snapshot = await ref.putFile(file).snapshotEvents.last;
    return snapshot.ref.getDownloadURL();
  }

  Future<String> getDownloadUrl(String path) {
    return storage.ref(path).getDownloadURL();
  }
}
