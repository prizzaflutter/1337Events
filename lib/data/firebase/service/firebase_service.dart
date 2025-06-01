import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';
import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/data/local/service/local_service.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final LocalStorageService _localStorageService;

  const FirebaseService(
    this._localStorageService,
    this._firestore,
    this._storage,
  );

  final String collection = 'user_profiles';
  final String _eventsCollection = 'events';

  Future<void> saveUserProfileToFirestore(UserProfile userProfile) async {
    try {
      await _firestore
          .collection(collection)
          .doc(userProfile.id.toString())
          .set(
            userProfile.toJson(),
            SetOptions(merge: true), // Use merge to update existing documents
          )
          .then((value) async {
            debugPrint("User profile saved to Firestore: ${userProfile.login}");
            // save user profile to local storage
            await _localStorageService.saveUserProfileToLocalStorage(
              userProfile,
            );
          });
    } catch (e) {
      throw Exception("Failed to save user profile: $e");
    }
  }

  /// todo : over here i will Get user profile - Local First, then Firestore
  Future<UserProfileDto?> getUserProfileFromFirestore(int userId) async {
    try {
      UserProfileDto? localProfile =
          await _localStorageService.getUserProfileFromLocalStorage();

      if (localProfile != null && localProfile.id == userId) {
        return localProfile;
      }
      final DocumentSnapshot doc =
          await _firestore.collection(collection).doc(userId.toString()).get();

      if (doc.exists && doc.data() != null) {
        final userProfile = UserProfileDto.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
        await _localStorageService.saveUserProfileToLocalStorage(
          userProfile.toDomain(),
        );
        debugPrint(
          "✅ User profile loaded from Firestore and saved locally: ${userProfile.login}",
        );

        return userProfile;
      } else {
        debugPrint("User profile not found in Firestore for ID: $userId");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");

      // Final fallback: try local storage one more time
      try {
        final fallbackProfile =
            await _localStorageService.getUserProfileFromLocalStorage();
        if (fallbackProfile != null) {
          debugPrint(
            "🔄 Using cached profile as fallback: ${fallbackProfile.login}",
          );
          return fallbackProfile;
        }
      } catch (localError) {
        debugPrint("Local storage fallback also failed: $localError");
      }

      return null;
    }
  }

  Future<void> updateUserProfileFields({
    required int userId,
    bool isClubAdmin = false,
  }) async {
    try {
      await _firestore.collection(collection).doc(userId.toString()).update(
        {'isClubAdmin': isClubAdmin},
        // SetOptions(merge: true),
      );

      debugPrint("User profile updated in Firestore for user: $userId");

      // Update local storage with fresh data
      // final updatedProfileDto = await getUserProfileFromFirestore(userId);
      // if (updatedProfileDto != null) {
      //   await _localStorageService.saveUserProfileToLocalStorage(updatedProfileDto.toDomain());
      // }
    } catch (e) {
      throw Exception("Failed to update user profile: $e");
    }
  }

  Future<void> deleteUserProfile(int userId) async {
    try {
      await _firestore.collection(collection).doc(userId.toString()).delete();

      debugPrint("User profile deleted from Firestore for user: $userId");

      // Remove from local storage
      await _localStorageService.removeUserProfileFromLocalStorage();
      debugPrint("User profile removed from local storage");
    } catch (e) {
      throw Exception("Failed to delete user profile: $e");
    }
  }

  Future<bool> userProfileExists(int userId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(collection).doc(userId.toString()).get();

      return doc.exists;
    } catch (e) {
      debugPrint("Error checking user profile existence: $e");
      return false;
    }
  }

  // todo : new event function
  Future<void> addNewEventToFirestore(
      NewEventModelDto newEvent, {
        required String filePath,
      }) async {
    try {
      final String fileName = "${newEvent.id}.jpg";
      final String downloadUrl = await uploadEventImageToStorage(filePath, fileName);
      debugPrint("Image uploaded to Firebase Storage: $downloadUrl");

      if (downloadUrl.isNotEmpty) {
        // Update the event with image URL and filename before saving
        final eventWithImage = newEvent.copyWith(
          eventImage: downloadUrl, // Make sure your model has this field
        );

        final docRef = _firestore.collection(_eventsCollection).doc(newEvent.id.toString());
        await docRef.set(eventWithImage.toJson());

        debugPrint("New event added to Firestore with ID: ${newEvent.id}");
      } else {
        throw Exception("Failed to upload event image, download URL is empty.");
      }
    } catch (e) {
      // If event creation fails but image was uploaded, clean it up
      try {
        final fileName = "${newEvent.id}.jpg";
        await deleteImageFromStorage(fileName);
      } catch (cleanupError) {
        debugPrint("Failed to cleanup uploaded image: $cleanupError");
      }
      throw Exception("Failed to add new event: $e");
    }
  }

  Future<void> updateEventInFirestore(
      String eventId,
      NewEventModelDto updatedEvent,
      bool updateImage, // Single boolean parameter
      ) async {
    try {
      NewEventModelDto finalEvent = updatedEvent;
      String? existingImage;

      // Get existing event data
      final existingEvent = await _firestore
          .collection(_eventsCollection)
          .doc(eventId)
          .get();

      if (existingEvent.exists) {
        final existingData = existingEvent.data() as Map<String, dynamic>;
        existingImage = existingData['event_image'] as String?;
      }

      if (updateImage) {
        // Update image: upload new one and delete old one
        if (updatedEvent.eventImage.isNotEmpty) {
          // Delete the old image if it exists
          if (existingImage != null && existingImage.isNotEmpty) {
            try {
              await deleteImageFromStorage(existingImage);
              debugPrint("Old image deleted: $existingImage");
            } catch (deleteError) {
              debugPrint("Failed to delete old image: $deleteError");
              // Continue with update even if old image deletion fails
            }
          }

          // Upload the new image
          final String fileName = "${updatedEvent.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
          final String downloadUrl = await uploadEventImageToStorage(
            updatedEvent.eventImage, // This should be the file path
            fileName,
          );

          if (downloadUrl.isNotEmpty) {
            // Update event with new image filename
            finalEvent = updatedEvent.copyWith(eventImage: fileName);
            debugPrint("New image uploaded: $fileName");
          } else {
            throw Exception("Failed to upload new image, download URL is empty.");
          }
        } else {
          throw Exception("Cannot update image: new image path is empty");
        }
      } else {
        // Keep existing image: don't update image
        finalEvent = updatedEvent.copyWith(eventImage: existingImage ?? '');
        debugPrint("Keeping existing image: $existingImage");
      }

      // Update Firestore with final event data
      await _firestore
          .collection(_eventsCollection)
          .doc(eventId)
          .update(finalEvent.toJson());

      debugPrint("Event updated in Firestore with ID: $eventId");
    } catch (e) {
      throw Exception("Failed to update event: $e");
    }
  }


  Future<void> deleteEventInFirestore(String eventId) async {
    try {
      // Get event data first to check for image
      final eventDoc = await _firestore.collection(_eventsCollection).doc(eventId).get();

      if (eventDoc.exists) {
        final eventData = eventDoc.data() as Map<String, dynamic>;
        final imageName = eventData['imageName'] as String?;

        // Delete image from storage if exists
        if (imageName != null && imageName.isNotEmpty) {
          await deleteImageFromStorage(imageName);
          debugPrint("Event image deleted: $imageName");
        }
      }

      // Delete event from Firestore
      await _firestore.collection(_eventsCollection).doc(eventId).delete();
      debugPrint("Event deleted from Firestore with ID: $eventId");
    } catch (e) {
      throw Exception("Failed to delete event: $e");
    }
  }
  // todo : this listen to all events in the Firestore collection
  Stream<List<NewEventModelDto>> listenToEvents() {
    try {
      return _firestore.collection(_eventsCollection).snapshots().map((
        snapshot,
      ) {
        return snapshot.docs.map((doc) {
          return NewEventModelDto.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      throw Exception("Failed to listen to events: $e");
    }
  }

  // Alternative: Listen to events with multiple tag filters
  Stream<List<NewEventModelDto>> listenToEventsByTags(List<String> tags) {
    try {
      return _firestore
          .collection(_eventsCollection)
          .where('tag', whereIn: tags)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return NewEventModelDto.fromFirestore(doc);
            }).toList();
          });
    } catch (e) {
      throw Exception("Failed to listen to events by tags: $e");
    }
  }

  // todo: Storage management functions
  Future<String> uploadEventImageToStorage(
    String filePath,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref('events').child('images/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint("Image uploaded to Firebase Storage: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<String> getImageUrlFromStorage(String fileName) async {
    try {
      final ref = _storage.ref('events').child('images/$fileName');
      final downloadUrl = await ref.getDownloadURL();
      debugPrint("Image URL retrieved from Firebase Storage: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to get image URL: $e");
    }
  }

  Future<String> deleteImageFromStorage(String fileName) async {
    try {
      final ref = _storage.ref('events').child('images/$fileName');
      await ref.delete();
      debugPrint("Image deleted from Firebase Storage: $fileName");
      return "Image deleted successfully";
    } catch (e) {
      throw Exception("Failed to delete image: $e");
    }
  }

  Future<void> deleteEventImageFromStorage(String eventId) async {
    try {
      final ref = _storage.ref('events').child('images/$eventId');
      await ref.delete();
      debugPrint("Event image deleted from Firebase Storage: $eventId");
    } catch (e) {
      throw Exception("Failed to delete event image: $e");
    }
  }
}
