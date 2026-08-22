// ignore_for_file: avoid_print, unused_local_variable, unused_import

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

void main() {
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

    final t = TTag();
    final res = t.openFile(f.path);
    if (res.isErr) {
      print('Error: ${res.unwrapError()} - $nameOnly');
      continue;
    }
    final pRes = t.savePicture('${outDir.path}/$nameOnly.jpg');
    if (pRes.isErr) {
      print('write: ${pRes.unwrapError()} - ${nameOnly.substring(0, 30)}');
    }

    t.close();

    print(nameOnly);
  }
}

void testPro(String path) {
  final tag = TTag();

  final tagRes = tag.openFile(path);
  if (tagRes.isErr) {
    print('Error: ${tagRes.unwrapError()}');
    return;
  }

  print(tag.tag);

  final prosRes = tag.readProperties;
  if (prosRes.isErr) {
    tag.close();
    print('prosRes: ${prosRes.unwrapError()}');
    return;
  }
  print('props: ${prosRes.unwrap()}');

  // final picRes = tag.readPicture;
  // if (picRes.isErr) {
  //   tag.close();
  //   print('picRes: ${picRes.unwrapError()}');
  //   return;
  // }
  // print('picRes: ${picRes.unwrap()}');

  // update
  // final upRes = tag.updateTagAndSave(tag.tag.copyWith(title: 'test one'));

  // if (upRes.isErr) {
  //   print('save error: ${upRes.unwrapError()}');
  // } else {
  //   print('update tag');
  // }
  final p = '/home/thancoder/Pictures/reader-logo.jpeg';
  // final pRes = tag.removePictureAndSave();
  // if (pRes.isErr) {
  //   print(pRes.unwrapError());
  // }
  final pRes = tag.savePicture('test2.png');
  if (pRes.isErr) {
    print(pRes.unwrapError());
  }
  tag.close();
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
