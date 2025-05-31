import 'package:flutter/material.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

class EventPage extends StatefulWidget {
  final UserProfile? userProfile;
  const EventPage({super.key, required this.userProfile});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Event Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      // You can add more widgets here to build your event page
    );
  }
}
