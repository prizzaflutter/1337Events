import 'package:flutter/material.dart';
import 'package:go_router/src/misc/errors.dart';

class ErrorPage extends StatefulWidget {
  final  GoException? error;
   const ErrorPage({super.key,this.error});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'An error occurred. Please try again later.',
          style: TextStyle(fontSize: 24, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
