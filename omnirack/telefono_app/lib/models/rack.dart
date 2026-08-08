class Rack {
  final String id;
  final String name;
  final String location;
  final String status;
  final Map<String, dynamic> thresholds;

  Rack({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.thresholds,
  });

  factory Rack.fromJson(Map<String, dynamic> json) {
    return Rack(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      thresholds: json['thresholds'] as Map<String, dynamic>? ?? {},
    );
  }
}
