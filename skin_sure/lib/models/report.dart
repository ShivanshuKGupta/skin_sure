import 'gender.dart';
import 'location.dart';

class Report {
  String id;
  String? imgPath;
  String? label;
  String? segImagePath;

  /// Additional fields
  Gender? gender;
  int? age;
  Location? location;

  /// Additional fields for the report
  String? causes;
  String? treatment;
  String? precautions;

  Report({
    required this.id,
    this.imgPath,
    this.label,
    this.segImagePath,
    this.gender,
    this.age,
    this.location,
    this.causes,
    this.treatment,
    this.precautions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imgUrl': imgPath,
        'class': label,
        'seg_image_url': segImagePath,
        'gender': gender?.name,
        'age': age,
        'location': location?.name,
        'causes': causes,
        'treatment': treatment,
        'precautions': precautions,
      };

  static Report fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      imgPath: json['imgUrl']?.toString(),
      label: json['class']?.toString(),
      segImagePath: json['seg_image_url']?.toString(),
      gender: Gender.values.firstWhere(
        (element) => element.name == json['gender']?.toString(),
        orElse: () => Gender.unknown,
      ),
      age: int.tryParse(json['age'].toString()),
      location: Location.values.firstWhere(
        (element) => element.name == json['location']?.toString(),
        orElse: () => Location.unknown,
      ),
      causes: json['causes']?.toString(),
      treatment: json['treatment']?.toString(),
      precautions: json['precautions']?.toString(),
    );
  }
}
