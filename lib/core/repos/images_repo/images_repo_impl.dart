import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pharma_dashboard/core/errors/failures.dart';
import 'package:pharma_dashboard/core/repos/images_repo/images_repo.dart';

import '../../Services/storage_service.dart';
import '../../utils/backend_endpoint.dart';

class ImagesRepoImpl implements ImagesRepo {
  final StorageService storageService;

  ImagesRepoImpl(this.storageService);

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    try {
      // Upload the image and get the download URL
      String url = await storageService.uploadFile(
        image,
        BackendEndpoint.images,
      );
      // Return the URL wrapped in a Right object
      return Right(url);
    } catch (e) {
      // Return a failure wrapped in a Left object
      return Left(ServerFailure("Failed to upload image"));
    }
  }
}
