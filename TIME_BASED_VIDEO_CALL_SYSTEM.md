# Time-Based Video Call Availability System

## Overview

Implemented a comprehensive time-based video call availability system that allows users to join video consultations only within a specific 30-minute window starting from the scheduled time.

## System Behavior

### ⏰ Time Windows

1. **Before Scheduled Time**: Video call button shows "Available in Xm/Xh/Xd"
2. **During 30-Minute Window**: Video call button shows "Join Call (Xm left)" and is clickable
3. **After 30-Minute Window**: Consultation automatically removed from upcoming schedule

### 🔄 Real-Time Updates

- **Auto-refresh every 60 seconds** for consultation list updates
- **Button updates every 30 seconds** for precise countdown timing
- **Automatic expiration** of consultations past the 30-minute window
- **Manual refresh** available via pull-to-refresh

## Implementation Details

### 1. Enhanced Consultation Model

**File**: `lib/features/home/presentation/providers/consultation_provider.dart`

**New Properties Added**:

```dart
class ConsultationWithDoctor {
  // Time-based availability checking
  bool get isVideoCallAvailable
  bool get shouldBeRemoved
  Duration? get timeUntilAvailable
  Duration? get timeRemainingInWindow
  String get callStatusText
}
```

**Key Methods**:

- `isVideoCallAvailable`: Checks if current time is within the 30-minute window
- `shouldBeRemoved`: Determines if consultation should be removed (>30 min past scheduled time)
- `callStatusText`: Returns user-friendly status text with countdown

### 2. Database Auto-Expiration

**Automatic Cleanup Process**:

```dart
// Updates consultations older than 30 minutes to 'completed' status
final expiredTime = DateTime.now()
    .toUtc()
    .subtract(const Duration(minutes: 30))
    .toIso8601String();

await supabase
    .from('consultations')
    .update({'consultation_status': 'completed'})
    .eq('consultation_status', 'scheduled')
    .lt('scheduled_time', expiredTime);
```

**Triggers**:

- Manual refresh (pull-to-refresh)
- App startup
- Timer-based background updates

### 3. Real-Time UI Updates

**Timer-Based Refresh System**:

```dart
// Main consultation list refreshes every minute
Timer.periodic(const Duration(minutes: 1), (timer) {
  if (mounted) {
    ref.invalidate(upcomingConsultationsProvider);
  }
});

// Individual buttons update every 30 seconds
Timer.periodic(const Duration(seconds: 30), (timer) {
  if (mounted) {
    setState(() {}); // Triggers rebuild with updated calculations
  }
});
```

## User Experience Flow

### 📅 Before Scheduled Time

```
[🕐 Schedule] Dr. Smith - Cardiology
Available in 2h 15m
```

- Button disabled and shows countdown
- Icon: `Icons.schedule`
- Background: Grayed out

### ⚡ During Active Window (0-30 minutes)

```
[📹 Join Call] Dr. Smith - Cardiology
Join Call (25m left)
```

- Button enabled and pulsing/highlighted
- Icon: `Icons.video_call`
- Background: Bright white/colored
- Real-time countdown of remaining window

### ❌ After Window Expires

- Consultation automatically removed from list
- No longer appears in upcoming schedule
- Database status updated to 'completed'

## Technical Architecture

### 🏗️ Provider Structure

```dart
// Main data provider with time-based filtering
upcomingConsultationsProvider → FutureProvider<List<ConsultationWithDoctor>>

// Real-time updates (optional enhancement)
realTimeConsultationsProvider → StreamProvider<List<ConsultationWithDoctor>>
```

### 📊 Database Integration

- **Consultation Status Values**: `scheduled`, `in_progress`, `completed`, `canceled`
- **Time Filtering**: Server-side filtering excludes consultations older than 30 minutes
- **Auto-Expiration**: Background process updates expired consultations

### 🎨 UI Components

1. **UpcomingScheduleSection**: Main container with minute-based refresh timer
2. **AppointmentCard**: Individual consultation display
3. **RealTimeCallButton**: Button with 30-second update cycle for precise timing

## Configuration

### ⏱️ Time Windows (Customizable)

```dart
// Current settings - can be modified as needed
const int CALL_AVAILABILITY_MINUTES = 30;  // Window duration
const int UI_REFRESH_SECONDS = 30;          // Button update frequency
const int DATA_REFRESH_MINUTES = 1;         // Consultation list refresh
```

### 🔧 Customization Options

- **Window Duration**: Change from 30 minutes to any desired timeframe
- **Early Join**: Allow joining X minutes before scheduled time
- **Grace Period**: Extend window for late joiners
- **Refresh Frequency**: Adjust update intervals for performance

## Error Handling

### 🛡️ Robustness Features

- **Network Failures**: Graceful degradation with cached data
- **Timer Management**: Proper cleanup to prevent memory leaks
- **State Consistency**: Multiple validation layers for time calculations
- **Timezone Handling**: All calculations in UTC for consistency

### 📱 Offline Behavior

- Cached consultation data remains available
- Time calculations continue working offline
- Sync occurs when connection restored

## Performance Optimizations

### ⚡ Efficiency Measures

1. **Smart Refresh**: Only refresh when data might have changed
2. **Selective Updates**: Individual button timers vs full list refresh
3. **Background Processing**: Auto-expiration runs separately from UI
4. **Debounced Updates**: Prevents excessive database calls

### 💾 Memory Management

- **Timer Cleanup**: All timers properly disposed
- **State Management**: Efficient provider invalidation
- **Widget Lifecycle**: Proper mounting checks before updates

## Future Enhancements

### 🚀 Potential Additions

1. **Push Notifications**: Alert users when video call becomes available
2. **Queue System**: Handle multiple patients for same time slot
3. **Flexible Windows**: Doctor-configurable availability windows
4. **Analytics**: Track join patterns and optimize timing
5. **Reminder System**: Automated reminders before consultations

### 🔮 Advanced Features

- **Smart Scheduling**: AI-powered optimal time suggestions
- **Conflict Resolution**: Automatic rescheduling for overlapping appointments
- **Multi-timezone Support**: Global patient base considerations
- **Backup Doctors**: Automatic fallback if primary doctor unavailable

## Testing Scenarios

### ✅ Validation Cases

1. **Time Boundary Testing**: Exact moment video becomes available/unavailable
2. **Timezone Edge Cases**: Different user timezones vs server time
3. **Network Interruptions**: App behavior during connectivity issues
4. **Rapid State Changes**: Multiple consultations with overlapping windows
5. **Background/Foreground**: App state changes during active consultation window

### 🧪 Test Data Setup

```dart
// Example test consultations
- Consultation A: Scheduled for now + 2 hours (should show countdown)
- Consultation B: Scheduled for now - 15 minutes (should allow joining)
- Consultation C: Scheduled for now - 45 minutes (should be auto-removed)
```

## Monitoring & Analytics

### 📈 Key Metrics

- **Join Rate**: Percentage of scheduled consultations actually joined
- **Join Timing**: When users typically join within the 30-minute window
- **Expiration Rate**: How many consultations expire without being joined
- **UI Performance**: Timer update performance and battery impact

### 🔍 Debug Information

- Real-time logging of time calculations
- Provider refresh events
- Database auto-expiration runs
- UI update cycles

This system ensures that video consultations are only available when appropriate, automatically manages the consultation lifecycle, and provides users with clear, real-time feedback about availability status.
