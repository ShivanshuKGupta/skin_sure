import '../../services/server.dart';
import '../report.dart';

enum UserType { user, bot }

class MessageData {
  /// The datetime object representing the
  late String id;

  /// The markdown text
  late String txt;

  /// Sender of the message
  late UserType from;

  /// CreatedAt
  late DateTime createdAt;

  /// Modified At
  DateTime? modifiedAt;

  /// These indicative messages are used to indicate
  /// that something has happened in the chat
  /// like the inclusion of someone in the chat
  /// can only be created but not deleted
  late bool indicative;

  MessageData({
    required this.id,
    required this.txt,
    required this.from,
    required this.createdAt,
    this.indicative = false,
    this.modifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'txt': txt,
      'from': from.name,
      'indicative': indicative,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (modifiedAt != null) 'modifiedAt': modifiedAt!.millisecondsSinceEpoch,
    };
  }

  MessageData.fromJson(this.id, Map<String, dynamic> data) {
    txt = data['txt'] ?? 'Error!';
    from = data['from'] == 'user' ? UserType.user : UserType.bot;
    createdAt = DateTime.fromMillisecondsSinceEpoch(data['createdAt']);

    indicative = data['indicative'] ?? false;
    modifiedAt = data['modifiedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(data['modifiedAt']);
  }
}

Future<Report> addMessage(String reportId, MessageData msg) async {
  return await server.addMessage(reportId, msg);
}
