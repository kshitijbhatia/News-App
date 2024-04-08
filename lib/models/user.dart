class AppUser{
  String name;
  String email;
  String password;
  DateTime createdOn;


  AppUser({required this.name, required this.email, required this.password, required this.createdOn});

  Map<String, dynamic> toJson(){
    return {
      "name" : name,
      "email" : email,
      "password" : password,
      "createdOn" : createdOn
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json){
    return AppUser(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        createdOn: json["createdOn"]
    );
  }
}