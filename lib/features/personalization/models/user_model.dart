import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2_ecom/utils/formatters/formatter.dart';

class UserModel {
  final String id;
  String firstName;
  String lastName;
  final String username;
  final String email;
  String phoneNumber;
  String profilePicture;
  String fcmToken; // الحقل الجديد للإشعارات
  double walletBalance; // الحقل الأساسي هنا
  String bankName;
  String bankNoumber;

  UserModel({
    required this.id,
    this.fcmToken = "", // قيمة افتراضية فارغةs
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    this.walletBalance = 0.0,
    this.bankName = "",
    this.bankNoumber = "",
  });

  String get fullName => "$firstName $lastName";

  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  static List<String> nameParts(fullName) => fullName.split(" ");

  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String cameCaseUserName = "$firstName$lastName";
    String userNameWithPrefix = "unt_$cameCaseUserName";
    return userNameWithPrefix;
  }

  static String get getUserCollectionName => "User";
  static String get getFcmToken => "fcmToken";
  static String get getId => "Id";
  static String get getFirstName => "FirstName";
  static String get getLastName => "LastName";
  static String get getUsername => "Username";
  static String get getEmail => "Email";
  static String get getPhoneNumber => "PhoneNumber";
  static String get getProfilePicture => "ProfilePicture";
  static String get getWalletBalance => "walletBalance";
  static String get getBankName => "BankName";
  static String get getBankNoumber => "BankNoumber";

  static UserModel empty() => UserModel(
    id: "",
    firstName: "",
    lastName: "",
    username: "",
    email: "",
    phoneNumber: "",
    profilePicture: "",
  );

  Map<String, dynamic> tojson() {
    return {
      getFirstName: firstName,
      getLastName: lastName,
      getUsername: username,
      getEmail: email,
      getPhoneNumber: phoneNumber,
      getProfilePicture: profilePicture,
      getFcmToken: fcmToken, // إضافة التوكن هنا
      getWalletBalance: walletBalance,
      getBankName: bankName,
      getBankNoumber: bankNoumber,
    };
  }

  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        fcmToken: data[getFcmToken] ?? "", // قراءة التوكن هنا
        firstName: data[getFirstName] ?? "",
        lastName: data[getLastName] ?? "",
        username: data[getUsername] ?? "123",
        email: data[getEmail] ?? "",
        phoneNumber: data[getPhoneNumber] ?? "",
        profilePicture: data[getProfilePicture] ?? "",
        walletBalance: data[getWalletBalance] != null
            ? (data[getWalletBalance] as num).toDouble()
            : 0.0,
        bankName: data[getBankName] ?? "",
        bankNoumber: data[getBankNoumber] ?? "",
      );
    } else {
      return UserModel.empty();
    }
  }
}
