import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../models/chat/chat.dart';
import '../../models/chat/message.dart';
import '../../services/notification_service.dart';
import '../../utils/extensions/datetime_extension.dart';
import 'indicative_message.dart';

class Message extends StatelessWidget {
  final MessageData msg;
  final ChatData chat;
  final bool first, last;
  final bool msgAlignment;

  const Message({
    required this.msg,
    required this.first,
    required this.last,
    required this.msgAlignment,
    required this.chat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double r = 13;
    final size = MediaQuery.of(context).size;

    return msg.indicative
        ? IndicativeMessage(
            txt: msg.txt,
          )
        : Wrap(
            alignment: !msgAlignment ? WrapAlignment.start : WrapAlignment.end,
            // mainAxisSize: MainAxisSize.min,
            children: [
              if (!msgAlignment)
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: msg.from == UserType.bot
                      ? const Icon(Icons.smart_toy_rounded)
                      : const Icon(Icons.person_3_rounded),
                ).animate().slideX(),
              GestureDetector(
                key: ValueKey(msg.id),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 100,
                    maxWidth: size.width - 35,
                  ),
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  margin: const EdgeInsets.only(
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(first && !msgAlignment ? 0 : r),
                      topRight: Radius.circular(first && msgAlignment ? 0 : r),
                      bottomLeft: Radius.circular(r),
                      bottomRight: Radius.circular(r),
                    ),
                    color: msgAlignment
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (first && msg.from != UserType.user)
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, left: 1, top: 2),
                              child: msg.from == UserType.bot
                                  ? Text(
                                      'Bot',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    )
                                  : const Icon(Icons.person_3_rounded),
                            ),
                          MarkdownBody(
                            fitContent: true,
                            data: msg.txt,
                            selectable: true,
                          ),
                          const SizedBox(height: 20)
                        ],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.createdAt.time,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ).animate().fade().slideX(
                      begin: msgAlignment ? 1 : -1,
                      end: 0,
                      curve: Curves.decelerate,
                    ),
              ),
            ],
          );
  }

  Future<void> copyMsg(context) async {
    await Clipboard.setData(
        ClipboardData(text: msg.txt.replaceAll('\n\n', '\n')));
    if (context.mounted) {
      Navigator.of(context).pop();
      showMsg('Copied');
    }
  }
}
