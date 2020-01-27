import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intro_slider/intro_slider.dart';
import 'package:path/path.dart' as Path;
import 'package:async/async.dart';
import 'dart:io';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    initialRoute: '/',
  routes: {
    '/' : (context) => IntroScreen(),
    '/screen2': (context) => MyHomePage(),
  });
}
}


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}


class _IntroScreenState extends State<IntroScreen> {

List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Diagnosis",
        description: "Experience the diagonises done by the doctor!",
        pathImage: "assets/convo.jpg",
        backgroundColor: const Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "Upload prescription",
        description: "Whenever you are back home, upload the prescription!",
        pathImage: "assets/upload.png",
        backgroundColor: const Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: "Use later",
        description: "Now, no hassle of carrying records to every doctor, DocAid at your service",
        pathImage: "assets/pres.jpg",
        backgroundColor: const Color(0xff203152),
      ),
    );
  }

    void onDonePress() {
        Navigator.of(context).pushNamed(
      '/screen2'
    );
  }


  void onSkipPress() {
    Navigator.of(context).pushNamed(
      '/screen2'
    );
  }


  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body:IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
    ),);
    }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;



    upload(File imageFile) async {    
      // open a bytestream
      var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      // get file length
      var length = await imageFile.length();

      // string to uri
      var uri = Uri.parse("http://6bf7636e.ngrok.io/");

      // create multipart request
      var request = new http.MultipartRequest("POST", uri);

      var multipartFile = new http.MultipartFile('file', stream, length,
      // multipart that takes file
          filename: Path.basename(imageFile.path));

      // add file to multipart
      request.files.add(multipartFile);

      // send
      var response = await request.send();
      print(response.statusCode);

      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 640);
    // Dio dio = new Dio();
      
    // Map data = {
    //   'url': url,
    // };
    // //encode Map to JSON
    // var body = json.encode(data);

    // var response = await http.post(url1,
    //     headers: {"Content-Type": "application/json"}, body: body);
    // print("${response.statusCode}");
    // print("${response.body}");

    setState(() {
      _image = image;
      upload(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Prescription'),
      ),
      body: Center(
        child: _image == null ? Text('No image selected.') : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';
// import 'dart:convert';
// import 'package:http_parser/http_parser.dart';
// import 'package:toast/toast.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Image Upload Demo',
//         theme: ThemeData(primarySwatch: Colors.pink),
//         home: ImageInput());
//   }
// }

// class ImageInput extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _ImageInput();
//   }
// }

// class _ImageInput extends State<ImageInput> {
//   // To store the file provided by the image_picker
//   File _imageFile;

//   // To track the file uploading state
//   bool _isUploading = false;

//   String baseUrl = 'http://6f367e12.ngrok.io/';

//   void _getImage(BuildContext context, ImageSource source) async {
//     File image = await ImagePicker.pickImage(source: source);

//     setState(() {
//       _imageFile = image;
//     });

//     // Closes the bottom sheet
//     Navigator.pop(context);
//   }

//   Future<Map<String, dynamic>> _uploadImage(File image) async {
//     setState(() {
//       _isUploading = true;
//     });

//     // Find the mime type of the selected file by looking at the header bytes of the file
//     final mimeTypeData =
//         lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

//     // Intilize the multipart request
//     final imageUploadRequest =
//         http.MultipartRequest('POST', Uri.parse(baseUrl));

//     // Attach the file in the request
//     final file = await http.MultipartFile.fromPath('image', image.path,
//         contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

//     // Explicitly pass the extension of the image with request body
//     // Since image_picker has some bugs due which it mixes up
//     // image extension with file name like this filenamejpge
//     // Which creates some problem at the server side to manage
//     // or verify the file extension
//     imageUploadRequest.fields['ext'] = mimeTypeData[1];

//     imageUploadRequest.files.add(file);

//     try {
//       final streamedResponse = await imageUploadRequest.send();

//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode != 200) {
//         return null;
//       }

//       final Map<String, dynamic> responseData = json.decode(response.body);

//       _resetState();

//       return responseData;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   void _startUploading() async {
//     final Map<String, dynamic> response = await _uploadImage(_imageFile);
//     print(response);
//     // Check if any error occured
//     if (response == null || response.containsKey("error")) {
//       Toast.show("Image Upload Failed!!!", context,
//           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//     } else {
//       Toast.show("Image Uploaded Successfully!!!", context,
//           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//     }
//   }

//   void _resetState() {
//     setState(() {
//       _isUploading = false;
//       _imageFile = null;
//     });
//   }

//   void _openImagePickerModal(BuildContext context) {
//     final flatButtonColor = Theme.of(context).primaryColor;
//     print('Image Picker Modal Called');
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             height: 150.0,
//             padding: EdgeInsets.all(10.0),
//             child: Column(
//               children: <Widget>[
//                 Text(
//                   'Pick an image',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(
//                   height: 10.0,
//                 ),
//                 FlatButton(
//                   textColor: flatButtonColor,
//                   child: Text('Use Camera'),
//                   onPressed: () {
//                     _getImage(context, ImageSource.camera);
//                   },
//                 ),
//                 FlatButton(
//                   textColor: flatButtonColor,
//                   child: Text('Use Gallery'),
//                   onPressed: () {
//                     _getImage(context, ImageSource.gallery);
//                   },
//                 ),
//               ],
//             ),
//           );
//         });
//   }

//   Widget _buildUploadBtn() {
//     Widget btnWidget = Container();

//     if (_isUploading) {
//       // File is being uploaded then show a progress indicator
//       btnWidget = Container(
//           margin: EdgeInsets.only(top: 10.0),
//           child: CircularProgressIndicator());
//     } else if (!_isUploading && _imageFile != null) {
//       // If image is picked by the user then show a upload btn

//       btnWidget = Container(
//         margin: EdgeInsets.only(top: 10.0),
//         child: RaisedButton(
//           child: Text('Upload'),
//           onPressed: () {
//             _startUploading();
//           },
//           color: Colors.pinkAccent,
//           textColor: Colors.white,
//         ),
//       );
//     }

//     return btnWidget;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Upload Demo'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
//             child: OutlineButton(
//               onPressed: () => _openImagePickerModal(context),
//               borderSide:
//                   BorderSide(color: Theme.of(context).accentColor, width: 1.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Icon(Icons.camera_alt),
//                   SizedBox(
//                     width: 5.0,
//                   ),
//                   Text('Add Image'),
//                 ],
//               ),
//             ),
//           ),
//           _imageFile == null
//               ? Text('Please pick an image')
//               : Image.file(
//                   _imageFile,
//                   fit: BoxFit.cover,
//                   height: 300.0,
//                   alignment: Alignment.topCenter,
//                   width: MediaQuery.of(context).size.width,
//                 ),
//           _buildUploadBtn(),
//         ],
//       ),
//     );
//   }
// }