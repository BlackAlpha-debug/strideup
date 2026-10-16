# Routes, correctness, recovery, estimates, and sensitivity

## Scope and reviewed strategy

1. Replace demo map content with actual GPS recordings. Persist route geometry,
   start/end timestamps, distance and measured step deltas. Save an in-progress
   draft; after an interrupted recording show the saved partial walk rather than
   silently resuming GPS. Add a history picker and a density view based on recorded
   points. Avoid fabricated location or movement.
2. Centralize distance/pace conversion; generate the seven date labels from the
   same dates as the data. Read the signed-in email and package version rather
   than inventing values. Adapt changed views to narrow screens and larger text.
3. Resume an already opted-in health service after boot/package replacement when
   permissions allow. Persist sensor checkpoints and reconcile per-step events
   with cumulative counter events without double counting. Attribute timestamped
   steps to their real local calendar day. A recovered aggregate spanning midnight
   cannot reveal exact per-day counts: keep any unresolved remainder explicitly
   undated instead of inventing a split. Explicit Android Force stop still requires
   reopening the app, and OEM restrictions cannot be bypassed by a fake setting.
4. Add validated weight and step-length preferences; use one documented walking
   estimate formula in Flutter and Android. Existing data remains intact and
   estimates are clearly labelled. Values are optional with visible defaults.
5. Default to responsive hardware detection, with the cumulative counter as a
   reconciliation source. Remove deliberate five-second sensor batching and
   shorten notification update throttling. Offer high-sensitivity accelerometer
   detection for slow/soft steps using gravity filtering, peak hysteresis,
   cadence validation, and isolated-movement rejection. It remains optional because
   raw motion sampling uses more power and is not guaranteed to identify walking.
   Hardware thresholds themselves are not configurable through Android APIs.
6. Validate route persistence/recovery, GPS rejection, distance and pace units,
   dates and estimates, sensor fusion ordering/restarts/midnight, and synthetic
   motion signals. Run static analysis, Flutter and native tests, then build and
   inspect an installable APK. Test/install on the Redmi when connected; never
   claim measured hardware accuracy or battery savings from synthetic tests.

## Review corrections before implementation

- Do not add the detector, accelerometer, and cumulative-counter counts together.
  Reconcile timestamped provisional detections with counter checkpoints.
- Do not invent exact dates for steps recovered across an unknown midnight gap.
- Reboot recovery must respect both switches, permissions, and logout state.
- Route recording needs bounded GPS accuracy/jump checks, serialized persistence,
  explicit error states, and actual steps rather than distance-derived fake steps.
- Changing estimates must refresh the native notification as well as Flutter.
- High sensitivity is an alternate motion source, not a multiplier on step counts.

References: Android [motion sensors](https://developer.android.com/develop/sensors-and-location/sensors/sensors_motion),
[foreground-service background start rules](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start).

## Implemented result

- GPS routes now contain recorded points, elapsed time, distance, and the actual
  step-counter delta. Routes and interrupted drafts persist locally; the map has
  route history, deletion, and a density view built only from saved recordings.
- The profile now stores weight and step length, reports the real signed-in email
  and installed app version, and lets the user choose Battery saver, Responsive,
  or High sensitivity tracking. Distance units, pace, calories, and rolling chart
  dates use shared calculations.
- Responsive mode combines the low-latency Android step detector with cumulative
  counter correction. High sensitivity adds cadence-filtered accelerometer peaks.
  Provisional counts persist across process restarts and are reconciled instead of
  added twice. Unknown cross-midnight remainder is marked undated.
- An opted-in background service restarts after boot or app replacement when its
  permissions remain available. The ongoing notification refresh throttle is two
  seconds. Turning counting off unregisters every step/motion sensor.
- The narrow-profile row and five-item bottom navigation were verified at 393 dp
  width, 1.3x text, and 24/48/72 dp system navigation insets.

Additional audit fixes completed: locally created accounts can authenticate again
after logout without storing plaintext passwords; the Health Data Permissions row
opens Android settings; active GPS recordings use an Android foreground location
notification for screen-off continuity; and the Stats layouts now fit all tested
Redmi text/inset combinations.

Validation completed: Flutter static analysis has no issues; all 16 Flutter tests
and all 9 app-owned Android unit tests pass. Release APK 1.2.0+3 was built and its
manifest/version inspected at `build/app/outputs/flutter-apk/app-release.apk`.
