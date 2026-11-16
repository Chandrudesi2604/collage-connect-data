class AppConfig {
  // Replace this with the RAW URL of your public GitHub data file.
  //
  // Example:
  // https://raw.githubusercontent.com/YOUR-ACCOUNT/YOUR-REPO/main/data/content.json
  //
  // The student app only READS this file.
  static const String contentUrl =
      'https://raw.githubusercontent.com/YOUR-ACCOUNT/YOUR-REPO/main/data/content.json';

  // Admin publishing is intentionally NOT performed from the student APK.
  // See README_SETUP.md for the safe free publishing workflow.
}
