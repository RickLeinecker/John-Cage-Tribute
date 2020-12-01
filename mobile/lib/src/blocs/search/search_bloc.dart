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

  // Search
  final searchText = TextEditingController();
  final _filterSearch = BehaviorSubject<FilterOption>();
  final _querySearch = BehaviorSubject<bool>();
  final _searchCompList = BehaviorSubject<List<CompositionModel>>();

  // Library
  final _filterLibrary = BehaviorSubject<FilterOption>();
  final _queryLibrary = BehaviorSubject<bool>();
  final _libraryCompList = BehaviorSubject<List<CompositionModel>>();
  final _deletingComposition = BehaviorSubject<bool>();

  Stream<FilterOption> get filterSearch => _filterSearch.stream;
  Stream<bool> get querySearch => _querySearch.stream;
  Stream<List<CompositionModel>> get searchCompList => _searchCompList.stream;

  Stream<FilterOption> get filterLibrary => _filterLibrary.stream;
  Stream<bool> get queryLibrary => _queryLibrary.stream;
  Stream<List<CompositionModel>> get libraryCompList => _libraryCompList.stream;

  Function(FilterOption) get changeFilterSearch => _filterSearch.sink.add;

  Function(FilterOption) get changeFilterLibrary => _filterLibrary.sink.add;
  Stream<bool> get deletingComposition => _deletingComposition.stream;

  SearchBloc() {
    changeFilterSearch(FilterOption.TITLE);
    changeFilterLibrary(FilterOption.TITLE);
    searchRecents(ScreenType.SEARCH);
  }

  /// Performs a search for compositions based on the user's search query.
  ///
  /// The search itself is dependent on the current filterSearch the user
  /// selected and the current screen they are making their searches from.
  /// The [LibraryScreen] restricts its searches to a user's own compositions.
  void search(
      {UserModel user,
      @required FilterOption filter,
      @required String query,
      @required ScreenType screen}) async {
    if (screen == ScreenType.SEARCH) {
      _querySearch.sink.add(true);
    } else if (screen == ScreenType.LIBRARY) {
      _queryLibrary.sink.add(true);
    }

    final List<CompositionModel> compositions = List();

    final compositionList =
        await compositionRepo.fetchCompositions(user, filter, query, screen);

    if (compositionList == null) {
      if (screen == ScreenType.SEARCH) {
        _searchCompList.sink
            .addError('There was a server error. Please try again later.');
        _querySearch.sink.add(false);
      } else if (screen == ScreenType.LIBRARY) {
        _libraryCompList.sink
            .addError('There was a server error. Please try again later.');
        _queryLibrary.sink.add(false);
      }

      return;
    }

    for (final map in compositionList) {
      compositions.add(CompositionModel.fromJson(map));
    }

    if (screen == ScreenType.SEARCH) {
      _searchCompList.sink.add(compositions);
      _querySearch.sink.add(false);
    } else if (screen == ScreenType.LIBRARY) {
      _libraryCompList.sink.add(compositions);
      _queryLibrary.sink.add(false);
    }
  }

  /// Performs a preliminary search for some compositions on certain screen.
  void searchRecents(ScreenType screen, {UserModel user}) async {
    // Loads recently made compositions.
    if (screen == ScreenType.SEARCH) {
      _querySearch.sink.add(true);
      final compositionList =
          await compositionRepo.fetchRecentCompositions(screen);

      if (compositionList == null) {
        _searchCompList.sink.add(null);
      }

      if (compositionList.length > 0) {
        final List<CompositionModel> compositions = List();

        for (final map in compositionList) {
          compositions.add(CompositionModel.fromJson(map));
        }

        _searchCompList.sink.add(compositions);
      }

      _querySearch.sink.add(false);
    }

    // Loads the user's own compositions.
    else if (screen == ScreenType.LIBRARY) {
      _queryLibrary.sink.add(true);
      final compositionList =
          await compositionRepo.fetchRecentCompositions(screen, user: user);

      if (compositionList == null) {
        _libraryCompList.sink.add(null);
      }

      if (compositionList.length > 0) {
        final List<CompositionModel> compositions = List();
        for (final map in compositionList) {
          compositions.add(CompositionModel.fromJson(map));
        }

        _libraryCompList.sink.add(compositions);
      }

      _queryLibrary.sink.add(false);
    }
  }

  /// Simulates a lack of a search, effectively refreshing the search function
  /// on the [SearchScreen].
  void clearSearchResults() {
    _searchCompList.sink.add(null);
  }

  /// Simulates a lack of a search query made on the [LibraryScreen].
  void clearLibraryResults() {
    _libraryCompList.sink.add(null);
  }

  /// Updates composition lists if the edited composition is currently present
  /// in them. Otherwise, they are left untouched.
  void updateCompositionLists(CompositionModel editedComp) {
    _editCompInList(_searchCompList.value, editedComp, ScreenType.SEARCH);
    _editCompInList(_libraryCompList.value, editedComp, ScreenType.LIBRARY);
  }

  /// Private helper of [updateCompositionLists] that updates the passed in list
  /// that belongs to a certain screen.
  void _editCompInList(List<CompositionModel> list, CompositionModel editedComp,
      ScreenType screen) {
    if (list == null) {
      return;
    }

    int compIndex = list.indexOf(editedComp);

    if (compIndex != -1) {
      if (screen == ScreenType.SEARCH) {
        _querySearch.sink.add(true);

        !editedComp.isPrivate
            ? list.replaceRange(compIndex, compIndex + 1, [editedComp])
            : list.removeAt(compIndex);
        _searchCompList.sink.add(list);

        _querySearch.sink.add(false);
      } else if (screen == ScreenType.LIBRARY) {
        _queryLibrary.sink.add(true);

        list.replaceRange(compIndex, compIndex + 1, [editedComp]);
        _libraryCompList.sink.add(list);

        _queryLibrary.sink.add(false);
      }
    }
  }

  /// Returns a filter stream based on the screen the user is on.
  Stream<FilterOption> getFilterStream(ScreenType screen) {
    if (screen == ScreenType.SEARCH) {
      return filterSearch;
    } else if (screen == ScreenType.LIBRARY) {
      return filterLibrary;
    }

    return null;
  }

  /// Changes the filter of a BehaviorSubject based on the screen the
  /// user is on.
  void changeFilter(ScreenType screen, FilterOption filter) {
    if (screen == ScreenType.SEARCH) {
      changeFilterSearch(filter);
    } else if (screen == ScreenType.SEARCH) {
      changeFilterLibrary(filter);
    }
  }

  /// Deletes a composition from the database, given that the user has
  /// sufficient authorization to do so. Subsequently, it removes the
  /// composition from the user's search results.
  Future<void> deleteComposition(
      String userId, String compositionId, int index) async {
    _deletingComposition.sink.add(true);
    _querySearch.sink.add(true);
    _queryLibrary.sink.add(true);

    final StatusModel statusModel =
        await compositionRepo.deleteComposition(compositionId);

    if (statusModel.code != 200) {
      print('Error deleting composition.');
      _deletingComposition.sink
          .addError('There seems to be a problem deleting this composition.');
      return;
    }

    final List<CompositionModel> libraryList = _libraryCompList.value;
    final List<CompositionModel> searchList = _searchCompList.value;

    final deletedCompIdx = searchList != null
        ? searchList.indexWhere((comp) => comp.id == compositionId)
        : -1;

    if (deletedCompIdx != -1) {
      searchList.removeAt(deletedCompIdx);
      _searchCompList.sink.add(searchList);
    }

    libraryList.removeAt(index);
    _libraryCompList.add(libraryList);
    _deletingComposition.sink.add(false);
    _querySearch.sink.add(false);
    _queryLibrary.sink.add(false);
  }

  /// Gets the current filter selected on a certain screen.
  FilterOption getFilter(ScreenType screen) {
    return _filterSearch.value;
  }

  void dispose() {
    searchText.dispose();
    _filterSearch.close();
    _filterLibrary.close();
    _querySearch.close();
    _queryLibrary.close();
    _searchCompList.close();
    _libraryCompList.close();
    _deletingComposition.close();
  }
}
