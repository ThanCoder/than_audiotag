# ThanAudioTag

### taglib-2.3.1

A lightweight Dart FFI wrapper around **TagLib** for reading and writing audio metadata, audio properties, and embedded cover artwork.

`ThanAudioTag` is designed for Dart and Flutter applications that need native metadata access without parsing media files entirely in Dart.

`than_audiotag` uses **TagLib 2.3.1** , a C++ library designed for reading and writing metadata in audio and media files.

The package provides a Dart-friendly API through **Dart FFI** and a native C-compatible wrapper around TagLib.

* [x] [Tag Picture Worker](#tag-picture-worker) New!
* [x] [Basic Usage New Version](#basic-usage-new-version) New!
* [x] [Tag Write Example](#tag-write-example) New!

## Features

* Read common audio metadata

  + Title
  + Artist
  + Album
  + Genre
  + Track number
  + Year
* Read audio properties

  + Duration
  + Bitrate
  + Sample rate
  + Number of channels
* Read embedded cover artwork

  + MIME type
  + Raw image bytes
* Write embedded cover artwork
* Supports common media containers handled by TagLib
* Uses Dart FFI for native performance
* Metadata and property pointers are managed by the native TagLib file object

---

## Installation

Add the package to your `pubspec.yaml` :

```yaml
dependencies:
  than_audio_tag: ^<version>

```

Then run:

```bash
dart pub get
```

or:

```bash
flutter pub get
```

> Replace `<version>` with the latest package version.

---

## Basic Usage New Version

```dart
final myTag = TTag(); //new instance

  final myTagRes = myTag.openFile(path); //Result<bool, AudioTagError>
  if (myTagRes.isErr) {
    print('Error: ${myTagRes.unwrapError()}'); //AudioTagError
    return;
  }

  final tagRes = myTag.tag; //Result<AuTag, String>
  if (tagRes.isErr) {
    myTag.close(); //free memory
    return;
  }
  final tag = tagRes.unwrap(); //AuTag
  // success
  print(tag.title);
  print(tag.album);
  print(tag.artist);
  print(tag.comment);
  print(tag.genre);
  print(tag.track);
  print(tag.year);

  final prosRes = myTag.readProperties; //Result<AuProperties, AudioTagError>
  if (prosRes.isErr) {
    myTag.close(); //free memory
    print('prosRes: ${prosRes.unwrapError()}'); //AudioTagError
    return;
  }
  final props = prosRes.unwrap(); //AuProperties

  print(props.bitrate);
  print(props.channels);
  print(props.duration);
  print(props.samplerate);

  final picRes = myTag.readPicture;
  if (picRes.isErr) {
    myTag.close(); //free memory
    print('picRes: ${picRes.unwrapError()}'); //AudioTagError
    return;
  }
  final pic = picRes.unwrap(); // AuPicture
  print(pic.pictureType);
  print(pic.mimeType);
  print(pic.description);
  print(pic.data); //Uint8List

  /// tag free
  myTag.close(); //free memory
```

### Tag Write Example

```dart
final myTag = TTag();

  final myTagRes = myTag.openFile(path); //Result<bool, AudioTagError>
  if (myTagRes.isErr) {
    print('Error: ${myTagRes.unwrapError()}'); //AudioTagError
    return;
  }

  // write tag

  //myTag.updateTagAndSave
  final updateTagRes = myTag.updateTag(
    //Result<AuTag, String>
    AuTag(
      title: title,
      artist: artist,
      album: album,
      comment: comment,
      genre: genre,
      track: track,
      year: year,
    ),
  );
  //you can save
  // myTag.save();

  myTag.removePicture(); //Result<bool, String>

  final wpdRes = myTag.writePictureData(
    // Result<bool, String>
    AuPicture(
      description: description,
      mimeType: mimeType,
      pictureType: pictureType,
      data: data,
    ),
  );
  if (wpdRes.isOk) {
    print('writed');
  }

  final wppRes = myTag.writePicturePath('[picturePath]'); //Result<bool, String>
  if (wppRes.isErr) {
    print('write error: ${wppRes.unwrapError()}');
  }

  myTag.close(); //free memory
```

## Basic Usage

Open a media file using `ThanAudioTag.open()` :

```dart
final path =
    "/home/thancoder/Videos/Black Panther Wakanda Forever (2022).mp4";

final file = ThanAudioTag.open(path);
```

### Read Metadata

```dart
print('title: ${file.tag.title}');
print('artist: ${file.tag.artist}');
print('album: ${file.tag.album}');
print('genre: ${file.tag.genre}');
print('track: ${file.tag.track}');
print('year: ${file.tag.year}');
```

Example output:

```text
title: Example Song
artist: Example Artist
album: Example Album
genre: Pop
track: 1
year: 2025
```

---

## Read Audio Properties

Audio properties can be accessed through `file.properties` :

```dart
final info = file.properties;

print('duration: ${info.duration}');
print('bitrate: ${info.bitrate}');
print('sampleRate: ${info.sampleRate}');
print('channels: ${info.channels}');
```

The returned properties include:

| Property     | Description              |
| ------------ | ------------------------ |
| `duration` | Media duration           |
| `bitrate` | Audio bitrate            |
| `sampleRate` | Audio sample rate        |
| `channels` | Number of audio channels |

For example:

```text
duration: 215
bitrate: 320
sampleRate: 44100
channels: 2
```

> The exact values and availability depend on the media format and the information provided by TagLib.

---

## Read Embedded Cover Artwork

Embedded artwork can be accessed using `file.cover` :

```dart
final cover = file.cover;

if (cover != null) {
  print('cover mimeType: ${cover.mimeType}');
  print('cover length: ${cover.data.length}');
}
```

The cover object provides:

```dart
cover.mimeType
cover.data
```

Where:

* `mimeType` is the image MIME type, such as `image/jpeg` or `image/png`.
* `data` contains the raw image bytes.

You can convert the bytes into a Dart `Uint8List` and display them directly in Flutter.

---

## Complete Example

```dart
final path =
    "/home/thancoder/Videos/Black Panther Wakanda Forever (2022).mp4";

// Open the media file.
final file = ThanAudioTag.open(path);

// Read metadata.
print('title: ${file.tag.title}');
print('artist: ${file.tag.artist}');
print('album: ${file.tag.album}');
print('genre: ${file.tag.genre}');
print('track: ${file.tag.track}');
print('year: ${file.tag.year}');

// Read audio properties.
final info = file.properties;

print('duration: ${info.duration}');
print('bitrate: ${info.bitrate}');
print('sampleRate: ${info.sampleRate}');
print('channels: ${info.channels}');

// Read embedded cover artwork.
final cover = file.cover;

if (cover != null) {
  print('cover mimeType: ${cover.mimeType}');
  print('cover length: ${cover.data.length}');
}

// Always close the native file handle when finished.
file.close();
```

---

## Writing Cover Artwork

An embedded cover can be written from raw image bytes.

```dart
final image = File('/home/thancoder/Pictures/logo.png');

ThanAudioTag.writeCoverFile(
  path,
  image.readAsBytesSync(),
  mimeType: 'image/png',
);
```

The `mimeType` should match the actual image format:

```dart
mimeType: 'image/png'
```

or:

```dart
mimeType: 'image/jpeg'
```

---

### Tag Picture Worker

```dart
class ThumbPage extends StatelessWidget {
  const ThumbPage({super.key, required this.list});
  final List<String> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thumb Page')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) => item(list[index]),
      ),
    );
  }

  Widget item(String path) {
    return FutureBuilder(
      future: TagPictureWorker.instance.getImageBytes(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        final data = snapshot.data;
        if (data != null) {
          if (data.isErr) {
            return Text('Error: ${data.unwrapError()}');
          }
          return Image.memory(data.unwrap());
        }

        return Text('Unkown Error:');
      },
    );
  }
}
```

---

## Resource Management

`ThanAudioTag.open()` creates a native TagLib file object.

Because the package uses Dart FFI, the native resource must be released when it is no longer needed.

Always call:

```dart
file.close();
```

when you finish working with the file.

For example:

```dart
final file = ThanAudioTag.open(path);

try {
  print(file.tag.title);
  print(file.properties.duration);
} finally {
  file.close();
}
```

This is especially important when processing many files.

---

## Pointer Ownership

Some objects returned by the native API are **borrowed pointers** owned by the underlying TagLib file object.

For example, audio properties returned by:

```dart
taglib_file_audioproperties(pointer);
```

must **not** be manually freed from Dart.

Their lifetime is tied to the native `TagLib::File` instance.

Conceptually:

```text
ThanAudioTag
    │
    └── TagLib::File
           │
           ├── Tag
           │
           ├── AudioProperties
           │
           └── Cover / Picture data
```

Therefore:

```dart
file.close();
```

must only be called after all required information has been read.

Do not keep using borrowed native pointers after the parent file has been closed.

---

## String Handling

Native strings are converted to Dart strings automatically.

For example:

```dart
static String _readString(ffi.Pointer<ffi.Char> pointer) {
  if (pointer == ffi.nullptr) {
    return '';
  }

  return pointer.cast<Utf8>().toDartString();
}
```

The native string is copied into a Dart `String` .

The returned Dart string does not require manual memory management.

---

## Supported Media

The actual supported formats depend on the TagLib version and enabled format support.

Typical supported formats include:

* MP3
* FLAC
* Ogg Vorbis
* Opus
* WAV
* AIFF
* MP4 / M4A
* ASF
* WavPack
* Matroska

TagLib is primarily a **metadata library** , not a full media decoding library.

It should not be considered a replacement for FFmpeg when you need:

* Video decoding
* Video frame extraction
* Thumbnail generation
* Video codec information
* FPS analysis
* Frame counting
* Video transcoding
* Audio/video playback

For those operations, a media framework such as FFmpeg is more appropriate.

---

## Video Files

Some video/container formats can expose duration or audio properties through TagLib.

For example:

```dart
final file = ThanAudioTag.open(
  '/path/to/video.mp4',
);

print(file.properties.duration);

file.close();
```

However, TagLib should primarily be used for **metadata and container-level information** .

If your application requires complete video information such as:

```text
Duration
Width
Height
FPS
Video Codec
Audio Codec
Bitrate
Frame Count
Streams
```

a dedicated media probing library such as FFmpeg is recommended.

---

## Error Handling

When working with native resources, use `try/finally` to guarantee cleanup:

```dart
final file = ThanAudioTag.open(path);

try {
  final title = file.tag.title;
  final duration = file.properties.duration;

  print(title);
  print(duration);
} finally {
  file.close();
}
```

This prevents native file handles from remaining open if an exception occurs.

---

## Architecture

The package uses a small Dart FFI layer over a native C-compatible API.

```text
Dart / Flutter
      │
      │ Dart FFI
      ▼
C-compatible TagLib wrapper
      │
      ▼
TagLib 2.3.1
      │
      ▼
Media file
```

The native wrapper exposes a stable C ABI so that Dart does not need to directly interact with C++ classes.

This keeps the Dart side simple while allowing TagLib to handle the actual media metadata parsing.

---

## Example: Reading a Music File

```dart
final file = ThanAudioTag.open(
  '/home/user/Music/song.opus',
);

try {
  print('Title: ${file.tag.title}');
  print('Artist: ${file.tag.artist}');
  print('Album: ${file.tag.album}');

  final properties = file.properties;

  print('Duration: ${properties.duration}');
  print('Bitrate: ${properties.bitrate}');
  print('Sample Rate: ${properties.sampleRate}');
  print('Channels: ${properties.channels}');

  final cover = file.cover;

  if (cover != null) {
    print('Cover: ${cover.mimeType}');
    print('Bytes: ${cover.data.length}');
  }
} finally {
  file.close();
}
```

---

## Example: Writing Cover Artwork

```dart
final image = File('/home/user/Pictures/cover.png');

ThanAudioTag.writeCoverFile(
  '/home/user/Music/song.mp3',
  image.readAsBytesSync(),
  mimeType: 'image/png',
);
```

---

## Design Goals

The main goals of `ThanAudioTag` are:

1. Keep the Dart API simple.
2. Avoid unnecessary copying of media data.
3. Keep native resource ownership explicit.
4. Provide a lightweight FFI interface.
5. Support both Dart and Flutter applications.
6. Use TagLib for metadata rather than implementing media parsers in Dart.

---

## Important Notes

`ThanAudioTag` is not a media player.

It is intended for tasks such as:

* Reading music library metadata
* Reading album artwork
* Updating tags
* Getting duration
* Scanning media libraries
* Building music managers
* Building media library applications

For media decoding, playback, transcoding, thumbnails, or detailed stream analysis, use a dedicated media framework.

### Powered by TagLib

`than_audiotag` uses **TagLib 2.3.1** , a C++ library designed for reading and writing metadata in audio and media files.

The package provides a Dart-friendly API through **Dart FFI** and a native C-compatible wrapper around TagLib.

```text
Dart / Flutter
      │
      │ Dart FFI
      ▼
than_audiotag
      │
      │ C-compatible API
      ▼
TagLib 2.3.1
      │
      ▼
Audio / Media Files
```

TagLib handles the native parsing and metadata operations, while `than_audiotag` provides a simple Dart API for applications.

This allows Dart and Flutter applications to work with features such as:

* Audio metadata
* Audio properties
* Embedded cover artwork
* Metadata writing

> `than_audiotag` uses TagLib 2.3.1 internally. TagLib is a separate third-party C++ library and is subject to its own license.

### Android Dependency

When using `than_audio_tag` on Android, you must also add the [ `android_libcpp_shared` ](https://pub.dev/packages/android_libcpp_shared) package as a dependency.

`than_audio_tag` uses native C/C++ libraries through Dart FFI. On Android, the native TagLib library depends on the Android C++ shared runtime library ( `libc++_shared.so` ).

Add both packages to your `pubspec.yaml` :

```yaml
dependencies:
  than_audio_tag: ^<version>
  android_libcpp_shared: ^<version>
```

The `android_libcpp_shared` package provides the required `libc++_shared.so` native library for Android architectures.

> **Android only:** `android_libcpp_shared` is required when using `than_audio_tag` on Android. It is not required for other platforms.

---

## License

This project is distributed under its own license.

TagLib is a separate third-party project and remains subject to its own license.

See the TagLib project documentation for details about its license and supported formats.
