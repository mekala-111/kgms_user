class UserModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  UserModel({this.statusCode, this.success, this.messages, this.data});

  // Initial method
  factory UserModel.initial() {
    return UserModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  // CopyWith method
  UserModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return UserModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
     messages = json['messages'].cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? accessToken;
  String? refreshToken;
  User? user;

  Data({this.accessToken, this.refreshToken, this.user});

  // Initial method
  factory Data.initial() {
    return Data(
      accessToken: '',
      refreshToken: '',
      user: User.initial(),
    );
  }

  // CopyWith method
  Data copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
  }) {
    return Data(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  Location? location;
  String? sId;
  String? mobile;
  String? password;
  String? role;
  String? name;
  String? email;
  String? address;
  String? employeeNumber;
  String? certificate;
  String? experience;
  String? ownerName;
  List<String>? profileImage;
  String? aadhar;
  String? gstNumber;
  String? firmName;
  String? activity;
  String? products;
  String? createdAt;
  String? updatedAt;
  int? iV;

  User({
    this.location,
    this.sId,
    this.mobile,
    this.password,
    this.role,
    this.name,
    this.email,
    this.address,
    this.employeeNumber,
    this.certificate,
    this.experience,
    this.ownerName,
    this.profileImage,
    this.aadhar,
    this.gstNumber,
    this.firmName,
    this.activity,
    this.products,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  // Initial method
  factory User.initial() {
    return User(
      location : Location.initial(),
       sId: '',
      mobile: '',
      password: '',
      role: '',
      name: '',
      email: '',
      address: '',
      employeeNumber: '',
      certificate: '',
      experience: '',
      ownerName: '',
      profileImage: [],
      aadhar: '',
      gstNumber: '',
      firmName: '',
      activity: '',
      products: '',
      createdAt: '',
      updatedAt: '',
      iV: 0,
    );
  }

  // CopyWith method
  User copyWith({
     Location? location,
     String? sId,
    String? mobile,
    String? password,
    String? role,
    String? name,
    String? email,
    String? address,
    String? employeeNumber,
    String? certificate,
    String? experience,
    String? ownerName,
    List<String>? profileImage,
    String? aadhar,
    String? gstNumber,
    String? firmName,
    String? activity,
    String? products,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return User(
      location: location ?? this.location,
      sId: sId ?? this.sId,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      certificate: certificate ?? this.certificate,
      experience: experience ?? this.experience,
      ownerName: ownerName ?? this.ownerName,
      profileImage: profileImage ?? this.profileImage,
      aadhar: aadhar ?? this.aadhar,
      gstNumber: gstNumber ?? this.gstNumber,
      firmName: firmName ?? this.firmName,
      activity: activity ?? this.activity,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
    );
  }

  User.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    sId = json['_id'];
    mobile = json['mobile'];
    password = json['password'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    address = json['address'];
    employeeNumber = json['employeeNumber'];
    certificate = json['certificate'];
    experience = json['experience'];
    ownerName = json['ownerName'];
     profileImage = json['profileImage'] != null
        ? List<String>.from(json['profileImage'])
        : [];
    aadhar = json['aadhar'];
    gstNumber = json['gstNumber'];
    firmName = json['firmName'];
    activity = json['activity'];
    products = json['products'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['_id'] = sId;
    data['mobile'] = mobile;
    data['password'] = password;
    data['role'] = role;
    data['name'] = name;
    data['email'] = email;
    data['address'] = address;
    data['employeeNumber'] = employeeNumber;
    data['certificate'] = certificate;
    data['experience'] = experience;
    data['ownerName'] = ownerName;
    data['profileImage'] = profileImage;
    data['aadhar'] = aadhar;
    data['gstNumber'] = gstNumber;
    data['firmName'] = firmName;
    data['activity'] = activity;
    data['products'] = products;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
class Location {
  String? latitude;
  String? longitude;

  Location({this.latitude, this.longitude});

  Location.initial()
      : latitude = '',
        longitude = '';

  Location copyWith({
    String? latitude,
    String? longitude,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

