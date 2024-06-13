class Constants {
  static const String paidAppTitle = "Dressage Companion - Paid";
  static const String freeAppTitle = "Dressage Companion - Free";
  static const String defaultTitle = "Dressage Companion";

  static const int CROSS_SIZE                 = 6;
  static const int FIX_SETTLE_TIMEOUT_SECONDS = 3;

  static const String appTitleStem = "Course";

  static const String UPLOAD_TEST_COUNTRY_KEY = "upload_country_name";
  static const String UPLOAD_TEST_USER_KEY    = "upload_test_user";
  static const String UPLOAD_TEST_EMAIL_KEY   = "upload_test_email";
  static const String DEVICE_UUID             = "device_uuid";

  static const String TEST_UPLOAD_URL  = "http://wamm.me.uk/dc/test_upload.php";

  static const String TEST_WINDOW_TITLE         = "Select a test";
  static const String RENAME_DIALOG_TITLE       = "Rename";
  static const String ERROR_DIALOG_TITLE        = "ERROR";
  static const String INFORMATION_DIALOG_TITLE  = "Information";
  static const String UPLOAD_TEST_DIALOG_TITLE  = "Upload Test";
  static const String GPS_STATUS_DIALOG_TITLE   = "GPS Status";

  static const String PROMPT_AWAIT_GPS            = "Await GPS";
  static const String PROMPT_START_TRACKING       = "Start";
  static const String PROMPT_STOP_TRACKING        = "Stop";
  static const String PROMPT_START_REPLAY         = "Replay";
  static const String PROMPT_STOP_REPLAY          = "Stop";
  static const String PROMPT_PAUSE                = "Pause";
  static const String PROMPT_RESUME               = "Resume";
  static const String PROMPT_LOAD                 = "Load";
  static const String PROMPT_RENAME               = "Rename";
  static const String PROMPT_DELETE               = "Delete";
  static const String PROMPT_NAME                 = "Name";
  static const String PROMPT_OK                   = "OK";
  static const String PROMPT_CANCEL               = "Cancel";
  static const String PROMPT_YES                  = "Yes";
  static const String PROMPT_NO                   = "No";
  static const String PROMPT_SET                  = "Set";
  static const String PROMPT_UPLOAD_TEST_USER     = "Uploaded by";
  static const String PROMPT_UPLOAD_TEST_EMAIL    = "Email";
  static const String PROMPT_UPLOAD_TEST_COUNTRY  = "Country";
  static const String PROMPT_UPLOAD_TEST_NAME     = "Test name";
  static const String PROMPT_UPLOAD_TEST_CLASS    = "Class";
  static const String PROMPT_UPLOAD_TEST_NOTES    = "Notes";
  static const String PROMPT_UPLOAD               = "Upload";

  static const String PROMPT_DELETE_TEST    = "Are you sure you want to delete this test?";

  static const String PROMPT_LATITUDE  = "Latitude";
  static const String PROMPT_LONGITUDE = "Longitude";

  static const String MENU_PROMPT_DEBUG_TESTS   = "Debug Tests";
  static const String MENU_PROMPT_DEBUG         = "Debug";
  static const String MENU_PROMPT_GPS_STATUS    = "GPS Status";
  static const String MENU_PROMPT_CLEAR_DISPLAY = "Clear Display";
  static const String MENU_PROMPT_GALLERY       = "Gallery";
  static const String MENU_PROMPT_TESTS         = "Tests";
  static const String MENU_PROMPT_MAPS          = "Maps";
  static const String MENU_PROMPT_UPLOAD        = "Upload test";
  static const String MENU_PROMPT_LOGIN         = "Login";
  static const String MENU_PROMPT_LOGOUT        = "Logout";

  static const Set<String> MENU_CHOICES = { MENU_PROMPT_DEBUG_TESTS,
  MENU_PROMPT_DEBUG,
  MENU_PROMPT_CLEAR_DISPLAY,
  MENU_PROMPT_TESTS,
  MENU_PROMPT_UPLOAD,
  MENU_PROMPT_LOGIN };

  static const double STOP_TIMEOUT_DELAY = 3000.0;
  static const int STOP_TIMEOUT_TICK     = 10;
  static const int REPLAY_TIMER_TICK     = 100;

  static const String STATE_STARTUP_AWAIT_PERMISSIONS     = "startup_await_permissions";
  static const String STATE_STARTUP_AWAIT_VALID_FIX       = "startup_await_valid_fix";
  static const String STATE_STARTUP_AWAIT_FIX_SETTLE      = "startup_await_fix_settle";
  static const String STATE_IDLE                          = "idle";
  static const String STATE_TEST_LOADED_AWAIT_VALID_FIX   = "test_loaded_await_valid_fix";
  static const String STATE_TEST_LOADED_AWAIT_FIX_SETTLE  = "test_loaded_await_fix_settle";
  static const String STATE_TEST_LOADED                   = "test_loaded";
  static const String STATE_TEST_REPLAYING                = "test_replaying";
  static const String STATE_TEST_REPLAY_PAUSED            = "test_replay_paused";
  static const String STATE_TRACKING                      = "tracking";
  static const String STATE_TRACKING_PAUSED               = "paused";
  static const String STATE_AWAIT_TRACKING_STOP_TIMEOUT   = "await_stop";
  static const String STATE_NEW_TEST_LOADING              = "new_test_loading";
  static const String STATE_TEST_LOADING                  = "test_loading";
  static const String STATE_TEST_LOADING_AWAIT_VALID_FIX  = "test_loading_await_valid_fix";
  static const String STATE_TEST_LOADING_AWAIT_FIX_SETTLE = "test_loading_await_fix_settle";
  static const String STATE_TEST_LOADED_AWAIT_PERMISSIONS = "test_loaded_await_permissions";
  static const String STATE_IDLE_AWAIT_PERMISSIONS        = "idle_await_permissions";

  static const String EVENT_STARTUP = "startup";

  static const String EVENT_GPS_GRANTED            = "gps_granted";
  static const String EVENT_GPS_DENIED             = "gps_denied";
  static const String EVENT_GPS_PERMANENTLY_DENIED = "gps_permanently_denied";

  static const String EVENT_FIX_SETTLE_TIMEOUT       = "gps_fix_settle_timeout";
  static const String EVENT_GPS_FIX                  = "gps_fix";
  static const String EVENT_GPS_COORDS               = "gps_coords";

  static const String EVENT_START_TRACKING           = "start_tracking";
  static const String EVENT_PAUSE_TRACKING           = "pause_tracking";
  static const String EVENT_RESUME_TRACKING          = "resume_tracking";
  static const String EVENT_STOP_TRACKING_PRESSED    = "stop_tracking_pressed";
  static const String EVENT_STOP_TRACKING_RELEASED   = "stop_tracking_released";
  static const String EVENT_STOP_TRACKING_TIMEOUT    = "stop_tracking_timeout";

  static const String EVENT_START_REPLAY             = "start_replay";
  static const String EVENT_STOP_REPLAY              = "stop_replay";
  static const String EVENT_PAUSE_REPLAY             = "pause_replay";
  static const String EVENT_RESUME_REPLAY            = "resume_replay";
  static const String EVENT_REPLAY_TIMER_TICK        = "replay_timer_tick";

  static const String EVENT_DEBUG                    = "debug";
  static const String EVENT_CREATE_DEBUG_TESTS       = "debug_tests";
  static const String EVENT_SHOW_GPS_STATUS_DIALOG   = "show_gps_status";
  static const String EVENT_CLEAR_DISPLAY            = "clear_display";
  static const String EVENT_SHOW_OPTIMUM_TIME_DIALOG = "show_optimum_time";
  static const String EVENT_SET_OPTIMUM_TIME         = "set_optimum_time";
  static const String EVENT_DISPLAY_TESTS            = "tests";
  static const String EVENT_LOAD_TEST                = "load_test";
  static const String EVENT_SHOW_UPLOAD_TEST_DIALOG  = "show_upload_test";
  static const String EVENT_UPLOAD_TEST              = "upload_test";

  static const String EVENT_TEST_LOADED              = "test_loaded";

  static const String EVENT_SWITCH_TO_BACKGROUND     = "background";
  static const String EVENT_SWITCH_TO_FOREGROUND     = "foreground";

  static const String EVENT_LOCATION_GRANTED         = "location_granted";
  static const String EVENT_LOCATION_NOT_YET_GRANTED = "location_denied";
  static const String EVENT_LOCATION_DENIED          = "location_problems";

  static const String EVENT_LOGIN  = "login";
  static const String EVENT_LOGOUT = "logout";

  static const String ERR_TEST_NAME_INVALID            = "Test name must not be blank or empty.";

  static const String ERR_USERNAME_AND_PASSWORD_MUST_BE_SPECIFIED = "The username and password must be specified";

  static const String ERR_TEST_NAME_AND_USER_MUST_BE_SET = "The course name and the user must be specified.";
  static const String ERR_CANT_UPLOAD_TEST               = "The course test cannot be uploaded - please report to admin@wamm.me.uk.";
  static const String ERR_NO_CONNECTIVITY                = "The course test cannot be uploaded as there is no internet connectivity. Please try again later.";

  static const String INFO_TEST_UPLOADED_OK = "The test was uploaded successfully.";

  static const String REQUEST_LOCATION_PERMISSIONS_BEFORE_GRANTED_TITLE = 'Location Permissions';
  static const String REQUEST_LOCATION_PERMISSIONS_AFTER_GRANTED_TITLE  = 'Location Permissions Removed';
  static const String REQUEST_LOCATION_PERMISSIONS_WHEN_TRACKING_TITLE  = 'Tracking Stopped';
  static const String REQUEST_LOCATION_PERMISSIONS_TEXT =
  'In order for this application to function, it requires '
  'location tracking to be enabled, precise accuracy to be '
  'turned on, and access to all location functions. '
  'Press the SETTINGS button to open the settings window '
  'then enable all these features to continue.';
}