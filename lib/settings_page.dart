import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/profile_page.dart';
import 'package:rpi_beefcake/style_lib.dart';

class SettingsPage extends StatelessWidget {

  void Function() swapTheme;
  SettingsPage(this.swapTheme, {Key? key}) : super(key: key);

  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
              onPressed: (() {Navigator.of(context).pop();}),
              icon: Icon(Icons.arrow_back_sharp, size: 32,)
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(

            ),
            Padding(
              padding: EdgeInsets.only(top:15),
              child: ElevatedButton.icon(
                icon: Icon(Icons.update_rounded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: (() {
                  Navigator.of(context).pushNamed('/profile');
                }),
                label: Text(
                  'Update Goals',
                  style: TextStyle(
                      fontSize: 30
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton.icon(
                icon: (this.dark == false) ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: swapTheme,
                label: Text(
                  'Toggle Dark Mode',
                  style: TextStyle(
                      fontSize: 30
                  ),
                ),
              )
              ),
            //),
            Padding(
              padding: EdgeInsets.only(top:15),
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: (() {
                  FirebaseAuth.instance.signOut();
                }),
                label: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 30
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