import 'package:flutter/foundation.dart';
import '../service/authoMethod.dart';

import '../service/user.dart';

class UserProviders with ChangeNotifier {
  Users? _user;
  final Authomethod _authomethod = Authomethod();

  Users get getUser => _user!;

  Future<void> refreshUser() async {
    Users user = await _authomethod.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
