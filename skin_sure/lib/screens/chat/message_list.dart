import 'package:flutter/material.dart';

import '../../models/chat/chat.dart';
import '../../models/chat/message.dart';
import '../../utils/extensions/datetime_extension.dart';
import 'indicative_message.dart';
import 'message.dart';

// ignore: must_be_immutable
class MessageList extends StatelessWidget {
  ChatData chat;
  MessageList({required this.chat, super.key});

  @override
  Widget build(BuildContext context) {
    if (chat.messages.isEmpty) {
      return Center(
        child: Text(
          'Send your first message',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      );
    }

    final messages = chat.messages.reversed.toList();

    return ListView.separated(
      reverse: true,
      shrinkWrap: true,
      separatorBuilder: (ctx, index) {
        if (index == messages.length - 1) return Container();
        final msg = messages[index];
        DateTime createdAt = msg.createdAt;
        final nextMsg = messages[index + 1];

        if (!_sameDay(nextMsg.createdAt, msg.createdAt)) {
          return _dateWidget(createdAt);
        }

        return SizedBox(
          height: nextMsg.from != msg.from ||
                  !_sameDay(msg.createdAt, nextMsg.createdAt)
              ? 10
              : 1,
        );
      },
      itemBuilder: (ctx, index) {
        if (index == messages.length) {
          final msg = messages[index - 1];
          DateTime createdAt = msg.createdAt;
          return _dateWidget(createdAt);
        }
        final msg = messages[index];
        final nextMsg =
            index == messages.length - 1 ? null : messages[index + 1];
        final preMsg = index == 0 ? null : messages[index - 1];
        final first = nextMsg == null ||
            nextMsg.from != msg.from ||
            !_sameDay(msg.createdAt, nextMsg.createdAt);
        return Message(
          chat: chat,
          msg: msg,
          last: preMsg == null ||
              preMsg.from != msg.from ||
              !_sameDay(msg.createdAt, preMsg.createdAt),
          first: first,
          msgAlignment: msg.from == UserType.user,
        );
      },
      itemCount: chat.messages.length + 1,
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return !(a.day != b.day || a.month != b.month || a.year != b.year);
  }

  Widget _dateWidget(DateTime createdAt) {
    return IndicativeMessage(txt: createdAt.toMonthString());
  }
}
