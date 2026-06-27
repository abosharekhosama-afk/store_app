import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/utils/constants/enums.dart';
import 'package:untitled2_ecom/utils/formatters/formatter.dart';

class StoreModel {
  final String storeId;
  String firstName;
  String lastName;
  final String storName;
  final String email;
  String phoneNumber;
  String banckAcountNumber;
  String profilePicture;
  String storeLogo;
  String storeBanner;
  String storeDescription;
  AddressModelNew addressModel;
  bool isOpen;
  Map<String, Map<String, dynamic>>? workingHours;
  StoreStatus storeStatus;
  bool isVerified;
  double commissionRate;
  double totalSales;
  double rating;
  DateTime? createdAt;
  DateTime? updatedAt;

  StoreModel({
    required this.storeId,
    required this.firstName,
    required this.lastName,
    required this.storName,
    required this.banckAcountNumber,
    required this.storeLogo,
    required this.storeBanner,
    required this.storeDescription,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.addressModel,
    required this.isOpen,
    required this.isVerified,
    required this.rating,
    required this.storeStatus,
    required this.workingHours,
    required this.commissionRate,
    required this.totalSales,
    required this.createdAt,
    required this.updatedAt,
  });

  static String get getStoreCollectionName => "Stores";
  static String get getStoreId => "storeId";
  static String get getUpdatedAt => "updatedAt";
  static String get getCreatedAt => "createdAt";
  static String get getTotalSales => "totalSales";
  static String get getCommissionRate => "commissionRate";
  static String get getStoreStatus => "storeStatus";
  static String get getRating => "rating";
  static String get getIsVerified => "isVerified";
  static String get getIsOpen => "isOpen";
  static String get getBanckAcountNumber => "banckAcountNumber";
  static String get getAddressModel => "addressModel";
  static String get getProfilePicture => "profilePicture";
  static String get getPhoneNumber => "phoneNumber";
  static String get getStoreDescription => "storeDescription";
  static String get getStoreBanner => "storeBanner";
  static String get getStoreLogo => "storeLogo";
  static String get getStorName => "storName";
  static String get getEmail => "email";
  static String get getLastName => "lastName";
  static String get getFirstName => "firstName";
  static String get getWorkingHours => "workingHours";

  String get fullName => "$firstName $lastName";

  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  String get fullAddress => addressModel.fullAddress;

  static List<String> nameParts(fullName) => fullName.split(" ");

  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String cameCaseUserName = "$firstName$lastName";
    String userNameWithPrefix = "unt_$cameCaseUserName";
    return userNameWithPrefix;
  }

  static StoreModel empty() => StoreModel(
    storeId: "",
    firstName: "",
    lastName: "",
    storName: "",
    storeLogo: "",
    storeBanner: "",
    storeDescription: "",
    email: "",
    phoneNumber: "",
    banckAcountNumber: "",
    profilePicture: "",
    addressModel: AddressModelNew.empty(),
    isOpen: false,
    isVerified: false,
    rating: 0.0,
    storeStatus: StoreStatus.suspended,
    workingHours: {},
    commissionRate: 0.0,
    totalSales: 0.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      getStoreId: storeId,
      getFirstName: firstName,
      getLastName: lastName,
      getStorName: storName,
      getEmail: email,
      getPhoneNumber: phoneNumber,
      getProfilePicture: profilePicture,
      getStoreLogo: storeLogo,
      getStoreBanner: storeBanner,
      getStoreDescription: storeDescription,
      getBanckAcountNumber: banckAcountNumber,
      getAddressModel: addressModel.toJson(),
      getIsOpen: isOpen,
      getWorkingHours: workingHours,
      getStoreStatus: storeStatus.name,
      getIsVerified: isVerified,
      getCommissionRate: commissionRate,
      getTotalSales: totalSales,
      getRating: rating,
      getCreatedAt: createdAt?.toIso8601String(),
      getUpdatedAt: updatedAt?.toIso8601String(),
    };
  }

  StoreModel copyWith({
    String? storeId,
    String? firstName,
    String? lastName,
    String? storName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? storeLogo,
    String? storeBanner,
    String? storeDescription,
    String? banckAcountNumber,
    AddressModelNew? addressModel,
    bool? isOpen,
    Map<String, Map<String, dynamic>>? workingHours,
    StoreStatus? storeStatus,
    bool? isVerified,
    double? commissionRate,
    double? totalSales,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      storeId: storeId ?? this.storeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      storName: storName ?? this.storName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      storeLogo: storeLogo ?? this.storeLogo,
      storeBanner: storeBanner ?? this.storeBanner,
      storeDescription: storeDescription ?? this.storeDescription,
      banckAcountNumber: banckAcountNumber ?? this.banckAcountNumber,
      addressModel: addressModel ?? this.addressModel,
      isOpen: isOpen ?? this.isOpen,
      workingHours: workingHours ?? this.workingHours,
      storeStatus: storeStatus ?? this.storeStatus,
      isVerified: isVerified ?? this.isVerified,
      commissionRate: commissionRate ?? this.commissionRate,
      totalSales: totalSales ?? this.totalSales,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StoreModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) return StoreModel.empty();

    // دالة مساعدة لتحويل القيم الرقمية بأمان (لتجنب أخطاء int vs double)
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    return StoreModel(
      storeId: document.id,
      // تأكدنا أن كل النصوص تأخذ قيمة افتراضية إذا كانت Null
      firstName: data[getFirstName]?.toString() ?? "",
      lastName: data[getLastName]?.toString() ?? "",
      storName: data[getStorName]?.toString() ?? "",
      email: data[getEmail]?.toString() ?? "",
      phoneNumber: data[getPhoneNumber]?.toString() ?? "",
      profilePicture: data[getProfilePicture]?.toString() ?? "",
      storeLogo: data[getStoreLogo]?.toString() ?? "",
      storeBanner: data[getStoreBanner]?.toString() ?? "",
      storeDescription: data[getStoreDescription]?.toString() ?? "",
      banckAcountNumber: data[getBanckAcountNumber]?.toString() ?? "",

      // حماية موديل العنوان (تأكد أن fromMap داخل AddressModelNew محمية أيضاً)
      addressModel: data[getAddressModel] != null
          ? AddressModelNew.fromMapToStore(data[getAddressModel])
          : AddressModelNew.empty(),

      isOpen: data[getIsOpen] ?? false,
      isVerified: data[getIsVerified] ?? false,

      // معالجة الخريطة المتداخلة بشكل صريح لتجنب أخطاء النوع
      workingHours: (data[getWorkingHours] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      ),

      storeStatus: StoreStatus.values.firstWhere(
        (e) => e.name == data[getStoreStatus],
        orElse: () => StoreStatus.suspended,
      ),

      commissionRate: toDouble(data[getCommissionRate]),
      totalSales: toDouble(data[getTotalSales]),
      rating: toDouble(data[getRating]),

      // معالجة التاريخ سواء كان String أو Timestamp (مهم جداً لـ Firebase)
      createdAt: _parseDate(data[getCreatedAt]),
      updatedAt: _parseDate(data[getUpdatedAt]),
    );
  }

  /// دالة تأخذ QuerySnapshot من نوع Object وتتعامل معه بأمان
  static List<StoreModel> fromQuerySnapshot(QuerySnapshot<Object?> snapshot) {
    return snapshot.docs.map((doc) {
      // نقوم بتحويل النوع يدوياً هنا لضمان التوافق مع DocumentSnapshot<Map<String, dynamic>>
      final mapDoc = doc as DocumentSnapshot<Map<String, dynamic>>;
      return StoreModel.fromSnapshot(mapDoc);
    }).toList();
  }

  // دالة ذكية لتحويل التاريخ من أي صيغة تأتي من Firebase
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate(); // إذا كان من نوع Timestamp
    if (date is String) return DateTime.tryParse(date); // إذا كان String
    return null;
  }

  /*
  factory StoreModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() != null) {
      final data = document.data()!;
      return StoreModel(
        storeId: document.id,
        firstName: data[getFirstName] ?? "",
        lastName: data[getLastName] ?? "",
        storName: data[getStorName] ?? "",
        email: data[getEmail] ?? "",
        phoneNumber: data[getPhoneNumber] ?? "",
        profilePicture: data[getProfilePicture] ?? "",
        storeLogo: data[getStoreLogo] ?? "",
        storeBanner: data[getStoreBanner] ?? "",
        storeDescription: data[getStoreDescription] ?? "",
        banckAcountNumber: data[getBanckAcountNumber] ?? "",
        addressModel: AddressModelNew.fromMap(data[getAddressModel] ?? {}),
        isOpen: data[getIsOpen] ?? false,
        workingHours: data[getWorkingHours] ?? {},
        storeStatus: StoreStatus.values.firstWhere(
          (e) => e.name == data[getStoreStatus],
          orElse: () => StoreStatus.suspended,
        ),
        isVerified: data[getIsVerified] ?? false,
        commissionRate: (data[getCommissionRate] ?? 0.0).toDouble(),
        totalSales: (data[getTotalSales] ?? 0.0).toDouble(),
        rating: (data[getRating] ?? 0.0).toDouble(),
        createdAt: data[getCreatedAt] != null
            ? DateTime.parse(data[getCreatedAt])
            : null,
        updatedAt: data[getUpdatedAt] != null
            ? DateTime.parse(data[getUpdatedAt])
            : null,
      );
    } else {
      return StoreModel.empty();
    }
  }
  
  */
  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}
