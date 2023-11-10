import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? email;
  String? userName;
  String? profileImage;


  UserModel(
      {this.userName,
        this.email,
        this.profileImage,

      });

  factory UserModel.fromJson(Map<dynamic, dynamic> map) {
    return UserModel(
      profileImage: map['profileImage'],
      userName: map['userName'],
      email: map['email'],
    );
  }
  Map<String, dynamic> toMap() {
    return {

      'profileImage': profileImage,
      'userName': userName,
      'email': email,

    };
  }
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return UserModel(
      userName: data!['userName'],
      email: data!['email'],
      profileImage: data!['profileImage'],
    );
  }
}