import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/library_screen.dart';
import 'package:jct/src/widgets/account/login_view.dart';
import 'package:jct/src/widgets/account/signup_view.dart';
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
            body: accountView(context, authBloc, searchBloc, snapshot.data),
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
                  LoginView(),
                  SignupView(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget accountView(BuildContext context, AuthBloc authBloc,
      SearchBloc searchBloc, UserModel user) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        centerTitle: true,
        title: Text(
          'Welcome, ${user.username}!',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 30.0,
            ),
            splashRadius: 25.0,
            onPressed: () => logoutOnPressed(context, authBloc),
          ),
          VerticalDivider(
            color: Colors.transparent,
            width: 8.0,
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple,
                Colors.transparent,
                Colors.transparent,
                Colors.purple
              ],
              stops: [0.0, 0.1, 0.9, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  Text(
                    'About Me',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 5.0,
                  ),
                  Text('Username: ${user.username}'),
                  Divider(
                    color: Colors.transparent,
                    height: 5.0,
                  ),
                  Text('Email: ${user.email}'),
                  Divider(
                    color: Colors.transparent,
                    height: 5.0,
                  ),
                  Text('Joined: ${user.dateJoined()}'),
                  Divider(
                    color: Colors.transparent,
                    height: 10.0,
                  ),
                  Divider(
                    color: Colors.blue,
                    height: 30.0,
                  ),
                  Text(
                    'My Creations',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 10.0,
                  ),
                  Text(
                    'Your own compositions can be accessed here. This also '
                    'includes compositions that you\'ve marked as \'private\'.',
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 10.0,
                  ),
                  RaisedButton.icon(
                    icon: Icon(Icons.search),
                    color: Theme.of(context).textTheme.bodyText1.color,
                    textColor: Theme.of(context).primaryColor,
                    label: Text('Search My Library'),
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
                  ),
                  Divider(
                    color: Colors.blue,
                    height: 30.0,
                  ),
                  Text(
                    'Account Settings',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 10.0,
                  ),
                  Text(
                    'Beware: Choosing to delete your account will not only '
                    'remove it from JCT, it will also remove any compositions '
                    'created under this account, as well.',
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 10.0,
                  ),
                  RaisedButton.icon(
                    icon: Icon(Icons.delete),
                    color: Theme.of(context).textTheme.bodyText1.color,
                    textColor: Colors.red,
                    label: Text('Delete'),
                    onPressed: () => deleteAccOnPressed(context, authBloc),
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> logoutOnPressed(BuildContext context, AuthBloc bloc) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.cyan[600],
          content: Container(
            height: 120,
            width: 300,
            color: Colors.cyan[600],
            child: Column(
              children: [
                Text(
                  'Would you like to log out of your account?',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RaisedButton(
                      color: Theme.of(context).textTheme.bodyText2.color,
                      textColor: Colors.cyan[900],
                      child: Text('Yes'),
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        await bloc.logout();
                      },
                    ),
                    VerticalDivider(
                      color: Colors.transparent,
                      width: 35.0,
                    ),
                    RaisedButton(
                      color: Theme.of(context).textTheme.bodyText2.color,
                      textColor: Colors.cyan[900],
                      child: Text('No'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> deleteAccOnPressed(BuildContext context, AuthBloc bloc) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.cyan[600],
          content: Container(
            height: 120,
            width: 300,
            color: Colors.cyan[600],
            child: Column(
              children: [
                Text(
                  'Are you SURE you\'d like to delete your account?',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StreamBuilder(
                      stream: bloc.deletingAccount,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
                              color: Colors.red,
                              textColor: Colors.white,
                              child: Text('YES!'),
                              onPressed: () => bloc.deleteAccount(),
                            ),
                          ],
                        );
                      },
                    ),
                    VerticalDivider(
                      color: Colors.transparent,
                      width: 35.0,
                    ),
                    RaisedButton(
                      color: Theme.of(context).textTheme.bodyText2.color,
                      textColor: Colors.cyan[900],
                      child: Text('NO!'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
