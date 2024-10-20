import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dttube/model/profilemodel.dart';
import 'package:dttube/model/successmodel.dart';
import 'package:dttube/webservice/apiservice.dart';

class UpdateprofileProvider extends ChangeNotifier {
  SuccessModel updateprofileModel = SuccessModel();
  ProfileModel profileModel = ProfileModel();
  bool loading = false;

  getupdateprofile(String userid, String fullname, String channelName,
      String email, String number, File image, File coverImage) async {
    loading = true;
    updateprofileModel = await ApiService().updateprofile(
        userid, fullname, channelName, email, number, image, coverImage);
    loading = false;
    notifyListeners();
  }

  getprofile(touserid) async {
    loading = true;
    profileModel = await ApiService().profile(touserid);
    loading = false;
    notifyListeners();
  }
}
