import 'package:flutter/material.dart';
import '../blocs/auth/bloc.dart';
import '../models/user_model.dart';

class LibraryScreen extends StatelessWidget {
  Widget build(context) {
    final AuthBloc bloc = AuthProvider.of(context);
    return StreamBuilder(
      stream: bloc.user,
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) {
          return loadingUser(context);
        }

        if (snapshot.data.username != null) {
          return Scaffold(
            body: SizedBox.expand(
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Logged in.'),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: SizedBox.expand(
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Not logged in.'),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget loadingUser(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.supervised_user_circle,
                color: Theme.of(context).accentColor, size: 50.0),
            Text(
              'Please wait while we\n authenticate you...',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: Colors.transparent,
              height: 40.0,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
