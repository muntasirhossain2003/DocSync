import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/storage_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String imageUrl) onImageUploaded;
  final double size;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageUploaded,
    this.size = 120,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.currentImageUrl;
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload image
      final String newImageUrl = await _storageService
          .uploadAndUpdateProfilePicture(
            userId: userId,
            imageFile: File(pickedFile.path),
            oldImageUrl: _currentImageUrl,
          );

      setState(() {
        _currentImageUrl = newImageUrl;
        _isUploading = false;
      });

      widget.onImageUploaded(newImageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            if (_currentImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeProfilePicture() async {
    if (_currentImageUrl == null) return;

    try {
      setState(() => _isUploading = true);

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      await _storageService.deleteAndRemoveProfilePicture(
        userId: userId,
        imageUrl: _currentImageUrl!,
      );

      setState(() {
        _currentImageUrl = null;
        _isUploading = false;
      });

      widget.onImageUploaded('');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile Image
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.indigo.shade200, width: 3),
          ),
          child: ClipOval(
            child: _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                ? Image.network(
                    _currentImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),

        // Loading Indicator
        if (_isUploading)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Edit Button
        if (!_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: widget.size * 0.6,
        color: Colors.grey.shade400,
      ),
    );
  }
}
