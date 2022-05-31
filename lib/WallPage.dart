import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

@override
getMeta() async {
  final p = {};
  final snapshot =
      await FirebaseDatabase.instance.ref("/pins").orderByKey().get();
  final map = snapshot.value as Map<Object?, Object?>;
  map.forEach((key, value) {
    p[key] = value;
    // print(key);
    // print(key,);
    // print(value);
  });
  // print(p);
  // var reversedList = new List.from(myList.reversed);
  return p;
}

class WallPage extends StatefulWidget {
  @override
  _WallPageState createState() => _WallPageState();
}

class _WallPageState extends State<WallPage> {
  late List pins;
  final List<Marker> allMarkers = [];
  late String _imageUrl;
  final List<Widget> imgs = [];

  var imageUrl = '';

  // @override
  getImageUrl(filename) async {
    final ref = FirebaseStorage.instance.ref().child("files/$filename");
    final surl = await ref.getDownloadURL().then((url) {
      setState(() {
        imageUrl = url.toString();
        // print(imageUrl);
      });
      // print(imageUrl);
    });
  }

  @override
  void initState() {
    super.initState();
    getMeta().then((meta) {
      meta.keys.forEach((key) {
        // print(key);
        addtoList(meta[key]['point'], key, meta[key]['caption'],
            meta[key]['name'], meta[key]['time']);
      });
      // print(allMarkers);
    });
  }

  @override
  addtoList(coord, filename, caption, name, time) async {
    filename = filename.replaceAll(",", ".");
    await getImageUrl(filename);
    // print(filename);
    // print(imageUrl);
    setState(() => imgs.add(
          Card(
              child: OptimizedCacheImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )),
        ));
    setState(() => imgs.add(Divider(
          color: Colors.white,
          thickness: 2,
          indent: MediaQuery.of(context).size.width * 0.30,
          endIndent: MediaQuery.of(context).size.width * 0.30,
        )));

    setState(() => imgs.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          '$caption',
          style: const TextStyle(color: Colors.white),
        ))));
    setState(() => imgs.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          '$name',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ))));
    setState(() => imgs.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          '$time',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ))));
    // imgs.sort();
    setState(() => imgs.add(Divider(
          color: Colors.white,
          thickness: 2,
          indent: MediaQuery.of(context).size.width * 0.15,
          endIndent: MediaQuery.of(context).size.width * 0.15,
        )));
  }

  @override
  Widget build(BuildContext context) {
    // PaintingBinding.instance.imageCache.clear();
    // print(imageUrl);
    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
            primary: true,
            restorationId: "test",
            child: Column(
              children: imgs.toList(),
            )));
  }
}
