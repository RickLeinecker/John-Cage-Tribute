import 'package:flutter/material.dart';
import 'package:jct/src/resources/composition_api_retriever.dart';
import 'package:rxdart/subjects.dart';
import '../../../src/constants/filter_option.dart';
import '../../../src/constants/screen_type.dart';
import '../../../src/models/composition_model.dart';

/// BLoC that houses the search composition behavior of the John Cage Tribute.
///
/// Currently, it performs the stateful actions in the [SearchScreen] and
/// [LibraryScreen]. It works closely with the [FilterButtons] and
/// [SearchField] widgets to pass state information between them.
class SearchBloc {
  final compositionRetriever = CompositionApiRetriever();
  final searchText = TextEditingController();
  final _filterSearch = BehaviorSubject<FilterOption>();
  final _searchCompList = BehaviorSubject<List<CompositionModel>>();

  final libraryText = TextEditingController();
  final _filterLibrary = BehaviorSubject<FilterOption>();
  final _libraryCompList = BehaviorSubject<List<CompositionModel>>();

  Stream<FilterOption> get filterSearch => _filterSearch.stream;
  Stream<List<CompositionModel>> get searchCompList => _searchCompList.stream;
  Function(FilterOption) get changeFilterSearch => _filterSearch.sink.add;

  Stream<FilterOption> get filterLibrary => _filterLibrary.stream;
  Stream<List<CompositionModel>> get libraryCompList => _libraryCompList.stream;
  Function(FilterOption) get changeFilterLibrary => _filterLibrary.sink.add;

  SearchBloc() {
    changeFilterSearch(FilterOption.TAGS);
    changeFilterLibrary(FilterOption.TAGS);
  }

  void search(FilterOption filter, String query, {String composer}) async {
    List<Map<String, dynamic>> compositionMap;
    List<CompositionModel> compositions = List();

    if (composer == null) {
      compositionMap =
          await compositionRetriever.fetchCompositions(filter, query);

      for (final map in compositionMap) {
        compositions.add(CompositionModel.fromJson(map));
      }

      _searchCompList.sink.add(compositions);
    } else {
      compositionMap = await compositionRetriever
          .fetchCompositions(filter, query, user: composer);

      for (final map in compositionMap) {
        compositions.add(CompositionModel.fromJson(map));
      }

      _libraryCompList.sink.add(compositions);
    }
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
        return FilterOption.NONE;
    }
  }

  void dispose() {
    searchText.dispose();
    _filterSearch.close();
    _searchCompList.close();
    _filterLibrary.close();
    libraryText.dispose();
    _libraryCompList.close();
  }
}
