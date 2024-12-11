import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

Future<void> requestPermissions() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    // Permission granted
  } else {
    // Permission not granted
    print("Permission not granted");
  }
}

class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  @override
  void initState() {
    super.initState();
    requestPermissions();  // Request permissions on app start
  }

  XFile? myPhoto;
  String? qrData;

  // Method to pick image from the camera
  Future<XFile?> pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    return image;
  }

  choosephoto() {
    pickImage().then((value) {
      setState(() {
        myPhoto = value;
        if (myPhoto != null) {
          compressImage();  // Compress the image after selection
        }
      });
    });
  }

  // Method to compress image
  Future<void> compressImage() async {
    var result = await FlutterImageCompress.compressWithFile(
      myPhoto!.path,
      minWidth: 50,  // Compress image width
      minHeight: 50,  // Compress image height
      quality: 60,  // Compress quality
    );

    if (result != null) {
      // Encode the compressed image to Base64 and assign it to qrData
      qrData = base64Encode(result);
      setState(() {});
    }
  }

  // Method to generate QR code from image URL
  Future<void> uploadImageAndGetUrl() async {
    String imageUrl = "https://your-server.com/path-to-image";  // Image URL
    qrData = imageUrl;  // Store URL in qrData
    setState(() {});
  }

  // Method to save the image to the gallery
  Future<void> downloadImage() async {
    if (myPhoto != null) {
      try {
        final bytes = await myPhoto!.readAsBytes(); // Read image as bytes
        final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving image to gallery')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate QR Code')),
      body: SingleChildScrollView(  // Allow scrolling of content
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,  // Use MainAxisSize.min for compact sizing
            children: [
              ElevatedButton(
                onPressed: choosephoto,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              myPhoto != null
                  ? Image.file(File(myPhoto!.path), height: 200)
                  : Text('No image selected'),
              SizedBox(height: 20),
              qrData != null
                  ? Flexible(
                fit: FlexFit.loose,  // Use Flexible with FlexFit.loose
                child: QrImageView(
                  data: qrData!,
                  size: 200.0,
                  version: QrVersions.auto,
                ),
              )
                  : Text('Generate QR Code after selecting an image'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: uploadImageAndGetUrl,
                child: Text('Generate QR from URL'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: downloadImage,
                child: Text('Download Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
