class Report {
  String id;
  String? imgUrl;
  String? label;
  String? segImageUrl;
  String? suggestions;

  Report({
    required this.id,
    this.imgUrl,
    this.label,
    this.segImageUrl,
    this.suggestions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imgUrl': imgUrl,
        'class': label,
        'seg_image_url': segImageUrl,
        'suggestions': suggestions
      };

  static Report fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      imgUrl: json['imgUrl']?.toString(),
      label: json['class']?.toString(),
      segImageUrl: json['seg_image_url']?.toString(),
      suggestions: json['suggestions']?.toString(),
    );
  }
}
