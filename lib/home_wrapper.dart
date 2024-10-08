import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perairan_ngale/utils/auth_utils.dart';

@RoutePage()
class HomeWrapperPage extends StatefulWidget {
  const HomeWrapperPage({super.key});

  @override
  State<HomeWrapperPage> createState() => _HomeWrapperPageState();
}

class _HomeWrapperPageState extends State<HomeWrapperPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (await isAdmin(user.uid)) {
        AutoRouter.of(context).replace(AdminMenuRoute());
      } else if (await isEmployee(user.uid)) {
        AutoRouter.of(context).replace(EmployeeHomeRoute());
      } else if (await isCustomer(user.uid)) {
        AutoRouter.of(context).replace(CustomerHomeRoute());
      } else {
        AutoRouter.of(context).replace(LoginRoute());
      }
    } else {
      AutoRouter.of(context).replace(LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
