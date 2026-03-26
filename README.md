# circle_wallet_sdk_flutter

Monorepo for the `circle_wallet` federated plugin and example app.

## Android: PW SDK Maven credentials

The **example app** Android build (`circle_wallet/example`) fetches the PW SDK from a private Maven repository. Credentials are resolved in this order:

1. **Environment variables** `PWSDK_MAVEN_URL` / `PWSDK_MAVEN_USERNAME` / `PWSDK_MAVEN_PASSWORD` (e.g. CI secrets)
2. **`circlefin-maven.properties`** at `circle_wallet/example/android/circlefin-maven.properties` (typical for local development)

The **`circle_wallet_android`** plugin module reads Maven credentials from environment variables only. Apps that depend on the published plugin must supply `PWSDK_MAVEN_*` in their environment or add their own Gradle repository configuration.

### Local setup (example app)

Create `circle_wallet/example/android/circlefin-maven.properties` next to `local.properties`

```properties
PWSDK_MAVEN_URL=https://maven.pkg.github.com/circlefin/w3s-android-sdk
PWSDK_MAVEN_USERNAME=<github_username>
PWSDK_MAVEN_PASSWORD=<github_pat>
```

After creating or changing the file, re-sync Gradle in Android Studio (or re-run your build).
