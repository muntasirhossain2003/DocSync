// lib/core/config/agora_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraConfig {
  // Load from environment variables
  static String get appId => dotenv.env['AGORA_APP_ID'] ?? '';
  static String get channelName =>
      dotenv.env['AGORA_CHANNEL_NAME'] ?? 'DocSync';
  static String get token => dotenv.env['AGORA_TOKEN'] ?? '';

  // Token expiration time (in seconds)
  static const int tokenExpirationTime = 3600;

  // Video call configuration
  static const int videoWidth = 640;
  static const int videoHeight = 480;
  static const int videoFrameRate = 15;
  static const int videoBitrate = 0; // 0 means adaptive bitrate

  // Validate configuration
  static bool get isConfigured {
    return appId.isNotEmpty && channelName.isNotEmpty && token.isNotEmpty;
  }

  // Get configuration status message
  static String get configurationStatus {
    if (!isConfigured) {
      final missing = <String>[];
      if (appId.isEmpty) missing.add('AGORA_APP_ID');
      if (channelName.isEmpty) missing.add('AGORA_CHANNEL_NAME');
      if (token.isEmpty) missing.add('AGORA_TOKEN');
      return 'Missing configuration: ${missing.join(', ')}';
    }
    return 'Configuration valid';
  }
}
