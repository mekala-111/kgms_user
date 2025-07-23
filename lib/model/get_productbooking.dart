class GetproductModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  GetproductModel({this.statusCode, this.success, this.messages, this.data});

  GetproductModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return GetproductModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  factory GetproductModel.initial() {
    return GetproductModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  GetproductModel.fromJson(Map<String, dynamic> json) {
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
    final data = <String, dynamic>{};
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
  String? sId;
  UserId? userId;
  String? otp;
  double? totalPrice;
  double? paidPrice;
  String? type;
  List<ProductIds>? productIds;
  String? location;
  String? address;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data({
     this.sId,
    this.userId,
    this.otp,
    this.totalPrice,
    this.paidPrice,
    this.type,
    this.productIds,
    this.location,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Data copyWith({
    String? sId,
    UserId? userId,
    String? otp,
    double? totalPrice,
    double? paidPrice,
    String? type,
    List<ProductIds>? productIds,
    String? location,
    String? address,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
      sId: sId ?? this.sId,
      userId: userId ?? this.userId,
      otp: otp ?? this.otp,
      totalPrice: totalPrice ?? this.totalPrice,
      paidPrice: paidPrice ?? this.paidPrice,
      type: type ?? this.type,
      productIds: productIds ?? this.productIds,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Data.initial() {
    return Data(
       sId: '',
        userId: UserId.initial(),
        otp: '',
        totalPrice: 0.0,
        paidPrice: null,
        type: '',
        productIds: [],
        location: '',
        address: '',
        status: '',
        createdAt: '',
        updatedAt: '',
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    otp = json['Otp'];
    totalPrice =(json['totalPrice'] ?? 0).toDouble();
    paidPrice = json['paidPrice'] != null ? (json['paidPrice'] as num).toDouble() : null;
    type = json['type'];
    if (json['productIds'] != null) {
      productIds = <ProductIds>[];
      json['productIds'].forEach((v) {
        productIds!.add(ProductIds.fromJson(v));
      });
    }
    location = json['location'];
    address = json['address'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    if (userId != null) data['userId'] = userId!.toJson();
    data['Otp'] = otp;
    data['totalPrice'] = totalPrice;
    data['paidPrice'] = paidPrice;
    data['type'] = type;
    if (productIds != null) {
      data['productIds'] = productIds!.map((v) => v.toJson()).toList();
    }
    data['location'] = location;
    data['address'] = address;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    
    return data;
  }
}
class UserId {
  String? sId;
  String? name;
  String? email;
  String? mobile;
  List<String>? profileImage;

  UserId({this.sId, this.name, this.email, this.mobile, this.profileImage});

  UserId copyWith({
    String? sId,
    String? name,
    String? email,
    String? mobile,
    List<String>? profileImage,
  }) {
    return UserId(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  factory UserId.initial() {
    return UserId(
      sId: '',
      name: '',
      email: '',
      mobile: '',
      profileImage: [],
    );
  }

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    profileImage = json['profileImage'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['profileImage'] = profileImage;
    return data;
  }
}
class ProductIds {
  String? sId;
  String? productName;
  String? productDescription;
  int? price;
  int? quantity;
  double? userPrice;
  String? bookingStatus;
  String? category;
  String? spareParts;
  List<String>? productImages;
  int? availableStock;
  DistributorId? distributorId;

  ProductIds({
    this.sId,
    this.productName,
    this.productDescription,
    this.price,
    this.quantity,
    this.userPrice,
    this.bookingStatus,
    this.category,
    this.spareParts,
    this.productImages,
    this.availableStock,
    this.distributorId,
  });

   ProductIds copyWith({
    String? sId,
    String? productName,
    String? productDescription,
    int? price,
    int? quantity,
    double? userPrice,
    String? bookingStatus,
    String? category,
    String? spareParts,
    List<String>? productImages,
    int? availableStock,
    DistributorId? distributorId,
  }) {
    return ProductIds(
      sId: sId ?? this.sId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      userPrice: userPrice ?? this.userPrice,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      category: category ?? this.category,
      spareParts: spareParts ?? this.spareParts,
      productImages: productImages ?? this.productImages,
      availableStock: availableStock ?? this.availableStock,
      distributorId: distributorId ?? this.distributorId,
    );
  }


  factory ProductIds.initial() => ProductIds(
        sId: '',
        productName: '',
        productDescription: '',
        price: 0,
        quantity: 0,
        userPrice: 0.0,
        bookingStatus: '',
        category: '',
        spareParts: '',
        productImages: [],
        availableStock: 0,
        distributorId: DistributorId.initial(),
      );

  ProductIds.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    price = json['price'];
    quantity = json['quantity'];
    // userPrice = json['userPrice'];
    userPrice = json['userPrice'] != null
    ? (json['userPrice'] is int
        ? (json['userPrice'] as int).toDouble()
        : json['userPrice'])
    : null;

    bookingStatus = json['bookingStatus'];
    category = json['category'];
    spareParts = json['spareParts'];
    productImages = json['productImages'].cast<String>();
    availableStock = json['availableStock'];
    distributorId = json['distributorId'] != null
        ? DistributorId.fromJson(json['distributorId'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['price'] = price;
    data['quantity'] = quantity;
    data['userPrice'] = userPrice;
    data['bookingStatus'] = bookingStatus;
    data['category'] = category;
    data['spareParts'] = spareParts;
    data['productImages'] = productImages;
    data['availableStock'] = availableStock;
    if (distributorId != null) {
      data['distributorId'] = distributorId!.toJson();
    }
    return data;
  }
}
class DistributorId {
  String? sId;
  String? firmName;
  String? ownerName;

  DistributorId({this.sId, this.firmName, this.ownerName});

  DistributorId copyWith({
    String? sId,
    String? firmName,
    String? ownerName,
  }) {
    return DistributorId(
      sId: sId ?? this.sId,
      firmName: firmName ?? this.firmName,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  factory DistributorId.initial() {
    return DistributorId(
      sId: '',
      firmName: '',
      ownerName: '',
    );
  }

  DistributorId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firmName = json['firmName'];
    ownerName = json['ownerName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['firmName'] = firmName;
    data['ownerName'] = ownerName;
    return data;
  }
}
