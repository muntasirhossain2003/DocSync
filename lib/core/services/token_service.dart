// lib/core/services/token_service.dart
// This service demonstrates how to implement dynamic token generation
// For production, implement this on your backend server

import 'dart:convert';

import 'package:http/http.dart' as http;

class TokenService {
  // TODO: Replace with your backend URL
  static const String tokenServerUrl = 'YOUR_BACKEND_URL/api/agora/token';

  /// Fetch a new Agora token from your backend
  ///
  /// Example backend endpoint response:
  /// ```json
  /// {
  ///   "token": "007eJxT...",
  ///   "uid": 12345,
  ///   "channel": "DocSync",
  ///   "expiresAt": "2025-10-16T10:00:00Z"
  /// }
  /// ```
  static Future<AgoraTokenResponse> fetchToken({
    required String channelName,
    required String userId,
    required String consultationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(tokenServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'channelName': channelName,
          'userId': userId,
          'consultationId': consultationId,
          'role': 'broadcaster', // or 'audience'
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AgoraTokenResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching token: $e');
    }
  }

  /// Check if token needs renewal (e.g., 5 minutes before expiry)
  static bool shouldRenewToken(DateTime expiresAt) {
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt.difference(now);
    return timeUntilExpiry.inMinutes <= 5;
  }
}

class AgoraTokenResponse {
  final String token;
  final int uid;
  final String channel;
  final DateTime expiresAt;

  AgoraTokenResponse({
    required this.token,
    required this.uid,
    required this.channel,
    required this.expiresAt,
  });

  factory AgoraTokenResponse.fromJson(Map<String, dynamic> json) {
    return AgoraTokenResponse(
      token: json['token'] as String,
      uid: json['uid'] as int,
      channel: json['channel'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'uid': uid,
      'channel': channel,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

/// Example Node.js backend code for token generation:
/// 
/// ```javascript
/// const { RtcTokenBuilder, RtcRole } = require('agora-token');
/// const express = require('express');
/// const app = express();
/// 
/// app.use(express.json());
/// 
/// app.post('/api/agora/token', async (req, res) => {
///   const { channelName, userId, consultationId, role } = req.body;
///   
///   const appID = process.env.AGORA_APP_ID;
///   const appCertificate = process.env.AGORA_APP_CERTIFICATE;
///   
///   // Generate UID from userId
///   const uid = parseInt(userId.substring(0, 8), 16);
///   
///   // Token expires in 24 hours
///   const expirationTimeInSeconds = 3600 * 24;
///   const currentTimestamp = Math.floor(Date.now() / 1000);
///   const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
///   
///   // Build token
///   const token = RtcTokenBuilder.buildTokenWithUid(
///     appID,
///     appCertificate,
///     channelName,
///     uid,
///     role === 'audience' ? RtcRole.AUDIENCE : RtcRole.PUBLISHER,
///     privilegeExpiredTs
///   );
///   
///   // Log consultation access
///   await logConsultationAccess(consultationId, userId);
///   
///   res.json({
///     token,
///     uid,
///     channel: channelName,
///     expiresAt: new Date(privilegeExpiredTs * 1000).toISOString()
///   });
/// });
/// 
/// app.listen(3000, () => console.log('Token server running on port 3000'));
/// ```
/// 
/// Install required packages:
/// ```bash
/// npm install agora-token express
/// ```
