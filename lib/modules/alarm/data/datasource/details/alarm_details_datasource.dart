import 'package:thingsboard_app/modules/alarm/data/datasource/details/i_alarm_details_datasource.dart';
import 'package:thingsboard_app/thingsboard_client.dart';

class AlarmDetailsDatasource implements IAlarmDetailsDatasource {
  const AlarmDetailsDatasource(this.thingsboardClient);

  final ThingsboardClient thingsboardClient;

  @override
  Future<PageData<AlarmCommentInfo>> fetchAlarmComments(
    AlarmCommentsQuery query,
  ) async {
    final result =
        await thingsboardClient.getAlarmService().getAlarmComments(query);
    for (final item in result.data) {
      _parseComment(item);
    }
    return result;
  }

  @override
  Future<AlarmInfo> acknowledgeAlarm(AlarmId id) {
    return thingsboardClient.getAlarmService().ackAlarm(id.id!);
  }

  @override
  Future<AlarmInfo> clearAlarm(AlarmId id) {
    return thingsboardClient.getAlarmService().clearAlarm(id.id!);
  }

  @override
  Future<AlarmCommentInfo> postComment(
    AlarmId alarmId, {
    required String comment,
  }) async {
    final result = await thingsboardClient.getAlarmService().postAlarmComment(
      AlarmComment(null, null, alarmId, null, AlarmCommentType.OTHER, {'text': comment}, null),
    );
    _parseComment(result);
    return result;
  }

  @override
  Future<void> deleteComment(AlarmId id, {required String commentId}) {
    return thingsboardClient.getAlarmService().deleteAlarmComment(
      commentId,
      alarmId: id,
    );
  }

  @override
  Future<AlarmCommentInfo> updateComment(
    AlarmId alarmId, {
    required String id,
    required String comment,
  }) async {
    final result = await thingsboardClient.getAlarmService().postAlarmComment(
      AlarmComment(id, null, alarmId, null, AlarmCommentType.OTHER, {'text': comment, 'edited': 'true'}, null),
    );
    _parseComment(result);
    return result;
  }

  @override
  Future<PageData<UserInfo>> fetchAssignee(UsersAssignQuery query) {
    return thingsboardClient.getUserService().getUsersAssign(query);
  }

  @override
  Future<AlarmInfo> assignAlarm(String alarmId, String assigneeId) {
    return thingsboardClient.getAlarmService().assignAlarm(alarmId, assigneeId);
  }

  @override
  Future<AlarmInfo> unassignAlarm(String alarmId) {
    return thingsboardClient.getAlarmService().unassignAlarm(alarmId);
  }

  void _parseComment(AlarmComment alarmComment) {
    if (alarmComment.comment is Map) {
      alarmComment.comment = AlarmCommentJsonNode.fromJson(
        Map<String, dynamic>.from(alarmComment.comment as Map),
      );
    } else if (alarmComment.comment is String) {
      alarmComment.comment = AlarmCommentJsonNode(
        text: alarmComment.comment as String,
        subtype: null,
        userId: null,
        edited: false,
        editedOn: null,
        assigneeId: null,
      );
    }
  }
}
