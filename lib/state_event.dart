// import 'package:intl/intl.dart';

import "dart:core";

import "constants.dart";
import "instance_vars.dart";
import "debug_walks.dart";
import "state_event_functions.dart";
import "event.dart";
import "state_event_functions_interface.dart";

// Need to alter the UI for when location disabled!
// ie switch button text, enable/disable menu items etc
// Might need a new function as cwc.trackingStopped might not be correct for this situation as it refreshes the UI
class StateEvent {
  String                      state  = Constants.STATE_STARTUP_AWAIT_PERMISSIONS;
  Map<String, dynamic>        actions = {};
  StateEventFunctionInterface sef;
  InstanceVars                iv;
  late DebugWalks             dw;
  late StateEventFunctions    f;

  StateEvent({required this.sef, required this.iv}) {
    dw = DebugWalks(iv: iv);
    f  = StateEventFunctions(iv: iv);

    final subscription = iv.eventQueueController.stream.listen((Event e) {
// Debug code to check how long it takes to go from "walk loading" to "walk loaded"
//       if (e.event != Constants.EVENT_GPS_COORDS) {
//         print("Time ${DateFormat("dd-MM-yyyy HH:mm:ss").format(
//             DateTime.now())} MS ${DateTime.now().millisecondsSinceEpoch} State $state event ${e.event}");
//       }
      print("State $state event $e.event");
      processEvents(state,e.event,e.parameter);
    });

  }

  void setActions() {
    actions[Constants.STATE_STARTUP_AWAIT_PERMISSIONS] = {
      Constants.EVENT_STARTUP:                  [sef.checkLocationPermissions],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService, (parms) {setState(Constants.STATE_STARTUP_AWAIT_VALID_FIX);}],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsBeforeGranted],
      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
    };

    actions[Constants.STATE_STARTUP_AWAIT_VALID_FIX] = {
      // Constants.EVENT_DEBUG:                    [validFixReceived],
      Constants.EVENT_GPS_FIX:                  [sef.initialFixReceived, (parms) {setState(Constants.STATE_STARTUP_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_GPS_COORDS:               [sef.initialFixReceived, sef.storePosition,(parms) {setState(Constants.STATE_STARTUP_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_SHOW_UPLOAD_TEST_DIALOG:  [sef.uploadWalkDialog],
      Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING_AWAIT_VALID_FIX);},],
      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService,],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions,(parms) {setState(Constants.STATE_STARTUP_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_STARTUP_AWAIT_PERMISSIONS);}],
    };

    actions[Constants.STATE_TEST_LOADING_AWAIT_VALID_FIX] = {
      Constants.EVENT_GPS_COORDS:  [sef.initialFixReceived, sef.storePosition, (parms) {setState(Constants.STATE_TEST_LOADING_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_TEST_LOADED: [sef.centreDisplay, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_VALID_FIX);},],
    };

    actions[Constants.STATE_TEST_LOADED_AWAIT_VALID_FIX] = {
      // Constants.EVENT_DEBUG:                    [validFixReceived],
      // Constants.EVENT_GPS_FIX:                  [validFixReceived],
      Constants.EVENT_GPS_FIX:                  [sef.initialFixReceived, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_GPS_COORDS:               [sef.initialFixReceived, sef.storePosition, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_SHOW_UPLOAD_TEST_DIALOG:  [sef.uploadWalkDialog],
      Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING_AWAIT_VALID_FIX);},],
      Constants.EVENT_CLEAR_DISPLAY:            [sef.clearWalkPoints,sef.clearDisplay,sef.centreDisplay,(parms) {setState(Constants.STATE_STARTUP_AWAIT_VALID_FIX);},],
      Constants.EVENT_UPLOAD_TEST:              [sef.uploadWalk],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService,],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);}],
    };

    actions[Constants.STATE_STARTUP_AWAIT_FIX_SETTLE] = {
      Constants.EVENT_FIX_SETTLE_TIMEOUT:       [sef.setReadyToTrack, (parms) {setState(Constants.STATE_IDLE);},],
      Constants.EVENT_GPS_COORDS:               [sef.storePosition,],
      Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING_AWAIT_FIX_SETTLE);},],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService,],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions,(parms) {setState(Constants.STATE_STARTUP_AWAIT_PERMISSIONS);}],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_STARTUP_AWAIT_PERMISSIONS);}],
      // Constants.EVENT_CLEAR_DISPLAY:        [cwc.disableOptimumTimeGalleryAndUploadMenu, cwc.clearWalkPoints, cwc.clearDisplay, cwc.centreDisplay, (parms) {setState(Constants.STATE_STARTUP_AWAIT_VALID_FIX);}, ],
    };

    actions[Constants.STATE_TEST_LOADING_AWAIT_FIX_SETTLE] = {
      Constants.EVENT_TEST_LOADED:        [sef.centreDisplay, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_FIX_SETTLE_TIMEOUT: [sef.setReadyToTrackOrReplay, (parms) {setState(Constants.STATE_TEST_LOADED);},],
      Constants.EVENT_GPS_COORDS:         [sef.storePosition,],
    };

    actions[Constants.STATE_TEST_LOADED_AWAIT_FIX_SETTLE] = {
      Constants.EVENT_FIX_SETTLE_TIMEOUT:       [sef.setReadyToTrackOrReplay, (parms) {setState(Constants.STATE_TEST_LOADED);},],
      Constants.EVENT_GPS_COORDS:               [sef.storePosition,],
      Constants.EVENT_SHOW_UPLOAD_TEST_DIALOG:  [sef.uploadWalkDialog],
      Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints, sef.loadWalk, (parms) {setState(Constants.STATE_TEST_LOADING_AWAIT_FIX_SETTLE);},],
      Constants.EVENT_CLEAR_DISPLAY:            [sef.clearWalkPoints,sef.clearDisplay,sef.centreDisplay,(parms) {setState(Constants.STATE_STARTUP_AWAIT_FIX_SETTLE);}, ],
      Constants.EVENT_UPLOAD_TEST:              [sef.uploadWalk],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService,],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);}],
    };

    actions[Constants.STATE_IDLE] = {
      // Constants.EVENT_CLEAR_DISPLAY:             [],
      Constants.EVENT_START_TRACKING:           [f.disableMenuItems,sef.clearWalkPoints,sef.startTracking,(parms) {setState(Constants.STATE_NEW_TEST_LOADING);},],
      Constants.EVENT_DEBUG:                    [dw.writeDebug],
      Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING);}],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.permissionRevoked, sef.requestLocationPermissions, (parms) {setState(Constants.STATE_IDLE_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.permissionRevoked, sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_IDLE_AWAIT_PERMISSIONS);},],

      Constants.EVENT_LOGIN:                    [sef.loginDialog,]
    };

    actions[Constants.STATE_IDLE_AWAIT_PERMISSIONS] = {
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService, (parms) {setState(Constants.STATE_STARTUP_AWAIT_VALID_FIX);}],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsBeforeGranted],
      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
    };

    actions[Constants.STATE_TEST_LOADING] = {
      Constants.EVENT_TEST_LOADED: [sef.centreDisplay, sef.setReadyToTrackOrReplay, (parms){setState(Constants.STATE_TEST_LOADED);},],
    };

    actions[Constants.STATE_TEST_LOADED] = {
      Constants.EVENT_START_TRACKING:           [f.disableMenuItems,sef.clearWalkPoints,sef.startTracking,(parms) {setState(Constants.STATE_NEW_TEST_LOADING);},],
      Constants.EVENT_DEBUG:                    [dw.writeDebug],
      Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      Constants.EVENT_CLEAR_DISPLAY:            [sef.setReadyToTrack,sef.clearWalkPoints,sef.clearDisplay,sef.centreDisplay,(parms) {setState(Constants.STATE_IDLE);}],
      Constants.EVENT_GPS_COORDS:               [sef.storePosition,],
      Constants.EVENT_SHOW_UPLOAD_TEST_DIALOG:  [sef.uploadWalkDialog],
      Constants.EVENT_SET_OPTIMUM_TIME:         [f.setOptimumTime],
      Constants.EVENT_UPLOAD_TEST:              [sef.uploadWalk],
      Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING);},],
      Constants.EVENT_START_REPLAY:             [f.disableMenuItems, sef.startReplay, (parms) {setState(Constants.STATE_TEST_REPLAYING);},],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.permissionRevoked, sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.permissionRevoked, sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
    };

    actions[Constants.STATE_TEST_REPLAYING] = {
      // Constants.EVENT_START_TRACKING:           [f.disableMenuItems,sef.clearWalkPoints,sef.startTracking,(parms) {setState(Constants.STATE_NEW_TEST_LOADING);},],
      // Constants.EVENT_DEBUG:                    [dw.writeDebug],
      // Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      // Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      // Constants.EVENT_CLEAR_DISPLAY:            [sef.setReadyToTrack,sef.clearWalkPoints,sef.clearDisplay,sef.centreDisplay,(parms) {setState(Constants.STATE_IDLE);}],
      // Constants.EVENT_GPS_COORDS:               [sef.storePosition,],
      // Constants.EVENT_SHOW_UPLOAD_TEST_DIALOG:  [sef.uploadWalkDialog],
      // Constants.EVENT_SET_OPTIMUM_TIME:         [f.setOptimumTime],
      // Constants.EVENT_UPLOAD_TEST:              [sef.uploadWalk],
      // Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      // Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING);},],
      // Constants.EVENT_START_REPLAY:             [sef.startReplayTimer, sef.replay, (parms) {setState(Constants.STATE_TEST_REPLAYING);},],
      //
      // Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      // Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      // Constants.EVENT_LOCATION_GRANTED:         [sef.startService],
      // Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.permissionRevoked, sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      // Constants.EVENT_LOCATION_DENIED:          [sef.permissionRevoked, sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_REPLAY_TIMER_TICK:         [sef.replayTimerTick],
      Constants.EVENT_PAUSE_REPLAY:              [sef.pauseReplay,(parms) {setState(Constants.STATE_TEST_REPLAY_PAUSED);},],
      Constants.EVENT_STOP_REPLAY:               [f.enableMenuItems,sef.stopReplay,sef.setReadyToTrackOrReplay,(parms) {setState(Constants.STATE_TEST_LOADED);},],
    };

    actions[Constants.STATE_TEST_REPLAY_PAUSED] = {
      // Constants.EVENT_START_TRACKING:           [f.disableMenuItems,sef.clearWalkPoints,sef.startTracking,(parms) {setState(Constants.STATE_NEW_TEST_LOADING);},],
      // Constants.EVENT_DEBUG:                    [dw.writeDebug],
      // Constants.EVENT_CREATE_DEBUG_TESTS:       [dw.addDebugWalks],
      // Constants.EVENT_SHOW_GPS_STATUS_DIALOG:   [sef.gpsStatusDialog],
      // Constants.EVENT_CLEAR_DISPLAY:            [sef.setReadyToTrack,sef.clearWalkPoints,sef.clearDisplay,sef.centreDisplay,(parms) {setState(Constants.STATE_IDLE);}],
      // Constants.EVENT_GPS_COORDS:               [sef.storePosition,],
      // Constants.EVENT_SHOW_UPLOAD_TEST_DIALOG:  [sef.uploadWalkDialog],
      // Constants.EVENT_SET_OPTIMUM_TIME:         [f.setOptimumTime],
      // Constants.EVENT_UPLOAD_TEST:              [sef.uploadWalk],
      // Constants.EVENT_DISPLAY_TESTS:            [sef.displayWalksWindow],
      // Constants.EVENT_LOAD_TEST:                [sef.clearWalkPoints,sef.loadWalk,(parms) {setState(Constants.STATE_TEST_LOADING);},],
      // Constants.EVENT_START_REPLAY:             [sef.startReplayTimer, sef.replay, (parms) {setState(Constants.STATE_TEST_REPLAYING);},],
      //
      // Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      // Constants.EVENT_SWITCH_TO_BACKGROUND:     [sef.stopService],
      // Constants.EVENT_LOCATION_GRANTED:         [sef.startService],
      // Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.permissionRevoked, sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      // Constants.EVENT_LOCATION_DENIED:          [sef.permissionRevoked, sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_RESUME_REPLAY:             [sef.resumeReplay,(parms) {setState(Constants.STATE_TEST_REPLAYING);},],
      Constants.EVENT_STOP_REPLAY:               [f.enableMenuItems, sef.stopReplay,sef.setReadyToTrackOrReplay,(parms) {setState(Constants.STATE_TEST_LOADED);},]
    };

    actions[Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS] = {
      Constants.EVENT_LOCATION_GRANTED:         [sef.startService, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_VALID_FIX);}],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.requestLocationPermissions],
      Constants.EVENT_LOCATION_DENIED:          [sef.showLocationSettingsBeforeGranted],
      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
    };

// This is the state from IDLE and WALK_LOADED when START TRACKING is pressed. We're waiting for the database to load or create the walk.
    actions[Constants.STATE_NEW_TEST_LOADING] = {
      Constants.EVENT_TEST_LOADED: [sef.centreDisplay, (parms) {setState(Constants.STATE_TRACKING);},],
    };

    actions[Constants.STATE_TRACKING] = {
      Constants.EVENT_GPS_COORDS:               [sef.addCoordsToMap, sef.storePosition,],
      Constants.EVENT_PAUSE_TRACKING:           [sef.pauseTracking, (parms) {setState(Constants.STATE_TRACKING_PAUSED);},],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.trackingStoppedAsPermissionRevoked, sef.stopService, f.enableMenuItems, sef.showLocationSettingsWhenTracking, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.trackingStoppedAsPermissionRevoked, sef.stopService, f.enableMenuItems, sef.showLocationSettingsWhenTracking, (parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
    };

    actions[Constants.STATE_TRACKING_PAUSED] = {
      Constants.EVENT_RESUME_TRACKING:          [sef.resumeTracking, (parms) {setState(Constants.STATE_TRACKING);},],
      Constants.EVENT_STOP_TRACKING_PRESSED:    [sef.stopTrackingPressedAction,(parms) {setState(Constants.STATE_AWAIT_TRACKING_STOP_TIMEOUT);},],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.trackingStoppedAsPermissionRevoked, sef.stopService, sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.trackingStoppedAsPermissionRevoked, sef.stopService, sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
    };

    actions[Constants.STATE_AWAIT_TRACKING_STOP_TIMEOUT] = {
      Constants.EVENT_STOP_TRACKING_RELEASED:   [sef.trackingStillPaused, (parms) {setState(Constants.STATE_TRACKING_PAUSED);},],
      Constants.EVENT_STOP_TRACKING_TIMEOUT:    [sef.trackingStopped, f.enableMenuItems, (parms) {setState(Constants.STATE_TEST_LOADED);},],

      Constants.EVENT_SWITCH_TO_FOREGROUND:     [sef.checkLocationPermissions],
      Constants.EVENT_LOCATION_NOT_YET_GRANTED: [sef.trackingStoppedAsPermissionRevoked, sef.stopService, sef.requestLocationPermissions,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
      Constants.EVENT_LOCATION_DENIED:          [sef.trackingStoppedAsPermissionRevoked, sef.stopService, sef.showLocationSettingsAfterGranted,(parms) {setState(Constants.STATE_TEST_LOADED_AWAIT_PERMISSIONS);},],
    };
  }

  void setState(String newState) {
    state = newState;
  }

  // Add an event to the queue
  void addEventToQueue(String event, var param) {
    print("Adding event $event to queue");
    f.addEventToQueue(event, param);
  }

  // The most important method in the system!!!
  void processEvents(String state, String event, var parameter) {
    // final DateTime now = DateTime.now();
    // final DateFormat formatter = DateFormat('yyyy-MM-dd');
    // final String formatted = formatter.format(now);s
    // String f = DateFormat('yyyy-MM-dd H:m:s').format(DateTime.now());
    // print("${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now())} state $state event $event");

    final actionsForEvent = actions[state];
    final actionVector = actionsForEvent[event];
    if (actionVector != null) {
      for (final action in actionVector) {
        if (action != null) {
          action(parameter);
        }
      }
    }
  }

}

