class Report {
  String id;
  String? imgPath;
  String? label;
  String? segImagePath;

  String? suggestions;

  Report({
    required this.id,
    this.imgPath,
    this.label,
    this.segImagePath,
    this.suggestions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imgUrl': imgPath,
        'class': label,
        'seg_image_url': segImagePath,
        'suggestions': suggestions,
      };

  static Report fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      imgPath: json['imgUrl']?.toString(),
      label: json['class']?.toString(),
      segImagePath: json['seg_image_url']?.toString(),
      suggestions: json['suggestions']?.toString(),
    );
  }
}
