# WindChime Home Screen Redesign - Implementation Roadmap

## Executive Summary

This document provides a step-by-step implementation guide for the WindChime home screen redesign, incorporating:

- 🔥 Meditation Streaks with Social Sharing
- 😊 Mood Tracking Dashboard
- 🎵 Ambient Sound Customization
- ⚡ Quick Session Button
- 📚 Personalized Meditation Journeys

**Approach**: Build UI-first with placeholders, then progressively enhance with backend functionality.

---

## Phase 1: UI Foundation (Week 1-2) - CURRENT PHASE

### Goal

Create a beautiful, functional UI with placeholder data to visualize the new design.

### Tasks

#### 1.1 Create Placeholder Widgets

- [ ] [`lib/widgets/home/streak_card_widget.dart`](lib/widgets/home/streak_card_widget.dart)

  - Display mock streak data (5 days)
  - Share button (shows toast: "Coming soon!")
  - Flame animation using Lottie or custom animation
  - Tap to navigate to placeholder analytics screen

- [ ] [`lib/widgets/home/mood_tracker_widget.dart`](lib/widgets/home/mood_tracker_widget.dart)

  - 5 mood emoji buttons (Happy, Calm, Anxious, Tired, Neutral)
  - Mock line chart using fl_chart package
  - Haptic feedback on mood selection
  - Shows toast with selected mood

- [ ] [`lib/widgets/home/journey_carousel_widget.dart`](lib/widgets/home/journey_carousel_widget.dart)

  - Horizontal PageView with 3 sample journeys
  - Progress indicators (circles)
  - "Start" or "Continue" buttons
  - Sample data: "7-Day Sleep Reset", "Stress Relief Path", "Focus Mastery"

- [ ] [`lib/widgets/home/quick_session_fab.dart`](lib/widgets/home/quick_session_fab.dart)

  - Floating Action Button with gradient
  - Pulsing animation (AnimatedBuilder)
  - Play icon
  - Tap to show dialog with quick meditation options
  - Long press for expanded menu (future)

- [ ] [`lib/widgets/home/enhanced_meditation_card.dart`](lib/widgets/home/enhanced_meditation_card.dart)
  - Extend existing meditation card
  - Add sound icon (top-right corner)
  - Add favorite star (bottom-left)
  - Add "Last played" timestamp
  - Sound icon shows placeholder bottom sheet

#### 1.2 Update Home Screen Layout

- [ ] [`lib/screens/home/redesigned_home_screen.dart`](lib/screens/home/redesigned_home_screen.dart)
  - Create new file (keep old one for comparison)
  - Implement scrollable column layout:
    1. Header (existing)
    2. Streak Card
    3. Mood Tracker
    4. Journey Carousel
    5. Section Tabs (existing)
    6. Meditation Grid (existing with enhancements)
  - Add Quick Session FAB
  - Stagger animations on load

#### 1.3 Dependencies Update

- [ ] Update [`pubspec.yaml`](pubspec.yaml):
  ```yaml
  dependencies:
    fl_chart: ^0.68.0 # Mood trend charts
    share_plus: ^7.2.2 # Social sharing
    lottie: ^3.1.0 # Animations
  ```

#### 1.4 Create Placeholder Screens

- [ ] [`lib/screens/analytics/streak_analytics_screen.dart`](lib/screens/analytics/streak_analytics_screen.dart)

  - Show detailed streak history
  - Calendar view with meditation days highlighted
  - Achievements/badges section
  - Placeholder data

- [ ] [`lib/screens/mood/mood_analytics_screen.dart`](lib/screens/mood/mood_analytics_screen.dart)

  - Detailed mood trends (weekly, monthly)
  - Mood correlations with meditation types
  - Insights and patterns
  - Placeholder charts

- [ ] [`lib/screens/journeys/journey_detail_screen.dart`](lib/screens/journeys/journey_detail_screen.dart)
  - Journey overview and description
  - Day-by-day breakdown
  - Progress tracking
  - Start/Continue button

**Deliverable**: Fully functional UI with placeholder data. Users can interact with all new features visually, even though backend isn't connected yet.

**Time Estimate**: 8-12 hours

---

## Phase 2: Data Layer (Week 3-4)

### Goal

Implement database schema and services for new features.

### Tasks

#### 2.1 Database Schema Updates

- [ ] Update [`lib/data/db_helper.dart`](lib/data/db_helper.dart):

  ```sql
  -- Mood tracking table
  CREATE TABLE mood_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    mood TEXT NOT NULL,
    note TEXT,
    session_id INTEGER,
    FOREIGN KEY (session_id) REFERENCES meditation_sessions(id)
  );

  -- Streak data table
  CREATE TABLE streak_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    streak_count INTEGER NOT NULL,
    is_current_streak INTEGER DEFAULT 1
  );

  -- Journey progress table
  CREATE TABLE journey_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    journey_id TEXT NOT NULL,
    current_day INTEGER DEFAULT 0,
    completed INTEGER DEFAULT 0,
    started_date TEXT NOT NULL,
    completed_date TEXT
  );

  -- Sound preferences table
  CREATE TABLE sound_preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    meditation_type TEXT NOT NULL,
    sound_mix TEXT NOT NULL,
    created_date TEXT NOT NULL
  );
  ```

#### 2.2 Create Data Models

- [ ] [`lib/models/mood_entry.dart`](lib/models/mood_entry.dart)
- [ ] [`lib/models/streak_data.dart`](lib/models/streak_data.dart)
- [ ] [`lib/models/meditation_journey.dart`](lib/models/meditation_journey.dart)
- [ ] [`lib/models/sound_preset.dart`](lib/models/sound_preset.dart)

#### 2.3 Create Service Layer

- [ ] [`lib/services/mood_service.dart`](lib/services/mood_service.dart)

  - saveMood(mood, note, sessionId)
  - getMoodHistory(startDate, endDate)
  - getMoodStats()
  - getMoodTrends()

- [ ] [`lib/services/streak_service.dart`](lib/services/streak_service.dart)

  - getCurrentStreak()
  - updateStreak(date)
  - getStreakHistory()
  - checkMilestone()

- [ ] [`lib/services/journey_service.dart`](lib/services/journey_service.dart)

  - getAvailableJourneys()
  - startJourney(journeyId)
  - updateProgress(journeyId, day)
  - getActiveJourneys()
  - completeJourney(journeyId)

- [ ] [`lib/services/sound_service.dart`](lib/services/sound_service.dart)
  - saveSoundPreset(meditationType, soundMix)
  - getSoundPreset(meditationType)
  - playAmbientSounds(soundMix)

#### 2.4 Create Providers for State Management

- [ ] [`lib/providers/streak_provider.dart`](lib/providers/streak_provider.dart)
- [ ] [`lib/providers/mood_provider.dart`](lib/providers/mood_provider.dart)
- [ ] [`lib/providers/journey_provider.dart`](lib/providers/journey_provider.dart)

**Deliverable**: Fully functional backend with real data persistence.

**Time Estimate**: 12-16 hours

---

## Phase 3: Feature Integration (Week 5-6)

### Goal

Connect UI to backend services and implement core functionality.

### Tasks

#### 3.1 Mood Tracking Integration

- [ ] Connect mood selector to [`MoodService`](lib/services/mood_service.dart)
- [ ] Save mood after each meditation session
- [ ] Display real mood trends in chart
- [ ] Implement mood analytics screen

#### 3.2 Streak System Integration

- [ ] Calculate daily streaks based on session history
- [ ] Update streak automatically after sessions
- [ ] Show achievement notifications on milestones
- [ ] Implement calendar view in analytics

#### 3.3 Journey System Integration

- [ ] Load predefined journey data
- [ ] Track user progress through journeys
- [ ] Unlock next day after session completion
- [ ] Show completion celebrations

#### 3.4 Quick Session Implementation

- [ ] Implement smart session suggestions (time-based)
- [ ] Store last used meditation preference
- [ ] Add quick start logic to FAB
- [ ] Create quick menu for session types

#### 3.5 Sound Mixer Integration

- [ ] Implement multi-track audio player
- [ ] Create sound mixing UI in bottom sheet
- [ ] Save/load sound presets
- [ ] Volume control for each ambient sound

**Deliverable**: Fully functional features with real data.

**Time Estimate**: 16-20 hours

---

## Phase 4: Social & Analytics (Week 7-8)

### Goal

Add social sharing and advanced analytics features.

### Tasks

#### 4.1 Social Sharing

- [ ] Implement Share Plus integration
- [ ] Design shareable streak images
- [ ] Create achievement cards for sharing
- [ ] Add social media templates
- [ ] Privacy settings for sharing

#### 4.2 Advanced Analytics

- [ ] Build comprehensive analytics dashboard
- [ ] Meditation heatmap calendar
- [ ] Time of day analysis
- [ ] Meditation type preferences
- [ ] Mood correlation insights
- [ ] Export data functionality

#### 4.3 Journey Customization

- [ ] Allow users to create custom journeys
- [ ] Journey templates
- [ ] Journey sharing (future consideration)
- [ ] Personalized recommendations

**Deliverable**: Complete social and analytics features.

**Time Estimate**: 12-16 hours

---

## Phase 5: Polish & Optimization (Week 9-10)

### Goal

Refine animations, performance, and user experience.

### Tasks

#### 5.1 Animation Refinement

- [ ] Fine-tune all micro-interactions
- [ ] Add celebration animations (confetti, badges)
- [ ] Improve page transitions
- [ ] Test on various devices

#### 5.2 Performance Optimization

- [ ] Implement image caching
- [ ] Optimize database queries
- [ ] Lazy load journey images
- [ ] Reduce widget rebuilds
- [ ] Test on low-end devices

#### 5.3 Accessibility Improvements

- [ ] Add comprehensive screen reader support
- [ ] Test with TalkBack/VoiceOver
- [ ] Ensure keyboard navigation
- [ ] High contrast mode testing
- [ ] Large text support verification

#### 5.4 User Testing & Feedback

- [ ] Beta testing with select users
- [ ] Gather feedback on new features
- [ ] A/B test different layouts
- [ ] Iterate based on feedback

**Deliverable**: Production-ready, polished app.

**Time Estimate**: 8-12 hours

---

## Implementation Strategy

### Parallel Development

While Phase 1 is being reviewed by stakeholders, start on Phase 2 (data layer) to maintain momentum.

### Testing Strategy

- Unit tests for services
- Widget tests for new components
- Integration tests for user flows
- Manual testing on iOS and Android

### Git Workflow

```
main
  ├── feature/ui-redesign-phase1
  ├── feature/data-layer-phase2
  ├── feature/integration-phase3
  ├── feature/social-analytics-phase4
  └── feature/polish-phase5
```

### Rollout Plan

1. **Internal Testing**: Phases 1-2 (UI + Backend)
2. **Beta Release**: Phase 3 (Features)
3. **Staged Rollout**: Phases 4-5 (25% → 50% → 100%)

---

## Risk Mitigation

### Technical Risks

| Risk                               | Mitigation                                           |
| ---------------------------------- | ---------------------------------------------------- |
| Performance issues with animations | Profile early, use const widgets, optimize rebuilds  |
| Database migration failures        | Thorough testing, backup strategy, version checks    |
| Sound mixing complexity            | Use proven audio packages, fallback to simple sounds |
| Chart rendering lag                | Use lightweight chart library, implement caching     |

### User Experience Risks

| Risk                    | Mitigation                                            |
| ----------------------- | ----------------------------------------------------- |
| Feature overload        | Gradual onboarding, tooltips, progressive disclosure  |
| Streak pressure/anxiety | Gentle language, "rest days" concept, no punishment   |
| Complex journey system  | Clear instructions, simple first journey, skip option |

---

## Success Metrics

### Phase 1 Success Criteria

- [ ] All placeholder widgets render correctly
- [ ] Smooth animations at 60 FPS
- [ ] No crashes or errors
- [ ] Positive stakeholder feedback

### Overall Success Metrics (Post-Launch)

- **Engagement**: 30% increase in daily active users
- **Retention**: 20% improvement in 7-day retention
- **Session Length**: 15% increase in average session duration
- **Feature Adoption**: 50%+ users try new features within first week
- **Mood Tracking**: 40%+ of sessions include mood logging
- **Streaks**: 30%+ users maintain 7+ day streaks

---

## Next Immediate Steps

### For Code Mode Implementation

1. Install required dependencies (fl_chart, share_plus, lottie)
2. Create widget directory structure
3. Build StreakCardWidget first (highest visual impact)
4. Build MoodTrackerWidget second
5. Build JourneyCarousel third
6. Build QuickSessionFAB fourth
7. Integrate all into new home screen
8. Add routing for placeholder screens

### Resources Needed

- Lottie animation files for flame/celebrations
- Sample journey images (3 journeys)
- Icon assets for mood states
- Ambient sound files (ocean, rain, forest, fire)

---

## Conclusion

This roadmap provides a clear path from concept to production. The phased approach allows for:

- **Quick wins**: Beautiful UI in Phase 1
- **Solid foundation**: Robust backend in Phase 2
- **User value**: Working features in Phase 3
- **Differentiation**: Unique social/analytics in Phase 4
- **Excellence**: Polish in Phase 5

Each phase builds on the previous, allowing for iterative feedback and course correction.

**Ready to implement?** Start with Phase 1, Task 1.1 in Code mode! 🚀
