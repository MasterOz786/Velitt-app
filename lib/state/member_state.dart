import 'package:flutter/material.dart';

class MemberState extends ChangeNotifier {
  String? memberId;
  String? memberEmail;
  String? memberName;
  String? profileImage;
  double memberCoins;

  MemberState({
    this.memberId,
    this.memberEmail,
    this.memberName,
    this.memberCoins = 0,
    this.profileImage,
  });

  /// Updates the member data and notifies listeners.
  void updateMember({
    required String id,
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
