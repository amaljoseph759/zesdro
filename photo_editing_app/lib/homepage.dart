import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageData;

  Future<void> getImage() async {
    final ImagePicker pickerInstance = ImagePicker();

    try {
      final pickedImage =
          await pickerInstance.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        imageData = await pickedImage.readAsBytes();

        setState(() {});
      }
    } catch (e) {
      (e);
    }
  }

  void _sendToWhatsApp() {
    if (imageData == null) return;

    const link = WhatsAppUnilink(
      phoneNumber: '+1234567890',
      text: 'Check out this image!',
    );

    launch(link.toString());
  }

  Future<void> launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> editImage() async {
    var editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
            appBar: Colors.grey,
            allowMultiple: true,
            features: const ImageEditorFeatures(
              pickFromGallery: true,
              captureFromCamera: false,
              crop: true,
              blur: true,
              brush: true,
              emoji: true,
              filters: true,
              flip: true,
              rotate: true,
              text: true,
            ),
            image: imageData),
      ),
    );
    if (editedImage != null) {
      setState(() {
        imageData = editedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        centerTitle: true,
        backgroundColor: Colors.amber[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await getImage();
                editImage();
              },
              child: imageData != null
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      height: MediaQuery.of(context).size.height / 2,
                      child: Image.memory(
                        imageData!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : CircleAvatar(
                      radius: 66,
                      backgroundColor: Colors.amber[100],
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(65),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(height: 10),
                              Text(
                                'Choose Image',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              )
                            ],
                          )),
                    ),
            ),
            const SizedBox(height: 30),
            Visibility(
              visible: imageData != null ? true : false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await getImage();
                          editImage();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[100],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.fromLTRB(18, 15, 20, 15)),
                        child: const Text('Choose another image'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          editImage();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[100],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.fromLTRB(18, 15, 20, 15)),
                        child: const Text('Edit Image'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      saveToGallery(context, imageData!);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[100],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 15, 20, 15)),
                    child: const Text('Save Image'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _sendToWhatsApp();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[100],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 15, 20, 15)),
                    child: const Text('share'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Future<void> saveToGallery(context, Uint8List uint8List) async {
  final result = await ImageGallerySaver.saveImage(uint8List);

  if (result['isSuccess']) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.symmetric(vertical: 15),
      content: Text('Success',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 3),
    ));
  } else {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.symmetric(vertical: 15),
      content: Text('Failure',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 3),
    ));
  }
}
