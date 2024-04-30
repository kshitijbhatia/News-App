import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/utils/constants.dart';

class Authentication{
  Authentication._privateConstructor();
  static final Authentication _instance = Authentication._privateConstructor();
  static Authentication get getInstance => _instance;

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>> signUp(String name,String email,String password) async {
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await _firebaseAuth.currentUser!.updateDisplayName(name);
      await _firebaseAuth.currentUser!.updatePhotoURL(Constants.defaultImageUrl);

      Map<String, dynamic> data = {
        'name' : name,
        'email' : email,
        'password' : password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString(),
        'imageUrl' : Constants.defaultImageUrl
      };

      await users.doc(_firebaseAuth.currentUser!.uid).set(data);

      return {
        'uid' : _firebaseAuth.currentUser!.uid.toString(),
        'name' : name,
        'email' : email,
        'password' : password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString(),
        'imageUrl' : Constants.defaultImageUrl
      };

    } catch(error){
      CustomError customError = _handleError(error);
      throw(customError);
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async{
    try{
      final currentUser = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final user = await users.doc(currentUser.user!.uid).get();
      if(!user.exists){
        throw Exception("user-not-found");
      }
      final Map<String, dynamic> data = user.data() as Map<String, dynamic>;
      return {
        'uid' : _firebaseAuth.currentUser!.uid,
        'name' : data["name"],
        'email' : email,
        'password' : password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString(),
        'imageUrl' : data["imageUrl"]
      };

    } catch(error){
      CustomError customError = _handleError(error);
      throw(customError);
    }
  }

  Future<void> deleteAccount(AppUser user) async {
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: user.email, password: user.password);
      await _firebaseAuth.currentUser!.delete();
      await users.doc(user.uid).delete();

      if(user.imageUrl != Constants.defaultImageUrl){
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('images');
        Reference referenceImageToUpload = referenceDirImages.child('image-${user.uid}');
        await referenceImageToUpload.delete();
      }
    } catch(error){
      CustomError customError = _handleError(error);
      throw(customError);
    }
  }

  Future<Map<String, dynamic>> updateDetails(AppUser user,String newName, String newEmail, String newPassword) async {
    try{
      if(newName != "")await _firebaseAuth.currentUser!.updateDisplayName(newName);
      if(newEmail != "")await _firebaseAuth.currentUser!.updateEmail(newEmail);
      if(newPassword != "")await _firebaseAuth.currentUser!.updatePassword(newPassword);

      await users.doc(user.uid).update({
        'name' : newName == "" ? user.name : newName,
        'email' : newEmail == "" ? user.email : newEmail,
        'password' : newPassword == "" ? user.password : newPassword,
      });

      return {
        "uid" : user.uid,
        "name" : newName == "" ? user.name : newName,
        "email" : newEmail == "" ? user.email : newEmail,
        "password" : newPassword == "" ? user.password : newPassword,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString(),
        'imageUrl' : user.imageUrl
      };

    } catch(error){
      CustomError customError = _handleError(error);
      throw(customError);
    }
  }

  Future<Map<String, dynamic>> updateImage(AppUser user,String imageUrl) async{
    try{
      await _firebaseAuth.currentUser!.updatePhotoURL(imageUrl);
      await users.doc(user.uid).update({
        "imageUrl" : imageUrl
      });

      return {
        "uid" : user.uid,
        "name" : user.name,
        "email" : user.email,
        "password" : user.password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString(),
        'imageUrl' : imageUrl
      };
    }catch(error){
      CustomError customError = _handleError(error);
      throw(customError);
    }
  }

  CustomError _handleError(dynamic error){
    CustomError customError = CustomError();
    customError.message = error.toString();
    customError.description = "Error Occurred. Please try again";
    customError.errorType = "snackbar";
    if(error is FirebaseAuthException){
      customError.message = error.code;
      switch(error.code){
        case "invalid-email":
          customError.errorType = "email";
          customError.description = "Please enter a valid email";
          break;
        case "user-not-found":
          customError.description = "Wrong Email Or Password";
          break;
        case "wrong-password":
          customError.description = "Wrong Password";
          break;
        case "network-request-failed":
        case "too-many-requests":
          customError.description = "Please check your internet connection";
          break;
        case "email-already-in-use":
          customError.errorType = "email";
          customError.description = "Email Already Exists";
          break;
        case "weak-password":
          customError.errorType = "password";
          customError.description = error.message!;
          break;
        case "requires-recent-login":
          customError.description = "Please Login Again to Update Details";
          break;
        case "user-deleted":
          customError.description = "Account Already Deleted";
          break;
        default:
          customError.description = "Unknown Error. Please try again later";
          break;
      }
    }
    return customError;
  }
}

