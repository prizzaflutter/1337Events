import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QrCheckWidget extends StatefulWidget {
  final String? eventId;
  const QrCheckWidget({super.key, required this.eventId});

  @override
  State<QrCheckWidget> createState() => _QrCheckWidgetState();
}


Future<void> addUserToVisitedUsersSimple(String eventId, String userId) async {
  try {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final eventDoc = await _firestore.collection("events").doc(eventId).get();

    if (!eventDoc.exists) {
      throw Exception("Event not found");
    }

    final data = eventDoc.data() as Map<String, dynamic>;
    final registeredUsers = List<String>.from(data['registeredUsers'] ?? []);

    // Check if user is registered for this event
    if (!registeredUsers.contains(userId)) {
      throw Exception("User is not registered for this event");
    }

    // User is registered, add to visited users (arrayUnion handles duplicates)
    await _firestore.collection("events").doc(eventId).update({
      'visitedUsers': FieldValue.arrayUnion([userId]),
    });
  } catch (e) {
    throw Exception("Failed to add user to visited users: $e");
  }
}

class _QrCheckWidgetState extends State<QrCheckWidget> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('QR Check Widget'),
      ),
      body: Center(
        child: Text('QR Check Functionality Goes Here ${widget.eventId}'),
      ),
    );
  }
}

