# StrideUp review and implementation

## Code review

Reviewed the Flutter entry point, all screen flows, providers, services, models,
widgets, theme, utilities, tests, dependency list, and Android integration. The
other platform folders are generated scaffolding; this tracking implementation
targets Android, including the Redmi Note 13.

Findings relevant to the request:

- Authentication was a local demo with an in-memory login flag. It had no session
  restoration. Signup also left its pushed route open after succeeding.
- The bottom navigation source had an unclosed Scaffold expression. Its system
  padding needed an explicit outer safe area and separate visual spacing.
- Step tracking depended on a Flutter subscription, had no persistent Android
  service, and could accumulate duplicate listeners. Session-only baselines,
  debounce-on-every-step persistence, and missing midnight handling made totals
  unreliable across long walks and restarts.
- The notification setting only saved a boolean. No notification was created.
- Location tracking's settings switch did not stop an active GPS subscription.
- The sole test imported a nonexistent app file.
- Testing found additional phone-width overflows in dashboard cards, profile
  names/goals, and the shell header. These now use flexible layout constraints.

## Plan and review adjustments

1. Restore the saved local session before rendering the first screen; save it on
   successful login/signup and remove it on explicit logout. Do not save passwords.
2. Keep bottom navigation above gesture and three-button navigation insets. Test
   phone-width layouts with larger text as well as normal text.
3. Use one native Android step-counter sensor owner shared by the activity and a
   health foreground service. Persist the sensor baseline and history natively,
   then mirror totals into the existing Flutter storage for statistics and levels.
4. Request notification access when enabling tracking, or on the first new steps
   for an existing installation. Never repeatedly prompt after denial. Provide an
   Android-settings link for permissions and blocked notification channels.
5. Make notification and counting switches independent and persistent. Review
   clarified that disabling the notification must also disable background
   tracking: foreground services require a notification. Counting can still run
   while the app is visible. Disabling counting unregisters the sensor completely.
6. Exclude paused periods and sensor resets from deltas; preserve native totals
   over service restarts; use local calendar days for daily totals. Update a quiet
   notification at most once per two seconds, with the latest pending count.
7. Stop step tracking and active GPS routes on logout. Respect the location
   setting when starting a route. Avoid updating Flutter UI from background sensor
   events, GPS for step counting, polling loops, or a wake lock.

Android reference: [Health foreground service requirements](https://developer.android.com/develop/background-work/services/fgs/service-types#health).

## Behavior and limits

- Profile contains **Step notification** and **Step counting** switches.
- Notification on + counting on + permissions granted: background sensor tracking
  with a quiet ongoing notification showing daily steps and estimated kcal.
- Notification off: counting only while the app is visible.
- Counting off: no step sensor listener, no step service/notification; history is
  retained. GPS route recording remains a separately controlled feature.
- Notifications use the app's dark/light cyan accent, a walking icon, and the
  system notification template. Android/HyperOS ultimately controls appearance.
- The first cumulative sensor event establishes a baseline after a pause or reboot.
  Timestamped detector steps are assigned to their real local day. A cumulative
  remainder spanning midnight is retained as undated because Android provides no
  per-step timestamps for that remainder.
- A normal service restart recovers and reconciles its persisted baseline and
  provisional detector steps. An opted-in service also starts after boot/package
  replacement when permissions allow. Explicit Android force-stop still requires
  reopening the app. OEM battery restrictions can affect background delivery.
- Authentication is local to this installation. A signed-up account can log back
  in after logout; its password is stored only as a salted, repeatedly hashed
  verifier. `test@strideup.com` / `stride123` remains available as a local demo.
  There is no remote account, password recovery, or cloud synchronization.
- iOS/desktop/web sensor and notification implementations are not part of this
  Android change; unsupported platforms display tracking as unavailable.
- Maps use recorded GPS routes only. Saved and interrupted routes can be selected
  or deleted, and the density overlay is derived from recorded points.

## Validation

Completed: static analysis has no issues; all 16 Flutter tests and all 9 Android
counter/motion tests pass; release APK 1.2.0+3 builds successfully. The release APK
is `build/app/outputs/flutter-apk/app-release.apk` (54.4 MB as reported by Flutter).
It uses the project's existing debug signing configuration for local installation.

- `flutter analyze --no-pub`
- `flutter test --no-pub`: session restoration/logout/signup; independent persisted
  switches; denied activity permission; duplicate and daily snapshots; route draft
  recovery, GPS rejection, route step deltas; dates, units, pace and calorie math;
  phone nav clearance at 393 logical pixels with 24/48/72 pixel bottom insets and
  every main tab plus profile at 1.3x text.
- `android/gradlew.bat :app:testDebugUnitTest`: first sample, restarts, duplicates,
  paused periods, changed boot ID, decreasing hardware counts, cadence validation,
  isolated-motion rejection, and sensitivity thresholds.
- `flutter build apk --release --no-pub`

On a Redmi Note 13, verify gesture and three-button navigation; walk with the app
open and then locked; decline/allow notifications; turn each switch off/on; reopen
after closing; and log out/reopen. Measure battery behavior over a representative
walk. No Android device was connected during implementation, so hardware counting,
HyperOS appearance, high-sensitivity accuracy, and measured battery use require
physical-device checks. No Android device was connected for this final build.
