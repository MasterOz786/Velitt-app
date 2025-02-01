import 'package:flutter/material.dart';

class MemberState extends ChangeNotifier {
  String? memberId;
  String? memberEmail;
  String? memberName;
  String? profileImage;

  /// Updates the member data and notifies listeners.
  void updateMember({
    required String id,
    required String email,
    required String name,
    required String image,
  }) {
    memberId = id;
    memberEmail = email;
    memberName = name;
    profileImage = image;
    notifyListeners();
  }
}
