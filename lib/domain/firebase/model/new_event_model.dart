import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/domain/firebase/model/feedback_model.dart';

class NewEventModel {
  final List<FeedBackModel> feedbacks;
  int id = DateTime.now().millisecondsSinceEpoch;
  final List<String> registeredUsers;
  final String eventImage;
  final double rate;
  final String tag;
  final String eventName;
  final String eventDescription;
  final DateTime startDate;
  final DateTime endDate;
  final LocationEventModel location;

  NewEventModel({
    required this.feedbacks,
    required this.registeredUsers,
    required this.id,
    required this.eventImage,
    required this.rate,
    required this.tag,
    required this.eventName,
    required this.eventDescription,
    required this.startDate,
    required this.endDate,
    required this.location,
  });


 NewEventModel copyWith({
    List<FeedBackModel>? feedbacks,
   List<String>? registeredUsers,
   int? id,
    String? eventImage,
    double? rate,
    String? tag,
    String? eventName,
    String? eventDescription,
    DateTime? startDate,
    DateTime? endDate,
    LocationEventModel? location,
  }) {
    return NewEventModel(
      feedbacks: feedbacks ?? this.feedbacks,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      id: id ?? this.id,
      eventImage: eventImage ?? this.eventImage,
      rate: rate ?? this.rate,
      tag: tag ?? this.tag,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbacks': feedbacks,
      'registeredUsers': registeredUsers,
      'id': id,
      'EventImage': eventImage,
      'rate': rate,
      'tag': tag,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location.toJson(),
    };
  }

  NewEventModelDto toDto() {
    return NewEventModelDto(
      feedbacks: feedbacks,
      registeredUsers: registeredUsers,
      id: id,
      eventImage: eventImage,
      rate: rate,
      tag: tag,
      eventName: eventName,
      eventDescription: eventDescription,
      startDate: startDate,
      endDate: endDate,
      location: location.toDto(),
    );
  }
}

class LocationEventModel {
  final String campus;
  final String place;

  LocationEventModel({required this.campus, required this.place});

  factory LocationEventModel.fromJson(Map<String, dynamic> json) {
    return LocationEventModel(
      campus: json['campus'] as String,
      place: json['place'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'campus': campus, 'place': place};
  }

  LocationEventModel copyWith({
    String? campus,
    String? place,
  }) {
    return LocationEventModel(
      campus: campus ?? this.campus,
      place: place ?? this.place,
    );
  }

  LocationEventModelDto toDto() {
    return LocationEventModelDto(campus: campus, place: place);
  }
}
