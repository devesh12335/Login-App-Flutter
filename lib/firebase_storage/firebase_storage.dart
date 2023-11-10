import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_app/Authentication/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseStorag {
  Reference storageReference = FirebaseStorage.instance.ref();

  Future<String?> addImageToFirebase(BuildContext context, File _image) async {
    String filePath = _image.path;
    List<String> fileName = filePath.split("/");
    List<String> extension = fileName.last.split(".");
    print(extension.last);
    //CreateRefernce to path.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Reference ref = storageReference.child("profile_images").child("${Auth().currentUser?.email ?? prefs.getString("email")}.${extension.last}");

    //StorageUpload task is used to put the data you want in storage
    //Make sure to get the image first before calling this method otherwise _image will be null.
    try {
      await ref.putFile(_image);
      print(await ref.getDownloadURL());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image Updated Successfully"),backgroundColor: Colors.green,),);
      return await ref.getDownloadURL();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image Update Failed as, ${error.message}"),backgroundColor: Colors.red,));
    }

  }
}