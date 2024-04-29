import 'dart:core';

import 'package:expense_tracker/ui/common_view/logout_bottom_sheet.dart';
import 'package:expense_tracker/ui/screens/account/account_screen.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../modals/local_modal/profile_screen_modal.dart';
import '../../../../utils/custom_icons.dart';
import 'profile_widget/edit_name_dialog.dart';

class ProfileBloc {
  final BuildContext context;

  ProfileBloc({required this.context});

  final auth = FirebaseAuth.instance;

  List<ProfileFeatureOption> profileFeatureOptionList = [];

  final editNameController = TextEditingController();

  final basicUserDetailsSubject = BehaviorSubject<UserDetails>();
  Stream<UserDetails> get getBasicUserDetails => basicUserDetailsSubject.stream;
  Function(UserDetails) get setBasicUserDetails => basicUserDetailsSubject.add;

  final changeNameProcessStatusSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get getChangeNameProcessStatus => changeNameProcessStatusSubject.stream;
  Function(bool) get setChangeNameProcessStatus => changeNameProcessStatusSubject.add;

  void getBasicDetails() async {
    final currentUserStream = auth.userChanges();

    currentUserStream.listen((currentUser) {
      String name = currentUser!.displayName != null && currentUser.displayName!.isNotEmpty
          ? currentUser.displayName!
          : 'Set your name!';
      final profileUrl = currentUser.photoURL ??
          'https://images.unsplash.com/photo-1567436670499-8d4129485548?q=80&w=2029&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

      setBasicUserDetails(UserDetails(name: name, profileUrl: profileUrl));
    });
  }

  void getProfileFeatureList() {
    profileFeatureOptionList = [
      ProfileFeatureOption(
        iconData: CustomIcons.wallet_icons,
        iconColor: violet100Color,
        iconBG: violet20Color,
        label: 'Account',
        onPressed: account,
      ),
      ProfileFeatureOption(
        iconData: CustomIcons.settings_icons,
        iconColor: violet100Color,
        iconBG: violet20Color,
        label: 'Settings',
        onPressed: null,
      ),
      ProfileFeatureOption(
        iconData: CustomIcons.expense_icons,
        iconColor: violet100Color,
        iconBG: violet20Color,
        label: 'Export Data',
        onPressed: null,
      ),
      ProfileFeatureOption(
        iconData: CustomIcons.logout_icons,
        iconColor: red100Color,
        iconBG: red20Color,
        label: 'Logout',
        onPressed: logout,
      ),
    ];
  }

  void account() {
    pushWithoutNavBar(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
  }

  void editName() {
    showDialog(
      context: context,
      builder: (context) => EditNameDialog(
        editNameController: editNameController,
        getChangeNameProcessStatus: getChangeNameProcessStatus,
        setChangeNameProcessStatus: setChangeNameProcessStatus,
      ),
    );
  }

  void logout() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: light100Color,
      builder: (context) => const LogoutBottomSheet(),
    );
  }

  void dispose() {
    basicUserDetailsSubject.close();
    editNameController.dispose();
    changeNameProcessStatusSubject.close();
  }
}
