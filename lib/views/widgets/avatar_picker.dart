import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AvatarPicker extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;
  final Function(File) onImagePicked;

  const AvatarPicker({
    Key? key,
    this.imageFile,
    this.imageUrl,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // Basic permission check
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
      if(status.isPermanentlyDenied) {
          // Fallback mostly for Android 13+ or restricted iOS
          // On newer Android versions READ_MEDIA_IMAGES is used, check platform version if robust needed
      }
    }

    // Attempt to pick regardless of explicit check if status allows or is limited
    // ImagePicker handles some permission requests internally on mobile
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        widget.onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;
    if (widget.imageFile != null) {
      backgroundImage = FileImage(widget.imageFile!);
    } else if (widget.imageUrl != null) {
      backgroundImage = NetworkImage(widget.imageUrl!);
    }

    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage: backgroundImage,
        child: backgroundImage == null
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 20, color: Colors.blue),
                ),
              ),
      ),
    );
  }
}
