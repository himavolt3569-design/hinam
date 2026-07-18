import 'package:hinam/features/hinam_ride/administration/data/datasources/ride_incident_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/administration/data/models/ride_incident_model.dart';

class RideIncidentRepository {
  final RideIncidentRemoteDatasource datasource;

  RideIncidentRepository(this.datasource);

  Future<void> createIncident(RideIncidentModel incident) {
    return datasource.createIncident(incident);
  }

  Stream<List<RideIncidentModel>> watchOpenIncidents() {
    return datasource.watchOpenIncidents();
  }

  Future<void> updateIncidentStatus({
    required String incidentId,
    required String adminUid,
    required RideIncidentStatus status,
  }) {
    return datasource.updateIncidentStatus(
      incidentId: incidentId,
      adminUid: adminUid,
      status: status,
    );
  }
}
