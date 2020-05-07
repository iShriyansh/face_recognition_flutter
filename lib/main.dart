import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'face_painter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLutter Face Dector',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File pickedImage;
  var imageFile;

  List<Rect> rect =  new List<Rect>();
  bool isFaceDetected = false;

  void pickImage() async {
  var awaitImage  =  await ImagePicker.pickImage(source : ImageSource.gallery);
  imageFile = await awaitImage.readAsBytes();
  imageFile = await decodeImageFromList(imageFile);

  setState(() {
    pickedImage = awaitImage;
    imageFile = imageFile;
  });

  FirebaseVisionImage firebaseVisionImage = FirebaseVisionImage.fromFile(pickedImage);
  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();

  final List<Face> faces =  await faceDetector.processImage(firebaseVisionImage);
  if (rect.length > 0) {
    rect = new List<Rect>();
  }
  for (Face face in faces) {
    rect.add(face.boundingBox);
    final double rotY =
        face.headEulerAngleY; // Head is rotated to the right rotY degrees
    final double rotZ =
        face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
    print('the rotation y is ' + rotY.toStringAsFixed(2));
    print('the rotation z is '+ rotZ.toStringAsFixed(2));
    }
    setState(() {
    isFaceDetected = true;
    });



  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Recognition"),
        centerTitle: true,
      ),
     
      body: Column(
        children: <Widget>[

         Expanded(
           child: imageFile != null ? FittedBox(
              child: SizedBox(
                width: imageFile.width.toDouble(),
                height: imageFile.height.toDouble(),
                child: CustomPaint(
                  painter:
                  FacePainter(rect: rect, imageFile: imageFile),
                ),),):Container(),
         ),
          

      FlatButton(
        onPressed: (){
          pickImage();
        },
        color: Colors.red,
        child: Text("Pick Image"),
      )


        ],
      ),
  
  
    );
  }
}

