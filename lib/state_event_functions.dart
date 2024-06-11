import 'package:gps_tracker_db/gps_tracker_db.dart';
import 'event.dart';
import 'instance_vars.dart';
import 'constants.dart';

class StateEventFunctions {

  InstanceVars iv;

  StateEventFunctions({required this.iv});

  // Add an event to the queue
  void addEventToQueue(String event, var param) {
    Event e = Event(event: event, parameter: param);
    iv.eventQueueController.sink.add(e);
  }

  void disableMenuItems(var param) {
    iv.uploadTestEnabled = false;
    iv.displayTestsEnabled = false;
    iv.clearDisplayEnabled = false;
  }

  void enableMenuItems(var param) {
    iv.uploadTestEnabled = true;
    iv.displayTestsEnabled = true;
    iv.clearDisplayEnabled = true;
  }

  Future<void> setOptimumTime(var param) async {
    // Get the current walk
    final Walk walk                        = await iv.db.getWalk(iv.testName);
    final double metresPerMinute           = (iv.distanceNotifier.value/param)*60;
    double nextMarker                      = metresPerMinute;
    final List<WalkWaypoint> minuteMarkers = [];

    // Loop over the walk points setting the markers.
    // This should really interpolate between the two, but I'm lazy.....
    final WalkTrackPoint wtp1 = walk.track[0];
    for (int i = 1; i < walk.track.length; i++) {
      final WalkTrackPoint wtp2 = walk.track[i];
      if (wtp1.distance < nextMarker && wtp2.distance >= nextMarker) {
        // var distanceToMarker = nextMarker - wtp1.distance;
        // var bearing          = calculateBearing(wtp1.latitude,wtp1.longitude,wtp2.latitude,wtp2.longitude);
        // var newPos           = calculateLatLon(wtp1.latitude,wtp1.longitude,distanceToMarker,bearing);
        // minuteMarkers.add(WalkWaypoint(latitude: newPos[0],longitude: newPos[1]));
        minuteMarkers.add(WalkWaypoint(latitude: wtp2.latitude, longitude: wtp2.longitude));
        nextMarker += metresPerMinute;
      }
    }

    // Update the database and reload the walk
    await iv.db.deleteWaypointsFromWalk(iv.testName);
    await iv.db.addWalkWaypoints(iv.testName,minuteMarkers);
    await iv.db.updateWalkOptimumDurn(iv.testName,(param as int)~/60, param%60);
    addEventToQueue(Constants.EVENT_LOAD_TEST, iv.testName);
  }

}