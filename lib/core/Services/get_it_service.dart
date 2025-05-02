import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pharma_dashboard/core/Services/data_service.dart';
import 'package:pharma_dashboard/core/Services/firestore_service.dart';
import 'package:pharma_dashboard/core/Services/storage_service.dart';
import 'package:pharma_dashboard/core/Services/supabase_storage.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo_impl.dart';

import '../repos/images_repo/images_repo.dart';
import '../repos/images_repo/images_repo_impl.dart';
import '../repos/medicine_repo/add_medicine_repo.dart';

final getIt = GetIt.instance;

void setupGetit() {
  getIt.registerSingleton<StorageService>(SupabaseStorageService());

  getIt.registerSingleton<DatabaseService>(FireStoreService());

  getIt.registerSingleton<ImagesRepo>(
    ImagesRepoImpl(getIt.get<StorageService>()),
  );

  getIt.registerSingleton<MedicineRepo>(
    MedicineRepoImpl(getIt.get<DatabaseService>()),
  );
}
