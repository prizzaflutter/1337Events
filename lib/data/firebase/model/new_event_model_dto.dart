import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';

class NewEventModelDto {
  int id = DateTime.now().millisecondsSinceEpoch;
  final String eventImage;
  final String tag;
  final String eventName;
  final String eventDescription;
  final DateTime startDate;
  final DateTime  endDate;
  final LocationEventModelDto location;
  final double rate;

// todo : hna ma3arfch  dyal date widget
  NewEventModelDto({
  required this.id,
    required this.eventImage,
    required this.tag,
    required this.eventName,
    required this.eventDescription,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.rate,
  });

  factory NewEventModelDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NewEventModelDto(
      id: data['id'] as int,
      eventImage: data['eventImage'] as String,
      rate: data['rate'] as double,
      tag: data['tag'] as String,
      eventName: data['eventName'] as String,
      eventDescription: data['eventDescription'] as String,
      startDate: DateTime.parse(data['startDate'] as String),
      endDate: DateTime.parse(data['endDate'] as String),
      location: LocationEventModelDto.fromJson(data['location'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'eventImage': eventImage,
      'rate': rate,
      'tag': tag,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location.toJson(),
    };
  }

  NewEventModel toDomain() {
    return NewEventModel(
      id : id,
      eventImage: eventImage,
      rate: rate,
      tag: tag,
      eventName: eventName,
      eventDescription: eventDescription,
      startDate: startDate,
      endDate: endDate,
      location: location.toDomain(),
    );
  }

  NewEventModelDto copyWith({
    int? id,
    String? eventImage,
    String? tag,
    String? eventName,
    String? eventDescription,
    DateTime? startDate,
    DateTime? endDate,
    LocationEventModelDto? location,
    double? rate,
  }) {
    return NewEventModelDto(
      id : id ?? this.id,
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
}

class LocationEventModelDto {
  final String campus;
  final String place;

  LocationEventModelDto({
    required this.campus,
    required this.place,
  });

  factory LocationEventModelDto.fromJson(Map<String, dynamic> json) {
    return LocationEventModelDto(
      campus: json['campus'] as String,
      place: json['place'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'campus': campus,
      'place': place,
    };
  }

  LocationEventModel toDomain() {
    return LocationEventModel(
      campus: campus,
      place: place,
    );
  }
}