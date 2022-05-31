import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fbutton/fbutton.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CamPage extends StatefulWidget {
  @override
  _CamPageState createState() => _CamPageState();
}

class _CamPageState extends State<CamPage> {
  File _image = File('');
  final database = FirebaseDatabase.instance.ref();

  //Controller to fetch caption text
  late TextEditingController myController;
  String caption = "";

  @override
  void initState() {
    super.initState();
    myController = TextEditingController();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  //Add Picture MetaData to Database
  updateMetaData(filename, caption) async {
    //Get Current User Credentials
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final name = user!.email!.split("@")[0];
    final time = DateTime.now();
    String now = DateFormat.yMd().add_jm().format(time);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final loc = [position.latitude, position.longitude];
    final ref = database.child("pins/$filename");
    await ref
        .set({'point': loc, 'caption': caption, 'name': name, 'time': now});
  }

  Future getImage(bool isCamera) async {
    XFile? image;
    if (isCamera) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    setState(() {
      _image = File(image!.path);
    });
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    final time = DateTime.now();
    String basenow = DateFormat('yyyyMMddhhmmss').format(time).toString();


    final filename = '$basenow';
    final File newImage = await _image.copy('$path/$filename)');

    // final filename = basename(image!.path);
    final destination = 'files/$filename';
    FirebaseApi.uploadFile(destination, _image);
    return filename;
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      Navigator.of(context).pop(myController.text);
      myController.clear();
    }

    Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Kindly add a caption'),
              content: TextField(
                controller: myController,
                decoration: const InputDecoration(hintText: "Be creative!"),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: submit,
                  child: const Text('Upload'),
                ),
              ],
            ));
    Future<String?> confirmDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pinned successfully.'),
          content: const Text("Go to map to view your pin"),
          actions: <Widget>[
            TextButton(
              onPressed: submit,
              child: const Text('OK'),
            ),
          ],
        ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: const Text("There's no better time than now!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      )),
                ),
                // Container(child: const Text("You only have to look to see it.", textAlign: TextAlign.center,style: TextStyle(
                //   color: Colors.white,
                //   fontSize: 17,
                //   fontFamily: 'Montserrat',
                //   fontWeight: FontWeight.w500,
                // )),),
                const SizedBox(
                  width: 200,
                  height: 100,
                ),
                FButton(
                  onPressed: () async {
                    final fileMetaName = await getImage(true);
                    final caption = await openDialog();
                    setState(() => this.caption = caption!);
                    await updateMetaData(fileMetaName.replaceAll(".", ","), caption);
                    confirmDialog();
                  },
                  image: const Icon(
                    Icons.camera,
                    color: Colors.white,
                    size: 50,
                  ),
                  imageMargin: 8,
                  corner: FCorner.all(9),
                  imageAlignment: ImageAlignment.left,
                  text: "Take Photo ",
                  shadowColor: Colors.white,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                  color: Colors.white12,
                ),
                const SizedBox(
                  height: 110,
                ),
                FButton(
                  onPressed: () async {
                    final fileMetaName = await getImage(false);
                    final caption = await openDialog();
                    setState(() => this.caption = caption!);
                    await updateMetaData(fileMetaName.replaceAll(".", ","), caption);
                    confirmDialog();
                  },
                  image: const Icon(
                    Icons.photo_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  imageMargin: 8,
                  corner: FCorner.all(9),
                  imageAlignment: ImageAlignment.left,
                  text: "From Gallery ",
                  shadowColor: Colors.white,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                  color: Colors.white12,
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
          )),
    );
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    final ref = FirebaseStorage.instance.ref(destination);
    return ref.putFile(file);
  }
}
