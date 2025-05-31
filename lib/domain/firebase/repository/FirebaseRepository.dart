import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';

abstract class FirebaseRepository {
 // todo : user profile firestore management
 Future<void> saveUserProfileToFirestore(UserProfile userProfile);
  Future<UserProfile?> getUserProfileFromFirestore(int userId);
  Future<void> deleteUserProfile(int userId);
  Future<void> updateUserProfile({required int userId, bool isClubAdmin = false});


 Future<void> addNewEvent(NewEventModel event);
 Future<void> updateEvent (String eventId, NewEventModelDto updateEvent);
 Future<void> deleteEvent (String eventId);

 Stream<List<NewEventModelDto>> listenToEvents();
 Stream<List<NewEventModelDto>> listenToEventsByTags(List<String> tags);
}