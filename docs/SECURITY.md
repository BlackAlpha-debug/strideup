# Security and privacy

## Data model

StrideUp is local-first. Profile details, sign-in state, step history, goals, preferences, and routes are stored on the device with Flutter's preferences storage. The app does not include an analytics SDK, advertising SDK, cloud database client, or remote account service.

Clearing app data or uninstalling the app removes this local state unless the operating system restores it from a device backup.

## Local accounts

Passwords are not stored as plain text. A random salt and derived verifier are stored locally and compared during sign-in. This is suitable for a private, offline profile gate; it is not equivalent to a remotely authenticated account, encrypted vault, or multi-device identity. Anyone with control of an unlocked device may be able to inspect or reset local application data.

## Permissions

- **Physical activity** is used only for Android step sensors.
- **Notifications** are used for live step status and active tracking on Android versions that require notification consent.
- **Foreground service** permissions allow user-enabled tracking to continue while the app is not visible.
- **Fine location** is requested when the user starts route recording. Location is saved into local route history.

The user can turn off the live step notification independently. Turning off step counting stops and unregisters the step sensors. Route recording begins only through an explicit user action.

## Network behavior

Map views may request map tiles from the configured OpenStreetMap tile provider. Core account, step, calorie, and route persistence does not require a StrideUp backend.

## Repository secret policy

The repository ignores common secret-bearing files, including:

- `.env` variants
- Android keystores and `key.properties`
- PEM, P12, PFX, DER, and private key files
- Firebase `google-services.json` and `GoogleService-Info.plist`
- files named `secrets.*`

Do not add credentials directly to Dart, Kotlin, Gradle, workflow, or documentation files. Production signing keys must remain outside the repository. If a secret is committed accidentally, revoke or rotate it before removing it from Git history.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting feature for this repository when it is available. Avoid opening a public issue that contains credentials, personal routes, or exploit details.
