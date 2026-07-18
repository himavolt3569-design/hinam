import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/administration/data/models/ride_incident_model.dart';

class RideIncidentRemoteDatasource {
  final FirebaseFirestore firestore;

  RideIncidentRemoteDatasource(this.firestore);

  Future<void> createIncident(RideIncidentModel incident) async {
    await firestore.collection('ride_incidents').add(incident.toMap());
  }

  // "Open" here means "not yet resolved" — it includes incidents an admin has
  // already acknowledged, so they remain visible until resolved.
  Stream<List<RideIncidentModel>> watchOpenIncidents() {
    return firestore
        .collection('ride_incidents')
        .where('status', whereIn: ['open', 'acknowledged'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideIncidentModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updateIncidentStatus({
    required String incidentId,
    required String adminUid,
    required RideIncidentStatus status,
  }) async {
    await firestore.collection('ride_incidents').doc(incidentId).update({
      'status': status.name,
      'acknowledgedBy': adminUid,
    });
  }
}
