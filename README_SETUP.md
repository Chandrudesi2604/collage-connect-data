# College Connect — ₹0 / no-payment architecture

This version deliberately DOES NOT use Firebase, a paid database, file storage, or a server you have to pay for.

The student APK reads one public JSON file from GitHub.

Students:
- No login.
- Read announcements.
- Read study-material links.
- Search everything.
- Open links in the browser.

The app never stores PDFs.

## Important limitation

A completely free static app cannot safely contain a secret admin password and then use that password to write directly to a public repository. Anything embedded in an APK can be extracted.

Therefore this project separates:
1. Student app = public read-only app.
2. Publishing = GitHub repository update done by the admin.

This means there is no secret publishing token inside the APK.

GitHub's official REST API supports reading and modifying repository contents, but a write token must be kept private. Do NOT put such a token in Flutter source code or the APK.

## 1. Create a public GitHub repository

Create a public repository, for example:

college-connect-data

Inside it create:

data/content.json

Copy the included data/content.json into that file.

The repository is public because the student app needs to read the content without requiring student accounts.

## 2. Find the raw content URL

After the repository exists, the raw URL will look like:

https://raw.githubusercontent.com/YOUR-ACCOUNT/college-connect-data/main/data/content.json

Open:

lib/config/app_config.dart

Replace:

https://raw.githubusercontent.com/YOUR-ACCOUNT/YOUR-REPO/main/data/content.json

with your real raw URL.

Then:

flutter pub get
flutter run

## 3. Publishing announcements/materials

The simplest zero-cost publishing method is:

1. Admin opens the GitHub repository.
2. Opens data/content.json.
3. Edits the JSON.
4. Commits the change.
5. Students refresh the app.

Example announcement:

{
  "id": "announcement-2026-08-11-1",
  "type": "announcement",
  "title": "Tomorrow's class timing",
  "description": "Mathematics class starts at 9:00 AM tomorrow.",
  "category": "Other",
  "link": "",
  "important": true,
  "date": "2026-08-11T15:30:00+05:30"
}

Example study material:

{
  "id": "math-unit-2-2026-08-11",
  "type": "material",
  "title": "Mathematics Unit 2 Notes",
  "description": "Unit 2 class notes.",
  "category": "Class Notes",
  "link": "https://your-online-file-link.example",
  "important": false,
  "date": "2026-08-11T15:30:00+05:30"
}

The PDF itself is NOT stored in GitHub. Only the external link is stored.

## 4. Admin login requirement

The requested roll-number/password screen is included as an interface.

However, do NOT put a real secret publishing password in the student APK.

The sample local gate in lib/screens/admin_screen.dart is only a UI convenience and does NOT grant repository write access.

For a real secure admin publishing system, the credential/token must live outside the APK. A practical no-cost option is to use the admin's GitHub account directly to edit the data file.

## 5. Why this design

You requested:
- nobody pays anything;
- students don't log in;
- no PDF storage;
- only announcements and external links;
- common search.

This architecture satisfies those requirements without a paid backend.

GitHub Pages is also available with GitHub Free for public repositories, but this app does not need Pages for the student data itself; it reads the raw JSON directly.

## 6. Updating content

After an admin commits a new content.json:
- students can pull down the newest data by opening/refreshing the app;
- no APK update is required.

## 7. Build APK

flutter pub get
flutter build apk --release

The APK will be generated under:

build/app/outputs/flutter-apk/app-release.apk

## 8. Security

Do not put:
- GitHub personal access tokens
- passwords
- private keys
- service-account credentials

inside Flutter source code, assets, or the APK.

If you later want a proper in-app admin publishing dashboard, we can build one using a free backend or a separate protected admin web interface, but the credential must remain server-side/private.
