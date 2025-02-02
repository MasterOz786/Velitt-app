import 'package:flutter/material.dart';

class MemberState extends ChangeNotifier {
  int memberId;
  String? memberEmail;
  String? memberName;
  String? profileImage;
  double memberCoins;

  MemberState({
    this.memberId = 121,
    this.memberEmail,
    this.memberName,
    this.memberCoins = 0,
    this.profileImage,
  });

  /// Updates the member data and notifies listeners.
  void updateMember({
    required int id,
    required String email,
    required String name,
    required String image,
    required double coins,
  }) {
    memberId = id;
    memberEmail = email;
    memberName = name;
    profileImage = image;
    memberCoins = coins;
    notifyListeners();
  }
}
