import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'profile-images';

  /// Upload user profile image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Generate unique file name
      final String fileExt = imageFile.path.split('.').last;
      final String fileName =
          '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete user profile image from Supabase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the index of the bucket name in the path
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex == -1) {
        throw Exception('Invalid image URL');
      }

      // Get the file path after the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Delete from Supabase Storage
      await _supabase.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Update profile picture URL in the users table
  Future<void> updateUserProfilePicture({
    required String userId,
    required String profilePictureUrl,
  }) async {
    try {
      print('Updating user profile picture for auth_id: $userId');
      print('New profile picture URL: $profilePictureUrl');

      // First, check if user exists
      final existingUser = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // User doesn't exist, create one
        print('User not found in database, creating new record...');
        final authUser = _supabase.auth.currentUser;
        await _supabase.from('users').insert({
          'auth_id': userId,
          'email': authUser?.email ?? '',
          'full_name': authUser?.email?.split('@').first ?? 'User',
          'role': 'patient',
          'profile_picture_url': profilePictureUrl,
        });
        print('User record created successfully');
      } else {
        // User exists, update it
        final response = await _supabase
            .from('users')
            .update({
              'profile_picture_url': profilePictureUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('auth_id', userId)
            .select();

        print('Update response: $response');
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      throw Exception('Failed to update profile picture in database: $e');
    }
  }

  /// Remove profile picture URL from the users table
  Future<void> removeUserProfilePicture(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'profile_picture_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', userId);
    } catch (e) {
      throw Exception('Failed to remove profile picture from database: $e');
    }
  }

  /// Complete process: Upload image and update database
  Future<String> uploadAndUpdateProfilePicture({
    required String userId,
    required File imageFile,
    String? oldImageUrl,
  }) async {
    try {
      // Delete old image if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await deleteProfileImage(oldImageUrl);
        } catch (e) {
          // Continue even if delete fails
          print('Warning: Failed to delete old image: $e');
        }
      }

      // Upload new image
      final String newImageUrl = await uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );

      // Update database
      await updateUserProfilePicture(
        userId: userId,
        profilePictureUrl: newImageUrl,
      );

      return newImageUrl;
    } catch (e) {
      throw Exception('Failed to upload and update profile picture: $e');
    }
  }

  /// Complete process: Delete image and update database
  Future<void> deleteAndRemoveProfilePicture({
    required String userId,
    required String imageUrl,
  }) async {
    try {
      // Delete image from storage
      await deleteProfileImage(imageUrl);

      // Update database
      await removeUserProfilePicture(userId);
    } catch (e) {
      throw Exception('Failed to delete and remove profile picture: $e');
    }
  }
}
