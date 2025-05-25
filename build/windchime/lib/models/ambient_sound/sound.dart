class Sound {
  final String name;
  final String filePath;
  final Duration duration;
  final String category;
  final bool isPlaying; // Add isPlaying property

  const Sound({
    required this.name,
    required this.filePath,
    required this.duration,
    required this.category,
    required this.isPlaying, // Add isPlaying to the constructor
  });
}
