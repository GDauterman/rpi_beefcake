import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';

final emailRegex = RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
final existsRegex = RegExp(r'.+');
final properPasswordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
final nameRegex = RegExp(r'[A-Z]\w* [A-Z]\w*');

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool usernameCorrect = false;
  bool passwordCorrect = false;
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Image.asset('images/beefcake_icon.jpg', height:125, width:125),
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
              child: Container(
                decoration: BoxDecoration(
                  color: bc_style().backgroundcolor,
                  border: Border.all(width: 5, color: bc_style().accent1color),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email_outlined, color: bc_style().textcolor),
                          ),
                          onChanged: ((String str) {
                            bool valid = emailRegex.hasMatch(str);
                            if (usernameCorrect && !valid) {
                              setState(() {usernameCorrect = false;});
                            } else if (!usernameCorrect && valid) {
                              setState(() {usernameCorrect = true;});
                            }
                          }),
                        ),
                      ),
                    ),
                    Icon(usernameCorrect ? Icons.check_circle : Icons.flag_circle_rounded, size: 28, color: usernameCorrect ? Colors.green : bc_style().errorcolor),
                  ],
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Container(
                decoration: BoxDecoration(
                  color: bc_style().backgroundcolor,
                  border: Border.all(width: 5, color: bc_style().accent1color),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: bc_style().textcolor),
                          ),
                          controller: passwordController,
                          obscureText: true,
                          onChanged: ((String str) {
                            bool valid = existsRegex.hasMatch(str);
                            if (passwordCorrect && !valid) {
                              setState(() {passwordCorrect = false;});
                            } else if (!passwordCorrect && valid) {
                              setState(() {passwordCorrect = true;});
                            }
                          })
                        )
                      )
                    )
                  ],
                )
              ),
            ),
            ElevatedButton(
              onPressed: ((){
                if(!usernameCorrect) {
                  setState(() {
                    errorText = 'Invalid Email';
                  });
                } else if(!passwordCorrect) {
                  setState(() {
                    errorText = 'Enter a Password';
                  });
                } else {
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: usernameController.text.toString(),
                      password: passwordController.text.toString()
                  ).then((userCredential) =>

                  {
                  }).catchError((error) {
                    setState(() {
                      errorText = error.message;
                      passwordController.clear();
                    });
                  });
                }
              }),
              child: const Text('Log In')
            ),
            Text(errorText, style: TextStyle(color: bc_style().errorcolor)),
            ElevatedButton(
              onPressed: (() {Navigator.of(context).popAndPushNamed('/register');}),
              child: const Text(
                'Register with Email/Password',
                textDirection: TextDirection.ltr
            ))
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
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  bool usernameCorrect = false;
  bool passwordCorrect = false;
  bool passwordConfirmCorrect = false;
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Image.asset('images/beefcake_icon.jpg', height:125, width:125),
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
              child: Container(
                  decoration: BoxDecoration(
                    color: bc_style().backgroundcolor,
                    border: Border.all(width: 5, color: bc_style().accent1color),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.email_outlined, color: bc_style().textcolor),
                            ),
                            onChanged: ((String str) {
                              bool valid = emailRegex.hasMatch(str);
                              if (usernameCorrect && !valid) {
                                setState(() {usernameCorrect = false;});
                              } else if (!usernameCorrect && valid) {
                                setState(() {usernameCorrect = true;});
                              }
                            }),
                          ),
                        ),
                      ),
                      Icon(usernameCorrect ? Icons.check_circle : Icons.flag_circle_rounded, size: 28, color: usernameCorrect ? Colors.green : bc_style().errorcolor),
                    ],
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Container(
                  decoration: BoxDecoration(
                    color: bc_style().backgroundcolor,
                    border: Border.all(width: 5, color: bc_style().accent1color),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: bc_style().textcolor),
                            ),
                            onChanged: ((String str) {
                              bool valid = properPasswordRegex.hasMatch(str);
                              if (passwordCorrect && !valid) {
                                setState(() {passwordCorrect = false;});
                              } else if (!passwordCorrect && valid) {
                                setState(() {passwordCorrect = true;});
                              }
                            }),
                          ),
                        ),
                      ),
                      Icon(passwordCorrect ? Icons.check_circle : Icons.flag_circle_rounded, size: 28, color: passwordCorrect ? Colors.green : bc_style().errorcolor),
                    ],
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Container(
                  decoration: BoxDecoration(
                    color: bc_style().backgroundcolor,
                    border: Border.all(width: 5, color: bc_style().accent1color),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                              height: 40,
                              child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Repeat Password',
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.lock_outline_rounded, color: bc_style().textcolor),
                                  ),
                                  controller: passwordConfirmController,
                                  obscureText: true,
                                  onChanged: ((String str) {
                                    bool valid = str.compareTo(passwordController.text.toString()) == 0;
                                    if (passwordConfirmCorrect && !valid) {
                                      setState(() {passwordConfirmCorrect = false;});
                                    } else if (!passwordConfirmCorrect && valid) {
                                      setState(() {passwordConfirmCorrect = true;});
                                    }
                                  })
                              )
                          )
                      ),
                      Icon(passwordConfirmCorrect ? Icons.check_circle : Icons.flag_circle_rounded, size: 28, color: passwordConfirmCorrect ? Colors.green : bc_style().errorcolor),
                    ],
                  )
              ),
            ),
            ElevatedButton(
                onPressed: ((){
                  if(!usernameCorrect) {
                    setState(() {
                      errorText = 'Invalid Email';
                    });
                  } else if(!passwordCorrect) {
                    setState(() {
                      errorText = 'Password must be 8 characters, including 1 number and 1 letter';
                    });
                  } else if(!passwordConfirmCorrect) {
                    setState(() {
                      errorText = 'Passwords do not match';
                    });
                  } else {
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: usernameController.text.toString(),
                        password: passwordController.text.toString()
                    ).then((userCredential) =>
                    {
                    }).catchError((error) {
                      setState(() {
                        errorText = error.message;
                        passwordController.clear();
                      });
                    });
                  }
                }),
                child: const Text('Register')
            ),
            Text(errorText, style: TextStyle(color: bc_style().errorcolor)),
            ElevatedButton(
              onPressed: (() {Navigator.of(context).popAndPushNamed('/login');}),
              child: const Text(
                  'Login with Email/Password',
                  textDirection: TextDirection.ltr
              ))
          ],
        ),
      ),
    );
  }
}

