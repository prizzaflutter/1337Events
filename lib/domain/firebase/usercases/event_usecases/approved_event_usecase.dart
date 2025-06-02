import 'package:flutter/material.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class ApprovedEventUseCase {
  final FirebaseRepository _firebaseRepository;
  ApprovedEventUseCase(this._firebaseRepository);

  Future<void> call(String eventId) async {
    try {
      // Assuming the FirebaseRepository has a method to reject an event
      await _firebaseRepository.approveEvent(eventId);
    } catch (e) {
      // Handle exceptions or errors as needed
      throw Exception('Failed to reject event: $e');
    }
  }
}