# WindChime Home Screen Redesign - Architecture Plan

## Overview

This document outlines the redesigned home screen architecture integrating new features while maintaining the app's core meditation functionality.

## Design Philosophy

- **Modern & Minimalist**: Clean card-based design with smooth animations
- **User-Centric**: Quick access to frequent actions, personalized content
- **Discoverable**: New features visible but not overwhelming
- **Consistent**: Maintains existing design language and color scheme

## New Features Integration

### 1. **Meditation Streaks & Social Sharing**

- **Location**: Top hero card with gradient background
- **Display**: Current streak count with flame icon
- **Interaction**: Tap to view detailed stats, share button for social media
- **Data**: Days consecutive, total sessions, achievements

### 2. **Mood Tracking Dashboard**

- **Location**: Second card below streak
- **Display**: Today's mood selector + weekly mood trend chart
- **Interaction**: Quick mood buttons (emoji-based), tap for detailed analytics
- **Visual**: Line chart showing mood patterns over time

### 3. **Quick Session Button**

- **Location**: Floating Action Button (FAB) - bottom right
- **Style**: Large circular button with gradient, pulsing animation
- **Function**: Starts last used meditation OR smart suggestion based on time
- **States**: Default, Loading, Pulsing (reminder after inactivity)

### 4. **Personalized Meditation Journeys**

- **Location**: Horizontal scrollable carousel after mood card
- **Display**: Journey cards showing progress (e.g., "7-Day Sleep Reset")
- **Interaction**: Tap to view journey details and continue
- **Visual**: Progress ring, current day indicator, completion badges

### 5. **Ambient Sound Customization**

- **Location**: Integrated into existing meditation cards
- **Display**: Small sound icon on each meditation card
- **Interaction**: Tap icon for sound mixer (rain, ocean, forest, etc.)
- **Implementation**: Sound layer overlay system

## Home Screen Layout Structure

```
┌─────────────────────────────────────┐
│  Header (App Logo + Profile/About) │
├─────────────────────────────────────┤
│  🔥 Streak Card (3D elevated card)  │
│  "5 Day Streak! Keep it going!"    │
│  [Share Button]                     │
├─────────────────────────────────────┤
│  😊 Today's Mood + Trend Chart      │
│  [Happy] [Calm] [Anxious] [Tired]  │
├─────────────────────────────────────┤
│  📚 Your Journeys (Horizontal)      │
│  [Journey Card 1] [Journey Card 2]  │
├─────────────────────────────────────┤
│  Section Tabs [Breathwork|Guided]   │
├─────────────────────────────────────┤
│                                     │
│  Scrollable Meditation Grid         │
│  (Existing breathwork/guided med)   │
│  Each card now has 🔊 sound icon    │
│                                     │
└─────────────────────────────────────┘
                                    [FAB]
                                    Quick
                                    Start
```

## UI Components Breakdown

### Hero Streak Card

```dart
- Gradient background (primary color fade)
- Large streak number with flame animation
- Motivational message
- Social share button
- Tap for detailed analytics
- Shimmer effect on milestone days
```

### Mood Tracker Widget

```dart
- Compact horizontal emoji selector
- Mini line chart (last 7 days)
- Color-coded mood states
- Smooth emoji transitions
- Haptic feedback on selection
```

### Journey Carousel

```dart
- Horizontal PageView with snap
- Card design: Image + Title + Progress
- Circular progress indicator
- "Continue" or "Start" button
- Swipe indicator dots
```

### Enhanced Meditation Cards

```dart
- Existing card design maintained
- Added: Sound icon (top-right corner)
- Added: "Last played" indicator
- Added: Quick favorite star
- Tap sound icon → Sound mixer sheet
```

### Quick Session FAB

```dart
- Large circular button (64x64)
- Gradient fill matching theme
- Play icon with subtle rotation
- Pulsing animation on idle
- Haptic feedback
- Long press → Quick menu
```

## Color Scheme Enhancements

- **Streak Fire**: Orange gradient (#FF6B35 → #F7931E)
- **Mood Happy**: Yellow (#FFD700)
- **Mood Calm**: Blue (#4A90E2)
- **Mood Anxious**: Purple (#9B59B6)
- **Mood Tired**: Gray (#95A5A6)
- **Journey Progress**: Green gradient (#00C853 → #64DD17)

## Animation & Interactions

### Micro-interactions

1. **Streak Card**: Flame flickers on tap, confetti on milestone
2. **Mood Selection**: Emoji bounces, haptic feedback
3. **Journey Card**: Progress ring fills smoothly
4. **FAB**: Pulsing glow, expands on press
5. **Sound Icon**: Ripple effect on tap

### Page Transitions

- Fade + slide animations between sections
- Parallax scroll for header
- Stagger animation for grid items

## Implementation Phases

### Phase 1: UI Structure (This Phase)

- Create placeholder widgets
- Implement new layout structure
- Add navigation skeleton
- Design system updates

### Phase 2: Data Layer (Future)

- Database schema for mood, streaks, journeys
- Service layer for analytics
- Local storage for preferences

### Phase 3: Feature Implementation (Future)

- Mood tracking logic
- Streak calculation system
- Journey progression engine
- Sound mixing functionality
- Social sharing integration

### Phase 4: Polish (Future)

- Animation refinements
- Performance optimization
- A/B testing different layouts
- User feedback integration

## Technical Considerations

### State Management

- Provider for global state (streaks, mood, journeys)
- Local state for UI animations
- Cached data for offline support

### Performance

- Lazy loading for journey images
- Virtualized scrolling for meditation grid
- Optimized animations (60 FPS target)
- Image caching strategy

### Accessibility

- Screen reader support for all new widgets
- High contrast mode support
- Semantic labels for interactive elements
- Keyboard navigation support

## Dependencies to Add

```yaml
fl_chart: ^0.68.0 # For mood trend charts
share_plus: ^7.2.2 # For social sharing
shimmer: ^3.0.0 # For loading states
lottie: ^3.1.0 # For advanced animations
confetti: ^0.7.0 # For celebration effects
```

## File Structure for New Components

```
lib/
├── widgets/
│   ├── home/
│   │   ├── streak_card.dart
│   │   ├── mood_tracker_widget.dart
│   │   ├── journey_carousel.dart
│   │   ├── quick_session_fab.dart
│   │   └── enhanced_meditation_card.dart
│   └── shared/
│       └── mood_chart.dart
├── models/
│   ├── mood_entry.dart
│   ├── streak_data.dart
│   └── meditation_journey.dart
├── services/
│   ├── mood_service.dart
│   ├── streak_service.dart
│   ├── journey_service.dart
│   └── analytics_service.dart
└── screens/
    └── home/
        └── new_home_screen.dart
```

## Next Steps

1. ✅ Create this architecture document
2. Create placeholder widgets
3. Implement new home screen layout
4. Add navigation structure
5. Polish with animations
6. Get user feedback on UI
7. Implement backend features iteratively

---

**Note**: This redesign maintains backward compatibility with existing features while providing a foundation for future enhancements. All new features start as placeholders with polished UI, ready for backend implementation.
