import 'message.dart';

class ChatData {
  String title;
  List<MessageData> messages;

  ChatData({
    required this.title,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'messages': messages.map((e) => e.toJson()).toList(),
      };

  static ChatData fromJson(Map<String, dynamic> json) {
    return ChatData(
      title: json['title'].toString(),
      messages: (json['messages'] as List)
          .map((e) => MessageData.fromJson(e['id'], e))
          .toList(),
    );
  }
}

Future<ChatData> fetchChatData(ChatData chat) async {
  throw UnimplementedError();
}
