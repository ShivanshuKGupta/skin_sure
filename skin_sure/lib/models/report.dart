import 'chat/chat.dart';
import 'chat/message.dart';

class Report {
  String id;
  String? imgPath;
  String? label;
  String? segImagePath;
  ChatData? chat;

  Report({
    required this.id,
    this.imgPath,
    this.label,
    this.segImagePath,
    this.chat,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imgUrl': imgPath,
        'class': label,
        'seg_image_url': segImagePath,
        'messages': chat?.messages.map((e) => e.toJson()).toList(),
      };

  static Report fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      imgPath: json['imgUrl']?.toString(),
      label: json['class']?.toString(),
      segImagePath: json['seg_image_url']?.toString(),
      chat: json['messages'] != null
          ? ChatData(
              title: 'Get more help',
              messages: (json['messages'] as List?)
                      ?.map((e) => MessageData.fromJson(e['id'], e))
                      .toList() ??
                  [],
            )
          : null,
    );
  }
}
