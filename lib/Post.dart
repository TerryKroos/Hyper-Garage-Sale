import 'package:firebase_database/firebase_database.dart';

class Post {
  String _id;
  String _title;
  String _price;
  String _description;


  List<dynamic> _images;


  Post(this._id, this._title,this._price, this._description,this._images);

  Post.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._price = obj['price'];
    this._description = obj['description'];

    this._images = obj['images'];
  }

  String get id => _id;
  String get title => _title;
  String get price => _price;
  String get description => _description;

  List<dynamic> get images => _images;

  Post.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _title = snapshot.value['title'];
    _price = snapshot.value['price'];
    _description = snapshot.value['description'];

    _images = snapshot.value['images'];
  }
}