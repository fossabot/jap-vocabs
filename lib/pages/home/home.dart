import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jap_vocab/components/custom_layout.dart';
import 'package:jap_vocab/pages/home/components/list_item.dart';
import 'package:jap_vocab/models/item.dart';
import 'package:jap_vocab/pages/home/components/home_appbar.dart';
import 'package:jap_vocab/pages/home/components/review_button.dart';
import 'package:jap_vocab/redux/state/app_state.dart';
import 'package:jap_vocab/redux/thunk/items.dart';
import 'package:redux/redux.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      appBar: HomeAppBar(),
      body: StoreConnector(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        onInit: (Store<AppState> store) =>
            store.dispatch(getItems()), // TODO: CHECK
        builder: (context, _ViewModel vm) {
          print('HomePage build) ${vm.items.length}');

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: vm.items?.length ?? 0,
            itemBuilder: (_, index) {
              return ListItem(
                item: vm.items[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {'id': vm.items[index].id},
                  );
                },
              );
            },
            /*separatorBuilder: (_, index) {
              return Divider(height: 0);
            },*/
          );
        },
      ),
      floatingActionButton: ReviewButton(),
    );
  }
}

class _ViewModel {
  final List<Item> items;
  final Function getAllItems;

  _ViewModel({this.items, this.getAllItems});

  factory _ViewModel.create(Store<AppState> store) {
    final _items = store.state.itemsState.items;
    final _sorted = List<Item>.from(_items)
      ..sort((a, b) {
        final dateA = a.nextReview ?? DateTime.now();
        final dateB = b.nextReview ?? DateTime.now();

        return dateA.compareTo(dateB);
      });

    void _getItems() {
      store.dispatch(getItems());
    }

    return _ViewModel(
      items: _sorted,
      getAllItems: _getItems,
    );
  }
}
