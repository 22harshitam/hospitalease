class Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String age;
  final String bloodGroup;
  final String address;
  final String emergencyContact;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.bloodGroup,
    required this.address,
    required this.emergencyContact,
    required this.createdAt,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'blood_group': bloodGroup,
      'address': address,
      'emergency_contact': emergencyContact,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      bloodGroup: json['blood_group'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
