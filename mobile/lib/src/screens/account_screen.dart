import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/blocs/search/search_provider.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/constants/user_auth.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/library_screen.dart';
import 'package:jct/src/widgets/loading_user.dart';

class AccountScreen extends StatelessWidget {
  Widget build(context) {
    final AuthBloc authBloc = AuthProvider.of(context);
    final SearchBloc searchBloc = SearchProvider.of(context);

    return StreamBuilder(
      stream: authBloc.user,
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) {
          return LoadingUser();
        }

        if (snapshot.data != GUEST_USER) {
          return Scaffold(
            body: userView(context, authBloc, searchBloc, snapshot.data),
          );
        } else {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).accentColor,
                title: Text('Account'),
                centerTitle: true,
                bottom: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
                  indicatorColor: Colors.white,
                  onTap: (idx) => authBloc.clearFields,
                  tabs: [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  loginView(context, authBloc),
                  signupView(context, authBloc),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget userView(BuildContext context, AuthBloc authBloc,
      SearchBloc searchBloc, UserModel user) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Divider(
              color: Colors.transparent,
              height: 20.0,
            ),
            Text(
              'Reminiscing?\n Check your old compositions below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            Divider(
              color: Colors.transparent,
              height: 10.0,
            ),
            RaisedButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                searchBloc.clearSearchResults();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) {
                      return LibraryScreen(user: user);
                    },
                  ),
                );
              },
              child: Text('View My Compositions',
                  style: TextStyle(color: Colors.white)),
            ),
            Divider(
              color: Colors.transparent,
              height: 10.0,
            ),
            Text('Not ${user.username}?\n Feel free to log out below.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6),
            Divider(
              color: Colors.transparent,
              height: 10.0,
            ),
            RaisedButton(
              color: Theme.of(context).accentColor,
              onPressed: () async {
                await authBloc.logout();
              },
              child: Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
            Divider(
              color: Colors.transparent,
              height: 10.0,
            ),
            Text(
              'No longer interested in JCT?\nDelete your account below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            StreamBuilder(
                stream: authBloc.deletingAccount,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.data == true) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    );
                  }

                  return Column(
                    children: [
                      Visibility(
                        visible: snapshot.hasError,
                        child: Text(
                          snapshot.error ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          authBloc.deleteAccount();
                        },
                        child: Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget loginView(BuildContext context, AuthBloc bloc) {
    return Stack(
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
              'Get your persona going.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            emailField(bloc, UserAuth.LOGIN),
            passwordField(bloc, UserAuth.LOGIN),
            loginButton(bloc),
          ],
        ),
      ],
    );
  }

  Widget signupView(BuildContext context, AuthBloc bloc) {
    return Stack(
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
            emailField(bloc, UserAuth.SIGNUP),
            usernameField(bloc),
            passwordField(bloc, UserAuth.SIGNUP),
            confirmPasswordField(bloc),
            signupButton(bloc),
          ],
        ),
      ],
    );
  }

  Widget emailField(AuthBloc bloc, UserAuth authType) {
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          onChanged: bloc.changeEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'johndoe@example.com',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget usernameField(AuthBloc bloc) {
    return StreamBuilder(
      stream: bloc.username,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          onChanged: bloc.changeUsername,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Three or more letters or numbers.',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget passwordField(AuthBloc bloc, UserAuth authType) {
    return StreamBuilder(
      stream: bloc.password,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          obscureText: true,
          onChanged: bloc.changePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Use capitals and numbers.',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget confirmPasswordField(AuthBloc bloc) {
    return StreamBuilder(
      stream: bloc.confirmPassword,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          obscureText: true,
          onChanged: bloc.changeConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm the password above.',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget signupButton(AuthBloc bloc) {
    return StreamBuilder(
      stream: bloc.signupValid,
      builder: (context, snapshot) {
        return Column(
          children: [
            StreamBuilder(
              stream: bloc.authSubmit,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return Text(
                  snapshot.hasError ? snapshot.error : '',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                );
              },
            ),
            RaisedButton(
              onPressed:
                  snapshot.hasData ? () => onSignup(context, bloc) : null,
              color: Theme.of(context).accentColor,
              child: Text('Sign Up', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget loginButton(AuthBloc bloc) {
    return StreamBuilder(
      stream: bloc.loginValid,
      builder: (context, snapshot) {
        return Column(
          children: [
            StreamBuilder(
              stream: bloc.authSubmit,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return Text(
                  snapshot.hasError ? snapshot.error : '',
                  style: TextStyle(
                    color: Colors.red[700],
                  ),
                );
              },
            ),
            RaisedButton(
              onPressed: snapshot.hasData ? () => onLogin(context, bloc) : null,
              color: Theme.of(context).accentColor,
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void onSignup(BuildContext context, AuthBloc bloc) async {
    bool success = await bloc.submitAndSignup();

    if (success) {
      print('Signup successful!');
    } else {
      print('Signup error, bruv.');
    }
  }

  void onLogin(BuildContext context, AuthBloc bloc) async {
    bool success = await bloc.submitAndLogin();

    if (success) {
      print('Login successful!');
    } else {
      print('Login error, bruv.');
    }
  }
}
