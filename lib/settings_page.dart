import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';

class SettingsPage extends StatelessWidget {

  GlobalKey<NavigatorState> nk;
  SettingsPage(this.nk, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: bc_style().accent2color,
        leading: IconButton(
              onPressed: (() {nk.currentState!.pop();}),
              icon: Icon(Icons.arrow_back_sharp, size: 32,)
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton(
                onPressed: (() {
                }),
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                    child: Text(
                      'Dark Theme',
                      style: TextStyle(
                          fontSize: 30
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton(
                onPressed: (() {
                  FirebaseAuth.instance.signOut();
                }),
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                          fontSize: 30
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}