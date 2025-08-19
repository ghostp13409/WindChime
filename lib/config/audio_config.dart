class AudioConfig {
  // Base URL for downloading audio files from GitHub releases
  static const String baseUrl =
      'https://github.com/ghostp13409/WindChime/releases/download/AudioFiles/';

  // Audio files that should be downloaded dynamically (not bundled)
  static const Map<String, String> downloadableAudioFiles = {
    // Body Scan meditations
    'sounds/meditation/guided/body_scan/Body Scan.mp3': 'body_scan.mp3',
    'sounds/meditation/guided/body_scan/Fifteen Minute Body Scan.mp3':
        'fifteen_minute_body_scan.mp3',
    'sounds/meditation/guided/body_scan/Forty-Five Minute Body Scan.mp3':
        'forty_five_minute_body_scan.mp3',
    'sounds/meditation/guided/body_scan/Four Minute Body Scan.mp3':
        'four_minute_body_scan.mp3',
    'sounds/meditation/guided/body_scan/Twenty Minute Body Scan.mp3':
        'twenty_minute_body_scan.mp3',

    // Breathing Practices
    'sounds/meditation/guided/breathing_practices/Five Minute Breathing.mp3':
        'five_minute_breathing.mp3',
    'sounds/meditation/guided/breathing_practices/Six Minute Breath Awareness.mp3':
        'six_minute_breath_awareness.mp3',
    'sounds/meditation/guided/breathing_practices/Ten Minute Breathing.mp3':
        'ten_minute_breathing.mp3',
    'sounds/meditation/guided/breathing_practices/Ten Minute Mindfulness of Breathing.mp3':
        'ten_minute_mindfulness_of_breathing.mp3',
    'sounds/meditation/guided/breathing_practices/Three Minute Breathing.mp3':
        'three_minute_breathing.mp3',

    // Brief Mindfulness Practices
    'sounds/meditation/guided/brief_mindfulness_practices/Brief Mindfulness Practice.mp3':
        'brief_mindfulness_practice.mp3',
    'sounds/meditation/guided/brief_mindfulness_practices/The Breathing Space.mp3':
        'the_breathing_space.mp3',
    'sounds/meditation/guided/brief_mindfulness_practices/The Tension Release Meditation.mp3':
        'the_tension_release_meditation.mp3',
    'sounds/meditation/guided/brief_mindfulness_practices/Three Minute Mindfulness of Sounds.mp3':
        'three_minute_mindfulness_of_sounds.mp3',
    'sounds/meditation/guided/brief_mindfulness_practices/Three Step Breathing Space.mp3':
        'three_step_breathing_space.mp3',

    // Guided Imagery
    'sounds/meditation/guided/guided_imagery/MindfulnessMountainMeditationPeterMorgan.mp3':
        'mindfulnessmountainmeditationpetermorgan.mp3',
    'sounds/meditation/guided/guided_imagery/PadraigTheMountain.mp3':
        'padraigthemountain.mp3',

    // Self Guided Mindfulness Exercises
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Five Minutes Just Bells.mp3':
        'five_minutes_just_bells.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Forty-Five Minute Bells (5 min intervals).mp3':
        'forty_five_minute_bells_5_min_intervals.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Forty-Five Minute Bells (15 min intervals).mp3':
        'forty_five_minute_bells_15_min_intervals.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Ten Minutes Just Bells.mp3':
        'ten_minutes_just_bells.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Thirty Minute Bells (5 min intervals).mp3':
        'thirty_minute_bells_5_min_intervals.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty Minute Bells (5 min intervals).mp3':
        'twenty_minute_bells_5_min_intervals.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty Minutes Just Bells.mp3':
        'twenty_minutes_just_bells.mp3',
    'sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty-Five Minute Bells (5 min intervals).mp3':
        'twenty_five_minute_bells_5_min_intervals.mp3',

    // Sitting Meditations
    'sounds/meditation/guided/sitting_meditations/Breath, Sound and Body.mp3':
        'breath_sound_and_body.mp3',
    'sounds/meditation/guided/sitting_meditations/Breath, Sounds, Body, Thoughts, Emotions.mp3':
        'breath_sounds_body_thoughts_emotions.mp3',
    'sounds/meditation/guided/sitting_meditations/Compassionate Breath.mp3':
        'compassionate_breath.mp3',
    'sounds/meditation/guided/sitting_meditations/Seated Meditation.mp3':
        'seated_meditation.mp3',
    'sounds/meditation/guided/sitting_meditations/Sitting Meditation.mp3':
        'sitting_meditation.mp3',
    'sounds/meditation/guided/sitting_meditations/Ten Minute Wisdom Meditation.mp3':
        'ten_minute_wisdom_meditation.mp3',
  };

  // Audio files that should be bundled (smaller files)
  static const List<String> bundledAudioFiles = [
    'meditation/Anxiety.mp3',
    'meditation/Focus.mp3',
    'meditation/Sleep.mp3',
    'meditation/happy.mp3',
    'startup/bell.wav',
    'startup/completetask.mp3',
    'startup/smallbell.mp3',
    'meditation/statechange/breath_in.wav',
    'meditation/statechange/breath_out.wav',
    'meditation/statechange/hold.wav',
    'meditation/statechange/rest.wav',
  ];

  // Check if an audio file should be downloaded
  static bool shouldDownload(String audioPath) {
    return downloadableAudioFiles.containsKey(audioPath);
  }

  // Get the download URL for an audio file
  static String getDownloadUrl(String audioPath) {
    final fileName = downloadableAudioFiles[audioPath];
    if (fileName != null) {
      return '$baseUrl$fileName';
    }
    return '';
  }

  // Get the local file name for downloaded audio
  static String getLocalFileName(String audioPath) {
    return downloadableAudioFiles[audioPath] ?? '';
  }
}
