import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';

class NewEventModel {
  int id = DateTime.now().millisecondsSinceEpoch;
  final String eventImage;
  final double rate;
  final String tag;
  final String eventName;
  final String eventDescription;
  final DateTime startDate;
  final DateTime endDate;
  final LocationEventModel location;

  NewEventModel({
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

  Map<String, dynamic> toJson() {
    return {
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

  LocationEventModelDto toDto() {
    return LocationEventModelDto(campus: campus, place: place);
  }
}
