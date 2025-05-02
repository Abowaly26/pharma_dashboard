import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharma_dashboard/core/utils/color_manger.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImageField extends StatefulWidget {
  const ImageField({super.key, required this.OnFileChanged});

  final ValueChanged<File?> OnFileChanged;

  @override
  State<ImageField> createState() => _ImageFieldState();
}

bool isLoading = false;
File? fileImage;

class _ImageFieldState extends State<ImageField> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () async {
          isLoading = true;
          setState(() {});
          try {
            await pickImage();
          } catch (e) {
            isLoading = false;
            setState(() {});
          }

          isLoading = false;
          setState(() {});
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorManager.textInputColor),
              ),

              child:
                  fileImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(fileImage!),
                      )
                      : Icon(
                        Icons.image_outlined,
                        color: ColorManager.textInputColor,
                        size: 200,
                      ),
            ),

            Visibility(
              visible: fileImage != null,
              child: IconButton(
                onPressed: () {
                  fileImage = null;
                  widget.OnFileChanged(fileImage);
                  setState(() {});
                },
                padding: EdgeInsets.zero,
                icon: Icon(Icons.close, color: ColorManager.redColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    fileImage = File(image!.path);

    widget.OnFileChanged(fileImage!);
  }
}
