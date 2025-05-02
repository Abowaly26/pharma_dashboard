// class FireStorage implements StorageService {
//     // Initialize Firebase Storage reference
//     final StorageReference storageReference = FirebaseStorage.getInstance().getReference();

//     @Override
//     Future<String> uploadFile(File file, String path) async {
//         // Extract the base name and extension of the file
//         String fileName = b.basename(file.path);
//         String extensionName = b.extension(file.path);

//         // Create a reference to the specific file path in Firebase Storage
//         var fileReference = storageReference.child('$path/$fileName.$extensionName');

//         // Upload the file to Firebase Storage asynchronously
//         await fileReference.putFile(file);

//         // Get the download URL of the uploaded file
//         var fileUrl = fileReference.getDownloadURL();

//         // Return the download URL
//         return fileUrl;
//     }
// }
