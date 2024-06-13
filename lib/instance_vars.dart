import "dart:async";
import "dart:core";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";
import "package:latlong2/latlong.dart";
import "package:gps_tracker_db/gps_tracker_db.dart";

import 'event.dart';

class InstanceVars {
  final eventQueueController   = StreamController<Event>();

  late DatabaseHelper db;
  late ui.Image landscapeImage;
  late ui.Image portraitImage;
  late ui.Image image2;
  late ui.Image image3;
  late AnimationController animator;
  List<Widget?> buttons = [null, null, null];
  Timer? timer;
  String uploadTestCountry = "";
  String uploadTestName    = "";
  String uploadTestUser    = "";
  String uploadTestEmail   = "";
  String uploadTestClass   = "";
  String uploadTestNotes   = "";
  String deviceUuid        = "";
  String packageName       = "";

  Text  appTitle  = const Text("");
  String title    = "";
  String testName = "";

  bool showImage           = true;
  bool displayTestsEnabled = true;
  bool clearDisplayEnabled = false;
  bool uploadTestEnabled   = false;
  bool showProgressBar     = false;

  bool isImageLoaded        = false;
  String landscapeImageFile = "assets/images/CrossCountryLandscape.png";
  String portraitImageFile  = "assets/images/CrossCountryPortrait.png";
  String imageFile2         = "assets/images/z900.png";
  String imageFile3         = "assets/images/SaturnV.jpeg";
  int loadedImage           = 1;

// double value              = 0.0;
  ValueNotifier<int>    distanceNotifier = ValueNotifier<int>(0);
  ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

  late GlobalKey mapKey;
  List<WalkTrackPoint> wayPoints = [];
  LatLng currentPosition         = LatLng(-1.0, -1.0);
  final double zoom              = 16;
  LatLng badminton               = LatLng(51.58002, -2.2989);

  int msecSinceReplayStart = 0;
  int firstWalkPoint       = -1;
  int lastWalkPoint        = -1;


// *** Google Ads ***
  final List<BannerAd> bannerAds = [];
  int bannerAdIndex    = 1;
  bool isBannerAdReady = false;
  bool showBanner      = false;

  InstanceVars() {
    DatabaseHelper.getDatabaseHelper().then((DatabaseHelper dbase) {
      db = dbase;
    });
  }
}