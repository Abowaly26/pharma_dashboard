import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/services/remove_bg_service.dart';
import 'package:pharma_dashboard/core/utils/color_manger.dart';

class EnhancedImageField extends StatefulWidget {
  final Function(File?) onFileChanged;
  final Function(String?) onUrlChanged;
  final String? initialUrl;

  const EnhancedImageField({
    Key? key,
    required this.onFileChanged,
    required this.onUrlChanged,
    this.initialUrl,
  }) : super(key: key);

  @override
  State<EnhancedImageField> createState() => _EnhancedImageFieldState();
}

class _EnhancedImageFieldState extends State<EnhancedImageField> {
  File? _selectedImage;
  final TextEditingController _urlController = TextEditingController();
  bool _isUrlMode = false;
  bool _isProcessing = false; // To show a loading indicator
  final RemoveBgService _removeBgService = RemoveBgService();

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _isUrlMode = true;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _removeBackground() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an image URL first.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _removeBgService.removeBackgroundFromUrl(
        _urlController.text,
      );

      await result.fold(
        (errorMsg) async {
          // Failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        },
        (imageBytes) async {
          // Success
          final uploadResult = await _removeBgService.uploadProcessedImage(
            imageBytes,
          );

          uploadResult.fold(
            (errorMsg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
              );
            },
            (newUrl) {
              _urlController.text = newUrl;
              widget.onUrlChanged(newUrl);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Background removed and new URL is set!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUrlMode = false;
          _urlController.clear();
        });
        widget.onFileChanged(_selectedImage);
        widget.onUrlChanged(null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred while picking the image. Please check permissions and try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeBackgroundFromFile() async {
    if (_selectedImage == null) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      final result = await _removeBgService.removeBackgroundFromFile(
        _selectedImage!,
      );
      await result.fold(
        (errorMsg) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        },
        (imageBytes) async {
          final uploadResult = await _removeBgService.uploadProcessedImage(
            imageBytes,
          );
          uploadResult.fold(
            (errorMsg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
              );
            },
            (newUrl) {
              setState(() {
                _selectedImage = null;
                _isUrlMode = true;
                _urlController.text = newUrl;
              });
              widget.onFileChanged(null);
              widget.onUrlChanged(newUrl);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Background removed and new URL is set!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _toggleInputMode() {
    setState(() {
      _isUrlMode = !_isUrlMode;
      if (_isUrlMode) {
        _selectedImage = null;
        widget.onFileChanged(null);
      } else {
        _urlController.clear();
        widget.onUrlChanged(null);
      }
    });
  }

  void _removeImage() {
    setState(() {
      if (_isUrlMode) {
        _urlController.clear();
        widget.onUrlChanged(null);
      } else {
        _selectedImage = null;
        widget.onFileChanged(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Medicine Image',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.colorOfArrows,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _toggleInputMode,
              icon: Icon(_isUrlMode ? Icons.image : Icons.link),
              label: Text(_isUrlMode ? 'Select Image' : 'Enter URL'),
              style: TextButton.styleFrom(
                foregroundColor: ColorManager.secondaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        if (_isUrlMode)
          // URL Input Field
          Column(
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                  hintStyle: TextStyle(color: ColorManager.textInputColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.textInputColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  suffixIcon: Visibility(
                    visible: _urlController.text.isNotEmpty,
                    child: IconButton(
                      onPressed: _removeImage,
                      icon: Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // This will trigger a rebuild to show/hide the clear button
                  });
                  widget.onUrlChanged(value.isNotEmpty ? value : null);
                },
              ),
              const SizedBox(height: 8),
              if (_urlController.text.isNotEmpty &&
                  _removeBgService.isApiConfigured)
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _removeBackground,
                  icon:
                      _isProcessing
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.auto_fix_high),
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Remove Background',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),

              // Preview for URL mode
              if (_urlController.text.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 250.h, // Increased from 150.h to 250.h
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorManager.textInputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _urlController.text,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                'Invalid image URL',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )
        else
          // Image Picker Field
          Stack(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250.h, // Increased from 150.h to 250.h
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[190],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 70, // Increased from 50 to 70
                                color: ColorManager.textInputColor,
                              ),
                              SizedBox(
                                height: 16.h,
                              ), // Increased from 8.h to 16.h
                              Text(
                                'Tap to select an image',
                                style: TextStyle(
                                  color: ColorManager.textInputColor,
                                  fontSize:
                                      16.sp, // Increased from 13.sp to 16.sp
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              // Remove button for file image
              if (_selectedImage != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.close, color: Colors.red),
                      iconSize: 24, // Increased from 20 to 24
                      padding: const EdgeInsets.all(6), // Increased from 4 to 6
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),

              // Remove Background button for picked image
              if (_selectedImage != null && _removeBgService.isApiConfigured)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isProcessing ? null : _removeBackgroundFromFile,
                      icon:
                          _isProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.auto_fix_high),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Remove Background',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
