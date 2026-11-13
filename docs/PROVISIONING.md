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
