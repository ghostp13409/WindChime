import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static const apiKey = 'AIzaSyD6CJ8QGSBIUh2Voeryk7qhSjUQ4E8Imdw';

  Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required double lat,
    required double lng,
    required int radius,
    List<String>? type,
    List<String>? keyword,
  }) async {
    try {
      final typeString = type?.join('|') ?? '';
      final keywordString = keyword?.join('|') ?? '';

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=$lat,$lng'
          '&radius=$radius'
          '${typeString.isNotEmpty ? '&type=$typeString' : ''}'
          '${keywordString.isNotEmpty ? '&keyword=$keywordString' : ''}'
          '&key=$apiKey');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results'].map((place) {
            return {
              'id': place['place_id'],
              'name': place['name'],
              'vicinity': place['vicinity'],
              'lat': place['geometry']['location']['lat'],
              'lng': place['geometry']['location']['lng'],
            };
          }));
        } else {
          print(
              'Places API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('Error fetching places: $e');
      return [];
    }
  }
}
