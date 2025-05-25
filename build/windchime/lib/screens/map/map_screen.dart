import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:windchime/services/places_service.dart';

// Utility class for places functionality
class WebUtil {
  static final _placesService = PlacesService();

  static void initializeMapService(
      {required Function(dynamic) onPlacesServiceCreated}) {
    onPlacesServiceCreated(_placesService);
  }

  static Map<String, dynamic> createRequest(Map<String, dynamic> params) {
    return params;
  }

  static Future<void> searchNearbyPlaces({
    required dynamic placesService,
    required dynamic request,
    required Function(List<Map<String, dynamic>>) onResults,
  }) async {
    try {
      final places = await _placesService.searchNearbyPlaces(
        lat: request['location']['lat'],
        lng: request['location']['lng'],
        radius: request['radius'],
        type: (request['type'] as List<dynamic>).cast<String>(),
        keyword: (request['keyword'] as List<dynamic>).cast<String>(),
      );
      onResults(places);
    } catch (e) {
      print('Error searching nearby places: $e');
      onResults([]);
    }
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  static const darkModeStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';
  String output = 'Tap to find facilities';
  late GoogleMapController mapController;
  List<Marker> markers = [];
  bool isLoading = false;
  LatLng currentPosition = const LatLng(43.47063, -80.54138);
  dynamic placesService;
  int selectedRadius = 5000; // Default 5km
  bool _mounted = true;
  final List<Map<String, dynamic>> radiusOptions = [
    {'label': '5 km', 'value': 5000},
    {'label': '10 km', 'value': 10000},
    {'label': '20 km', 'value': 20000},
    {'label': '50 km', 'value': 50000},
  ];

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _initializeMapService();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _initializeMapService() {
    WebUtil.initializeMapService(
      onPlacesServiceCreated: (service) {
        placesService = service;
      },
    );
  }

  Future<void> getLocation() async {
    try {
      if (!_mounted) return;
      setState(() => isLoading = true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      if (!_mounted) return;
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        output = 'Location updated';
        markers = [
          Marker(
            markerId: const MarkerId('current'),
            position: currentPosition,
            infoWindow: const InfoWindow(title: 'Current Location'),
          )
        ];
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition, 14),
      );

      final request = WebUtil.createRequest({
        'location': {'lat': position.latitude, 'lng': position.longitude},
        'radius': selectedRadius,
        'type': ['health'],
        'keyword': [
          'mental health',
          'counseling',
          'therapy',
          'psychiatrist',
          'psychologist'
        ]
      });

      if (placesService != null) {
        WebUtil.searchNearbyPlaces(
          placesService: placesService,
          request: request,
          onResults: (places) {
            final newMarkers = places.map((place) {
              return Marker(
                markerId: MarkerId(place['id'] as String),
                position: LatLng(
                  place['lat'] as double,
                  place['lng'] as double,
                ),
                infoWindow: InfoWindow(
                  title: place['name'] as String,
                  snippet: place['vicinity'] as String,
                ),
              );
            }).toList();

            if (!_mounted) return;
            setState(() {
              markers = newMarkers;
              output =
                  'Found ${newMarkers.length} facilities within ${selectedRadius ~/ 1000} km';
            });

            _focusOnClosestMarker();
          },
        );
      }
    } catch (e) {
      if (!_mounted) return;
      setState(() => output = 'Error: ${e.toString()}');
    } finally {
      if (!_mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _focusOnClosestMarker() {
    if (markers.isEmpty) return;

    Marker closestMarker = markers.first;
    double minDistance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      closestMarker.position.latitude,
      closestMarker.position.longitude,
    );

    for (final marker in markers) {
      final double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestMarker = marker;
      }
    }

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: closestMarker.position,
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Mental Health Facilities',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: Theme.of(context).brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: selectedRadius,
                        items: radiusOptions.map((option) {
                          return DropdownMenuItem<int>(
                            value: option['value'],
                            child: Text(option['label']),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedRadius = value!),
                        decoration: const InputDecoration(
                          labelText: 'Search Radius',
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : getLocation,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF8E97FD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (output != 'Tap to find facilities')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E97FD).withOpacity(0.2)
                    : const Color(0xFF8E97FD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF8E97FD),
                  width: 1,
                ),
              ),
              child: Text(
                output,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8E97FD)
                      : const Color(0xFF8E97FD),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: Theme.of(context).brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                    mapController.setMapStyle(darkModeStyle);
                  },
                  markers: Set<Marker>.of(markers),
                  myLocationEnabled: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: markers.isEmpty ? null : _focusOnClosestMarker,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: const Color(0xFF8E97FD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Focus on Closest Facility',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
