import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class IndicativeMessage extends StatelessWidget {
  const IndicativeMessage({
    required this.txt,
    super.key,
  });
  final String txt;

  @override
  Widget build(BuildContext context) {
    final containsFormatting = txt.contains('**');
    return Align(
      heightFactor: 1.25,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Theme.of(context).colorScheme.primary,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MarkdownBody(
            data: txt,
            // textAlign: TextAlign.center,
            // style: Theme.of(context).textTheme.bodySmall!.copyWith(
            //       color: Theme.of(context).colorScheme.onPrimary,
            //       fontWeight: FontWeight.bold,
            //     ),
            styleSheet: MarkdownStyleSheet(
              p: containsFormatting
                  ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
              textAlign: WrapAlignment.center,
            ),
          ),
        ),
      ),
    ).animate().fade();
  }
}
