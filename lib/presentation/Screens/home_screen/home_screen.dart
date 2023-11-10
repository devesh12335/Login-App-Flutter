import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/Authentication/auth.dart';
import 'package:login_app/Authentication/user_firestore.dart';
import 'package:login_app/models/user_model.dart';
import 'package:login_app/my_singleton.dart';
import 'package:login_app/presentation/Screens/login_screens/login_screen.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase_storage/firebase_storage.dart';

class HomescreenView extends StatefulWidget {
  const HomescreenView({super.key});

  @override
  State<HomescreenView> createState() => _HomescreenViewState();
}

class _HomescreenViewState extends State<HomescreenView> {
  StreamController<UserModel> _streamController = StreamController.broadcast();
  TextEditingController _nameController = TextEditingController();
  late File _image;
  @override
  void initState() {

      FireUser().getCurrentUser().then((value) {
        if(value != null){
          _streamController.sink.add(value!);
        }else{
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreenView()));
        }
      });


    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("HomeScreen"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton.filledTonal(onPressed: () async {
              await _showLogoutDialog(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreenView()));

            }, icon: Icon(Icons.power_settings_new_sharp)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<UserModel>(
          initialData: MySingleton.loggedInUser,
          stream: _streamController.stream,
          builder: (context,AsyncSnapshot<UserModel> snapshot) {

            if(snapshot.hasData){
              return Container(
                margin: EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(foregroundImage: NetworkImage(snapshot.data!.profileImage!),radius: 120,),
                        Positioned(
                            bottom: 30,
                            right: 0,
                            child: IconButton.filled(
                                color: Colors.yellow,
                                onPressed: (){
                                  getImageFromGallery(snapshot.data!);
                                }, icon: Icon(Icons.edit,color: Colors.yellow,)))
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Name : ${snapshot.data!.userName}"),
                        IconButton(onPressed: (){
                          _nameController.text = snapshot.data!.userName!;
                          Future.delayed(Duration.zero,()=>_showUpdateName(context,snapshot.data!));

                        }, icon: Icon(Icons.edit))
                      ],
                    ),
                    Text("Email : ${snapshot.data!.email}"),
                  ],),
              );
            }else if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(),);
            }else{
              return Center(child: Text("User Not Found"),);
            }
          }
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext cont) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text('Log Out'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure to LogOut ?'),
                // Text('This Cannot undone once Done'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout',style: TextStyle(color: Colors.purple),),
              onPressed: () async {
                try{
                  await Auth().signOutGoogle();
                  SharedPreferences prefs =await  SharedPreferences.getInstance();
                  print("Login Details Cleared = ${await prefs.clear()}");
                  print("Email After logout : ${prefs.getString("email")}");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You Have Logged Out")));
                  // Navigator.of(cont).push(MaterialPageRoute(builder: (context)=>LoginScreenView()));
                  Navigator.of(context).pop();
                }catch(e){
                  print(e);
                }
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }

  Future getImageFromGallery(UserModel userModel) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        FirebaseStorag().addImageToFirebase(context, File(pickedFile.path)).then((value){
          if(value != null){
            UserModel user = UserModel(email: userModel.email,userName: userModel.userName,profileImage: value!);
            _streamController.sink.add(user);
             FireUser().updateName(user);
          }
        }) ;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Image Selected,Plz Select Image First")));
      }
    });
  }

  void _showUpdateName(BuildContext context,UserModel userModel){
    showModalBottomSheet<void>(context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context){

      return Container(
        // height: 300,
        padding: MediaQuery.of(context).viewInsets,
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: _nameController,
              decoration: InputDecoration(label: Text("Change Name"),),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: () async {
              UserModel user = UserModel(userName: _nameController.text,profileImage: userModel.profileImage,email: userModel.email);
              await FireUser().updateName(user);
              await FireUser().getCurrentUser().then((value) => _streamController.sink.add(value!));


              Navigator.of(context).pop();
            } ,child: Text("Update Name"))
          ],
        ),
      );
    });
  }
}
