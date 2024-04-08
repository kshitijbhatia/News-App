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
        'updatedOn' : _firebaseAuth.currentUser!.metadata.creationTime.toString()
      };

      await users.doc(_firebaseAuth.currentUser!.uid).set(data);

      return data;

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
        throw FirebaseAuthException(code: "user-not-found");
      }
      final Map<String, dynamic> data = user.data() as Map<String, dynamic>;
      return {
        'name' : data["name"],
        'email' : email,
        'password' : password,
        'createdOn' : data["createdOn"].toString(),
        'updatedOn' : data["updatedOn"].toString()
      };

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

