import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/feedback_model.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';

abstract class FirebaseRepository {
 // todo : user profile firestore management
 Future<void> saveUserProfileToFirestore(UserProfile userProfile);
  Future<UserProfile?> getUserProfileFromFirestore(int userId);
  Future<void> deleteUserProfile(int userId);
  Future<void> updateUserProfile({required int userId, bool isClubAdmin = false});

// todo : event firestore management
 Future<void> addNewEvent(NewEventModel event, {required String filePath});
 Future<void> updateEvent (String eventId, NewEventModelDto updateEvent);
 Future<void> deleteEvent (String eventId);
 Stream<List<NewEventModelDto>> listenToEvents();
 Stream<List<NewEventModelDto>> listenToEventsByTags(List<String> tags);
 Stream<List<NewEventModelDto>> listenToUpComingEvents();

 // todo : storage management

  Future<String> uploadImageToStorage(String filePath, String fileName);
  Future<String> getImageUrlFromStorage(String fileName);
  Future<void> deleteImageFromStorage(String fileName);


  // todo : register/unregister event
   Future<void> registerToEvent(String eventId, String userId);
   Future<void> unregisterFromEvent(String eventId, String userId);


   // todo : get Event that need feed back
  Stream<List<NewEventModel>> getEventThatNeedFeedBackStream(String userId);
 Future<void> submitFeedback({required String eventId, required FeedBackModel feedback});
 Future<bool> userExistsByLogin(String login);
 Future<void> updateUserClubAdminStatusById(String userId, bool isClubAdmin);
 Future<String> getIdFromLogin(String login);
 Future<bool> checkUserHasAccess (String login);

 // todo : pending events
  Stream<List<NewEventModel>> getPendingEvents();
  Future<void> approveEvent(String eventId);
}