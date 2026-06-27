import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModelNew {
  String id;
  String country;
  String city;
  String district;
  String street;
  String buildingNumber;
  String postalCode;
  String address;
  final DateTime? dateTime;
  bool selectedAddress;

  AddressModelNew({
    this.id = "",
    this.dateTime,
    required this.country,
    required this.city,
    required this.district,
    required this.street,
    required this.buildingNumber,
    required this.postalCode,
    required this.address,
    this.selectedAddress = true,
  });

  static String get getId => "Id";
  static String get getCountry => "country";
  static String get getCity => "city";
  static String get getDistrict => "district";
  static String get getStreet => "street";
  static String get getBuildingNumber => "buildingNumber";
  static String get getPostalCode => "postalCode";
  static String get getAddress => "address";
  static String get getSelectedAddress => "SelectedAddress";
  static String get getdAddressCollection => "Addresses";
  static String get getDateTime => "DateTime";

  String get fullAddress => "$city, $district, $street ";
  String get fullAddressWithPostCode =>
      "$country, $city, $district, $street $buildingNumber, $postalCode";

  static AddressModelNew empty() => AddressModelNew(
    id: "",
    country: "",
    city: "",
    district: "",
    street: "",
    buildingNumber: "",
    postalCode: "",
    address: "",
  );

  Map<String, dynamic> toJson() {
    return {
      getId: id,
      getCountry: country,
      getCity: city,
      getDistrict: district,
      getStreet: street,
      getBuildingNumber: buildingNumber,
      getPostalCode: postalCode,
      getAddress: address,
      getDateTime: DateTime.now(),
      getSelectedAddress: selectedAddress,
    };
  }

  AddressModelNew copyWith({
    String? country,
    String? city,
    String? district,
    String? street,
    String? buildingNumber,
    String? postalCode,
    String? address,
    String? id,
  }) {
    return AddressModelNew(
      id: id ?? this.id,
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
    );
  }

  factory AddressModelNew.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() != null) {
      final data = document.data()!;
      return AddressModelNew(
        id: data[getId] as String,
        country: data[getCountry] ?? "",
        city: data[getCity] ?? "",
        district: data[getDistrict] ?? "",
        street: data[getStreet] ?? "",
        address: data[getAddress] ?? "",
        buildingNumber: data[getBuildingNumber] ?? "",
        postalCode: data[getPostalCode] ?? "",
      );
    } else {
      return AddressModelNew.empty();
    }
  }

  factory AddressModelNew.fromMap(Map<String, dynamic> data) {
    return AddressModelNew(
      id: data[getId] as String,
      country: data[getCountry] ?? "",
      city: data[getCity] ?? "",
      district: data[getDistrict] ?? "",
      street: data[getStreet] ?? "",
      buildingNumber: data[getBuildingNumber] ?? "",
      postalCode: data[getPostalCode] ?? "",
      address: data[getAddress] ?? "",
      selectedAddress: data[getSelectedAddress] as bool,
      dateTime: (data[getDateTime] as Timestamp).toDate(),
    );
  }

  factory AddressModelNew.fromMapToStore(Map<String, dynamic> data) {
    return AddressModelNew(
      country: data[getCountry] ?? "",
      city: data[getCity] ?? "",
      district: data[getDistrict] ?? "",
      street: data[getStreet] ?? "",
      buildingNumber: data[getBuildingNumber] ?? "",
      postalCode: data[getPostalCode] ?? "",
      address: data[getAddress] ?? "",
    );
  }

  factory AddressModelNew.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AddressModelNew(
      id: snapshot.id,
      country: data[getCountry] ?? "",
      city: data[getCity] ?? "",
      district: data[getDistrict] ?? "",
      street: data[getStreet] ?? "",
      buildingNumber: data[getBuildingNumber] ?? "",
      postalCode: data[getPostalCode] ?? "",
      address: data[getAddress] ?? "",
      selectedAddress: data[getSelectedAddress] as bool,
      dateTime: (data[getDateTime] as Timestamp).toDate(),
    );
  }
}
