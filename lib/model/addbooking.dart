class BookingModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  Data? data;

  BookingModel({this.statusCode, this.success, this.messages, this.data});

  BookingModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages']?.cast<String>();
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

  /// Creates a copy of the object with optional updated values
  BookingModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    Data? data,
  }) {
    return BookingModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  /// Returns an initial empty instance
  factory BookingModel.initial() {
    return BookingModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: Data.initial(),
    );
  }
}

class Data {
  String? userId;
  List<String>? productIds;
  String? location;
  String? address;
  String? status;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.userId,
    this.productIds,
    this.location,
    this.address,
    this.status,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    productIds = json['productIds']?.cast<String>();
    location = json['location'];
    address = json['address'];
    status = json['status'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['productIds'] = productIds;
    data['location'] = location;
    data['address'] = address;
    data['status'] = status;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }

  /// Creates a copy of the object with optional updated values
  Data copyWith({
    String? userId,
    List<String>? productIds,
    String? location,
    String? address,
    String? status,
    String? sId,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return Data(
      userId: userId ?? this.userId,
      productIds: productIds ?? this.productIds,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      sId: sId ?? this.sId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
    );
  }

  /// Returns an initial empty instance
  factory Data.initial() {
    return Data(
      userId: '',
      productIds: [],
      location: '',
      address: '',
      status: '',
      sId: '',
      createdAt: '',
      updatedAt: '',
      iV: 0,
    );
  }
}
