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
  bool maxTagsReached;
  bool isSubmitting;
  bool isPrivate;

  void initState() {
    super.initState();

    isPrivate = widget.composition.isPrivate ?? false;
    _title = TextEditingController.fromValue(
        TextEditingValue(text: widget.composition.title ?? ''));
    _description = TextEditingController.fromValue(
        TextEditingValue(text: widget.composition.description ?? ''));
    _tags = widget.composition.tags ?? List();

    submitError = '';
    maxTagsReached = _tags.length >= MAX_TAGS;
    isSubmitting = false;
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
            maxLength: MAX_TITLE_LENGTH,
            maxLengthEnforced: true,
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
            'Any tags to go with it? \n(${MAX_TAGS - _tags.length} left.)',
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
            maxLength: MAX_DESCRIPTION_LENGTH,
            maxLengthEnforced: true,
            style: Theme.of(context).textTheme.bodyText2,
            minLines: 3,
            maxLines: 100,
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          Text(
            'Hide this composition from \nusers\' searches?',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
          Checkbox(
            value: isPrivate,
            onChanged: (data) => setState(() => isPrivate = !isPrivate),
          ),
          Divider(
            color: Colors.transparent,
            height: 15.0,
          ),
          Text(
            submitError,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[900],
            ),
          ),
          Align(
            child: SizedBox(
              width: 150,
              child: RaisedButton(
                onPressed: () => onSubmit(roomBloc, searchBloc),
                color: Theme.of(context).primaryColor,
                child:
                    isSubmitting ? awaitingSubmitWidget() : allowSubmitWidget(),
              ),
            ),
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
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
          setState(() => _tags.add(str));
          setState(() => maxTagsReached = _tags.length >= MAX_TAGS);
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
              setState(() => maxTagsReached = _tags.length >= MAX_TAGS);
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
    setState(() => isSubmitting = true);
    StatusModel status = await roomBloc.submitCompositionInfo(
      userId: widget.user.id,
      compositionId: widget.composition.id,
      title: _title.text,
      description: _description.text,
      tags: _tags,
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
        searchBloc.clearSearchHistory();
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

// TODO: Try with and without final for GlobalKey instantiation
final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
