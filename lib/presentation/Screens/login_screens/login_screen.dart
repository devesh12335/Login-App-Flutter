import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:login_app/presentation/Screens/home_screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Authentication/auth.dart';
import '../../../Authentication/user_firestore.dart';
import '../../../models/user_model.dart';
import '../../../my_singleton.dart';

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView> {

  Future<String> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle();
      return "Successful";
    } on FirebaseAuthException catch (error) {
      print("Fire Base Problem :- ${error.message}");
      return "${error.message}";
    }
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    // Future.delayed(Duration(milliseconds: 500),(){
    //   if(FireUser().getCurrentUser() != null){
    //     FireUser().getCurrentUser().then((value) => MySingleton.loggedInUser = value);
    //     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomescreenView()));
    //   }
    // });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Select Login Option"),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          ElevatedButton(onPressed: (){
            signInWithGoogle().then((value) async {
              UserModel? existingUser = await FireUser().getCurrentUser();
              if(value != null){

                if(existingUser == null){
                  UserModel userData = UserModel(
                      userName: Auth().currentUser!.displayName,
                      email:Auth().currentUser!.email,
                      profileImage:Auth().currentUser!.photoURL,

                  );
                  FireUser fireStoreData= FireUser();
                  fireStoreData.addUser(userModel: userData);

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString("email", userData.email!);
                  await prefs.setString("name", userData.userName!);
                  await prefs.setString("imageUrl", userData.profileImage!);

                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomescreenView()));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome ${Auth().currentUser!.email}")));
                }else{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString("email", existingUser.email!);
                  await prefs.setString("name", existingUser.userName!);
                  await prefs.setString("imageUrl", existingUser.profileImage!);

                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomescreenView()));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome ${existingUser.email}")));
                }
                if (Auth().currentUser != null) {
                  MySingleton.loggedInUser = await FireUser().getCurrentUser();
                } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed")));
                }

              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed")));
              }

            });
          }, child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              Text("Google Login"),

        ],),
      ),
            SizedBox(height: 20,),

            //Facebook Login
            ElevatedButton(onPressed: () async {
             UserCredential? user = await Auth().signInWithFacebook();
             if(user != null){

               print(user!.additionalUserInfo!.profile!);
               Map<String,dynamic> jsonData = user!.additionalUserInfo!.profile!;
               String pictureUrl = jsonData["picture"]["data"]["url"]; //***
               String name = jsonData["name"]; //***
               String email = jsonData["email"]; //***
               UserModel userModel = UserModel(userName: name,profileImage: pictureUrl,email: email);

               SharedPreferences prefs = await SharedPreferences.getInstance();
               await prefs.setString("email", userModel.email!);
               await prefs.setString("name", userModel.userName!);
               await prefs.setString("imageUrl", userModel.profileImage!);

               UserModel? existingUser = await FireUser().getCurrentUser();
               if(existingUser == null){
                  //Adding User Data
                 FireUser fireStoreData= FireUser();
                 fireStoreData.addUser(userModel: userModel);
                  //Saving data local


                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomescreenView()));
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome ${Auth().currentUser!.email}")));
               }else{
                 SharedPreferences prefs = await SharedPreferences.getInstance();
                 await prefs.setString("email", existingUser.email!);
                 await prefs.setString("name", existingUser.userName!);
                 await prefs.setString("imageUrl", existingUser.profileImage!);
                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomescreenView()));
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome ${existingUser.email}")));
               }
               if (Auth().currentUser != null) {
                 MySingleton.loggedInUser = await FireUser().getCurrentUser();
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed")));
               }

               print(" Image Url : $pictureUrl");
               print(" User Name : $name");
               print(" Email : $email");

             }else{
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Not Found")));
             }

            }, child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                Text("Facebook Login"),
              ],
            )),
      ]
    )));
  }
}
