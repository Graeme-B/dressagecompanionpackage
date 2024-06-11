import "dart:convert";
import "dart:core";
import "dart:io";
import "dart:ui" as ui;
import "package:connectivity_plus/connectivity_plus.dart";
import "package:dressagecompanionpackage/state_event.dart";
import "package:dressagecompanionpackage/state_event_functions_interface.dart";
import "package:dressagecompanionpackage/upload_results.dart";
import "package:dressagecompanionpackage/utils.dart";
import "package:dressagecompanionpackage/walk_window.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";
import "dart:async";

import "package:gps_tracker/gps_tracker.dart";
import "package:gps_tracker_db/gps_tracker_db.dart";
import "package:intl/intl.dart";
import "package:latlong2/latlong.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uuid/uuid.dart";

import "ad_helper.dart";
import "constants.dart";
import "imagepainter.dart";
import "instance_vars.dart";
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

class DressageCompanionState
    extends State<DressageCompanionPage>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements StateEventFunctionInterface
{
  // Text appTitle             = const Text("");
  // String title              = "";
  // bool showBanner           = false;
  // bool isImageLoaded        = false;
  // bool showImage            = true;
  // String landscapeImageFile = "assets/images/CrossCountryLandscape.png";
  // String portraitImageFile  = "assets/images/CrossCountryPortrait.png";
  // String imageFile2         = "assets/images/z900.png";
  // String imageFile3         = "assets/images/SaturnV.jpeg";

  late GlobalKey mapKey;
  late ui.Image landscapeImage;
  late ui.Image portraitImage;
  late ui.Image image2;
  late ui.Image image3;

  static final ChangeNotifier _repaint = ChangeNotifier();
  static final TrackPainter   _painter = TrackPainter(repaint: _repaint);
  static final InstanceVars   _iv      = InstanceVars();
  late StateEvent     _stateEvent;

  DressageCompanionState({required title, required showBanner}) {
    _iv.showBanner = showBanner;
    _iv.title      = title;
    _iv.appTitle   = Text(title);
  }

  @override
  void initState() {
    super.initState();
    _iv.buttons[0] = simpleButton(Constants.PROMPT_AWAIT_GPS, null);

    _stateEvent = StateEvent(sef: this, iv: _iv);
    _stateEvent.setActions();

    init();
    // *** Google Ads ***
    if (_iv.showBanner) {
      _loadBannerAds();
    }

//    _stateEvent.addEventToQueue(Constants.EVENT_STARTUP, null);
  }

  Future <void> init() async {
    print("Init");
    final ByteData dataH = await rootBundle.load(_iv.landscapeImageFile);
    landscapeImage = await loadImage(Uint8List.view(dataH.buffer));
    final ByteData dataV = await rootBundle.load(_iv.portraitImageFile);
    portraitImage = await loadImage(Uint8List.view(dataV.buffer));
    final ByteData data2 = await rootBundle.load(_iv.imageFile2);
    image2 = await loadImage(Uint8List.view(data2.buffer));
    final ByteData data3 = await rootBundle.load(_iv.imageFile3);
    image3 = await loadImage(Uint8List.view(data3.buffer));
    setState(() {
      _iv.isImageLoaded = true;
    });
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void _loadBannerAds() {
    for (int i = 0; i < 2; i++) {
      _iv.bannerAds.add(
          BannerAd(
            adUnitId: bannerAdUnitId,
            request: const AdRequest(),
            size: AdSize.banner,
            listener: BannerAdListener(
              onAdLoaded: (_) {
                setState(() {
                  _iv.isBannerAdReady = true;
                });
              },
              onAdFailedToLoad: (Ad ad, LoadAdError err) {
                _iv.isBannerAdReady = false;
                ad.dispose();
              },
            ),
          )
      );
      _iv.bannerAds[i].load();
    }
  }

  void _listener(dynamic o) {
    final Map<dynamic,dynamic> map = o as Map;
    final reason = map["reason"];
    if (reason == "COORDINATE_UPDATE") {
      _stateEvent.addEventToQueue(Constants.EVENT_GPS_COORDS, map);
    } else {
      final bool fixValid = map["fix_valid"] as bool;
      if (fixValid)
      {
        _stateEvent.addEventToQueue(Constants.EVENT_GPS_FIX, map);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // *** Google Ads ***
    if (_iv.showBanner) {
      for (final BannerAd ad in _iv.bannerAds) {
        ad.dispose();
      }
    }

    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     GpsTracker.checkForLocationPermissionChanges();
  //     _stateEvent.addEventToQueue(Constants.EVENT_SWITCH_TO_FOREGROUND, null);
  //   } else if(state == AppLifecycleState.paused) {
  //     _stateEvent.addEventToQueue(Constants.EVENT_SWITCH_TO_BACKGROUND, null);
  //     // } else if(lifecycleState == AppLifecycleState.inactive) {
  //     //   print("didChangeAppLifecycleState Inactive");
  //     // } else if(lifecycleState == AppLifecycleState.detached) {
  //     //   print("didChangeAppLifecycleState Detached");
  //   }
  // }

  @override
  void actOnPermissions(var permission) {
    String event = "";
    switch (permission) {
      case GpsTracker.GRANTED:
        event = Constants.EVENT_LOCATION_GRANTED;
        break;
      case GpsTracker.DENIED:
        event = Constants.EVENT_LOCATION_NOT_YET_GRANTED;
        break;
      case GpsTracker.LOCATION_OFF:
      case GpsTracker.INACCURATE_LOCATION:
      case GpsTracker.PARTLY_DENIED:
      case GpsTracker.PERMANENTLY_DENIED:
        event = Constants.EVENT_LOCATION_DENIED;
        break;
    }
    _stateEvent.addEventToQueue(event, permission);
  }

  @override
  Future<void> checkLocationPermissions(var param) async {
    int permission = await GpsTracker.getCurrentLocationPermissions();
    actOnPermissions(permission);
  }

  @override
  Future<void> requestLocationPermissions(var param) async {
    int permission = await GpsTracker.requestLocationPermissions();
    actOnPermissions(permission);
  }

  @override
  Future<void> showLocationSettingsBeforeGranted(var param) async {
    await showLocationSettings(Constants.REQUEST_LOCATION_PERMISSIONS_BEFORE_GRANTED_TITLE);
  }

  @override
  Future<void> showLocationSettingsWhenTracking(var param) async {
    await showLocationSettings(Constants.REQUEST_LOCATION_PERMISSIONS_WHEN_TRACKING_TITLE);
  }

  @override
  Future<void> showLocationSettingsAfterGranted(var param) async {
    await showLocationSettings(Constants.REQUEST_LOCATION_PERMISSIONS_AFTER_GRANTED_TITLE);
  }

  Widget simpleButton(String prompt, void Function()? action) {
    return ElevatedButton(
      onPressed: action,
      child: Text(prompt),
    );
  }

  Widget listenerButton(String prompt, var startAction, var stopAction) {
    return Listener(
      // onPointerDown: (event) => stopTrackingPressed(event),
      // onPointerUp: (event) => stopTrackingReleased(event),
      onPointerDown: (PointerDownEvent event) => startAction(event),
      onPointerUp: (PointerUpEvent event) => stopAction(event),
      // onPointerCancel: (event) => print('Cancel'),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(prompt),
      ),
    );
  }

  Widget buildButtons() {
    final List<Widget> controls = [];
    for (final Widget? button in _iv.buttons) {
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
    if (_iv.isImageLoaded) {
      return CustomPaint(
        foregroundPainter: ImagePainter(portraitImage: portraitImage, landscapeImage: landscapeImage),
        child: Container(),
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

  Expanded drawByLine() {
    mapKey = GlobalKey();
    return Expanded(
      child: GestureDetector(
        child: Stack(
            children: <Widget>[
              CustomPaint(
                key: mapKey,
                painter: _painter,
                child: const Center(),
              ),
            ]
        ),
      ),
    );
  }

  Expanded mainDisplay() {
    return drawImage();
    // if (showImage)
    //   return drawImage();
    // return drawByLine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        title: _iv.appTitle,
        actions: [
          buildMenu(context),
        ],
      ),
      body: Column(
        children: <Widget>[
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

  // ------------------------ Dialog functions ---------------------------

  @override
  Future<void> showLocationSettings(var title) async {
    showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text(Constants.REQUEST_LOCATION_PERMISSIONS_TEXT),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Settings'),
                onPressed: () {
                  _dismissDialog();
                  openAppSettings();
                },
              ),
            ],
          );
        });
  }

  @override
  void gpsStatusDialog(var param) {
    showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(Constants.GPS_STATUS_DIALOG_TITLE),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget> [
                    const SizedBox(
                      height: 45,
                      width:  90,
                      child: Text("Latitude"),
                    ),
                    SizedBox(
                      height: 45,
                      width:  100,
//                      child: Text("${_iv.currentPosition.latitude.toStringAsFixed(5)}"),
                      child: Text(_iv.currentPosition.latitude.toStringAsFixed(5)),
                    ),
                  ],
                ),
                Row(
                  children: <Widget> [
                    const SizedBox(
                      height: 45,
                      width:  90,
                      child: Text("Longitude"),
                    ),
                    SizedBox(
                      height: 45,
                      width:  100,
                      child: Text(_iv.currentPosition.longitude.toStringAsFixed(5)),
                    ),
                  ],
                ),
                Row(
                  children: <Widget> [
                    const SizedBox(
                      height: 45,
                      width:  90,
                      child: Text("State"),
                    ),
                    SizedBox(
                      height: 45,
                      width:  100,
                      child: Text(_stateEvent.state),
                    ),
                  ],
                ),
                Row(
                  children: <Widget> [
                    const SizedBox(
                      height: 45,
                      width:  90,
                      child: Text("Walk"),
                    ),
                    SizedBox(
                      height: 45,
                      width:  100,
                      child: Text(Constants.WALK_UPLOAD_URL),
                    ),
                  ],
                ),
                Row(
                  children: <Widget> [
                    const SizedBox(
                      height: 45,
                      width:  90,
                      child: Text("Image"),
                    ),
                    SizedBox(
                      height: 45,
                      width:  100,
                      child: Text(Constants.IMAGE_UPLOAD_URL),
                    ),
                  ],
                ),
              ],
            ),

            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _dismissDialog();
                },
                child: const Text(Constants.PROMPT_CANCEL),
              )
            ],
          );
        });
  }

  @override
  Future<void> uploadWalkDialog(var param) async {
    _iv.uploadWalkName  = "";
    _iv.uploadWalkClass = "";
    _iv.uploadWalkNotes = "";

    final TextEditingController walkCountryController = TextEditingController(text: _iv.uploadWalkCountry);
    final TextEditingController walkNameController    = TextEditingController(text: _iv.uploadWalkName);
    final TextEditingController walkUserController    = TextEditingController(text: _iv.uploadWalkUser);
    final TextEditingController walkEmailController   = TextEditingController(text: _iv.uploadWalkEmail);
    final TextEditingController walkClassController   = TextEditingController(text: _iv.uploadWalkClass);
    final TextEditingController walkNotesController   = TextEditingController(text: _iv.uploadWalkNotes);

    // if (await ConnectivityUtils.hasConnection()) {
    if (await hasConnection()) {
      showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(Constants.UPLOAD_WALK_DIALOG_TITLE),
              scrollable: true,
              content: Container(
                constraints: const BoxConstraints(
                    maxWidth: 300, maxHeight: 390),
                // padding: const EdgeInsets.all(0),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextFormField(
                            controller: walkUserController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 4.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_USER,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextFormField(
                            controller: walkEmailController,
                            textAlignVertical: TextAlignVertical.center,
                            // validator: (val) => val!.isEmpty ? Constants.PROMPT_UPLOAD_WALK_EMAIL : null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 4.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_EMAIL,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextFormField(
                            controller: walkCountryController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 4.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_COUNTRY,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextFormField(
                            controller: walkNameController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 4.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_NAME,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextField(
                            controller: walkClassController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 4.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_CLASS,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 135,
                          width: 200,
                          child: TextField(
                            controller: walkNotesController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 4.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_NOTES,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      try {
                        if (walkNameController.text.isEmpty ||
                            walkUserController.text.isEmpty) {
                          throw Exception(Constants.ERR_WALK_NAME_AND_USER_MUST_BE_SET);
                        }
                        _iv.uploadWalkUser    = walkUserController.text;
                        _iv.uploadWalkEmail   = walkEmailController.text;
                        _iv.uploadWalkCountry = walkCountryController.text;
                        _iv.uploadWalkName    = walkNameController.text;
                        _iv.uploadWalkClass   = walkClassController.text;
                        _iv.uploadWalkNotes   = walkNotesController.text;
                        _dismissDialog();
                        _stateEvent.addEventToQueue(Constants.EVENT_UPLOAD_WALK, "");
                      } catch (err) {
                        showMessage(
                            Constants.ERROR_DIALOG_TITLE, err.toString());
                      }
                    },
                    child: const Text(Constants.PROMPT_SET)),
                TextButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  child: const Text(Constants.PROMPT_CANCEL),
                )
              ],
            );
          });
    } else {
      showMessage(Constants.ERROR_DIALOG_TITLE, Constants.ERR_NO_CONNECTIVITY);
    }
  }

  @override
  Future<void> loginDialog() async {
    final String password = "";
    final TextEditingController usernameController = TextEditingController(text: _iv.uploadWalkUser);
    final TextEditingController passwordController = TextEditingController(text: password);

    // if (await ConnectivityUtils.hasConnection()) {
    if (await hasConnection()) {
      showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(Constants.UPLOAD_WALK_DIALOG_TITLE),
              scrollable: true,
              content: Container(
                constraints: const BoxConstraints(
                    maxWidth: 300, maxHeight: 300),
                // padding: const EdgeInsets.all(0),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextFormField(
                            controller: usernameController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 8.0, 12.0, 8.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_USER,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: TextFormField(
                            controller: passwordController,
                            textAlignVertical: TextAlignVertical.center,
                            // validator: (val) => val!.isEmpty ? Constants.PROMPT_UPLOAD_WALK_EMAIL : null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                  12.0, 8.0, 12.0, 8.0),
                              labelText: Constants.PROMPT_UPLOAD_WALK_EMAIL,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      try {
                        if (usernameController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          throw Exception(Constants.ERR_USERNAME_AND_PASSWORD_MUST_BE_SPECIFIED);
                        }
                        //   _iv.uploadWalkUser    = walkUserController.text;
                        //   _iv.uploadWalkEmail   = walkEmailController.text;
                        //   _iv.uploadWalkCountry = walkCountryController.text;
                        //   _iv.uploadWalkName    = walkNameController.text;
                        //   _iv.uploadWalkClass   = walkClassController.text;
                        //   _dismissDialog();
                        //   _stateEvent.addEventToQueue(Constants.EVENT_UPLOAD_WALK, "");
                      } catch (err) {
                        showMessage(
                            Constants.ERROR_DIALOG_TITLE, err.toString());
                      }
                    },
                    child: const Text(Constants.PROMPT_SET)),
                TextButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  child: const Text(Constants.PROMPT_CANCEL),
                )
              ],
            );
          });
    } else {
      showMessage(Constants.ERROR_DIALOG_TITLE, Constants.ERR_NO_CONNECTIVITY);
    }
  }

  void stopTrackingPressed(var details) {
    _stateEvent.addEventToQueue(Constants.EVENT_STOP_TRACKING_PRESSED, null);
  }

  void stopTrackingReleased(var details) {
    _stateEvent.addEventToQueue(Constants.EVENT_STOP_TRACKING_RELEASED, null);
  }

  // ------------------------ State event functions ---------------------------
  @override
  Future<void> startService(var param) async
  {
    try {
      GpsTracker.addGpsListener(_listener);
      await GpsTracker.start(
        title: _iv.title,
        text: "Text",
        subText: "Subtext",
        ticker: "Ticker",
      );
    } catch (err) {
      showMessage(Constants.ERROR_DIALOG_TITLE, err.toString());
    }
  }

  @override
  Future<void> stopService(var param) async
  {
    GpsTracker.removeGpsListener(_listener);
    GpsTracker.stop();
  }

  @override
  void displayWalksWindow(var param) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => WalkWindow(currentWalkName: _iv.walkName)),
    ).then((result) {
      if ((result as String).isNotEmpty) {
        _stateEvent.addEventToQueue(Constants.EVENT_LOAD_WALK, result);
      }
    });
  }

  @override
  Future<void> uploadWalk(var param) async {
    late BuildContext dialogContext; // <<----
    showDialog(
      context: context, // <<----
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              Text("Loading"),
            ],
          ),
        );
      },
    );
    final UploadResults results = await doWalkUpload(param);
    // Navigator.of(dialogContext, rootNavigator: true).pop();
    Navigator.pop(dialogContext);

    if (results.status == 200) {
      showMessage(Constants.INFORMATION_DIALOG_TITLE, Constants.INFO_WALK_UPLOADED_OK);
    } else {
      if (results.message == null || results.message!.isEmpty) {
        showMessage(Constants.ERROR_DIALOG_TITLE, Constants.ERR_CANT_UPLOAD_WALK);
      } else {
        String errm = "${results.message!} - status ${results.status}";
        showMessage(Constants.ERROR_DIALOG_TITLE, errm);
      }
    }
  }

  // For HTTPS:
  // https://mtabishk999.medium.com/tls-ssl-connection-using-self-signed-certificates-with-dart-and-flutter-6e7c46ea1a36
  @override
  Future<UploadResults> doWalkUpload(var param) async {

    late UploadResults results;

    // Get the current walk
    final Walk walk  = await _iv.db.getWalk(_iv.walkName);
    const Uuid uuid  = Uuid();
    final String uid = uuid.v1(); // Generate a v1 (time-based) id

    final String json = '{"device_uuid": "${_iv.deviceUuid}",' +
        '"name": "${Uri.encodeComponent(_iv.uploadWalkName)}",'       +
        '"year": ${DateFormat("yyyy").format(DateTime.now())},'       +
        '"country": "${Uri.encodeComponent(_iv.uploadWalkCountry)}",' +
        '"user": "${Uri.encodeComponent(_iv.uploadWalkUser)}",'       +
        '"email": "${Uri.encodeComponent(_iv.uploadWalkEmail)}",'     +
        '"class": "${Uri.encodeComponent(_iv.uploadWalkClass)}",'     +
        '"notes":"${Uri.encodeComponent(_iv.uploadWalkNotes)}",'      +
        '"uuid": "$uid",'                                             +
        '"walk":${walk.toJson()}}';

    const String url                = Constants.WALK_UPLOAD_URL;
    final HttpClient httpClient     = HttpClient();
    final HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    // request.headers.set('content-type', 'application/json; charset="UTF-8"');
    request.headers.set("content-type", 'text/html; charset="UTF-8"');
    // request.add(utf8.encode(json));
    request.write(utf8.encode(json));
    // request.write(json);
    final HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    int status = response.statusCode;
    final String reply = await response.transform(utf8.decoder).join();
    results = UploadResults(status,reply);
    httpClient.close();

    results.status = status;

    // Write the uploaded walk name and user to the preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.UPLOAD_WALK_COUNTRY_KEY,_iv.uploadWalkCountry);
    await prefs.setString(Constants.UPLOAD_WALK_USER_KEY,_iv.uploadWalkUser);
    await prefs.setString(Constants.UPLOAD_WALK_EMAIL_KEY,_iv.uploadWalkEmail);
    return results;
  }

  @override
  void clearWalkPoints(var param) {
    _iv.wayPoints.clear();
    _painter.clearWalkTrack();
    _repaint.notifyListeners();
    _iv.distanceNotifier.value = 0;
  }

  @override
  void clearDisplay(var param) {
    _iv.clearDisplayEnabled = false;
    setState(() {
      _iv.walkName               = "";
      _iv.distanceNotifier.value = 0;
      _iv.showImage              = true;
      _iv.appTitle               = Text(_iv.title);
    });
  }

  @override
  void addCoordsToMap(Map<Object?,Object?> map) {

    try {
      // var fix_valid = map["fix_valid"] as bool;
      // var walkName  = map["walk_name"];
      final latitude = map["latitude"]! as double;
      final longitude = map["longitude"]! as double;
      // var accuracy  = map["accuracy"] as double;
      // var speed     = map["speed"] as double;
      final distance = map["distance"]! as double;
      final LatLng point = LatLng(latitude, longitude);
      // ------------------ Here I am ------------------
      _iv.wayPoints.add(point);
      // ------------------ Here I am ------------------
      _iv.distanceNotifier.value = distance.toInt();

      _painter.addWalkTrackPoint(
          WalkTrackPoint(
              create_date: DateFormat("dd-MM-yyyyTHH:mm:ss").format(
                  DateTime.now()),
              latitude: map["latitude"]! as double,
              longitude: map["longitude"]! as double,
              distance: map["distance"]! as double,
              provider: "gps",
              accuracy: map["accuracy"]! as double,
              elapsed_time: 0)
      );
      _repaint.notifyListeners();
    } catch (e) {
      writeFile("log.txt","Exception $e");
    }
  }

  @override
  void  centreDisplay(var param) {
    _repaint.notifyListeners();
  }

  @override
  void initialFixReceived(var param) {
    Timer(
      const Duration(seconds: Constants.FIX_SETTLE_TIMEOUT_SECONDS),
          () {_stateEvent.addEventToQueue(Constants.EVENT_FIX_SETTLE_TIMEOUT, null);},
    );
  }

  @override
  Future<void> loadWalk(var param) async {

    final Walk walk = await _iv.db.getWalk(param);
    for (final WalkTrackPoint wtp in walk.track) {
      _iv.wayPoints.add(LatLng(wtp.latitude, wtp.longitude));
    }
    _painter.addWalkTrackPoints(walk.track);
    _painter.addWalkImages(walk.images);
    _painter.addWalkMinuteMarkers(walk.waypoints);

    String localPath = "";
    if (Platform.isAndroid) {
      final Directory? a = await getExternalStorageDirectory();  // OR return "/storage/emulated/0/Download";
      localPath = a!.path  + Platform.pathSeparator;
    } else if (Platform.isIOS) {
      final Directory d = await getApplicationDocumentsDirectory();
      localPath = d.path;
    }

    setState(() {
      _iv.walkName       = param;
      _iv.showImage      = false;
      _iv.appTitle       = Text("${_iv.title} - $param");
      if (walk.track.isNotEmpty) {
        _iv.distanceNotifier.value = walk.track[walk.track.length - 1].distance.toInt();
      } else {
        _iv.distanceNotifier.value = 0;
      }
      _iv.clearDisplayEnabled = true;
    });
    _stateEvent.addEventToQueue(Constants.EVENT_WALK_LOADED, null);
  }

  @override
  void storePosition(Map<Object?, Object?> map) {
    final double latitude  = map["latitude"]! as double;
    final double longitude = map["longitude"]! as double;
    _iv.currentPosition = LatLng(latitude,longitude);
  }

  void clearButtons() {
    for (int i = 0; i < _iv.buttons.length; i++) {
      _iv.buttons[i] = null;
    }
  }

  void _dismissDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void setReadyToTrack(var param) {
    setState(() {
      clearButtons();
      _iv.buttons[0] = simpleButton(Constants.PROMPT_START_TRACKING, () {
        _stateEvent.addEventToQueue(Constants.EVENT_START_TRACKING, null);
      });
    });
  }

  @override
  Future<void> startTracking(var param) async {
    final DateTime now = DateTime.now();
    final String walkName = "Walk on ${DateFormat("yyyy-MM-dd HH:mm:ss").format(now)}";
    try {
      await _iv.db.addWalk(walkName);

      GpsTracker.startTracking(walkName);

      setState(() {
        _iv.appTitle  = Text(walkName);
        _iv.walkName  = walkName;
        _iv.showImage = false;
        clearButtons();
        _iv.buttons[0] = simpleButton(Constants.PROMPT_PAUSE, () {
          _stateEvent.addEventToQueue(Constants.EVENT_PAUSE_TRACKING, null);
        });
      });
      _stateEvent.addEventToQueue(Constants.EVENT_WALK_LOADED, null);
    } catch (err) {
      //   print("Error $err adding walk '$walkName'");
    }
  }

  @override
  void pauseTracking(var param)
  {
    GpsTracker.pauseTracking();
    setState(() {
      clearButtons();
      _iv.buttons[0] = simpleButton(Constants.PROMPT_RESUME, () {
        _stateEvent.addEventToQueue(Constants.EVENT_RESUME_TRACKING,null);
      });
      _iv.buttons[1] = listenerButton(Constants.PROMPT_STOP_TRACKING, stopTrackingPressed, stopTrackingReleased);
    });
  }

  @override
  void resumeTracking(var param)
  {
    GpsTracker.resumeTracking();
    setState(() {
      clearButtons();
      _iv.buttons[0] = simpleButton(Constants.PROMPT_PAUSE, () {
        _stateEvent.addEventToQueue(Constants.EVENT_PAUSE_TRACKING,null);
      });
    });
  }

  @override
  void stopTrackingPressedAction(var param) {
    const double delay = 3000.0;
    const int    tick  = 10;
    _iv.progressNotifier.value = 0.0;
    _iv.timer = Timer.periodic(
        const Duration(milliseconds: tick), (Timer timer) {
      if (_iv.progressNotifier.value >= 1.0) {
        _stateEvent.addEventToQueue(Constants.EVENT_STOP_TRACKING_TIMEOUT, null);
      } else {
        _iv.progressNotifier.value += tick/delay;
      }
    });

    setState(() {
      _iv.showProgressBar = true;
    });
  }

  @override
  void trackingStillPaused(var param) {
    _iv.timer?.cancel();

    setState(() {
      clearButtons();
      _iv.buttons[0] = simpleButton(Constants.PROMPT_RESUME, () {
        _stateEvent.addEventToQueue(Constants.EVENT_RESUME_TRACKING,null);
      });
      _iv.buttons[1] = listenerButton(Constants.PROMPT_STOP_TRACKING, stopTrackingPressed, stopTrackingReleased);
      _iv.showProgressBar = false;
    });
  }

  @override
  void trackingStopped(var param) {
    setState(() {
      clearButtons();
      _iv.timer?.cancel();
      _iv.showProgressBar = false;
      _iv.buttons[0] = simpleButton(Constants.PROMPT_START_TRACKING, () {
        _stateEvent.addEventToQueue(Constants.EVENT_START_TRACKING,null);
      });
    });
    GpsTracker.stopTracking();
  }

  @override
  void trackingStoppedAsPermissionRevoked(var param) {
    setState(() {
      clearButtons();
      _iv.timer?.cancel();
      _iv.showProgressBar = false;
      _iv.buttons[0] = simpleButton(Constants.PROMPT_AWAIT_GPS, null);
    });
    GpsTracker.stopTracking();
  }

  @override
  void permissionRevoked(var param) {
    setState(() {
      clearButtons();
      _iv.buttons[0] = simpleButton(Constants.PROMPT_AWAIT_GPS, null);
    });
    GpsTracker.stopTracking();
  }

}

Future<bool> hasConnection() async {
  final ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
}
