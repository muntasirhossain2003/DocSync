// lib/features/video_call/data/services/agora_service.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/agora_config.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    await _requestPermissions();

    // Create RTC engine
    _engine = createAgoraRtcEngine();

    await _engine!.initialize(
      RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Enable video
    await _engine!.enableVideo();

    // Set video configuration
    await _engine!.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: VideoDimensions(
          width: AgoraConfig.videoWidth,
          height: AgoraConfig.videoHeight,
        ),
        frameRate: AgoraConfig.videoFrameRate,
        bitrate: AgoraConfig.videoBitrate,
      ),
    );

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null) {
      throw Exception('Agora engine not initialized');
    }

    if (AgoraConfig.appId.isEmpty) {
      throw Exception(
        'Agora App ID is not configured. Please check your .env file.',
      );
    }

    try {
      print('📞 Joining Agora channel: $channelName with UID: $uid');

      // Ensure audio and video are enabled before joining
      await _engine!.enableAudio();
      await _engine!.enableVideo();

      // Start preview to ensure local video is working
      await _engine!.startPreview();

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          // Ensure we subscribe to remote video and audio
          publishCustomAudioTrack: false,
          publishCustomVideoTrack: false,
        ),
      );

      print('✅ Successfully joined channel');
    } catch (e) {
      print('❌ Failed to join channel: $e');
      rethrow;
    }
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.stopPreview();
    await _engine!.leaveChannel();
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  Future<void> toggleMicrophone(bool muted) async {
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera(bool enabled) async {
    if (_engine == null) return;
    await _engine!.muteLocalVideoStream(!enabled);
  }

  Future<void> toggleSpeaker(bool enabled) async {
    if (_engine == null) return;
    await _engine!.setEnableSpeakerphone(enabled);
  }

  void registerEventHandler(RtcEngineEventHandler eventHandler) {
    if (_engine == null) return;
    _engine!.registerEventHandler(eventHandler);
  }

  RtcEngine? get engine => _engine;

  Future<void> dispose() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
    await _engine!.release();
    _engine = null;
    _isInitialized = false;
  }
}
