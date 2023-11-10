

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../models/user_model.dart';
import 'auth.dart';

class FireUser{
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  CollectionReference users = FirebaseFirestore.instance.collection('users');//For Writing Data

  Future<void> addUser({required UserModel userModel}) {
    // Call the user's CollectionReference to add a new user
    return firestore.collection('users')
        .add(userModel!.toMap())
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<List<UserModel>> getAllUsers() async {

  final snapshot = await firestore.collection('users').get();
  final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
  // print(userData.toString());
    return userData;
  }

  Future<bool> updateName(
      UserModel userModel
      ) async {
    String docId = "";
    try{
      final snapshot = await firestore
          .collection('users').where("email",isEqualTo: Auth().currentUser!.email)
          .get()
          .then((value) async  {
        // print("DocumentId = ${value.docs.first.id} Of uid = ${Auth().currentUser!.uid}");
        await firestore.collection('users').doc('${value.docs.first.id}').update(userModel.toMap());
      });
      print("$snapshot");
      return true;


      // final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();

      // print("${userData.toMap()}");

    }catch(e){
      print("Update SubscriptionFailed with ${e}");
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email =   prefs.getString("email") ?? "" ;
      final snapshot = await firestore.collection('users').where("email",isEqualTo: email).get();
      final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
      print("${userData}");
      if(userData != null && userData.isNotEmpty)
      {
        return userData.first;
      }else{
    print("User Not Found 235");
    }
    }on FirebaseException catch(e){
      print(e.message);
    }
    return null;
  }


}