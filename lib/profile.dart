import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  final uid;
  final location;
  final url;

  Profile(this.uid, this.location, this.url);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.uid);
    print(widget.location);
    _markers.add(Marker(
      onTap: () {},
      markerId: MarkerId('SomeId'),
      position: widget.location,
    ));
  }

  List<Marker> _markers = <Marker>[];
  double _crossAxisSpacing = 8, _mainAxisSpacing = 12, _aspectRatio = 3;
  int _crossAxisCount = 9;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    var width = (screenWidth - ((_crossAxisCount - 7) * _crossAxisSpacing)) /
        _crossAxisCount;
    var height = width / _aspectRatio;
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 20,
                  ),
                  child: Container(
                      height: 220,
                      width: 180,
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: new DecorationImage(
                            image: new NetworkImage(widget.url),
                            fit: BoxFit.cover,
                          ))),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection("users")
                              .document(widget.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return GradientText(
                              snapshot.data["name"],
                              gradient: LinearGradient(colors: [
                                Color(4294493271),
                                Color(4294681407)
                              ]),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 30,
                                  color: Colors.orange),
                            );
                          }),
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection("users")
                              .document(widget.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Text("${snapshot.data["age"]} years",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500)),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: GradientText(
                    'Allergies',
                    gradient: LinearGradient(
                        colors: [Color(4294493271), Color(4294681407)]),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 25,
                        color: Colors.orange),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 0),
                    child: StreamBuilder(
                        stream: Firestore.instance
                            .collection("users")
                            .document(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return GridView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data["allergies"].length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 9.0,
                                mainAxisSpacing: 0.0,
                                childAspectRatio: 2.9 / 1,
                              ),
                              itemBuilder: (ctx, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 6, bottom: 4, left: 9, right: 9),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white.withOpacity(0.1)),
                                    child: Text(snapshot.data["allergies"][i],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                );
                              });
                        }))
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: GradientText(
                            'Address',
                            gradient: LinearGradient(
                                colors: [Color(4294493271), Color(4294681407)]),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                                color: Colors.orange),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: StreamBuilder(
                            stream: Firestore.instance
                                .collection("users")
                                .document(widget.uid)
                                .snapshots(),
                            builder: (ctx, i) {
                              return Container(
                                width: 190,
                                child: Text(
                                  i.data["address"],
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 150,
                        height: 200,
                        child: GoogleMap(
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                            markers: Set.of(_markers),
                            initialCameraPosition: CameraPosition(
                                zoom: 15, target: widget.location),
                            onMapCreated: (GoogleMapController controller) {}),
                      ),
                    ),
                  )
                ]),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 30),
              child: GradientText(
                'Contact',
                gradient: LinearGradient(
                    colors: [Color(4294493271), Color(4294681407)]),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Colors.orange),
              ),
            ),
            StreamBuilder(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  return GestureDetector(
                    onTap: () {
                      launch("tel://${snapshot.data["no."]}");
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, right: 20, top: 10),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Color(4294493271),
                              Color(4294681407)
                            ])),
                        child: Align(
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 5.0, top: 5),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                                  .withOpacity(0.4)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20.0),
                                            child: Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 110,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Call',
                                      style: GoogleFonts.poppins(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                ])),
                      ),
                    ),
                  );
                })
          ]),
        ));
  }
}
