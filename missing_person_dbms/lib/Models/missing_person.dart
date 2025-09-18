class MissingPerson {
  int? id;
  String name;
  int age;
  String gender;
  String lastSeenLocation;
  String description;
  String? photoUrl;
  DateTime dateReported;

  MissingPerson({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.lastSeenLocation,
    required this.description,
    this.photoUrl,
    required this.dateReported,
  });

  // Convert JSON to MissingPerson object
  factory MissingPerson.fromJson(Map<String, dynamic> json) {
    return MissingPerson(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      lastSeenLocation: json['last_seen_location'],
      description: json['description'],
      photoUrl: json['photo_url'],
      dateReported: DateTime.parse(json['date_reported']),
    );
  }

  // Convert MissingPerson object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'last_seen_location': lastSeenLocation,
      'description': description,
      'photo_url': photoUrl,
      'date_reported': dateReported.toIso8601String(),
    };
  }
}
