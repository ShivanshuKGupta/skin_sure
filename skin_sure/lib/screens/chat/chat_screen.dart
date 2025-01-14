import 'package:flutter/material.dart';

import '../../models/chat/message.dart';
import '../../models/report.dart';
import 'message_input_field.dart';
import 'message_list.dart';

class ChatScreen extends StatefulWidget {
  final Report report;
  final MessageData? initialMsg;
  final void Function()? showInfo;

  const ChatScreen({
    required this.report,
    super.key,
    this.initialMsg,
    this.showInfo,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Report report = widget.report;

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = InkWell(
      onTap: widget.showInfo,
      child: Row(
        children: [
          const Icon(Icons.smart_toy_rounded),
          const SizedBox(width: 10),
          Text(
            report.chat!.title,
            overflow: TextOverflow.fade,
            maxLines: 2,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: titleWidget),
      body: MessageList(chat: report.chat!),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, left: 5, top: 5),
        child: MessageInputField(
          initialValue: widget.initialMsg != null ? widget.initialMsg!.txt : '',
          onSubmit: (MessageData msg) async {
            setState(() {
              report.chat?.messages.add(msg);
            });
            report = await addMessage(report.id, msg);
            setState(() {});
          },
        ),
      ),
    );
  }
}
