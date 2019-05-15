import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';


import 'package:flutter_cloud/Post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';









void main() => runApp(MyApp());

final notesReference = FirebaseDatabase.instance.reference().child('items');
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(


        body: ListViewPost(),


      ),


    );
  }
}



class ListViewPost extends StatefulWidget {
  @override
  _ListViewPostState createState() => new _ListViewPostState();
}



class _ListViewPostState extends State<ListViewPost> {
  List<Post> items;
  StreamSubscription<Event> _onPostAddedSubscription;
  StreamSubscription<Event> _onPostChangedSubscription;

  @override
  void initState() {
    super.initState();

    items = new List();

    _onPostAddedSubscription = notesReference.onChildAdded.listen(_onPostAdded);
    _onPostChangedSubscription = notesReference.onChildChanged.listen(_onPostUpdated);
  }

  @override
  void dispose() {
    _onPostAddedSubscription.cancel();
    _onPostChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(


      home: Scaffold(
        appBar: AppBar(
        title: Text("HyperGarageSale"),
        ),
        body: Center(
          child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(1.0),
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Divider(height: 5.0),
                    ListTile(
                      title: Text(
                        '${items[position].title.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      subtitle: Text(
                        '${items[position].price} dollars',
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      leading: Column(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(8.0)),
                          CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 15.0,
                            child: Text(
                              '${items[position].title.substring(0,1).toUpperCase()}',
                              style: TextStyle(
                                fontSize: 22.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _deletePost(context, items[position], position)),
                        ],
                      ),
                      onTap: () => {

                        Navigator.push(context,MaterialPageRoute(builder: (context)=> DetailsPage(post: items[position],length: items[position].images.length.toString(),))),
                      },
                    ),
                  ],

               );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createPost(context),
        ),
      ),
    );
  }

  void _onPostAdded(Event event) {
    setState(() {
      items.add(new Post.fromSnapshot(event.snapshot));
    });
  }

  void _onPostUpdated(Event event) {
    var oldPostValue = items.singleWhere((post) => post.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldPostValue)] = new Post.fromSnapshot(event.snapshot);
    });
  }

  void _deletePost(BuildContext context, Post post, int position) async {
    await notesReference.child(post.id).remove().then((_) {
      setState(() {
        items.removeAt(position);
      });
    });
  }


  void _createPost(BuildContext context) async {
    List<String> images;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>NewPostActivity(Post(null, '', '','',images))),
    );
  }
}


class NewPostActivity extends StatefulWidget {

  final Post post;
  NewPostActivity(this.post);
  @override
  _NewPostActivityState createState() => _NewPostActivityState();

}
class _NewPostActivityState extends State<NewPostActivity>  {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();


 List<String> list = new List();

  Widget _snackSample() => SnackBar(
    content: Text(
      titleController.text,
      style: TextStyle(

        fontSize: 20,
      ),
      textAlign: TextAlign.center,

    ),
    duration: Duration(milliseconds: 5000),
  );


  _goToTakePhotos(BuildContext context) async{

    final String url = await Navigator.push(context, MaterialPageRoute(builder: (context)=>MyImagePicker()));

    this.setState((){


        list.add(url);





    });

}
_goToViewPhotos(BuildContext context) async{
Navigator.push(context, MaterialPageRoute(builder: (context)=> DisplayPictureScreen(images: list)));

}

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
  GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Add New"),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: 'Enter the title of the item'

            ),
          ),
          TextField(
            controller: priceController,
            decoration: InputDecoration(
                hintText: 'Enter price'
            ),
          ),

          TextFormField(
          maxLines: 20,
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'enter description',


            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ButtonTheme(
                  minWidth: 5.0,
                  height: 30.0,
                  child:RaisedButton(
                    onPressed: (){
                      _goToTakePhotos(context

                      ); },
                    child:Text("TAKE NEW PHOTO"),
                  ),
              ),
              ButtonTheme(
                minWidth: 5.0,
                height: 30.0,
                child:RaisedButton(
                  onPressed: (){
                    _goToViewPhotos(context

                    ); },
                  child:Text("VIEW PHOTOS"),
                ),
              ),
             ButtonTheme(
               minWidth: 5.0,
               height: 30.0,
               child: RaisedButton(onPressed: () {
                 notesReference.push().set({
                   'title': titleController.text,
                   'price': priceController.text,
                   'description': descriptionController.text,
                   'images':list,

                 }).then((_) {
                   final bar = _snackSample();
                   _key.currentState.showSnackBar(bar);
                   Navigator.pop(context);
                 }


                 );

               },

                   child: Text('POST')
               ),
             ),




            ]


          ),


        ],

      ),


    );

  }
}


class MyImagePicker extends StatefulWidget {
  @override
  _MyImagePickerState createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  File _image;
  String _imageName;




  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);



    setState(() {
      _image = image;

    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Picture'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
      Card(
      semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,

        child:Image.file(_image, height: 300.0, width: 300.0,fit: BoxFit.fill,),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),

          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () async {
              String date = DateTime.now().toString();
              final StorageReference firebaseStorageRef =
              FirebaseStorage.instance.ref().child('${date}.png');
              final StorageUploadTask task =
              firebaseStorageRef.putFile(_image);
              StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;
              String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
              print("url is"+ downloadUrl);
              Navigator.pop(context,downloadUrl);

            },
          )
        ],
      ),
    );
  }


}
class DisplayPictureScreen extends StatelessWidget {
  final List<String> images;


  const DisplayPictureScreen({Key key, this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(title: Text('Pictures')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image
        //Image.file(File(imagePath)),
        body: new Center(

          child: GridView.count(

            crossAxisCount: 2,
            children: List.generate(images.length, (index){
              return Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,

                child: CachedNetworkImage(
                  imageUrl: images[index],
                  placeholder: (context, url) => new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                  fit: BoxFit.fill,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(10),
              );
            })


          ),
        )
    );
  }
}
class DetailsPage extends StatelessWidget {
  final Post post;
  final String length;


  DetailsPage({Key key, @required this.post, this.length}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(post.title.toUpperCase()),
        ),
      body: Stack(
        children: <Widget>[


          Align(

            alignment: Alignment.topCenter,

            child:Text("${post.title.toUpperCase() } for ${post.price.toUpperCase()} ",textAlign: TextAlign.center,

                style: TextStyle(color:Colors.black38,fontSize:30,fontWeight: FontWeight.bold) ),

          ),



          _buildGridView(context,post.images.length),

          Container(
            margin: EdgeInsets.fromLTRB(5.0, 200.0, 0.0, 10.0),

            child:Text("Description: ${post.description} ",textAlign: TextAlign.center,

                style: TextStyle(color:Colors.black38,fontSize:25,fontWeight: FontWeight.bold) ),
          )



        ],

      ),
    );
  }

  Widget _buildGridView(BuildContext context,int length) {

    return GridView.count(
      padding:EdgeInsets.fromLTRB(0, 25.0, 0, 0),
        crossAxisCount: 2,
children: <Widget>[
  InkWell(

    onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> viewFullImage(url:post.images[0])));
    },
    child:  Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,


      child: CachedNetworkImage(
        imageUrl: post.images[0],
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
        fit: BoxFit.fill,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
    ),
  ),
  InkWell(

    onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> viewFullImage(url:post.images[1])));
    },
    child:  Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,


      child: CachedNetworkImage(
        imageUrl: post.images[1],
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
        fit: BoxFit.fill,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
    ),
  ),


],






    );
  }
}

class viewFullImage extends StatelessWidget{
  final String url;

  const viewFullImage({Key key, this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("HyperGarageSale"),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        )
      ),
      body:Container(

        width: double.infinity,
        height: double.infinity,

        child: new CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
        fit: BoxFit.fill,
        height: double.infinity,
        width: double.infinity
      ),

      )

    );
  }
  
  
  
}