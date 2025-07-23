class ServiceEngineerModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ServiceEngineerModel({this.statusCode, this.success, this.messages, this.data});

  ServiceEngineerModel.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  /// *🔹 CopyWith Method*
  ServiceEngineerModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ServiceEngineerModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  /// *🔹 Initial Factory Method*
  factory ServiceEngineerModel.initial() {
    return ServiceEngineerModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }
}

class Data {
  List<String>? serviceIds;
  List<String>? serviceEngineerImage;
  String? sId;
  String? name;
  String? mobile;
  String? role;
  String? email;
  String? address;
  int? experience;
  String? status;
  String? serviceId;
  List<String>? productIds;
  String? description;
  List<String>? dutyTimings;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? certificate;

  Data({
    this.serviceIds,
    this.serviceEngineerImage,
    this.sId,
    this.name,
    this.mobile,
    this.role,
    this.email,
    this.address,
    this.experience,
    this.status,
    this.serviceId,
    this.productIds,
    this.description,
    this.dutyTimings,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.certificate,
  });

  Data.fromJson(Map<String, dynamic> json) {
    serviceIds = json['serviceIds'].cast<String>();
    serviceEngineerImage = json['serviceEngineerImage'].cast<String>();
    sId = json['_id'];
    name = json['name'];
    mobile = json['mobile'];
    role = json['role'];
    email = json['email'];
    address = json['address'];
    experience = json['experience'];
    status = json['status'];
    serviceId = json['serviceId'];
    productIds = json['productIds'].cast<String>();
    description = json['description'];
    dutyTimings = json['dutyTimings'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    certificate = json['certificate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['serviceIds'] = serviceIds;
    data['serviceEngineerImage'] = serviceEngineerImage;
    data['_id'] = sId;
    data['name'] = name;
    data['mobile'] = mobile;
    data['role'] = role;
    data['email'] = email;
    data['address'] = address;
    data['experience'] = experience;
    data['status'] = status;
    data['serviceId'] = serviceId;
    data['productIds'] = productIds;
    data['description'] = description;
    data['dutyTimings'] = dutyTimings;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['certificate'] = certificate;
    return data;
  }

  /// *🔹 CopyWith Method*
  Data copyWith({
    List<String>? serviceIds,
    List<String>? serviceEngineerImage,
    String? sId,
    String? name,
    String? mobile,
    String? role,
    String? email,
    String? address,
    int? experience,
    String? status,
    String? serviceId,
    List<String>? productIds,
    String? description,
    List<String>? dutyTimings,
    String? createdAt,
    String? updatedAt,
    int? iV,
    String? certificate,
  }) {
    return Data(
      serviceIds: serviceIds ?? this.serviceIds,
      serviceEngineerImage: serviceEngineerImage ?? this.serviceEngineerImage,
      sId: sId ?? this.sId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      email: email ?? this.email,
      address: address ?? this.address,
      experience: experience ?? this.experience,
      status: status ?? this.status,
      serviceId: serviceId ?? this.serviceId,
      productIds: productIds ?? this.productIds,
      description: description ?? this.description,
      dutyTimings: dutyTimings ?? this.dutyTimings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
      certificate: certificate ?? this.certificate,
    );
  }

  /// *🔹 Initial Factory Method*
  factory Data.initial() {
    return Data(
      serviceIds: [],
      serviceEngineerImage: [],
      sId: '',
      name: '',
      mobile: '',
      role: '',
      email: '',
      address: '',
      experience: 0,
      status: '',
      serviceId: '',
      productIds: [],
      description: '',
      dutyTimings: [],
      createdAt: '',
      updatedAt: '',
      iV: 0,
      certificate: '',
    );
  }
}