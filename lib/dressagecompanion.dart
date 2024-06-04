import "dart:core";
import "dart:ui" as ui;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "dart:async";
import "dart:typed_data";

import "constants.dart";
import "imagepainter.dart";
import "track_painter.dart";

class DressageCompanion extends StatelessWidget {

  const DressageCompanion({
    required this.showBanner,
    required this.title,
    Key? key,
  }) : super(key: key);
  final bool showBanner;
  final String title;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DressageCompanionPage(title: title, showBanner: showBanner),
    );
  }
}

class DressageCompanionPage extends StatefulWidget {
  const DressageCompanionPage(
      {Key? key, required this.title, required this.showBanner})
      : super(key: key);
  final String title;
  final bool showBanner;

  @override
  State<DressageCompanionPage> createState() => DressageCompanionState(title: title, showBanner: showBanner);
}

class DressageCompanionState extends State<DressageCompanionPage>
{
  Text appTitle             = const Text("");
  String title              = "";
  bool showBanner           = false;
  bool isImageLoaded        = false;
  bool showImage            = true;
  String landscapeImageFile = "assets/images/CrossCountryLandscape.png";
  String portraitImageFile  = "assets/images/CrossCountryPortrait.png";
  // String landscapeImageFile = "packages/dressagecompanionpackage/assets/images/CrossCountryLandscape.png";
  // String portraitImageFile  = "packages/dressagecompanionpackage/assets/images/CrossCountryPortrait.png";
  // String imageFile2         = "packages/dressagecompanionpackage/assets/images/z900.png";
  // String imageFile3         = "packages/dressagecompanionpackage/assets/images/SaturnV.jpeg";

  late GlobalKey mapKey;
  // late ui.Image landscapeImage;
  // late ui.Image portraitImage;
  // late ui.Image image2;
  // late ui.Image image3;
  late AssetImage img1;
  late AssetImage img2;
  late ui.Image landscapeImage;
  late ui.Image portraitImage;

  static final ChangeNotifier _repaint = ChangeNotifier();
  // static final TrackPainter   _painter = TrackPainter(repaint: _repaint);
  List<Widget?> buttons = [null, null, null];

  DressageCompanionState({required title, required showBanner}) {
    this.showBanner = showBanner;
    this.title      = title;
    appTitle        = Text(title);
  }

  @override
  void initState() {
    super.initState();
    buttons[0] = simpleButton(Constants.PROMPT_AWAIT_GPS, null);
    init();
  }

  Future <void> init() async {
    // img1 = AssetImage('assets/images/CrossCountryLandscape.png', package: 'dressagecompanionpackage');
    // img2 = AssetImage('assets/images/CrossCountryPortrait.png', package: 'dressagecompanionpackage');
    // landscapeImage = await loadImageFromAsset(img1);
    // portraitImage = await loadImageFromAsset(img2);
//    img1.loadImage();

    final ByteData dataH = await rootBundle.load(landscapeImageFile);
    landscapeImage = await loadImage(Uint8List.view(dataH.buffer));
    final ByteData dataV = await rootBundle.load(portraitImageFile);
    portraitImage = await loadImage(Uint8List.view(dataV.buffer));
    // final ByteData data2 = await rootBundle.load(imageFile2);
    // image2 = await loadImage(Uint8List.view(data2.buffer));
    // final ByteData data3 = await rootBundle.load(imageFile3);
    // image3 = await loadImage(Uint8List.view(data3.buffer));
    setState(() {
      isImageLoaded = true;
    });
  }

  // Future<ui.Image> loadImageFromAsset(AssetImage img) async {
  //   // final Completer<ui.Image> completer = Completer();
  //   // ui.decodeImageFromList(img, (ui.Image img) {
  //   //   return completer.complete(img);
  //   // });
  //   // return completer.future;
  //   final Completer<ui.Image> completer = img.loadImage() as Completer<ui.Image>;
  //   return completer.future;
  // }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget simpleButton(String prompt, void Function()? action) {
    return ElevatedButton(
      onPressed: action,
      child: Text(prompt),
    );
  }

  Widget buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
      },
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: "Menu Item 1",
          child: const Text("Select menu item 1"),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: "Menu Item 2",
          child: const Text("Select menu item 2"),
        ),
      ],
    );
  }

  Widget buildImage() {
    if (isImageLoaded) {
      return CustomPaint(
        foregroundPainter: ImagePainter(portraitImage: portraitImage, landscapeImage: landscapeImage),
        child: Container(

        ),
      );
    } else {
      return const Center(child: Text("loading"));
    }
  }

  Expanded drawImage() {
    return
      Expanded(
        child: Stack(
            children: <Widget>[
              buildImage(),
            ]
        ),
      )
    ;
  }

  // Expanded drawByLine() {
  //   mapKey = GlobalKey();
  //   return Expanded(
  //     child: GestureDetector(
  //       child: Stack(
  //           children: <Widget>[
  //             CustomPaint(
  //               key: mapKey,
  //               painter: _painter,
  //               child: const Center(),
  //             ),
  //           ]
  //       ),
  //     ),
  //   );
  // }

  Expanded mainDisplay() {
    return drawImage();
    // if (showImage)
    //   return drawImage();
    // return drawByLine();
  }

  Widget buildButtons() {
    final List<Widget> controls = [];
    for (final Widget? button in buttons) {
      if (button != null) {
        controls.add(
          Expanded(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.33,
              margin: const EdgeInsets.all(1.0),
              child: button,
            ),
          ),
        );
      } else {
        controls.add(
          Expanded(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.33,
            ),
          ),
        );
      }
    }
    return Row(children: controls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        title: appTitle,
        actions: [
          buildMenu(context),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(5.0),
                child: const Text("Distance :"),
              ),
            ],
          ),
          // mainDisplay(),
          Expanded(
            child: Stack(
                children: <Widget>[
                  CustomPaint(
                    foregroundPainter: ImagePainter(portraitImage: portraitImage, landscapeImage: landscapeImage),
                    child: Container(),
                  ),
                ],
            ),
          ),
          buildButtons(),
        ],
      ),
    );
  }

  Future<void> showMessage(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(Constants.PROMPT_OK),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }
}