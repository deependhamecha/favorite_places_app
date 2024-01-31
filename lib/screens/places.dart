import 'package:favorite_places_app/providers/user_places.dart';
import 'package:favorite_places_app/screens/add_place.dart';
import 'package:favorite_places_app/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerWidget is StatelessWidget of riverpod
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlacesScreenState();
  }
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {

  late Future<void> _placesFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }


  @override
  Widget build(BuildContext context) {

    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [IconButton(onPressed: () {
          // Navigate
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AddPlaceScreen()));
        }, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(future: _placesFuture, builder: (context, snapshot) =>
        snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator()) : PlacesList(
        places: userPlaces,
      )
      )
    );
  }
}

