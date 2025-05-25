// Stub implementation for non-web platforms
class WebUtil {
  static void initializeMapService({
    required Function(dynamic) onPlacesServiceCreated,
  }) {
    // No-op on non-web platforms
  }

  static dynamic createRequest(Map<String, dynamic> params) {
    return null;
  }

  static void searchNearbyPlaces({
    required dynamic placesService,
    required dynamic request,
    required Function(List<Map<String, dynamic>>) onResults,
  }) {
    // No-op on non-web platforms
    onResults([]);
  }
}
