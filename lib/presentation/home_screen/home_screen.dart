import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key})
      : super(
          key: key,
        );
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<List<dynamic>> fetchSensorData(String token) async {
  // final url = Uri.https(
  //     'https://api.waziup.io/api/v2/devices/ESP32Device/sensors/TC/values',
  //     '.json');
  // final response = await http.get(url);
  // print(response.body);

  final url =
      Uri.parse('https://api.waziup.io/api/v2/devices/ESP32Device/sensors');

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody;
      print("*****data****");
    } else {
      throw Exception(
          'Failed to load sensor data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching sensor data: $e');
  }
}

Future<String> get_auth_token(String username, String password) async {
  final url = Uri.parse('https://api.waziup.io/api/v2/auth/token');

  // Prepare the request body
  final Map<String, dynamic> requestBody = {
    'username': username,
    'password': password
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(requestBody),
  );

  // Check the response status and content type
  if (response.statusCode == 200) {
    if (response.headers['content-type']?.contains('application/json') ==
        true) {
      // Parse the response body as JSON
      final responseBody = json.decode(response.body);
      final authToken = responseBody['token'];
      print('Authentication Token: $authToken');
      return responseBody['token'];
      // Do something with the token, like saving it or using it for subsequent requests
    } else if (response.headers['content-type']?.contains('text/plain') ==
        true) {
      // Treat the response body as plain text
      final authToken = response.body;
      print('Authentication Token: $authToken');
      return response.body;
      // Do something with the token, like saving it or using it for subsequent requests
    } else {
      print('Unexpected content type: ${response.headers['content-type']}');
      throw Exception(
          'Unexpected content type: ${response.headers['content-type']}');
    }
  } else {
    print(
        'Failed to get the authentication token. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception(
        'Failed to load sensor data. Status code: ${response.statusCode}');
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _sensorData;
  late String _authToken;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  late GoogleMapController mapController;
  late BitmapDescriptor animalIcon;

  final LatLng _center =
      const LatLng(45.521563, -122.677433); // Example: Portland, OR coordinates

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initState() {
    super.initState();
    //get_auth_token("albertngigi3@gmail.com", "Albert18684");
    _authenticateAndFetchData();
    _setCustomMapPin();
  }

  void _setCustomMapPin() async {
    animalIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/animal_icon.png', // Replace with your custom animal icon image path
    );
  }

  Future<void> _authenticateAndFetchData() async {
    try {
      _authToken =
          await get_auth_token("albertngigi3@gmail.com", "Albert18684");
      setState(() {
        _sensorData = fetchSensorData(_authToken);
        print(_sensorData);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Pori Tracker",
              style: theme.textTheme.titleSmall,
            ),
            backgroundColor: Color.fromARGB(131, 77, 223, 208),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: Container(
                color: Color.fromARGB(203, 255, 255, 255),
                height: 4.0,
              ),
            ),
          ),
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/homescreen.jpeg'),
                      fit: BoxFit.cover)),
            ),
            // Container(
            //   color: Colors.black.withOpacity(0.4), // Adjust opacity as needed
            // ),
            Container(
              //color: Colors.black.withOpacity(0.4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                theme.colorScheme.onPrimary.withOpacity(0.8),
                const Color.fromARGB(91, 0, 150, 135)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _sensorData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SpinKitFadingCircle(
                              color: Colors.teal,
                              size: 50.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No data available'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final sensor = snapshot.data?[index];
                              final sensorValues = sensor['value'];
                              print(sensor['value']);
                              return Card(
                                color: Colors.white.withOpacity(0.8),
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                child: ListTile(
                                  title: Text(
                                    sensor['id'] ?? 'unknown Sensor',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Value : ${sensorValues['value']}',
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    height: 200,
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },

                      initialCameraPosition: _kGooglePlex,
                      // markers:
                      //   Marker(
                      //     markerId: MarkerId('animal_marker'),
                      //     position: _center,
                      //     icon: animalIcon ?? BitmapDescriptor.defaultMarker,
                      //   ),
                      // },
                    ),
                  )
                ],
              ),
            ),
          ])
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     Image.asset('assets/images/homescreen.jpeg'),
          //     SizedBox(
          //       height: 100,
          //     ),

          //     Text(
          //       "Sensor Data",
          //       style: GoogleFonts.roboto(
          //           textStyle: const TextStyle(
          //               color: Colors.black,
          //               decoration: TextDecoration.underline),
          //           fontSize: 30,
          //           fontWeight: FontWeight.bold),
          //       textAlign: TextAlign.center,
          //     ),
          //     SizedBox(
          //       height: 20,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 50),
          //       child: Row(
          //         children: [
          //           Container(
          //             width: 30,
          //             height: 30,
          //             decoration: const BoxDecoration(
          //               //border: Border.all(width: 0),
          //               shape: BoxShape.circle,
          //               //borderRadius: BorderRadius.all(Radius.circular(1)),
          //               color: Color.fromARGB(159, 255, 214, 64),
          //             ),
          //             child: Center(
          //               child: Text("1"),
          //             ),
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "Temperature :",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "23",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          //     ),
          //     SizedBox(
          //       height: 20,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 50),
          //       child: Row(
          //         children: [
          //           Container(
          //             width: 30,
          //             height: 30,
          //             decoration: const BoxDecoration(
          //               //border: Border.all(width: 0),
          //               shape: BoxShape.circle,
          //               //borderRadius: BorderRadius.all(Radius.circular(1)),
          //               color: Color.fromARGB(159, 255, 214, 64),
          //             ),
          //             child: Center(
          //               child: Text("2"),
          //             ),
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "Accelerometer :",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "23",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          //     ),
          //     SizedBox(
          //       height: 20,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 50),
          //       child: Row(
          //         children: [
          //           Container(
          //             width: 30,
          //             height: 30,
          //             decoration: const BoxDecoration(
          //               //border: Border.all(width: 0),
          //               shape: BoxShape.circle,
          //               //borderRadius: BorderRadius.all(Radius.circular(1)),
          //               color: Color.fromARGB(159, 255, 214, 64),
          //             ),
          //             child: Center(
          //               child: Text("3"),
          //             ),
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "Gas Sensor :",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "23",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          //     ),
          //     SizedBox(
          //       height: 20,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 50),
          //       child: Row(
          //         children: [
          //           Container(
          //             width: 30,
          //             height: 30,
          //             decoration: const BoxDecoration(
          //               //border: Border.all(width: 0),
          //               shape: BoxShape.circle,
          //               //borderRadius: BorderRadius.all(Radius.circular(1)),
          //               color: Color.fromARGB(159, 255, 214, 64),
          //             ),
          //             child: Center(
          //               child: Text("1"),
          //             ),
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "Temperature",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Text(
          //             "23",
          //             style: GoogleFonts.roboto(
          //                 textStyle: const TextStyle(
          //                   color: Color.fromARGB(221, 0, 0, 0),
          //                   //decoration: TextDecoration.underline
          //                 ),
          //                 fontSize: 25,
          //                 fontWeight: FontWeight.normal),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          //     )

          //     // isLoading
          //     //     ? CircularProgressIndicator()
          //     //     : ListView.builder(
          //     //         padding: const EdgeInsets.all(8),
          //     //         itemCount: list.length,
          //     //         itemBuilder: (BuildContext context, int index) {
          //     //           return Container(
          //     //             child: Center(
          //     //               child: Text(
          //     //                 list[index],
          //     //                 style: TextStyle(fontSize: 24),
          //     //               ),
          //     //               //
          //     //             ),
          //     //           );
          //     //         },
          //     //       ),

          //     //   SizedBox(
          //     //     //width: double.maxFinite,
          //     //     child: SingleChildScrollView(
          //     //       child: Padding(
          //     //         padding: EdgeInsets.only(bottom: 0.v),
          //     //         child: Column(
          //     //           crossAxisAlignment: CrossAxisAlignment.start,
          //     //           children: [
          //     //             CustomImageView(
          //     //               imagePath: ImageConstant.imgShape,
          //     //               height: 157.v,
          //     //               width: 199.h,
          //     //             ),
          //     //             //SizedBox(height: 10.v),
          //     //             CustomImageView(
          //     //               imagePath: ImageConstant.imgClipPathGroup,
          //     //               height: 108.v,
          //     //               width: 250.h,
          //     //               alignment: Alignment.center,
          //     //             )
          //     //           ],
          //     //         ),
          //     //       ),
          //     //     ),
          //     //   ),
          //   ],
          // ),
          ),
    );
  }

  Set<Marker> _buildMarkers() {
    return <Marker>[
      Marker(
        markerId: MarkerId('example_marker'),
        position: _center,
        icon: animalIcon,
        infoWindow: InfoWindow(
          title: 'Tracked Animal',
          snippet: 'Location',
        ),
      ),
    ].toSet();
  }
}
