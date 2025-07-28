import 'package:flutter/material.dart';

class ServiceModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  static String? name;

  ServiceModel({this.statusCode, this.success, this.messages, this.data});

  factory ServiceModel.initial() => ServiceModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

  ServiceModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ServiceModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  ServiceModel.fromJson(Map<String, dynamic> json) {
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

  when({required Widget Function(dynamic services) data, required Center Function() loading, required Center Function(dynamic error, dynamic stackTrace) error}) {}
}

class Data {
  String? sId;
  String? name;
  String? details;
  int? price;
  String? distributorId;
  List<String>? productIds;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.name,
    this.details,
    this.price,
    this.distributorId,
    this.productIds,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory Data.initial() => Data(
        sId: '',
        name: '',
        details: '',
        price: 0,
        distributorId: '',
        productIds: [],
        createdAt: '',
        updatedAt: '',
        iV: 0,
      );

  Data copyWith({
    String? sId,
    String? name,
    String? details,
    int? price,
    String? distributorId,
    List<String>? productIds,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return Data(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      details: details ?? this.details,
      price: price ?? this.price,
      distributorId: distributorId ?? this.distributorId,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    details = json['details'];
    price = json['price'];
    distributorId = json['distributorId'];
    productIds = json['productIds'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['details'] = details;
    data['price'] = price;
    data['distributorId'] = distributorId;
    data['productIds'] = productIds;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
