class FocusArea {
  final String id;
  final String name;
  final String? icon;

  final String? description;

  const FocusArea({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  String get title => name;

  factory FocusArea.fromJson(Map<String, dynamic> json) {
    return FocusArea(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
}
