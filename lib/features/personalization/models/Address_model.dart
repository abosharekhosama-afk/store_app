import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2_ecom/utils/formatters/formatter.dart';

class AddressModel {
  String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final DateTime? dateTime;
  bool selectedAddress;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.dateTime,
    this.selectedAddress = true,
  });

  static String get getId => "Id";
  static String get getName => "Name";
  static String get getPhoneNumber => "PhoneNumber";
  static String get getStreet => "Street";
  static String get getCity => "City";
  static String get getState => "State";
  static String get getPostalCode => "PostalCode";
  static String get getCountry => "Country";
  static String get getDateTime => "DateTime";
  static String get getSelectedAddress => "SelectedAddress";
  static String get getdAddressCollection => "Addresses";

  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  static AddressModel empty() => AddressModel(
    id: "",
    name: "",
    phoneNumber: "",
    street: "",
    city: "",
    state: "",
    postalCode: "",
    country: "",
  );

  Map<String, dynamic> toJson() {
    return {
      getId: id,
      getName: name,
      getPhoneNumber: phoneNumber,
      getStreet: street,
      getCity: city,
      getState: state,
      getPostalCode: postalCode,
      getCountry: country,
      getDateTime: DateTime.now(),
      getSelectedAddress: selectedAddress,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> data) {
    return AddressModel(
      id: data[getId] as String,
      name: data[getName] as String,
      phoneNumber: data[getPhoneNumber] as String,
      street: data[getStreet] as String,
      city: data[getCity] as String,
      state: data[getState] as String,
      postalCode: data[getPostalCode] as String,
      country: data[getCountry] as String,
      selectedAddress: data[getSelectedAddress] as bool,
      dateTime: (data[getDateTime] as Timestamp).toDate(),
    );
  }

  factory AddressModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AddressModel(
      id: snapshot.id,
      name: data[getName] ?? "",
      phoneNumber: data[getPhoneNumber] ?? "",
      street: data[getStreet] ?? "",
      city: data[getCity] ?? "",
      state: data[getState] ?? "",
      postalCode: data[getPostalCode] ?? "",
      country: data[getCountry] ?? "",
      selectedAddress: data[getSelectedAddress] as bool,
      dateTime: (data[getDateTime] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$street, $city, $state, $postalCode, $country";
  }
}
