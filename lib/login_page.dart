import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'package:rpi_beefcake/widget_library.dart';

const emailRegexString = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
final emailRegex = RegExp(emailRegexString);
const existsRegexString = r'.+';
final existsRegex = RegExp(existsRegexString);
const properPasswordRegexString = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
final properPasswordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
const nameRegexString = r'[A-Z]\w* [A-Z]\w*';
final nameRegex = RegExp(r'[A-Z]\w* [A-Z]\w*');

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  late CustTextInput _emailInput;
  late CustTextInput _pwInput;
  late final FieldOptions _emailOptions;
  late final FieldOptions _pwOptions;
  bool usernameCorrect = false;
  bool passwordCorrect = false;
  String errorText = '';

  @override
  initState() {
    _emailOptions = FieldOptions(
        hint: "Email",
        invalidText: "Enter a valid email",
        showValidSymbol: true,
        icon: Icons.mail_outline_rounded,
        regString: emailRegexString,
        obscureText: false);

    _pwOptions = FieldOptions(
        hint: "Password",
        invalidText: "Make sure your password is valid",
        showValidSymbol: true,
        icon: Icons.lock_outline_rounded,
        regString: properPasswordRegexString,
        obscureText: true);
  }

  @override
  Widget build(BuildContext context) {
    _emailInput = CustTextInput(options: _emailOptions);
    _pwInput = CustTextInput(options: _pwOptions);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Image.asset('images/beefcake_icon.jpg',
                  height: 125, width: 125),
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: Text('Welcome Back',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Proxima Nova',
                      fontFamilyFallback: <String>['Comic Sans'],
                      fontSize: 38,
                    ))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: _emailInput,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: _pwInput,
            ),
            ElevatedButton(
                onPressed: (() {
                  if (!_emailInput.child.isValid()) {
                    setState(() {
                      errorText = 'Invalid Email';
                    });
                  } else if (!_pwInput.child.isValid()) {
                    setState(() {
                      errorText = 'Enter a Password';
                    });
                  } else {
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailInput.child.getVal(),
                            password: _pwInput.child.getVal())
                        .then((userCredential) => {})
                        .catchError((error) {
                      setState(() {
                        errorText = error.message;
                        _pwInput.child.clear();
                      });
                    });
                  }
                }),
                child: const Text('Log In')),
            Text(errorText, style: TextStyle(color: bc_style().errorcolor)),
            ElevatedButton(
                onPressed: (() {
                  Navigator.of(context).popAndPushNamed('/register');
                }),
                child:
                    const Text('New User?', textDirection: TextDirection.ltr))
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  late CustTextInput _emailInput;
  late CustTextInput _pw1Input;
  late CustTextInput _pw2Input;
  late final FieldOptions _emailOptions;
  late final FieldOptions _pw1Options;
  late final FieldOptions _pw2Options;
  bool usernameCorrect = false;
  bool passwordCorrect = false;
  bool passwordConfirmCorrect = false;
  String errorText = '';

  bool confirmationValidator(String str) {
    return str.compareTo(_pw1Input.child.getVal()) == 0;
  }

  @override
  initState() {
    _emailOptions = FieldOptions(
        hint: "Email",
        invalidText: "Enter a valid email",
        showValidSymbol: true,
        icon: Icons.mail_outline_rounded,
        regString: emailRegexString,
        obscureText: false);

    _pw1Options = FieldOptions(
        hint: "Password",
        invalidText: "Make sure your password is valid",
        showValidSymbol: true,
        icon: Icons.lock_outline_rounded,
        regString: properPasswordRegexString,
        obscureText: true);

    _pw2Options = FieldOptions(
        hint: "Password Confirmation",
        invalidText: "Make sure your passwords match",
        showValidSymbol: true,
        icon: Icons.lock_outline_rounded,
        validator: confirmationValidator,
        obscureText: true);
  }

  @override
  Widget build(BuildContext context) {
    _emailInput = CustTextInput(options: _emailOptions);
    _pw1Input = CustTextInput(options: _pw1Options);
    _pw2Input = CustTextInput(options: _pw2Options);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Image.asset('images/beefcake_icon.jpg',
                  height: 125, width: 125),
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: Text('Register',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Proxima Nova',
                      fontFamilyFallback: <String>['Comic Sans'],
                      fontSize: 38,
                    ))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: _emailInput,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: _pw1Input,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: _pw2Input,
            ),
            ElevatedButton(
                onPressed: (() {
                  if (!_emailInput.child.isValid()) {
                    setState(() {
                      errorText = 'Invalid Email';
                    });
                  } else if (!_pw1Input.child.isValid()) {
                    setState(() {
                      errorText =
                          'Password must be 8 characters, including 1 number and 1 letter';
                    });
                  } else if (!_pw2Input.child.isValid()) {
                    setState(() {
                      errorText = 'Passwords do not match';
                    });
                  } else {
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email: _emailInput.child.getVal(),
                          password: _pw1Input.child.getVal(),
                        )
                        .then((userCredential) => {})
                        .catchError((error) {
                      setState(() {
                        errorText = error.message;
                        _pw1Input.child.clear();
                        _pw2Input.child.clear();
                      });
                    });
                  }
                }),
                child: const Text('Register')),
            Text(errorText, style: TextStyle(color: bc_style().errorcolor)),
            ElevatedButton(
                onPressed: (() {
                  Navigator.of(context).popAndPushNamed('/login');
                }),
                child: const Text('Returning User?',
                    textDirection: TextDirection.ltr))
          ],
        ),
      ),
    );
  }
}
