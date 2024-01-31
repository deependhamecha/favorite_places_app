import 'dart:io';

import 'package:favorite_places_app/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbPath, 'places.db'),
        onCreate: (db, version) {
      // On Create will be called if db is created
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT)');
    }, version: 1);

    return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  // Initial Value
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final places = data.map((row) => Place(id: row['id'] as String, title: row['title'] as String, image: File(row['image'] as String))).toList();

    state = places;
  }

  /**
   * Reducer
   */
  void addPlace(String title, File image) async {
    /**
     * Storing Image On Device
     */ 
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    // final newPlace = Place(title: title, image: image); // OLD BEFORE SAVING
    final newPlace = Place(title: title, image: copiedImage);

    final db = await _getDatabase();

    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path
    });


    state = [newPlace, ...state];
  }
}

// Reducer class = UserPlacesNotifier
// type of data = List<Place>
final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
        (ref) => UserPlacesNotifier());
