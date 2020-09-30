import 'package:flutter/material.dart';

import 'package:flutter_tags/flutter_tags.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/constants/tag_data.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/models/status_model.dart';

class CompositionInfoScreen extends StatefulWidget {
  final ScreenType screen;
  final CompositionModel composition;

  CompositionInfoScreen({@required this.screen, this.composition});

  State<StatefulWidget> createState() => _CompositionInfoScreenState();
}

class _CompositionInfoScreenState extends State<CompositionInfoScreen> {
  final int maxTitleLen = 64;
  TextEditingController _title;
  TextEditingController _description;
  List<String> _items;
  String submitError;
  bool maxTagsReached;
  bool isSubmitting;
  bool isPrivate;

  // TODO: If arrived from library screen, provide comp. info
  // TODO: Else, provide default values
  void initState() {
    super.initState();

    if (widget.composition == null) {
      _title = TextEditingController();
      _description = TextEditingController();
      _items = List();
    } else {
      _title = TextEditingController.fromValue(
          TextEditingValue(text: widget.composition.title));
      _description = TextEditingController.fromValue(
          TextEditingValue(text: widget.composition.description));
      _items = widget.composition.tags;
    }

    submitError = '';
    maxTagsReached = _items.length >= MAX_TAGS;
    isSubmitting = false;
    isPrivate = false;
  }

  Widget build(context) {
    AuthBloc authBloc = AuthProvider.of(context);
    RoomBloc roomBloc = RoomProvider.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        // Users cannot return to an already-ended session via Session screen.
        // They CAN return to their Library if they choose to undo any editing.
        automaticallyImplyLeading: widget.screen != ScreenType.SESSION,
        title: Text(
          'About Your Composition',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      body: ListView(
        children: [
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          Text(
            'What shall this masterpiece go by?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          TextFormField(
            controller: _title,
            maxLength: maxTitleLen,
            decoration: InputDecoration(
              hintText: 'Title',
              fillColor: Theme.of(context).primaryColor,
              filled: true,
              border: InputBorder.none,
            ),
          ),
          Divider(
            color: Colors.transparent,
            height: 30.0,
          ),
          Text(
            'Any tags to go with it? \n(${MAX_TAGS - _items.length} left.)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          compositionTags(),
          Divider(
            color: Colors.transparent,
            height: 50.0,
          ),
          Text(
            'How would you describe this wonderful thing?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          TextFormField(
            controller: _description,
            decoration: InputDecoration(
              hintText: 'Describe your composition here!',
              fillColor: Theme.of(context).primaryColor,
              filled: true,
              border: InputBorder.none,
            ),
            maxLength: 100,
            style: Theme.of(context).textTheme.bodyText2,
            minLines: 3,
            maxLines: 100,
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Searchable?', // TODO: Fix isPrivate text label here
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Checkbox(
                value: isPrivate,
                onChanged: (data) => setState(() => isPrivate = !isPrivate),
              ),
            ],
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          Text(
            submitError,
            style: TextStyle(
              color: Colors.red[900],
            ),
          ),
          Align(
            child: SizedBox(
              width: 150,
              child: RaisedButton(
                onPressed: () => onSubmit(authBloc, roomBloc),
                color: Theme.of(context).primaryColor,
                child:
                    isSubmitting ? awaitingSubmitWidget() : allowSubmitWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget awaitingSubmitWidget() {
    return CircularProgressIndicator(
      backgroundColor: Colors.white,
    );
  }

  Widget allowSubmitWidget() {
    return Text(
      'Submit!',
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  Widget compositionTags() {
    return Tags(
      key: _tagStateKey,
      textField: TagsTextField(
        inputDecoration: InputDecoration(
          border: InputBorder.none,
          fillColor: maxTagsReached
              ? Theme.of(context).accentColor
              : Theme.of(context).primaryColor,
          filled: true,
        ),
        hintText: maxTagsReached ? '' : 'Add a tag!',
        enabled: !maxTagsReached,
        maxLength: 12,
        textStyle: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
        ),
        constraintSuggestion: true,
        onSubmitted: (String str) {
          setState(() => _items.add(str));
          setState(() => maxTagsReached = _items.length >= MAX_TAGS);
        },
      ),
      itemCount: _items.length,
      itemBuilder: (int index) {
        final item = _items[index];

        return ItemTags(
          key: Key(index.toString()),
          activeColor: Colors.white,
          textActiveColor: Colors.black,
          index: index,
          title: item,
          textStyle: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
          ),
          removeButton: ItemTagsRemoveButton(
            onRemoved: () {
              setState(() => _items.removeAt(index));
              setState(() => maxTagsReached = _items.length >= MAX_TAGS);
              return true;
            },
          ),
          onPressed: (item) => print(item),
          onLongPressed: (item) => print(item),
        );
      },
    );
  }

  void onSubmit(AuthBloc authBloc, RoomBloc roomBloc) async {
    String username = authBloc.currentUser.username;

    setState(() => isSubmitting = true);
    StatusModel status = await roomBloc.submitCompositionInfo(
      username,
      title: _title.value.text,
      description: _description.value.text,
      tags: _items,
      isPrivate: isPrivate,
    );

    setState(() => isSubmitting = false);

    if (status.code != 200) {
      print('Oh no! Could not submit composition info!');
      setState(() => submitError = status.message);
      return;
    }

    roomBloc.disconnectSocket();

    switch (widget.screen) {
      case ScreenType.LIBRARY:
        Navigator.pop(context);
        break;
      case ScreenType.SESSION:
        Navigator.pushNamed(context, '/');
        break;
      default:
        break;
    }
  }

  void dispose() {
    super.dispose();
    _title.dispose();
    _description.dispose();
  }
}

final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
