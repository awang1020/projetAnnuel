import 'package:eco_map/codeAPI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/src/material/dropdown.dart';

import 'dart:math' show cos, sqrt, asin;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eco Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapView(),
    );
  }
}

class PageVehicule extends StatefulWidget {
  Page2 createState() => Page2();
}

class Page2 extends State<PageVehicule> {

  String valueChoose = "PEUGEOT";
  List marque = ["PEUGEOT","RENAULT","TESLA", "MERCEDES", "OPEL"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caractéristique du véhicule'),
        centerTitle: true,
      ),
      body: Center(
        child:Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.only(left:16, right: 16),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width:1),
                  borderRadius: BorderRadius.circular(10.0)
              ),
              child : DropdownButton(
                hint: Text("Choisissez une marque: "),
                icon: Icon(Icons.arrow_drop_down),

                value: valueChoose,
                iconSize: 36,
                isExpanded: true,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22
                ),
                onChanged: (_value){
                  setState(() {
                    valueChoose = _value as String;
                  });
                },
                items: marque.map((valueItem){
                  return DropdownMenuItem(
                    value: valueItem,
                    child: Text(valueItem),
                  );
                }).toList(),
              ),
            )
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .pop();
          },
          child: Icon(Icons.check_circle_outlined)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialPosition = CameraPosition(
      target: LatLng(48.856614, 2.3522219));
  late GoogleMapController mapController;

  late Position _actuellePosition;
  String _adresseActuelle = '';

  final origineController = TextEditingController();
  final destinationController = TextEditingController();

  final origineAdresseNoeud = FocusNode();
  final destinationAddressNoeud = FocusNode();

  String _origineAdresse = '';
  String _destinationAddress = '';
  String? _distance;

  Set<Marker> marqueur = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> coordonneesPoly = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

// Les clés globales identifient de manière unique les éléments.
//Les clés globales permettent d'accéder à d'autres objets associés à ces éléments,
// tels que BuildContext. Pour StatefulWidgets, les clés globales donnent également accès à State.

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  _positionActuelle() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _actuellePosition = position;
        print('Position actuelle: $_actuellePosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _adresse();
    }).catchError((e) {
      print(e);
    });
  }

  _adresse() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _actuellePosition.latitude, _actuellePosition.longitude);

      Placemark place = p[0];

      setState(() {
        _adresseActuelle =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place
            .country}";
        origineController.text = _adresseActuelle;
        _origineAdresse = _adresseActuelle;
      });
    } catch (e) {
      print(e);
    }
  }


  Future<bool> _calculDistance() async {
    try {
      List<Location> marqueurDebut = await locationFromAddress(_origineAdresse);
      List<Location> marqueurArrivee =
      await locationFromAddress(_destinationAddress);

      double latitudeOrigine = _origineAdresse == _adresseActuelle
          ? _actuellePosition.latitude
          : marqueurDebut[0].latitude;

      double longitudeOrigine = _origineAdresse == _adresseActuelle
          ? _actuellePosition.longitude
          : marqueurDebut[0].longitude;

      double latitudeArrivee = marqueurArrivee[0].latitude;
      double longitudeArrivee = marqueurArrivee[0].longitude;

      String coordonneesOrigine = '($latitudeOrigine, $longitudeOrigine)';
      String coordonneesArrivee = '($latitudeArrivee, $longitudeArrivee)';

      Marker startMarker = Marker(
        markerId: MarkerId(coordonneesOrigine),
        position: LatLng(latitudeOrigine, longitudeOrigine),
        infoWindow: InfoWindow(
          title: 'Origine $coordonneesOrigine',
          snippet: _origineAdresse,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId(coordonneesArrivee),
        position: LatLng(latitudeArrivee, longitudeArrivee),
        infoWindow: InfoWindow(
          title: 'Destination $coordonneesArrivee',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Ajouter les marqueurs dans une liste
      marqueur.add(startMarker);
      marqueur.add(destinationMarker);

      print(
        'Coordonnées origine: ($latitudeOrigine, $longitudeOrigine)',
      );
      print(
        'Coordonnées destination: ($latitudeArrivee, $longitudeArrivee)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (latitudeOrigine <= latitudeArrivee)
          ? latitudeOrigine
          : latitudeArrivee;
      double minx = (longitudeOrigine <= longitudeArrivee)
          ? longitudeOrigine
          : longitudeArrivee;
      double maxy = (latitudeOrigine <= latitudeArrivee)
          ? latitudeArrivee
          : latitudeOrigine;
      double maxx = (longitudeOrigine <= longitudeArrivee)
          ? longitudeArrivee
          : longitudeOrigine;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      await _createPolylines(latitudeOrigine, longitudeOrigine, latitudeArrivee,
          longitudeArrivee);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < coordonneesPoly.length - 1; i++) {
        totalDistance += _coordinateDistance(
          coordonneesPoly[i].latitude,
          coordonneesPoly[i].longitude,
          coordonneesPoly[i + 1].latitude,
          coordonneesPoly[i + 1].longitude,
        );
      }

      setState(() {
        _distance = totalDistance.toStringAsFixed(2);
        print('Distance: $_distance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _createPolylines(double latitudeOrigine,
      double longitudeOrigine,
      double latitudeArrivee,
      double longitudeArrivee,) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      codeAPI.CLE_API,
      PointLatLng(latitudeOrigine, longitudeOrigine),
      PointLatLng(latitudeArrivee, longitudeArrivee),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        coordonneesPoly.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: coordonneesPoly,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    _positionActuelle();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Vue de la CARTE
            GoogleMap(
              markers: Set<Marker>.from(marqueur),
              initialCameraPosition: _initialPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),

            // BOUTON ZOOMER
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade400, // COULEUR BOUTON
                        child: InkWell(
                          splashColor: Colors.black26, // COULEUR FORME
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    //BOUTON DEZOOMER
                    SizedBox(height: 15),
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade400,
                        child: InkWell(
                          splashColor: Colors.black26,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // L'affichage de l'encadré de saisie des données
            // Montrer la route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Itinéraire',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Départ',
                              hint: 'Choisir un lieu de départ',
                              prefixIcon: Icon(Icons.adjust_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  origineController.text = _adresseActuelle;
                                  _origineAdresse = _adresseActuelle;
                                },
                              ),
                              controller: origineController,
                              focusNode: origineAdresseNoeud,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _origineAdresse = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Destination',
                              hint: 'Choisir une destination',
                              prefixIcon: Icon(Icons.add_location_rounded),
                              controller: destinationController,
                              focusNode: destinationAddressNoeud,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _distance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_distance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: (_origineAdresse != '' &&
                                _destinationAddress != '')
                                ? () async {
                              origineAdresseNoeud.unfocus();
                              destinationAddressNoeud.unfocus();
                              setState(() {
                                if (marqueur.isNotEmpty) marqueur.clear();
                                if (polylines.isNotEmpty)
                                  polylines.clear();
                                if (coordonneesPoly.isNotEmpty)
                                  coordonneesPoly.clear();
                                _distance = null;
                              });

                              _calculDistance().then((isCalculated) {
                                if (isCalculated) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Votre itinéraire a été calculée'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Votre itinéraire n\'a pas été calculée'),
                                    ),
                                  );
                                }
                              });
                            }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Démarrer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _actuellePosition.latitude,
                                  _actuellePosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //Bouton pour la page de caracteristique du véhicule
            SafeArea(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: Colors.white,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.add_circle_rounded),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                              MaterialPageRoute(
                                  builder: (context) => PageVehicule()
                              )
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}