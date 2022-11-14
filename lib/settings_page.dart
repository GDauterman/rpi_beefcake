import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';

class SettingsPage extends StatelessWidget {

  GlobalKey<NavigatorState> nk;
  void Function() swapTheme;
  SettingsPage(this.nk, this.swapTheme, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
          backgroundColor: Theme.of(context).colorScheme.background,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: (() {
                  swapTheme();
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
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