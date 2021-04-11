import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_pooling/profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gradient_text/gradient_text.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fdottedline/fdottedline.dart';
import 'dart:async';
import 'main.dart';
import 'package:fade/fade.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  LatLng mytarget;
  Maps(this.mytarget);
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final picker = ImagePicker();
  File image;
  TextEditingController foodcontroller = TextEditingController();

  String _value;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  double lat = 12332323;
  double long = 32332323232;
  String url;

  void initMarker(
    specify,
    markerIdVal,
  ) async {
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarker,
      markerId: markerId,
      onTap: () async {
        print("cdsccd");
        setState(() {
          issee = !issee;

          info = specify;
          location = LatLng(double.parse(specify['Location'][0]),
              double.parse(specify['Location'][1]));
          print(location);
        });

        profile_info = await Firestore.instance
            .collection("users")
            .document(specify["uid"])
            .get()
            .then((value) {
          setState(() {
            name = value.data["name"];
            foodphoto = info["foodphoto"];
            where_to_eat = info["where to eat"];
          });
        });
      },
      position: LatLng(double.parse(specify['Location'][0]),
          double.parse(specify['Location'][1])),
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  LatLng location;

  var info;
  var profile_info;
  bool issee = false;
  String name = "";
  String foodphoto = "";
  String where_to_eat = "";

  getMarkerData() async {
    Firestore.instance.collection('pins').getDocuments().then((myMockDoc) {
      if (myMockDoc.documents.isNotEmpty) {
        for (int i = 0; i < myMockDoc.documents.length; i++) {
          setState(() {});
          initMarker(
            myMockDoc.documents[i].data,
            myMockDoc.documents[i].documentID,
          );
        }
      }
    });
  }

  getuid() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    setState(() {
      useruid = uid;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMarkerData();
    getuid();
  }

  List<String> mylocation;
  savelocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    lat = position.latitude;
    long = position.longitude;
    print(position.latitude);
    setState(() {
      mylocation = [lat.toString(), long.toString()];
    });
  }

  String useruid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: Set<Marker>.of(markers.values),
              initialCameraPosition:
                  CameraPosition(zoom: 15, target: widget.mytarget),
              onMapCreated: (GoogleMapController controller) {
                getMarkerData();
              }),
          Fade(
            visible: issee,
            duration: Duration(milliseconds: 100),
            child: Padding(
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[900]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    foodphoto != null
                        ? Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              width: 130,
                              height: 150,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                      image: NetworkImage(foodphoto ?? ""),
                                      fit: BoxFit.cover)),
                            ))
                        : Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              width: 130,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: CircularProgressIndicator(),
                            )),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientText(
                            name ?? "",
                            gradient: LinearGradient(
                                colors: [Color(4294493271), Color(4294681407)]),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                color: Colors.orange),
                          ),
                          //  GoogleFonts.poppins(
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 20,
                          //       color: Colors.orange),
                          SizedBox(height: 1),
                          Text(
                            where_to_eat ?? "",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                          SizedBox(height: 25),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) =>
                                      Profile(useruid, location, foodphoto)));
                            },
                            child: Container(
                              height: 35,
                              width: 190,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Color(4294493271),
                                    Color(4294681407)
                                  ])),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Connect',
                                        style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 0,
                                      ),
                                      Icon(
                                        Icons.double_arrow_outlined,
                                        color: Colors.white,
                                      )
                                    ],
                                  )),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[900],
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (ctx) {
                savelocation();

                return ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Dialog(
                      child: Material(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40)),
                      width: 400,
                      height: 530,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Text(
                              "Please fill in these details to have a great bouffage !",
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue)),
                          SizedBox(
                            height: 20,
                          ),
                          new Material(
                              child: new Container(
                            height: 45,
                            child: new TextFormField(
                              controller: foodcontroller,
                              style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500),
                              decoration: new InputDecoration(
                                filled: true,
                                hintText: "Age",
                                hintStyle: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500),
                                fillColor: Colors.grey.withOpacity(0.5),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (val) {
                                if (val.length == 0) {
                                  return "";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          )),
                          SizedBox(
                            height: 30,
                          ),
                          StatefulBuilder(builder: (ctx, p) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey.withOpacity(0.5)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _value,
                                  //elevation: 5,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),

                                  items: <String>[
                                    'Your Place',
                                    'Their Place',
                                    'Food van',
                                    'Restaurants'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    "Please choose ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onChanged: (String value) {
                                    p(() {
                                      _value = value;
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 30),
                          StatefulBuilder(builder: (ctx, p) {
                            return GestureDetector(
                                onTap: () async {
                                  final pickedimage = await picker.getImage(
                                      source: ImageSource.gallery);
                                  p(() {
                                    if (pickedimage != null) {
                                      image = File(pickedimage.path);
                                    }
                                  });
                                },
                                child: Container(
                                    height: 180,
                                    width: 300,
                                    child: image == null
                                        ? FDottedLine(
                                            color: Colors.grey,
                                            strokeWidth: 3.0,
                                            dottedLength: 8.0,
                                            space: 10.0,
                                            corner: FDottedLineCorner.all(15.0),
                                            child: Container(
                                                height: 180,
                                                width: 300,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Center(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 33.0),
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        "assets/logo.png",
                                                        color: Colors.blue,
                                                        scale: 7,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        "Upload your delicacy",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black87),
                                                      )
                                                    ],
                                                  ),
                                                ))),
                                          )
                                        : Container(
                                            height: 180,
                                            width: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              image: DecorationImage(
                                                  image: FileImage(image),
                                                  fit: BoxFit.cover),
                                            ),
                                          )));
                          }),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (foodcontroller.text != null) {
                                // StorageReference ref = FirebaseStorage.instance
                                //     .ref()
                                //     .child("/photo.jpg");
                                // StorageUploadTask uploadTask =
                                //     ref.putFile(image);

                                // var dowurl = await (await uploadTask.onComplete)
                                //     .ref
                                //     .getDownloadURL()
                                //     .toString();

                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child('${DateTime.now()}user_image');

                                await ref.putFile(image).onComplete;
                                final url = await ref.getDownloadURL();
                                print("Image URL: " + url);
                                final FirebaseUser user =
                                    await auth.currentUser();
                                final uid = user.uid;
                                setState(() {
                                  useruid = uid;
                                });
                                url != null
                                    ? Firestore.instance
                                        .collection("pins")
                                        .add({
                                        "age": foodcontroller.text,
                                        "where to eat": _value,
                                        "foodphoto": url,
                                        "Location": mylocation,
                                        "uid": uid,
                                      }).then((value) {
                                        getMarkerData();
                                        Navigator.pop(context);
                                      })
                                    : null;
                              } else
                                null;
                            },
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.grey.withOpacity(0.5)),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Proceed",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    )),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                  )),
                );
              });
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
