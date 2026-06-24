class Prescription {
  final List<String> medicines;
  final String instructions;
  final DateTime date;

  Prescription({
    required this.medicines,
    required this.instructions,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicines': medicines,
      'instructions': instructions,
      'date': date.toIso8601String(),
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicines: List<String>.from(json['medicines']),
      instructions: json['instructions'],
      date: DateTime.parse(json['date']),
    );
  }
}
