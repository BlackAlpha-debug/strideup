# StrideUp architecture

StrideUp is a local-first Flutter application with a focused native Android layer. Flutter owns the product experience and durable app data. Kotlin owns sensor input and the foreground service required for dependable background collection.

## Component view

```mermaid
flowchart TB
    subgraph Flutter[Flutter application]
        Screens[Screens and widgets]
        Providers[Provider state models]
        Services[Application services]
        Models[Domain models]
        Store[(SharedPreferences)]
        Screens --> Providers
        Providers --> Services
        Providers --> Models
        Services --> Store
    end

    subgraph Android[Native Android layer]
        Activity[MainActivity channel bridge]
        Tracker[StepTracker]
        Service[StepTrackingService]
        Counter[StepCounter reconciliation]
        Motion[MotionStepDetector]
        Boot[BootReceiver]
        Notice[Foreground notification]
        Activity --> Tracker
        Service --> Tracker
        Tracker --> Counter
        Tracker --> Motion
        Service --> Notice
        Boot --> Service
    end

    Sensors[Step detector, step counter, accelerometer] --> Tracker
    Services <--> Activity
    Providers --> Geo[Geolocator]
    Geo --> GPS[Device location]
    Screens --> Tiles[OpenStreetMap tiles]
```

## Step processing flow

```mermaid
flowchart TD
    Start[User enables step counting] --> Mode{Sensitivity mode}
    Mode -->|Battery saver| Counter[Register cumulative step counter]
    Mode -->|Balanced| Detector[Register step detector]
    Mode -->|Balanced| Counter
    Mode -->|High| Detector
    Mode -->|High| Counter
    Mode -->|High| Accelerometer[Register accelerometer]

    Detector --> Candidate[Immediate hardware step]
    Accelerometer --> Filter[Cadence and motion filters]
    Filter --> Candidate
    Counter --> Reconcile[Reconcile cumulative total]
    Candidate --> Reconcile
    Reconcile --> Deduplicate[Reject duplicate or implausible events]
    Deduplicate --> Publish[Publish total through event channel]
    Publish --> Provider[StepProvider updates daily state]
    Provider --> Persist[(Persist local history)]
    Provider --> UI[Refresh UI]
    Provider --> Notice[Refresh optional notification]
```

The cumulative hardware counter is the source used to correct missed real-time events. The detector keeps updates responsive. High sensitivity supplements those sources with cadence-filtered accelerometer events, so it uses more power.

## Background lifecycle

```mermaid
stateDiagram-v2
    [*] --> Disabled
    Disabled --> Starting: counting enabled
    Starting --> Active: permission granted
    Starting --> Disabled: permission denied
    Active --> ActiveNotification: live notification enabled
    ActiveNotification --> Active: live notification disabled
    Active --> Disabled: counting disabled
    ActiveNotification --> Disabled: counting disabled
    Active --> Recovering: process or device restart
    ActiveNotification --> Recovering: process or device restart
    Recovering --> Active: saved preference allows restart
    Recovering --> ActiveNotification: preference and permission allow notification
    Recovering --> Disabled: counting was disabled
```

## Route recording sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as Map screen
    participant LP as LocationProvider
    participant LS as LocationService
    participant OS as Android location service
    participant DB as Local storage

    User->>UI: Start route
    UI->>LP: startTracking()
    LP->>LS: request permission and stream
    LS->>OS: start foreground location updates
    OS-->>LS: position samples
    LS-->>LP: filtered coordinates
    LP-->>UI: distance, time, path
    LP->>DB: checkpoint active route
    User->>UI: Stop route
    UI->>LP: stopTracking()
    LP->>DB: save completed route and step delta
    LP->>LS: stop location stream
```

An active route is checkpointed so an interrupted session can be recovered instead of silently discarded.

## Local authentication sequence

```mermaid
sequenceDiagram
    actor User
    participant Screen as Login or sign-up screen
    participant Auth as AuthService
    participant Store as SharedPreferences
    participant App as Application shell

    User->>Screen: Submit credentials
    Screen->>Auth: signUp() or signIn()
    Auth->>Store: Read local account
    Auth->>Auth: Derive and compare salted verifier
    Auth->>Store: Persist session on success
    Auth-->>Screen: Authenticated profile
    Screen->>App: Open main navigation
    Note over App,Store: A later launch restores the session until sign-out
```

## Storage ownership

| Data | Owner | Persistence |
| --- | --- | --- |
| Account and session | `AuthService` / `UserProvider` | Device-local preferences |
| Daily steps and settings | `StepProvider` | Device-local preferences |
| Route history and active checkpoint | `LocationProvider` | Device-local preferences |
| Theme | `ThemeProvider` | Device-local preferences |
| Sensor runtime state | Native Android service | Memory plus minimal restart preferences |

No cloud database is required. Clearing application data removes the local account and activity history.

## Failure handling

- Sensor totals are reconciled to reduce missed or duplicated step events.
- Permission failures return control to the UI and leave the related feature disabled.
- Route checkpoints preserve an in-progress route if the process is interrupted.
- Deserialization uses defaults where possible so one missing setting does not prevent startup.
- Counting can be disabled completely, which unregisters sensors and avoids ongoing collection.
