import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/models/user.dart';

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

      Map<String, dynamic> data = {
        'name' : name,
        'email' : email,
        'password' : password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString()
      };

      await users.doc(_firebaseAuth.currentUser!.uid).set(data);

      return {
        'uid' : _firebaseAuth.currentUser!.uid.toString(),
        'name' : name,
        'email' : email,
        'password' : password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString()
      };

    } on FirebaseAuthException catch(err){
      rethrow;
    } catch(err){
      rethrow;
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
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString()
      };

    } on FirebaseAuthException catch(err){
      log('Firebase Exception : $err');
      rethrow;
    } catch(err){
      log('API Service : $err');
      rethrow;
    }
  }

  Future<void> deleteAccount(AppUser user) async {
    try{
      await _firebaseAuth.currentUser!.delete();
      await users.doc(user.uid).delete();
    }  on FirebaseAuthException catch(err){
      log('$err');
      rethrow;
    } catch(err){
      log('API Service : $err');
      rethrow;
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
        'password' : newPassword == "" ? user.password : newPassword
      });

      return {
        "uid" : user.uid,
        "name" : newName == "" ? user.name : newName,
        "email" : newEmail == "" ? user.email : newEmail,
        "password" : newPassword == "" ? user.password : newPassword,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString(),
        'lastSignIn' : _firebaseAuth.currentUser!.metadata.lastSignInTime.toString()
      };

    } on FirebaseAuthException catch(err){
      rethrow;
    } catch(err){
      rethrow;
    }
  }
}

