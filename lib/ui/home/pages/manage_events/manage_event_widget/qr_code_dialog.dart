import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';

void showQRCodeDialog(BuildContext context,NewEventModel event, ColorScheme colorScheme) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Event QR Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Container(
          width: 200,
          height: 200,
          child: QrImageView(
            data: 'https://aquamarine-jelly-93d114.netlify.app/?eventId=${event.id}',
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}