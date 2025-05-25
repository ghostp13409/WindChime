// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show debugPrint;

class WebUtil {
  static void initializeMapService({
    required Function(dynamic) onPlacesServiceCreated,
  }) {
    if (!kIsWeb) return;

    try {
      _checkGoogleMapsLoaded().then((isLoaded) {
        if (!isLoaded) {
          debugPrint('Google Maps API failed to load');
          return;
        }

        final mapContainer = html.DivElement()
          ..id = 'map-container'
          ..style.display = 'none';
        html.document.body?.append(mapContainer);

        final google = js.context['google'];
        final maps = google['maps'];
        if (maps != null) {
          final mapOptions = js.JsObject.jsify({
            'center': {'lat': 43.47063, 'lng': -80.54138},
            'zoom': 14,
            'disableDefaultUI': true,
          });

          final jsMap = js.JsObject(maps['Map'], [mapContainer, mapOptions]);
          final places = maps['places'];
          if (places != null) {
            final placesService = js.JsObject(places['PlacesService'], [jsMap]);
            onPlacesServiceCreated(placesService);
          }
        }
      });
    } catch (e) {
      debugPrint('Error initializing map service: $e');
    }
  }

  static Future<bool> _checkGoogleMapsLoaded() async {
    int attempts = 0;
    const maxAttempts = 10;
    const delayMs = 500;

    while (attempts < maxAttempts) {
      if (js.context.hasProperty('google') &&
          js.context['google'].hasProperty('maps')) {
        return true;
      }
      await Future.delayed(Duration(milliseconds: delayMs));
      attempts++;
    }
    return false;
  }

  static dynamic createRequest(Map<String, dynamic> params) {
    if (!kIsWeb) return null;
    return js.JsObject.jsify(params);
  }

  static void searchNearbyPlaces({
    required dynamic placesService,
    required dynamic request,
    required Function(List<Map<String, dynamic>>) onResults,
  }) {
    if (!kIsWeb) return;

    try {
      final baseRequest = js.JsObject.fromBrowserObject(request);
      final location = baseRequest['location'];
      final radius = baseRequest['radius'];

      final places = <String, Map<String, dynamic>>{};
      var completedSearches = 0;
      const totalSearches = 5;

      void searchWithParams(String type, String keyword) {
        final searchRequest = js.JsObject.jsify({
          'location': location,
          'radius': radius,
          'type': type,
          'keyword': keyword,
        });

        placesService.callMethod('nearbySearch', [
          searchRequest,
          js.allowInterop((results, status, _) {
            completedSearches++;

            if (status == 'OK' && results != null) {
              for (final jsPlace in results as List<dynamic>) {
                final place = js.JsObject.fromBrowserObject(jsPlace);
                final geometry = place['geometry'];
                if (geometry != null) {
                  final placeLocation = geometry['location'];
                  if (placeLocation != null) {
                    final placeId = place['place_id'].toString();
                    if (!places.containsKey(placeId)) {
                      places[placeId] = {
                        'id': placeId,
                        'name': place['name'].toString(),
                        'vicinity': place['vicinity'].toString(),
                        'lat': placeLocation.callMethod('lat', []) as double,
                        'lng': placeLocation.callMethod('lng', []) as double,
                      };
                    }
                  }
                }
              }
            }

            if (completedSearches == totalSearches) {
              onResults(places.values.toList());
            }
          })
        ]);
      }

      // Perform multiple searches with different parameters
      searchWithParams('health', 'mental health');
      searchWithParams('health', 'counseling');
      searchWithParams('health', 'psychiatrist');
      searchWithParams('health', 'psychologist');
      searchWithParams('doctor', 'mental health');
    } catch (e) {
      debugPrint('Error searching nearby places: $e');
      onResults([]);
    }
  }
}
