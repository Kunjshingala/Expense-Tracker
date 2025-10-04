import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';

import 'account_bloc.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AccountBloc accountBloc;

  @override
  void didChangeDependencies() {
    accountBloc = AccountBloc(context: context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(languages.account),
      ),
    );
  }

  @override
  void dispose() {
    accountBloc.dispose();
    super.dispose();
  }
}
