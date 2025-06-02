# Separate Session History Implementation

## Overview

This implementation provides separate session history screens for breathwork and guided meditations while maintaining the common storage in the same database table.

## What's Implemented

### 1. Enhanced Repository (`lib/data/repositories/meditation_repository.dart`)

Added new methods to filter sessions by type:

**Breathwork Methods:**

- `getBreathworkSessions()` - Gets all breathwork sessions (excludes guided\_\* types)
- `getBreathworkSessionsCount()` - Count of breathwork sessions
- `getBreathworkTotalMinutes()` - Total minutes for breathwork sessions

**Guided Meditation Methods:**

- `getGuidedMeditationSessions()` - Gets all guided meditation sessions (guided\_\* types)
- `getGuidedMeditationSessionsCount()` - Count of guided meditation sessions
- `getGuidedMeditationTotalMinutes()` - Total minutes for guided meditation sessions

### 2. New History Screens

**Breathwork History (`lib/screens/meditation/breathwork_history_screen.dart`)**

- Shows only breathwork sessions (demo, sleep, focus, anxiety, happiness)
- Dedicated stats cards for breathwork sessions
- Custom styling with breathwork-specific icons and colors
- Delete functionality for individual sessions

**Guided Meditation History (`lib/screens/meditation/guided_meditation_history_screen.dart`)**

- Shows only guided meditation sessions (guided\_\* types)
- Handles all guided meditation categories with proper icons and colors
- Comprehensive mapping for different guided meditation types
- Delete functionality for individual sessions

### 3. Updated Navigation

**Breathwork Navigation (`lib/screens/meditation/home_screen.dart`)**

- History button now navigates to `BreathworkHistoryScreen`

**Main Home Screen (`lib/screens/home/home_screen.dart`)**

- Breathwork tab: History button shows breathwork sessions only
- Guided tab: Added new history button showing guided meditation sessions only

### 4. Session Type Detection

**Breathwork Session Types:**

- `demo`, `sleep`, `focus`, `anxiety`, `happiness`

**Guided Meditation Session Types:**

- `guided_breathing_practices`, `guided_brief_mindfulness`, `guided_body_scan`
- `guided_sitting_meditations`, `guided_guided_imagery`, `guided_self_guided`
- Plus specific session names and partial sessions (`*_partial`)

## Data Storage

- **Common Storage**: All sessions still stored in the same `meditation_sessions` table
- **Type Filtering**: Sessions are differentiated by the `meditation_type` field
- **Backward Compatibility**: Existing sessions continue to work normally

## User Experience

1. **Breathwork Page**: History button shows only breathwork meditation sessions
2. **Guided Meditation Page**: History button shows only guided meditation sessions
3. **Overall History**: The original `SessionHistoryScreen` still exists for complete history if needed
4. **Separate Stats**: Each history screen shows relevant statistics for that meditation type

## Benefits

- ✅ Separate, focused history views for each meditation type
- ✅ Maintains common storage architecture
- ✅ Type-specific statistics and insights
- ✅ Consistent UI/UX across both history screens
- ✅ Easy to extend with new meditation types
- ✅ Backward compatible with existing data

## Files Modified/Created

- `lib/data/repositories/meditation_repository.dart` - Enhanced with filtering methods
- `lib/screens/meditation/breathwork_history_screen.dart` - New breathwork-only history
- `lib/screens/meditation/guided_meditation_history_screen.dart` - New guided meditation-only history
- `lib/screens/meditation/home_screen.dart` - Updated navigation
- `lib/screens/home/home_screen.dart` - Added guided meditation history button
