# Agora Web SDK Loading Order Fix

## Problem

The app was showing "Connection Error" with this error in the console:

```
TypeError: Cannot read properties of undefined (reading 'createIrisApiEngine')
```

## Root Cause

The Agora Web SDK scripts were placed in the `<head>` section and Flutter's bootstrap script was loading with `async` attribute. This caused a **race condition**:

1. Flutter bootstrap loads asynchronously
2. Flutter app starts initializing
3. Video call tries to initialize Agora
4. **Agora SDKs haven't finished loading yet** → Error!

## Solution

Moved Agora SDK scripts to the `<body>` section **before** the Flutter bootstrap script:

```html
<body>
  <!-- Load Agora SDKs first (synchronously) -->
  <script src="https://download.agora.io/sdk/release/AgoraRTC_N-4.21.0.js"></script>
  <script src="https://download.agora.io/sdk/release/iris_4.3.2-build.2_DCG_Web_Video_Live.js"></script>

  <!-- Then load Flutter (after Agora is ready) -->
  <script src="flutter_bootstrap.js" async></script>
</body>
```

### Why This Works

1. **Scripts in `<body>` load sequentially** - Browser loads them in order
2. **Agora SDK loads completely** before Flutter starts
3. **When Flutter initializes**, `AgoraRTC` and `IrisWebRtc` are already available
4. **No more race condition** → Video calling works!

## Additional Improvements

Added a verification script to check SDK loading:

```javascript
window.addEventListener("load", function () {
  if (typeof AgoraRTC !== "undefined" && typeof IrisWebRtc !== "undefined") {
    console.log("✅ Agora Web SDKs loaded successfully");
  } else {
    console.error("❌ Agora Web SDKs failed to load");
  }
});
```

## Testing

1. **Check browser console** - Should see "✅ Agora Web SDKs loaded successfully"
2. **Join a video call** - Should connect without "Connection Error"
3. **No more `createIrisApiEngine` error**

## Browser Compatibility

- ✅ Chrome/Edge/Brave (Chromium-based)
- ✅ Firefox
- ✅ Safari 12+

## Important Notes

- **Always load Agora SDKs before Flutter** on web platform
- **Don't use `defer` or `async`** on Agora SDK script tags
- **HTTPS required** for camera/microphone access in production
- **localhost works** for development testing

## Related Files

- `web/index.html` - SDK loading order fixed here
- `lib/features/video_call/data/services/agora_service.dart` - Agora initialization
- `AGORA_WEB_SETUP.md` - Complete web setup guide
