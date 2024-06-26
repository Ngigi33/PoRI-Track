import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import 'package:mushroom_monitoring/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

// void readData() {
//   final database = FirebaseDatabase.instance.ref().child("");

//   database.onValue.listen((event) {
//     DataSnapshot dataSnapshot = event.snapshot;
//     Map<dynamic, dynamic> values = dataSnapshot.value;

//   });
// }

class SlashScreen extends StatelessWidget {
  const SlashScreen({Key? key})
      : super(
          key: key,
        );

  // void readData() {
  //   DatabaseReference databaseReference =
  //       FirebaseDatabase.instance.ref().child('UsersData');

  //   databaseReference.onValue.listen((event) {
  //     DataSnapshot dataSnapshot = event.snapshot;
  //     Map<dynamic, dynamic> values = dataSnapshot.value as Map;
  //     values.forEach((key, value) {
  //       print('Key: $key');
  //       print('humidity:${values['humidty']}');
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
// Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/data.jpeg'), // Replace with your actual image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Container(
          //   color: Colors.black.withOpacity(0.4), // Adjust opacity as needed
          // ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                appTheme.blue100.withOpacity(0.8),
                Color.fromARGB(72, 71, 223, 147)
              ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            ),
            width: double.maxFinite,
            child: Column(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgShape,
                  height: 157.v,
                  width: 199.h,
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(
                  height: 120,
                ),
                Spacer(),
                CustomImageView(
                  imagePath: ImageConstant.imgUndrawSurveillanceRe8tkl,
                  height: 120.v,
                  width: 167.h,
                ),
                SizedBox(height: 52.v),
                Text(
                  "Iot Wildlife Tracking System",
                  style: theme.textTheme.titleSmall,
                ),
                SizedBox(height: 5.v),
                SizedBox(
                  height: 100.v,
                  width: 250.h,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // CustomImageView(
                      //   imagePath: ImageConstant.imgClipPathGroup,
                      //   height: 148.v,
                      //   width: 250.h,
                      //   alignment: Alignment.center,
                      // ),
                      CustomElevatedButton(
                        width: 207.h,
                        text: "CONNECT",
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.homeScreen);
                        },
                        margin: EdgeInsets.only(left: 15.h),
                        buttonTextStyle: theme.textTheme.titleMedium!,
                        alignment: Alignment.bottomLeft,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 57.v)
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
