# Video Call Feature Documentation

## Overview

The DocSync app now includes video calling functionality using Agora RTC Engine, enabling patients to have video consultations with doctors directly from the app.

## Features

### 1. **Scheduled Video Calls**

- Patients can see upcoming video consultations on the home page
- Join button becomes active 15 minutes before scheduled time
- Button shows countdown timer when more than 15 minutes away
- Can join up to 30 minutes after scheduled time
- Supports video, audio, and chat consultation types

### 2. **Instant Video Calls**

- Available doctors can be called instantly from the Consult page
- Real-time availability status shown for each doctor

### 3. **Video Call Controls**

- Toggle microphone on/off
- Toggle camera on/off
- Switch between front and back camera
- End call button

### 4. **Call States**

- Connecting
- Connected
- Reconnecting (on network issues)
- Disconnected
- Error handling

## Technical Implementation

### Agora Configuration

All Agora configuration is stored securely in the `.env` file:

```properties
AGORA_APP_ID=1b4252ea1e424682b0e7af5d512b2c8f
AGORA_CHANNEL_NAME=DocSync
AGORA_TOKEN=007eJxTYKi5MIdz8rYuz1SRY+lXDnOtdf0xf6lzptcpgdcrqhqt7DgVGAyTTIxMjVITDVNNjEzMLIySDFLNE9NMU0wNjZKMki3S/k54n9EQyMigqnOUkZEBAkF8dgaX/OTgyrxkBgYAs3ggsA==
```

The configuration is loaded at runtime from environment variables using `flutter_dotenv`.

### Dependencies Added

```yaml
agora_rtc_engine: ^6.3.2
permission_handler: ^11.3.1
```

### Architecture

#### Core Configuration

- `lib/core/config/agora_config.dart` - Agora SDK configuration

#### Video Call Feature Structure

```
lib/features/video_call/
├── domain/
│   └── models/
│       └── call_state.dart          # Call states and VideoCallInfo model
├── data/
│   └── services/
│       └── agora_service.dart       # Agora SDK integration
└── presentation/
    ├── pages/
    │   └── video_call_page.dart     # Main video call UI
    ├── providers/
    │   └── video_call_provider.dart # State management
    └── widgets/
        ├── video_call_controls.dart # Call control buttons
        └── video_call_status.dart   # Connection status overlay
```

## Usage

### From Home Page

1. View upcoming scheduled consultations
2. Click "Join Video Call" when available (15 minutes before scheduled time)
3. Video call screen opens automatically

### From Consult Page

1. Browse available doctors
2. Click "Call Now" for doctors showing "Available" status
3. Instant video call is initiated

### During a Call

- **Mute/Unmute**: Toggle microphone
- **Camera On/Off**: Toggle video
- **Switch Camera**: Switch between front and rear camera
- **End Call**: Disconnect from the call

## Permissions

### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```

### iOS (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera for video calls with doctors</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for video calls with doctors</string>
```

## Database Integration

The video call feature integrates with the `consultations` table in Supabase:

```sql
-- Relevant fields
consultation_type: 'video' | 'audio' | 'chat'
scheduled_time: timestamptz
consultation_status: 'scheduled' | 'completed' | 'canceled'
```

## Future Enhancements

1. **Call Recording** - Record consultations for medical records
2. **Screen Sharing** - Share medical reports during calls
3. **Multi-party Calls** - Include specialists or family members
4. **Call Quality Indicators** - Show network quality
5. **Waiting Room** - Queue system for doctor availability
6. **Call History** - View past video consultations
7. **Chat Integration** - Text chat during video calls
8. **Call Scheduling** - Schedule calls directly from the app

## Troubleshooting

### Common Issues

1. **Camera/Microphone Permission Denied**

   - Solution: Check app permissions in device settings

2. **Connection Failed**

   - Solution: Check internet connection and Agora credentials

3. **No Video Visible**

   - Solution: Ensure camera is not being used by another app

4. **Audio Issues**
   - Solution: Check microphone permissions and device audio settings

## Testing

### Test Scenarios

1. Join a scheduled call
2. Make an instant call
3. Toggle microphone during call
4. Toggle camera during call
5. Switch camera
6. End call
7. Handle network interruption
8. Handle permission denial

## Installation & Setup

1. Install dependencies:

```bash
flutter pub get
```

2. For Android, ensure minimum SDK version is 21+ in `android/app/build.gradle`

3. Run the app:

```bash
flutter run
```

## Security Notes

⚠️ **Important**: The current implementation uses a hardcoded Agora token. For production:

- Implement token generation on the backend
- Use secure token storage
- Implement token refresh mechanism
- Add user authentication validation

## Support

For issues or questions related to video calling:

- Check Agora documentation: https://docs.agora.io/
- Review Flutter integration guide: https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter
