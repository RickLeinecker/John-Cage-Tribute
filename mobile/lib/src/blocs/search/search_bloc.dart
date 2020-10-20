import 'package:flutter/material.dart';
import 'package:jct/src/models/status_model.dart';
import 'package:jct/src/models/user_model.dart';

import 'package:rxdart/subjects.dart';

import 'package:jct/src/constants/filter_option.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/resources/composition_api_repository.dart';

/// BLoC that houses the search composition behavior of the John Cage Tribute.
///
/// Currently, it performs the stateful actions in the [SearchScreen] and
/// [LibraryScreen]. It works closely with the [FilterButtons] and
/// [SearchField] widgets to pass state information between them.
class SearchBloc {
  final compositionRepo = CompositionApiRepository();

  final searchText = TextEditingController();
  final _filterSearch = BehaviorSubject<FilterOption>();
  final _querySearch = BehaviorSubject<bool>();
  final _searchCompList = BehaviorSubject<List<CompositionModel>>();

  final libraryText = TextEditingController();
  final _filterLibrary = BehaviorSubject<FilterOption>();
  final _queryLibrary = BehaviorSubject<bool>();
  final _deletingComposition = BehaviorSubject<bool>();
  BehaviorSubject<List<CompositionModel>> _libraryCompList = BehaviorSubject();

  Stream<FilterOption> get filterSearch => _filterSearch.stream;
  Stream<List<CompositionModel>> get searchCompList => _searchCompList.stream;
  Stream<bool> get querySearch => _querySearch.stream;
  Function(FilterOption) get changeFilterSearch => _filterSearch.sink.add;

  Stream<FilterOption> get filterLibrary => _filterLibrary.stream;
  Stream<List<CompositionModel>> get libraryCompList => _libraryCompList.stream;
  Stream<bool> get queryLibrary => _queryLibrary.stream;
  Stream<bool> get deletingComposition => _deletingComposition.stream;
  Function(FilterOption) get changeFilterLibrary => _filterLibrary.sink.add;

  SearchBloc() {
    changeFilterSearch(FilterOption.TAGS);
    changeFilterLibrary(FilterOption.TAGS);
  }

  /// Performs a search for compositions based on the user's search query.
  ///
  /// The search itself is dependent on the current filter the user selected
  /// and the current screen they are making their searches from.
  /// The Library screen restricts its searches to a user's own compositions.
  void search(
      {UserModel user,
      @required FilterOption filter,
      @required String query,
      @required ScreenType screen}) async {
    if (screen == ScreenType.SEARCH) {
      _querySearch.add(true);
    } else if (screen == ScreenType.LIBRARY) {
      _queryLibrary.add(true);
    }

    final List<CompositionModel> compositions = List();

    final compositionList = await compositionRepo.fetchCompositions(
        user, filter, query.trim(), screen);

    // A server issue disallowed the retrieval of any compositions.
    if (compositionList == null) {
      if (screen == ScreenType.SEARCH) {
        _searchCompList.sink
            .addError('There was a server error. Please try again later.');
        _querySearch.add(false);
      } else if (screen == ScreenType.LIBRARY) {
        _libraryCompList.sink
            .addError('There was a server error. Please try again later.');
        _queryLibrary.add(false);
      }
    }
    // Load the compositions into our search stream.
    else {
      for (final map in compositionList) {
        compositions.add(CompositionModel.fromJson(map));
      }

      print('Amt. of compositions retrieved: ${compositions.length}');

      if (screen == ScreenType.SEARCH) {
        _searchCompList.sink.add(compositions);
        _libraryCompList.sink.add(null);
        _querySearch.add(false);
      } else if (screen == ScreenType.LIBRARY) {
        _libraryCompList.sink.add(compositions);
        _searchCompList.sink.add(null);
        _queryLibrary.add(false);
      }
    }
  }

  // Simulates a lack of a search, effectively refreshing the search function
  // of the screen. Currently supports the library screen.
  void clearSearchHistory() {
    _libraryCompList.sink.add(null);
  }

  Future<void> deleteComposition(
      ScreenType screen, String userId, String compositionId, int index) async {
    _deletingComposition.sink.add(true);

    final StatusModel statusModel =
        await compositionRepo.deleteComposition(compositionId);

    if (statusModel.code != 200) {
      print('Error deleting composition.');
      _deletingComposition.sink
          .addError('There seems to be a problem deleting this composition.');
      return;
    }

    switch (screen) {
      case ScreenType.SEARCH:
        final List<CompositionModel> searchList = _searchCompList.value;
        searchList.removeAt(index);
        _searchCompList.add(searchList);
        break;

      case ScreenType.LIBRARY:
        final List<CompositionModel> libraryList = _libraryCompList.value;
        libraryList.removeAt(index);
        _libraryCompList.add(libraryList);
        break;
      default:
        break;
    }

    _deletingComposition.sink.add(false);
  }

  void changeFilter(ScreenType screen, FilterOption filter) {
    switch (screen) {
      case ScreenType.SEARCH:
        changeFilterSearch(filter);
        break;
      case ScreenType.LIBRARY:
        changeFilterLibrary(filter);
        break;
      default:
        break;
    }
  }

  FilterOption getFilter(ScreenType screen) {
    switch (screen) {
      case ScreenType.SEARCH:
        return _filterSearch.value;
      case ScreenType.LIBRARY:
        return _filterLibrary.value;
      default:
        return null;
    }
  }

  void dispose() {
    searchText.dispose();
    _filterSearch.close();
    _querySearch.close();
    _searchCompList.close();
    _filterLibrary.close();
    _queryLibrary.close();
    libraryText.dispose();
    _libraryCompList.close();
    _deletingComposition.close();
  }
}
