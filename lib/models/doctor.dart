class Doctor {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int reviews;
  final String experience;
  final String imageUrl;
  final bool isAvailable;
  final String biography;
  final double consultationFee;
  final String? email;
  final String? password;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.imageUrl,
    this.isAvailable = true,
    required this.biography,
    required this.consultationFee,
    this.email,
    this.password,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'rating': rating,
      'reviews': reviews,
      'experience': experience,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'biography': biography,
      'consultation_fee': consultationFee,
      'email': email,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      rating: json['rating'].toDouble(),
      reviews: json['reviews'],
      experience: json['experience'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      biography: json['biography'],
      consultationFee: json['consultation_fee'].toDouble(),
      email: json['email'],
    );
  }
}
