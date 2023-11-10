import 'models/user_model.dart';

class MySingleton{
  static UserModel? loggedInUser;
  static bool isLogin = false;
  static bool hasAccount = false;
}