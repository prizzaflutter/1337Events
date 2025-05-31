import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';
import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/data/local/service/local_service.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

class FirebaseService{
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorageService;
  const FirebaseService(this._localStorageService, this._firestore);
  final String collection = 'user_profiles';
  final String _eventsCollection = 'events';
  Future<void> saveUserProfileToFirestore(UserProfile userProfile) async {
    try {
      await _firestore.collection(collection).doc(userProfile.id.toString()).set(
        userProfile.toJson(),
        SetOptions(merge: true), // Use merge to update existing documents
      ).then((value) async {
         debugPrint("User profile saved to Firestore: ${userProfile.login}");
         // save user profile to local storage
          await _localStorageService.saveUserProfileToLocalStorage(userProfile);
      });
    }catch (e) {
      throw Exception("Failed to save user profile: $e");
    }
  }
  /// todo : over here i will Get user profile - Local First, then Firestore
  Future<UserProfileDto?> getUserProfileFromFirestore(int userId) async {
    try {
      UserProfileDto? localProfile = await _localStorageService.getUserProfileFromLocalStorage();

      if (localProfile != null && localProfile.id == userId) {
        return localProfile;
      }
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(userId.toString())
          .get();

      if (doc.exists && doc.data() != null) {
        final userProfile = UserProfileDto.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        await _localStorageService.saveUserProfileToLocalStorage(userProfile.toDomain());
        debugPrint("✅ User profile loaded from Firestore and saved locally: ${userProfile.login}");

        return userProfile;
      } else {
        debugPrint("User profile not found in Firestore for ID: $userId");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");

      // Final fallback: try local storage one more time
      try {
        final fallbackProfile = await _localStorageService.getUserProfileFromLocalStorage();
        if (fallbackProfile != null) {
          debugPrint("🔄 Using cached profile as fallback: ${fallbackProfile.login}");
          return fallbackProfile;
        }
      } catch (localError) {
        debugPrint("Local storage fallback also failed: $localError");
      }

      return null;
    }
  }

  Future<void> updateUserProfileFields({required int userId, bool isClubAdmin = false}) async {
    try {

      await _firestore
          .collection(collection)
          .doc(userId.toString())
          .update({
            'isClubAdmin' : isClubAdmin,
      },
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
      await _firestore
          .collection(collection)
          .doc(userId.toString())
          .delete();

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
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(userId.toString())
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint("Error checking user profile existence: $e");
      return false;
    }
  }


  // todo : new event function

  Future<void> addNewEventToFirestore(NewEventModelDto newEvent) async {
      try {
        final docRef = _firestore.collection(_eventsCollection).doc();
        await docRef.set(newEvent.toJson());
        debugPrint("New event added to Firestore with ID: ${docRef.id}");
      } catch (e) {
        throw Exception("Failed to add new event: $e");
      }
    }
  Future<void> updateEventInFirestore(String eventId, NewEventModelDto updatedEvent) async {
      try {
        await _firestore.collection(_eventsCollection).doc(eventId).update(updatedEvent.toJson());
        debugPrint("Event updated in Firestore with ID: $eventId");
      } catch (e) {
        throw Exception("Failed to update event: $e");
      }
    }
  Future<void> deleteEventInFirestore(String eventId) async {
    try {
      await _firestore.collection(_eventsCollection).doc(eventId).delete();
      debugPrint("Event deleted from Firestore with ID: $eventId");
    } catch (e) {
      throw Exception("Failed to delete event: $e");
    }
  }

// todo : this listen to all events in the Firestore collection
  Stream<List<NewEventModelDto>> listenToEvents() {
    try {
      return _firestore
          .collection(_eventsCollection)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return NewEventModelDto.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      throw Exception("Failed to listen to events: $e");
    }
  }

  // Listen to events filtered by student's tag
  Stream<List<NewEventModelDto>> listenToEventsByTag(String studentTag) {
    try {
      return _firestore
          .collection(_eventsCollection)
          .where('tag', whereIn: [studentTag, 'all'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return NewEventModelDto.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      throw Exception("Failed to listen to events by tag: $e");
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


  // todo: just for testing

}

