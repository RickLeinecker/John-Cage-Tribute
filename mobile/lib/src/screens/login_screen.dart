import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController;
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Widget build(context) {
    return Scaffold(
        body: Stack(
      children: [
        SizedBox.expand(
          child: Container(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tired of acting as a guest?\nSign up below.',
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Email'),
              ),
              //
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(hintText: 'Username'),
              ),
              //
              TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: 'Password'),
                  obscureText: true),
              //
              RaisedButton(
                  child: Text('Sign up'),
                  onPressed: () => print('Signup button pressed')),
            ]),
      ],
    ));
    // return SizedBox.expand(
    //   child: Container(
    //       color: Theme.of(context).primaryColor,
    //       child: Center(
    //           child: Text(
    //         'Login Screen',
    //         textAlign: TextAlign.center,
    //         style: Theme.of(context).textTheme.headline6,
    //       ))),
    // );
  }

  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}
