# Wardrobe

A personal wardrobe inventory: keep track of the clothes you own, how many of
each, their colours and a photo.

## Features

- Add, edit and delete garments (name, category, colours, quantity, photo)
- Photos from the camera or photo library, stored in the app's documents folder
- Filter by category, search by name, category or colour
- Quick +/- quantity buttons; swipe left to delete, with undo
- Optional app lock (Face ID / Touch ID / fingerprint / device passcode)
- Everything stays on the device in `wardrobe/wardrobe.json`

## Structure

```
lib/
  main.dart                    bootstraps the store and ProviderScope
  app.dart                     MaterialApp + AppGate (loading / lock / home)
  models/garment.dart          Garment, Category, colour palette
  data/garment_store.dart      JSON file + image persistence
  state/wardrobe_providers.dart Riverpod notifier and auth seam
  screens/                     home, add/edit form, lock screen
  widgets/garment_photo.dart   photo thumbnail and colour dots
```

## Run

```sh
flutter pub get
flutter test
flutter run
```

Targets iOS, Android and macOS. Web is not supported because storage uses `dart:io`.
