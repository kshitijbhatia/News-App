import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUser{
  String uid;
  String name;
  String email;
  String password;
  String createdOn;
  String lastSignIn;
  String imageUrl;


  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.createdOn,
    required this.lastSignIn,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson(){
    return {
      "uid" : uid,
      "name" : name,
      "email" : email,
      "password" : password,
      "createdOn" : createdOn,
      "lastSignIn" : lastSignIn
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json){
    return AppUser(
        uid : json["uid"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        createdOn: json["createdOn"],
        lastSignIn: json["lastSignIn"],
        imageUrl : json["imageUrl"]
    );
  }

  AppUser copyWith({String? newName, String? newEmail, String? newPassword, String? newImageURL}){
    return AppUser(
        uid: uid,
        name: newName ?? name,
        email: newEmail ?? email,
        password: newPassword ??password,
        createdOn: createdOn,
        lastSignIn: lastSignIn,
        imageUrl: newImageURL ?? imageUrl,
    );
  }
}

class AppUserNotifier extends StateNotifier<AppUser>{
  AppUserNotifier({required AppUser user}) : super(user);

  updateName(String newName){
    state = state.copyWith(newName: newName);
  }

  updateEmail(String newEmail){
    state = state.copyWith(newEmail: newEmail);
  }

  updatePassword(String newPassword){
    state = state.copyWith(newPassword: newPassword);
  }

  updateImageUrl(String newImageUrl){
    state = state.copyWith(newImageURL: newImageUrl);
  }

  setUser({required AppUser currentUser}){
    state = currentUser;
  }
}

final currentUserNotifierProvider = StateNotifierProvider<AppUserNotifier, AppUser>((ref) {
  return AppUserNotifier(
      user: AppUser(uid: "", email: "", name: "", password: "", createdOn: "", imageUrl: "", lastSignIn: "")
  );
},);