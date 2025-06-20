// lib/services/nominatim_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimService {
  /// Interroge l'API Nominatim pour l'autocomplétion d'adresses
  static Future<List<String>> fetchAddresses(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(query)}'
            '&format=jsonv2'
            '&addressdetails=1'
            '&limit=5'
    );
    final response = await http.get(url, headers: {
      'User-Agent': 'DaaraDigitale/1.0'
    });
    if (response.statusCode != 200) return [];
    final List data = json.decode(response.body);
    return data.map<String>((e) => e['display_name'] as String).toList();
  }
}
