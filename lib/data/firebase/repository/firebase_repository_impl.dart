import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';
import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/data/firebase/service/firebase_service.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class FirebaseRepositoryImpl implements  FirebaseRepository {
  FirebaseService _firebaseService;
  FirebaseRepositoryImpl(this._firebaseService);

  @override
  Future<void> addNewEvent(NewEventModel event, {required String filePath})async{
     return await  _firebaseService.addNewEventToFirestore(event.toDto(), filePath: filePath);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    return await _firebaseService.deleteEventInFirestore(eventId);
  }

  @override
  Stream<List<NewEventModelDto>> listenToEvents() {
    return _firebaseService.listenToEvents();
  }

  @override
  Stream<List<NewEventModelDto>> listenToEventsByTags(List<String> tags) {
    return _firebaseService.listenToEventsByTags(tags);
  }

  @override
  Future<void> updateEvent(String eventId, NewEventModelDto updateEvent, bool updateImage) async {
    return await _firebaseService.updateEventInFirestore(eventId, updateEvent, updateImage);
  }
  
  
  

  @override
  Future<void> saveUserProfileToFirestore(UserProfile userProfile) async{
    return await _firebaseService.saveUserProfileToFirestore(userProfile);
  }

  @override
  Future<void> deleteUserProfile(int userId) async {
    return await _firebaseService.deleteUserProfile(userId);
  }

  @override
  Future<UserProfile?> getUserProfileFromFirestore(int userId) async{
      UserProfileDto? userProfileDto =  await _firebaseService.getUserProfileFromFirestore(userId);
      return userProfileDto?.toDomain();
  }

  @override
  Future<void> updateUserProfile({required int userId, bool isClubAdmin = false}) async {
      return await _firebaseService.updateUserProfileFields(userId: userId, isClubAdmin: isClubAdmin);
  }

  @override
  Future<void> deleteImageFromStorage(String fileName) {
    // TODO: implement deleteImageFromStorage
    throw UnimplementedError();
  }

  @override
  Future<String> getImageUrlFromStorage(String fileName) {
    // TODO: implement getImageUrlFromStorage
    throw UnimplementedError();
  }

  @override
  Future<String> uploadImageToStorage(String filePath, String fileName) {
    // TODO: implement uploadImageToStorage
    throw UnimplementedError();
  }

  @override
  Stream<List<NewEventModelDto>> listenToUpComingEvents() {
     return _firebaseService.listenToUpComingEvents();
  }

  @override
  Future<void> registerToEvent(String eventId, String userId) async {
    return await _firebaseService.RegisterToEvent(eventId, userId);
  }

  @override
  Future<void> unregisterFromEvent(String eventId, String userId) async{
    return await _firebaseService.UnRegisterFromEvent(eventId, userId);
  }

}