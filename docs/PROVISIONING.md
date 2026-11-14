# Device Owner provisioning

This app manages a **fully managed device** and must be provisioned as
**Device Owner**. It never grants itself privileges: provisioning is always
done from outside the app.

| Role | What it is | Enough for this MDM? |
|---|---|---|
| Device Administrator | Legacy admin activated in Settings. Can lock, little else. | No |
| Profile Owner / Work Profile | Owns a work profile on a personal device. | No |
| Device Owner / Fully Managed Device | Owns the whole device, set on a fresh device. | **Yes** |

Admin component: `com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver`

## Device conditions

Android only accepts a Device Owner when all of these hold:

- Dedicated test device, factory reset (or a fresh emulator image).
- Setup wizard finished **without adding any account** (Google or other).
- No secondary users, no work profile, no existing Device Owner.
- Developer options and USB debugging enabled (for the ADB route).

## Development provisioning (ADB)

```bash
flutter build apk --debug
```

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

```bash
adb shell dpm set-device-owner com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver
```

Expected output: `Success: Device owner set to package ...`.

## Verify

```bash
adb shell dpm list-owners
```

Expected: `User 0: admin=com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver,DeviceOwner`.
In the app, open **Device Owner Status** and press refresh: the status must read
**Device Owner active**. It is read live from
`DevicePolicyManager.isDeviceOwnerApp()`.

## Status values

| Status | Meaning |
|---|---|
| `NOT_PROVISIONED` | No management role. |
| `DEVICE_ADMIN_ACTIVE` | Active device admin only. Never reported as Device Owner. |
| `DEVICE_OWNER_ACTIVE` | App is Device Owner. |
| `PROVISIONING_FAILED` | Device lacks device-admin support, the app became Profile Owner instead, or managed provisioning completed without Device Owner. A reason is shown. |

## Troubleshooting

| ADB error | Cause | Fix |
|---|---|---|
| `Not allowed to set the device owner because there are already some accounts on the device` | An account exists. | Remove all accounts, or factory reset and skip account setup. |
| `...already several users on the device` | Secondary user or work profile exists. | Remove them or factory reset. |
| `Trying to set the device owner, but device owner is already set` | Another DPC owns the device. | Factory reset. |
| `Unknown admin: ComponentInfo{...}` | App not installed, or wrong component name. | Install the APK; copy the component exactly. |

## Removing Device Owner

A Device Owner app cannot be uninstalled. `adb shell dpm remove-active-admin`
only works for builds marked `android:testOnly="true"`, which this project does
not set. To release a test device, factory reset it (or wipe the emulator).

## Production provisioning (later phase)

QR-code provisioning from the setup wizard (tap the welcome screen six times)
is the production route. On Android 12+ it additionally requires the app to
handle `ACTION_GET_PROVISIONING_MODE` and `ACTION_ADMIN_POLICY_COMPLIANCE`,
plus a hosted, signed APK and its checksum in the QR payload. This is not
implemented yet. Change the application ID from `com.example.mdd_poc` before
then: the Device Owner component name cannot change after enrolment.

## Exact alarms for time-based restrictions

Time restrictions switch at the configured minute only if the app holds the
"Alarms & reminders" special access (Android 12+). Being Device Owner does not
grant it. Without it the app still works, using an inexact alarm (Android may
deliver it up to about an hour late) plus a 15-minute reconciliation job, and
the Time Restrictions screen shows a notice.

Grant it on the device under **Settings > Apps > Special app access > Alarms &
reminders**, or during development:

```bash
adb shell appops set com.example.mdd_poc SCHEDULE_EXACT_ALARM allow
```

The app notices the change and re-arms its alarm as exact.

## Installation restrictions, lock and factory reset

- **Block all installations** (`DISALLOW_INSTALL_APPS`) also blocks
  `adb install` and therefore `flutter run`. On a development device, switch it
  off in the app before deploying a new build. If the app itself is broken and
  the restriction is on, the only way out is a factory reset.
- **Block unknown sources** blocks sideloading only; ADB and store installs
  still work.
- **Lock device** needs a screen lock (PIN, pattern or password) to be a real
  lock. Without one, Android only turns the screen off.
- **Factory reset** must be tested on a real dedicated device. Emulator images
  without a recovery (`/misc`) partition accept the request but cannot perform
  it; the app then reports `FACTORY_RESET_NOT_PERFORMED` after 30 seconds.
