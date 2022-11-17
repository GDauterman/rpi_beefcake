import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback swapTheme;
  SettingsPage(this.swapTheme, {Key? key}) : super(key: key);

  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
              onPressed: (() {
                Navigator.of(context).pop();
              }),
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 32,
              ))),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.update_rounded),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: (() {
                Navigator.of(context).pushNamed('/profile');
              }),
              label: const Text(
                'Update Goals',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton.icon(
                icon: (dark == false)
                    ? const Icon(Icons.light_mode)
                    : const Icon(Icons.dark_mode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: swapTheme,
                label: const Text(
                  'Toggle Dark Mode',
                  style: TextStyle(fontSize: 30),
                ),
              )),
          //),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: (() {
                FirebaseAuth.instance.signOut();
              }),
              label: const Text(
                'Log Out',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class DarkModeToggle extends ElevatedButton {
  DarkModeToggle({required super.onPressed, required super.child});

}