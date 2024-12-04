import 'dart:developer';

import 'package:flutter/material.dart';

import '../../globals.dart';

void showMsg(dynamic msg) {
  debugPrint(msg.toString());
  ScaffoldMessenger.of(appContext).showSnackBar(
    SnackBar(
      content: Text(msg.toString()),
      showCloseIcon: true,
    ),
  );
}

void showError(String msg) {
  log(msg, name: 'Error');
  ScaffoldMessenger.of(appContext).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: colorScheme.error,
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    ),
  );
}

Future<bool?> showConfirmDialog(
    {required String title, required String content}) async {
  return showDialog<bool>(
    context: appContext,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              'Yes',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'No',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      );
    },
  );
}
