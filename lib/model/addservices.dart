class AddservicesModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  Data? data;

  AddservicesModel({this.statusCode, this.success, this.messages, this.data});

  AddservicesModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages'].cast<String>();
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  AddservicesModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    Data? data,
  }) {
    return AddservicesModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  static AddservicesModel initial() {
    return AddservicesModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: Data.initial(),
    );
  }
}

class Data {
  String? userId;
  List<String>? serviceId;
  String? location;
  String? address;
  String? date;
  String? time;
  String? status;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.userId,
    this.serviceId,
    this.location,
    this.address,
    this.date,
    this.time,
    this.status,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    serviceId = json['serviceId'].cast<String>();
    location = json['location'];
    address = json['address'];
    date = json['date'];
    time = json['time'];
    status = json['status'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['serviceId'] = serviceId;
    data['location'] = location;
    data['address'] = address;
    data['date'] = date;
    data['time'] = time;
    data['status'] = status;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }

  Data copyWith({
    String? userId,
    List<String>? serviceId,
    String? location,
    String? address,
    String? date,
    String? time,
    String? status,
    String? sId,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return Data(
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      location: location ?? this.location,
      address: address ?? this.address,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      sId: sId ?? this.sId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
    );
  }

  static Data initial() {
    return Data(
      userId: "",
      serviceId: [],
      location: "",
      address: "",
      date: '',
      time: '',
      status: "",
      sId: "",
      createdAt: "",
      updatedAt: "",
      iV: 0,
    );
  }
}
