class AppUser{
  String uid;
  String name;
  String email;
  String password;
  String createdOn;
  String lastSignIn;


  AppUser({required this.uid,required this.name, required this.email, required this.password, required this.createdOn, required this.lastSignIn});

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
        lastSignIn: json["lastSignIn"]
    );
  }
}