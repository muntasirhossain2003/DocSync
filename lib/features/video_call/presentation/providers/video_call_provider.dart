// lib/features/video_call/presentation/providers/video_call_provider.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/agora_config.dart';
import '../../data/services/agora_service.dart';
import '../../domain/models/call_state.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  final service = AgoraService();
  ref.onDispose(() => service.dispose());
  return service;
});

class VideoCallController extends StateNotifier<CallState> {
  final AgoraService _agoraService;
  final VideoCallInfo callInfo;

  int? _remoteUid;
  bool _isMuted = false;
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = true;

  VideoCallController({
    required AgoraService agoraService,
    required this.callInfo,
  }) : _agoraService = agoraService,
       super(CallState.idle);

  int? get remoteUid => _remoteUid;
  bool get isMuted => _isMuted;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isSpeakerEnabled => _isSpeakerEnabled;

  Future<void> initializeCall() async {
    try {
      state = CallState.connecting;

      // Update consultation status to 'calling' to notify doctor
      await _updateConsultationStatus();

      await _agoraService.initialize();

      // Register event handlers
      _agoraService.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('✅ Join channel success! Channel: ${connection.channelId}');
            state = CallState.connected;
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('👥 Remote user joined: $remoteUid');
            _remoteUid = remoteUid;
            state = CallState.connected;
            // Update status to in_progress when both users are in the call
            _updateConsultationStatus(status: 'in_progress');
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                print('👋 Remote user offline: $remoteUid, reason: $reason');
                if (_remoteUid == remoteUid) {
                  _remoteUid = null;
                  state = CallState.disconnected;
                }
              },
          onConnectionLost: (RtcConnection connection) {
            print('📡 Connection lost');
            state = CallState.reconnecting;
          },
          onConnectionStateChanged:
              (
                RtcConnection connection,
                ConnectionStateType state,
                ConnectionChangedReasonType reason,
              ) {
                print('🔄 Connection state changed: $state, reason: $reason');
                if (state == ConnectionStateType.connectionStateFailed) {
                  print('❌ Connection failed! Reason: $reason');
                  this.state = CallState.error;
                } else if (state ==
                    ConnectionStateType.connectionStateReconnecting) {
                  this.state = CallState.reconnecting;
                } else if (state ==
                    ConnectionStateType.connectionStateConnected) {
                  this.state = CallState.connected;
                }
              },
          onError: (ErrorCodeType err, String msg) {
            print('❌ Agora Error: $err - $msg');
            state = CallState.error;
          },
        ),
      );

      // Join channel with patient's user ID as uid
      // IMPORTANT: Token must match the channel name!
      // Using config channel name because token is for that specific channel
      final channelName = AgoraConfig.channelName;

      // Generate a valid UID (must be positive 32-bit integer)
      // Use hashCode but ensure it's positive and within valid range
      final uid = callInfo.patientId.hashCode.abs() % 2147483647;

      print('🎥 === Video Call Details ===');
      print('📱 App ID: ${AgoraConfig.appId}');
      print('📺 Channel: $channelName');
      print('👤 UID: $uid');
      print(
        '🔑 Token: ${AgoraConfig.token.isEmpty ? "No token (testing mode)" : "Token provided"}',
      );
      print('👨‍⚕️ Doctor: ${callInfo.doctorName}');
      print('🆔 Consultation ID: ${callInfo.consultationId}');
      print('⚠️ Using shared channel - all calls use same channel for testing');

      await _agoraService.joinChannel(
        channelName: channelName,
        token: AgoraConfig.token,
        uid: uid,
      );
    } catch (e) {
      print('❌ Error joining call: $e');
      state = CallState.error;
      rethrow;
    }
  }

  Future<void> toggleMicrophone() async {
    _isMuted = !_isMuted;
    await _agoraService.toggleMicrophone(_isMuted);
  }

  Future<void> toggleCamera() async {
    _isCameraEnabled = !_isCameraEnabled;
    await _agoraService.toggleCamera(_isCameraEnabled);
  }

  Future<void> switchCamera() async {
    await _agoraService.switchCamera();
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    await _agoraService.toggleSpeaker(_isSpeakerEnabled);
  }

  Future<void> endCall() async {
    await _agoraService.leaveChannel();
    state = CallState.disconnected;
    // Update status to completed when call ends
    await _updateConsultationStatus(status: 'completed');
  }

  /// Update consultation status in database
  /// [status] can be: 'calling', 'in_progress', 'completed', 'canceled', 'rejected'
  Future<void> _updateConsultationStatus({String status = 'calling'}) async {
    try {
      final supabase = Supabase.instance.client;

      final updateData = <String, dynamic>{
        'consultation_status': status,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Only include Agora details when initiating call
      if (status == 'calling') {
        updateData['agora_channel_name'] = AgoraConfig.channelName;
        updateData['agora_token'] = AgoraConfig.token;
      }

      await supabase
          .from('consultations')
          .update(updateData)
          .eq('id', callInfo.consultationId);

      print('✅ Updated consultation status to: $status');
    } catch (e) {
      print('❌ Error updating consultation status: $e');
      // Don't throw - allow call to proceed even if status update fails
    }
  }

  RtcEngine? get engine => _agoraService.engine;
}

final videoCallControllerProvider =
    StateNotifierProvider.family<VideoCallController, CallState, VideoCallInfo>(
      (ref, callInfo) {
        final agoraService = ref.watch(agoraServiceProvider);
        return VideoCallController(
          agoraService: agoraService,
          callInfo: callInfo,
        );
      },
    );
