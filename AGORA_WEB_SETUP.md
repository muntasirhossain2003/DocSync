# Agora Web SDK Integration Guide

## Overview

Added Agora Web SDK support to enable video calling in web browsers (Chrome, Edge, Firefox, Safari).

## Changes Made

### 1. Updated `web/index.html`

Added two script tags before the closing `</head>` tag:

```html
<!-- Agora Web SDK -->
<script src="https://download.agora.io/sdk/release/AgoraRTC_N-4.21.0.js"></script>
<!-- Agora Iris Web SDK for Flutter integration -->
<script src="https://download.agora.io/sdk/release/iris_4.3.2-build.2_DCG_Web_Video_Live.js"></script>
```

**What these do:**

- `AgoraRTC_N-4.21.0.js` - Core Agora Web RTC SDK
- `iris_4.3.2-build.2_DCG_Web_Video_Live.js` - Bridge between Flutter and Agora Web SDK

## How to Test

### 1. Run on Chrome

```bash
flutter run -d chrome
```

### 2. Run on Edge

```bash
flutter run -d edge
```

### 3. Build for Web

```bash
flutter build web
```

## Browser Compatibility

### Fully Supported

- ✅ Chrome 58+
- ✅ Edge 79+
- ✅ Firefox 56+
- ✅ Safari 11+

### Partially Supported

- ⚠️ Mobile browsers (iOS Safari, Chrome Mobile) - may have limitations

### Not Supported

- ❌ Internet Explorer

## Important Notes

### Camera/Microphone Permissions

**Web browsers require HTTPS for camera/microphone access!**

#### For Development (localhost)

- `localhost` is treated as secure by browsers
- Permissions will work without HTTPS
- Use: `flutter run -d chrome --web-port=8080`

#### For Production/Testing on Network

You need HTTPS! Options:

1. **Use ngrok (easiest for testing)**

   ```bash
   # Install ngrok
   # Run your app
   flutter run -d chrome --web-port=8080

   # In another terminal
   ngrok http 8080

   # Use the HTTPS URL provided by ngrok
   ```

2. **Use self-signed certificate**

   ```bash
   flutter run -d chrome --web-port=8080 --web-renderer html
   ```

3. **Deploy to hosting with HTTPS** (Firebase, Vercel, Netlify, etc.)

### Known Limitations on Web

1. **Screen Sharing** - Limited on some browsers
2. **Background Mode** - May pause when tab is inactive
3. **Performance** - Slightly lower than native apps
4. **Network Requirements** - More sensitive to network quality

## Troubleshooting

### Issue: "Cannot read properties of undefined"

**Solution:** Make sure the script tags are loaded before Flutter initializes.
The scripts are now in the `<head>` section which ensures they load first.

### Issue: Camera/Microphone not working

**Solutions:**

1. Check browser permissions (click lock icon in address bar)
2. Make sure you're on `localhost` or HTTPS
3. Check browser console for permission errors
4. Try running: `flutter run -d chrome --web-hostname localhost`

### Issue: "TypeError: Cannot read properties of undefined (reading 'createIrisApiEngine')"

**This was the original error - now fixed!**

The error occurred because:

1. Iris Web SDK wasn't loaded
2. Scripts needed to be in HTML head

**Now fixed by adding scripts to `web/index.html`**

### Issue: Video freezes or connection drops

**Solutions:**

1. Check internet connection
2. Reduce video quality in Agora config
3. Check browser console for WebRTC errors
4. Try different browser

### Issue: Echo or audio feedback

**Solutions:**

1. Use headphones
2. Lower speaker volume
3. Enable echo cancellation in browser settings

## Testing Checklist

- [ ] Camera permission granted
- [ ] Microphone permission granted
- [ ] Video appears in local preview
- [ ] Can join channel successfully
- [ ] Remote user video appears
- [ ] Audio is working both ways
- [ ] Mute button works
- [ ] Camera toggle works
- [ ] Screen sharing works (if enabled)
- [ ] Call ends properly

## Browser DevTools Debugging

### Chrome DevTools

1. Open DevTools (F12)
2. Go to Console tab - check for errors
3. Go to Network tab - check WebRTC connections
4. Go to Application > Permissions - check camera/mic access

### Check WebRTC Status

1. Chrome: `chrome://webrtc-internals/`
2. Edge: `edge://webrtc-internals/`
3. Firefox: `about:webrtc`

This shows real-time connection stats, ice candidates, and stream information.

## Performance Optimization

### For Better Performance on Web:

1. **Reduce Video Quality**

   ```dart
   // In agora_service.dart
   await _engine.setVideoEncoderConfiguration(
     const VideoEncoderConfiguration(
       dimensions: VideoDimensions(width: 640, height: 480), // Lower resolution
       frameRate: 15, // Lower framerate
       bitrate: 400, // Lower bitrate
     ),
   );
   ```

2. **Disable Beauty Filters** (if any)
   Beauty effects are resource-intensive on web

3. **Use Audio-Only Mode** (optional)
   Less bandwidth and CPU usage

## Production Deployment

### Build for Production

```bash
flutter build web --release
```

### Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Deploy to GitHub Pages

```bash
flutter build web --release --base-href "/DocSync/"
# Copy build/web/* to gh-pages branch
```

## Security Notes

### Never Expose Agora Credentials

- ✅ Use environment variables (.env file)
- ✅ Generate tokens server-side in production
- ❌ Don't hardcode App ID or token in code
- ❌ Don't commit .env file to git

### Token Generation (Production)

```dart
// Backend endpoint
POST /api/generate-agora-token
{
  "channelName": "consultation_123",
  "uid": 12345,
  "role": "publisher"
}

// Response
{
  "token": "006abc...xyz",
  "expiresAt": "2025-10-16T10:30:00Z"
}
```

## Monitoring & Analytics

### Track Video Call Metrics

```dart
// Listen to quality stats
_engine.onRtcStats = (RtcConnection connection, RtcStats stats) {
  print('Call duration: ${stats.duration}');
  print('Users in call: ${stats.userCount}');
  print('Packet loss: ${stats.txPacketLossRate}%');
};
```

### Common Metrics to Track

- Call duration
- Connection quality
- Packet loss rate
- Bitrate
- Frame rate
- User count

## Resources

### Official Documentation

- Agora Web SDK: https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=web
- Agora Flutter Plugin: https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter
- WebRTC Standards: https://webrtc.org/

### Example Apps

- Agora Flutter Examples: https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK
- Web Demo: https://webdemo.agora.io/

### Community

- Agora Developer Community: https://www.agora.io/en/community/
- Stack Overflow: Tag `agora.io`

## Version Information

- Agora RTC Engine (Flutter): 6.3.2
- Agora Web SDK: 4.21.0
- Iris Web SDK: 4.3.2-build.2
- Flutter SDK: 3.9.0+
- Dart SDK: 3.9.0+

## Next Steps

1. ✅ Scripts added to web/index.html
2. 🔄 Test on Chrome - Run: `flutter run -d chrome`
3. 🔄 Grant camera/microphone permissions
4. 🔄 Test video call with another user
5. ⏭️ Deploy to production with HTTPS
6. ⏭️ Implement server-side token generation

---

**Status: Web support is now configured! Ready to test.** 🎉
