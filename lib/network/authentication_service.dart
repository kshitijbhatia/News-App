import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication{
  Authentication._privateConstructor();
  static final Authentication _instance = Authentication._privateConstructor();
  static Authentication get getInstance => _instance;

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> signUp(String name,String email,String password) async {
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await _firebaseAuth.currentUser!.updateDisplayName(name);

      Map<String, dynamic> data = {
        'name' : name,
        'email' : email,
        'password' : password,
        'createdOn' : _firebaseAuth.currentUser!.metadata.creationTime,
        'updatedOn' : _firebaseAuth.currentUser!.metadata.creationTime
      };

      await users.doc(_firebaseAuth.currentUser!.uid).set(data);

    } on FirebaseAuthException catch(err){
      rethrow;
    } catch(err){
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(err){
      rethrow;
    }catch(err){
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try{
      final currentUser = _firebaseAuth.currentUser;
      await _firebaseAuth.currentUser!.delete();
      await users.doc(_firebaseAuth.currentUser!.uid).delete();

    }  on FirebaseAuthException catch(err){
      rethrow;
    } catch(err){
      rethrow;
    }
  }
}

