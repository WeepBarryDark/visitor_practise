import 'dart:convert';

/// Simple person model for site staff (manager, supervisor)
class SitePerson {
  final int id;
  final String name;

  const SitePerson({
    required this.id,
    required this.name,
  });

  factory SitePerson.fromJson(dynamic json) {
    // If it's a string, try to parse it as JSON first
    if (json is String) {
      // Check if it looks like a JSON object string
      if (json.trim().startsWith('{')) {
        try {
          // Try to parse as proper JSON
          final parsed = jsonDecode(json);
          if (parsed is Map<String, dynamic>) {
            return SitePerson(
              id: parsed['id'] ?? 0,
              name: (parsed['name'] ?? '').toString(),
            );
          }
        } catch (e) {
          // If JSON parsing fails, try manual parsing for format like "{id: 123, name: John}"
          try {
            final cleaned = json.trim().substring(1, json.trim().length - 1); // Remove { }
            final parts = cleaned.split(',');
            int id = 0;
            String name = '';

            for (var part in parts) {
              final keyValue = part.split(':');
              if (keyValue.length == 2) {
                final key = keyValue[0].trim().replaceAll(RegExp(r'["\s]'), '');
                final value = keyValue[1].trim().replaceAll(RegExp(r'^["\s]+|["\s]+$'), '');
                if (key == 'id') {
                  id = int.tryParse(value) ?? 0;
                } else if (key == 'name') {
                  name = value;
                }
              }
            }

            return SitePerson(id: id, name: name);
          } catch (e) {
            // If all parsing fails, treat the whole string as name
            return SitePerson(id: 0, name: json);
          }
        }
      }
      // Plain string name (legacy format)
      return SitePerson(id: 0, name: json);
    }

    // Normal Map object
    if (json is Map<String, dynamic>) {
      return SitePerson(
        id: json['id'] ?? 0,
        name: (json['name'] ?? '').toString(),
      );
    }

    return const SitePerson(id: 0, name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
