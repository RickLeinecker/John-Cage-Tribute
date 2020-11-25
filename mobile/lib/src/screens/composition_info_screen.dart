import 'package:flutter/material.dart';

import 'package:flutter_tags/flutter_tags.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/constants/comp_metadata.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/models/status_model.dart';
import 'package:jct/src/models/user_model.dart';

class CompositionInfoScreen extends StatefulWidget {
  final UserModel user;
  final ScreenType screen;
  final CompositionModel composition;

  CompositionInfoScreen(
      {@required this.user, @required this.screen, this.composition});

  State<StatefulWidget> createState() => _CompositionInfoScreenState();
}

class _CompositionInfoScreenState extends State<CompositionInfoScreen> {
  TextEditingController _title;
  TextEditingController _description;
  List<String> _tags;
  String submitError;
  bool _maxTagsReached;
  bool _isSubmitting;
  bool _isPrivate;

  void initState() {
    super.initState();

    _isPrivate = widget.composition.isPrivate ?? false;
    _title = TextEditingController.fromValue(
        TextEditingValue(text: widget.composition.title ?? ''));
    _description = TextEditingController.fromValue(
        TextEditingValue(text: widget.composition.description ?? ''));
    _tags = widget.composition.tags ?? List();

    submitError = '';
    _maxTagsReached = _tags.length >= MAX_TAGS;
    _isSubmitting = false;
  }

  Widget build(context) {
    RoomBloc roomBloc = RoomProvider.of(context);
    SearchBloc searchBloc = SearchProvider.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        // Users cannot return to an already-ended session via Session screen.
        // They CAN return to their Library if they choose to undo any editing.
        automaticallyImplyLeading: widget.screen != ScreenType.SESSION,
        centerTitle: true,
        title: Text(
          'About Your Composition...',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      body: ListView(
        children: [
          Divider(color: Colors.transparent, height: 20.0),
          Text(
            'Title',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(color: Colors.transparent, height: 20.0),
          Padding(
            padding: EdgeInsets.only(left: 40.0, right: 40.0),
            child: TextFormField(
              controller: _title,
              maxLength: MAX_TITLE_LENGTH,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                hintText: 'Title',
                fillColor: Theme.of(context).primaryColor,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
              ),
            ),
          ),
          Divider(color: Colors.blue[900], height: 60.0),
          Text(
            'Tags (${MAX_TAGS - _tags.length} left.)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(color: Colors.transparent, height: 20.0),
          compositionTags(),
          Divider(
            color: Colors.blue[900],
            height: 60.0,
          ),
          Text(
            'Description',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(color: Colors.transparent, height: 20.0),
          Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextFormField(
              controller: _description,
              decoration: InputDecoration(
                hintText: 'For e.g., an unparalleled coalescence of howling '
                    'winds and whispers greets your ears.',
                fillColor: Theme.of(context).primaryColor,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
              ),
              maxLength: MAX_DESCRIPTION_LENGTH,
              maxLengthEnforced: true,
              style: Theme.of(context).textTheme.bodyText2,
              minLines: 5,
              maxLines: 100,
            ),
          ),
          Divider(color: Colors.blue[900], height: 60.0),
          Text(
            'Make Public?',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              activeColor: Colors.blueAccent[100],
              value: _isPrivate,
              onChanged: (data) => setState(() => _isPrivate = !_isPrivate),
            ),
          ),
          Text(
            submitError,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[900],
            ),
          ),
          Align(
            child: RaisedButton(
              onPressed: () => onSubmit(roomBloc, searchBloc),
              color: Theme.of(context).textTheme.bodyText2.color,
              textColor: Theme.of(context).primaryColor,
              child: _isSubmitting
                  ? CircularProgressIndicator(backgroundColor: Colors.white)
                  : Text('Submit'),
            ),
          ),
          Divider(color: Colors.transparent, height: 20.0),
        ],
      ),
    );
  }

  Widget compositionTags() {
    return Tags(
      verticalDirection: VerticalDirection.up,
      direction: Axis.vertical,
      key: _tagStateKey,
      textField: TagsTextField(
        inputDecoration: InputDecoration(
          fillColor: Theme.of(context).primaryColor,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
        ),
        hintText: _maxTagsReached ? '' : 'Add a tag!',
        enabled: !_maxTagsReached,
        maxLength: 12,
        textStyle: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
        ),
        constraintSuggestion: true,
        onSubmitted: (String str) {
          setState(() => _tags.add(str));
          setState(() => _maxTagsReached = _tags.length >= MAX_TAGS);
        },
      ),
      itemCount: _tags.length,
      itemBuilder: (int index) {
        final item = _tags[index];

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
              setState(() => _tags.removeAt(index));
              setState(() => _maxTagsReached = _tags.length >= MAX_TAGS);
              return true;
            },
          ),
          onPressed: (item) => print(item),
          onLongPressed: (item) => print(item),
        );
      },
    );
  }

  void onSubmit(RoomBloc roomBloc, SearchBloc searchBloc) async {
    setState(() => _isSubmitting = true);
    StatusModel status = await roomBloc.submitCompositionInfo(
      userId: widget.user.id,
      compositionId: widget.composition.id,
      title: _title.text,
      description: _description.text,
      tags: _tags,
      isPrivate: _isPrivate,
    );

    setState(() => _isSubmitting = false);

    if (status.code != 200) {
      print('Oh no! Could not submit composition info!');
      setState(() => submitError = status.message);
      return;
    }

    roomBloc.disconnectSocket();

    switch (widget.screen) {
      case ScreenType.LIBRARY:
        searchBloc.clearSearchResults();
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
