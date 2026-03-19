# Release Documentation

## Android Release Configuration

### Keystore Information

**Location:** `android/app/taichi-release-key.jks`

**Details:**
- **Alias:** taichi
- **Store Password:** taichi2026
- **Key Password:** taichi2026
- **Key Algorithm:** RSA
- **Key Size:** 2048 bits
- **Validity:** 10,000 days
- **Distinguished Name:** CN=Taichi Qigong, OU=Development, O=Amazing eLearning, L=City, ST=State, C=US

### Key Properties File

The keystore credentials are stored in `android/key.properties`:
```
storePassword=taichi2026
keyPassword=taichi2026
keyAlias=taichi
storeFile=app/taichi-release-key.jks
```

**IMPORTANT:** Never commit the `key.properties` file or the keystore file to version control. These files should be kept secure and backed up safely.

### Building Release AAB

To build a release AAB file for Play Store upload:

```bash
cd android
./gradlew bundleRelease
```

The AAB file will be generated at:
`android/app/build/outputs/bundle/release/app-release.aab`

### Building Release APK

To build a release APK:

```bash
cd android
./gradlew assembleRelease
```

The APK file will be generated at:
`android/app/build/outputs/apk/release/app-release.apk`

### Backup Instructions

1. **Keystore File:** Keep a secure backup of `android/app/taichi-release-key.jks`
2. **Passwords:** Store the passwords (taichi2026) in a secure password manager
3. **Key Properties:** Keep a secure copy of `android/key.properties`

**WARNING:** If you lose the keystore file or forget the passwords, you will NOT be able to update your app on the Play Store. You would need to publish a new app with a different package name.

### Security Best Practices

- Add `key.properties` to `.gitignore`
- Add `*.jks` to `.gitignore`
- Never share the keystore or passwords publicly
- Keep backups in multiple secure locations
- Consider using a password manager for credentials
