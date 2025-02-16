import 'package:flutter/material.dart';

class MemberState extends ChangeNotifier {
  int memberId;
  String? memberEmail;
  String? memberName;
  String? profileImage;
  double memberCoins;
  
  // Additional profile fields
  String? firstName;
  String? middleName;
  String? lastName;
  String? telephone;
  String? mobile;
  String? dateOfBirth;
  String? agreementEffectiveDate;
  String? notes;
  
  MemberState({
    this.memberId = 0,
    this.memberEmail,
    this.memberName,
    this.profileImage,
    this.memberCoins = 0,
    this.firstName,
    this.middleName,
    this.lastName,
    this.telephone,
    this.mobile,
    this.dateOfBirth,
    this.agreementEffectiveDate,
    this.notes,
  });
  
  /// Updates all member data at once and notifies listeners.
  void updateMember({
    required int id,
    required String email,
    required String name,
    required String image,
    required double coins,
    required String firstName,
    required String middleName,
    required String lastName,
    required String telephone,
    required String mobile,
    required String dateOfBirth,
    required String agreementEffectiveDate,
    required String notes,
  }) {
    memberId = id;
    memberEmail = email;
    memberName = name;
    profileImage = image;
    memberCoins = coins;
    this.firstName = firstName;
    this.middleName = middleName;
    this.lastName = lastName;
    this.telephone = telephone;
    this.mobile = mobile;
    this.dateOfBirth = dateOfBirth;
    this.agreementEffectiveDate = agreementEffectiveDate;
    this.notes = notes;
    notifyListeners();
  }
  
  /// Updates only the fields provided (non-null) and notifies listeners.
  void updateMemberPartial({
    int? id,
    String? email,
    String? name,
    String? image,
    double? coins,
    String? firstName,
    String? middleName,
    String? lastName,
    String? telephone,
    String? mobile,
    String? dateOfBirth,
    String? agreementEffectiveDate,
    String? notes,
  }) {
    if (id != null) memberId = id;
    if (email != null) memberEmail = email;
    if (name != null) memberName = name;
    if (image != null) profileImage = image;
    if (coins != null) memberCoins = coins;
    if (firstName != null) this.firstName = firstName;
    if (middleName != null) this.middleName = middleName;
    if (lastName != null) this.lastName = lastName;
    if (telephone != null) this.telephone = telephone;
    if (mobile != null) this.mobile = mobile;
    if (dateOfBirth != null) this.dateOfBirth = dateOfBirth;
    if (agreementEffectiveDate != null) this.agreementEffectiveDate = agreementEffectiveDate;
    if (notes != null) this.notes = notes;
    notifyListeners();
  }
  
  /// Updates the member state from a JSON/map.
  /// Keys should match your API's response keys.
  void updateFromMap(Map<String, dynamic> data) {
    memberId = data['id'] ?? memberId;
    memberEmail = data['email'] ?? memberEmail;
    memberName = data['name'] ?? memberName;
    profileImage = data['profileImage'] ?? profileImage;
    if (data['coins'] != null) {
      memberCoins = data['coins'] is int
          ? (data['coins'] as int).toDouble()
          : data['coins'];
    }
    firstName = data['first_name'] ?? firstName;
    middleName = data['middle_name'] ?? middleName;
    lastName = data['last_name'] ?? lastName;
    telephone = data['telephone'] ?? telephone;
    mobile = data['mobile'] ?? mobile;
    dateOfBirth = data['date_of_birth'] ?? dateOfBirth;
    agreementEffectiveDate = data['agreement_effective_date'] ?? agreementEffectiveDate;
    notes = data['notes'] ?? notes;
    notifyListeners();
  }
  
  /// Updates only the coins value and notifies listeners.
  void updateCoins(double coins) {
    memberCoins = coins;
    notifyListeners();
  }
}
