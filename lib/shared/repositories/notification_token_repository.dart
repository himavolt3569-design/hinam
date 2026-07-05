import 'package:hinam/shared/datasources/notification_token_remote_datasource.dart';
import 'package:hinam/shared/models/notification_token_model.dart';

class NotificationTokenRepository {
  final NotificationTokenRemoteDatasource datasource;

  NotificationTokenRepository(this.datasource);

  Future<void> saveToken(NotificationTokenModel token) {
    return datasource.saveToken(token);
  }

  Future<void> deleteToken(String uid) {
    return datasource.deleteToken(uid);
  }
}
