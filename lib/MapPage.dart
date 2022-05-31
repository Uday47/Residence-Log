import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//get coordinates
Future<List<double>> getUserLocation() async {
  WidgetsFlutterBinding.ensureInitialized();
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  var pos = [position.latitude.toDouble(), position.longitude.toDouble()];
  return pos;
}

const MAP_ACCESS_TOKEN =
    'pk.eyJ1IjoidWRheTQ3IiwiYSI6ImNsM2RrNzNhNDA4cGwzZGw1cHd4NmFkOGIifQ.mmwjPgf93iLhFOCyCfc0dQ';
const MAP_STYLE_TOKEN = 'uday47/cl3ez4unv000015oa0oulk226';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
// final Future<String> pin = getUserLocation();
}

getMeta() async {
  final p = [];
  final snapshot = await FirebaseDatabase.instance.ref().orderByKey().get();
  final map = snapshot.value as Map<Object?, Object?>;
  map.forEach((key, value) {
    p.add(map);
    // print(p);
  });
  return p;
}

class _MapPageState extends State<MapPage> {
  late List pins;
  final List<Marker> allMarkers = [];
  late String _imageUrl;





  var imageUrl = '';
  getImageUrl(filename) async {
    final ref = FirebaseStorage.instance.ref().child("files/$filename");
    final surl = await ref.getDownloadURL().then((url) {
      setState(() {
        imageUrl = url.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getMeta().then((meta) {
      meta[0]['pins'].entries.forEach((ele) {
        // print(imgs);
        addtoList(
            meta[0]['pins'][ele.key]['point'],
            ele.key,
            meta[0]['pins'][ele.key]['caption'],
            meta[0]['pins'][ele.key]['name'],
            meta[0]['pins'][ele.key]['time']);
      });
    });
    // print(allMarkers);
  }

  addtoList(coord, filename, caption, name, time) {
    filename = filename.replaceAll(",", ".");

    // print(coord[0].toDouble());
    setState(() => allMarkers.add(Marker(
        width: 70,
        height: 70,
        // key: filename,
        point: LatLng(coord[0], coord[1]),
        builder: (_) {
          return GestureDetector(
            onTap: () async {
              await getImageUrl(filename);
              await showDialog(
                  context: context,
                  builder: (_) =>
                      imageDialog(caption, imageUrl, context, name, time));
              // return Scaffold();
            },
            child: Image.asset("assets/pinmarker-removebg-preview.png"),
          );
        })));
  }

  Widget imageDialog(text, path, context, name, time) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$text - $name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close_rounded),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Center(
                child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Stack(children: [
                      const Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 5,

                      )),
                      Center(
                        child: Image.network(path)
                      )
                    ])),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserLocation(),
        builder: (BuildContext context, AsyncSnapshot<List<double>> location) {
          if (location.hasData) {
            return Scaffold(
                backgroundColor: Colors.black,
                body: Stack(children: [
                  FlutterMap(
                      // mapController: MapController(),
                      options: MapOptions(
                        maxZoom: 22.4,
                        zoom: 5,
                        allowPanning: true,
                        center: LatLng(location.data![0], location.data![1]),
                        interactiveFlags:
                            InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        rotationWinGestures: 1,
                      ),
                      nonRotatedLayers: [
                        TileLayerOptions(
                            maxZoom: 25,
                            urlTemplate:
                                'https://api.mapbox.com/styles/v1/{id}/tiles/512/{z}/{x}/{y}?access_token={accesstoken}',
                            additionalOptions: {
                              'id': MAP_STYLE_TOKEN,
                              'accesstoken': MAP_ACCESS_TOKEN
                            }),
                        MarkerLayerOptions(markers: allMarkers),
                        MarkerLayerOptions(markers: [
                          Marker(
                              width: 20,
                              height: 20,
                              point:
                                  LatLng(location.data![0], location.data![1]),
                              builder: (_) {
                                return const MyLocationMarker();
                              })
                        ])
                      ])
                ]));
          }
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Loading...",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class MyLocationMarker extends StatelessWidget {
  const MyLocationMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
          color: Colors.pinkAccent,
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.white)),
    );
  }
}
