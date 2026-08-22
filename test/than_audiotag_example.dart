// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print, unused_local_variable, unused_import

import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:than_audiotag/core/chatgpt_native/models/audio_tag.dart';
import 'package:than_audiotag/core/my_native/result_t.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

final lib = getTag(
  libPath:
      '/home/thancoder/projects/dart_plugins/than_audiotag/src/lib/linux-64/libtag.so',
);

void main() async {
  // final name =
  //     "《芒种》音阙诗听⧸赵方婧 官方高画质 Official HD MV丨Grain in Ear丨Mang Chủng [q2WvTaqe9zU].opus";
  final name = "Imagine dragons - BABA YAGA (Original Lyric video).mp3";
  final path = "/home/thancoder/Music/test.mp3";
  // final path =
  //     "/home/thancoder/Videos/Black Panther Wakanda Forever (2022).mp4";

  final dir = Directory('/home/thancoder/Music/New 2');
  final outDir = Directory('${dir.path}/thums');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  for (var f in dir.listSync()) {
    final name = f.path.split('/').last;
    final nameParts = name.split('.');
    nameParts.removeLast();
    final nameOnly = nameParts.join('.');
    final outpath = '${outDir.path}/$nameOnly.jpg';

    final res = await TagPictureWorker.instance.generate(f.path, outpath);
    if (res.isErr) {
      print('Error: ${res.unwrapError()} - ${nameOnly}');
    } else {
      print('Success: ${res.unwrap()}');
    }
  }
}

void testWrite(String path) {
  // final myTag = TTag();

  // final myTagRes = myTag.openFile(path); //Result<bool, AudioTagError>
  // if (myTagRes.isErr) {
  //   print('Error: ${myTagRes.unwrapError()}'); //AudioTagError
  //   return;
  // }

  // // write tag

  // //myTag.updateTagAndSave
  // final updateTagRes = myTag.updateTag(
  //   //Result<AuTag, String>
  //   AuTag(
  //     title: title,
  //     artist: artist,
  //     album: album,
  //     comment: comment,
  //     genre: genre,
  //     track: track,
  //     year: year,
  //   ),
  // );
  // //you can save
  // // myTag.save();

  // myTag.removePicture(); //Result<bool, String>

  // final wpdRes = myTag.writePictureData(
  //   // Result<bool, String>
  //   AuPicture(
  //     description: description,
  //     mimeType: mimeType,
  //     pictureType: pictureType,
  //     data: data,
  //   ),
  // );
  // if (wpdRes.isOk) {
  //   print('writed');
  // }

  // final wppRes = myTag.writePicturePath('[picturePath]'); //Result<bool, String>
  // if (wppRes.isErr) {
  //   print('write error: ${wppRes.unwrapError()}');
  // }

  // myTag.close(); //free memory
}

void testPro(String path) {
  final myTag = TTag();

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
}

void testLib(String path) {
  final p = path.toNativeUtf8();
  final f = lib.taglib_file_new(p.cast<Char>());

  if (f == nullptr) {
    print('open failed');
  }
  final valid = lib.taglib_file_is_valid(f);
  print('valid: $valid');
  if (valid > 0) {
    print('ok');
  }

  final tag = lib.taglib_file_tag(f);
  if (tag == nullptr) {
    print('tag not found!');
  }

  final title = lib.taglib_tag_title(tag).cast<Utf8>().toDartString();
  final artist = lib.taglib_tag_artist(tag).cast<Utf8>().toDartString();
  final album = lib.taglib_tag_album(tag).cast<Utf8>().toDartString();
  final comment = lib.taglib_tag_comment(tag).cast<Utf8>().toDartString();
  final genre = lib.taglib_tag_genre(tag).cast<Utf8>().toDartString();
  final track = lib.taglib_tag_track(tag);
  final year = lib.taglib_tag_year(tag);

  print('title: $title');
  print('artist: $artist');
  print('album: $album');
  print('comment: $comment');
  print('track: $track');
  print('year: $year');

  final pros = lib.taglib_file_audioproperties(f);
  if (pros != nullptr) {
    final bitrate = lib.taglib_audioproperties_bitrate(pros);
    final channels = lib.taglib_audioproperties_channels(pros);
    final length = lib.taglib_audioproperties_length(pros);
    final samplerate = lib.taglib_audioproperties_samplerate(pros);

    print('bitrate $bitrate');
    print('channels $channels');
    print('duration: $length seconds');
    print('samplerate $samplerate');

    final key = "PICTURE".toNativeUtf8();
    final pProps = lib.taglib_complex_property_get(f, key.cast<Char>());
    malloc.free(key);
    if (pProps == nullptr) {
      print('PICTURE မရှိဘူး');
      return;
    }
    final picture = calloc<TagLib_Complex_Property_Picture_Data>();
    lib.taglib_picture_from_complex_property(pProps, picture);

    final data = picture.ref.data;
    final size = picture.ref.size;
    final description = picture.ref.description.cast<Utf8>().toDartString();
    final mimeType = picture.ref.mimeType.cast<Utf8>().toDartString();
    final pictureType = picture.ref.pictureType.cast<Utf8>().toDartString();

    print('description: $description');
    print('mimeType: $mimeType');
    print('pictureType: $pictureType');

    final rawBytes = data.cast<Uint8>().asTypedList(size).toList();
    print('Cover Size: ${rawBytes.length} bytes');

    //free
    lib.taglib_complex_property_free(pProps);
    calloc.free(picture);

    File('test.jpg').writeAsBytes(rawBytes);
  }

  lib.taglib_file_free(f);
}
