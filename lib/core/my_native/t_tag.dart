import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:than_audiotag/core/my_native/result_t.dart';
import 'package:than_audiotag/core/my_native/props/types.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

part 'props/au_tag.dart';
part 'props/au_properties.dart';
part 'props/au_picture.dart';
part 'tag_utils.dart';
part 'props/au_picture_writer.dart';

final _lib = getTag();

class TTag {
  bool _opened = false;
  bool get opened => _opened;

  Pointer<TagLib_File> _file = nullptr;
  Pointer<TagLib_AudioProperties> _pros = nullptr;
  Pointer<TagLib_Tag> _tagPtr = nullptr;

  late AuTag _auTag;
  Result<AuTag, String> get tag {
    try {
      return Ok(_auTag);
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// open tag
  Result<bool, AudioTagError> openFile(String path) {
    final pathPtr = path.toNativeUtf8();
    _file = _lib.taglib_file_new(pathPtr.cast<Char>());
    malloc.free(pathPtr);
    // open
    if (_file == nullptr) {
      return Err(
        .new(
          code: .fileOpenFailed,
          message:
              'file type cannot be determined or the file cannot be opened.',
        ),
      );
    }
    //valid
    if (_lib.taglib_file_is_valid(_file) == 0) {
      return Err(
        .new(
          code: .invalidFile,
          message: 'The file is not a valid or readable audio file.',
        ),
      );
    }
    // tag
    _tagPtr = _lib.taglib_file_tag(_file);
    if (_tagPtr == nullptr) {
      return Err(.new(code: .tagNotFound, message: 'audio tag not found'));
    }

    _auTag = AuTag.fromPointerTag(_tagPtr);

    _pros = _lib.taglib_file_audioproperties(_file);

    _opened = true;

    return Ok(true);
  }

  /// the audio properties associated with this file
  Result<AuProperties, AudioTagError> get readProperties {
    if (_pros == nullptr) {
      return Err(
        .new(code: .audioPropertiesNotFound, message: 'Properties Not Found!'),
      );
    }
    return Ok(AuProperties.fromPointer(_pros));
  }

  /// Read Picture
  Result<AuPicture, AudioTagError> get readPicture {
    final key = "PICTURE".toNativeUtf8();
    final pProps = _lib.taglib_complex_property_get(_file, key.cast<Char>());
    malloc.free(key);
    if (pProps == nullptr) {
      return Err(
        .new(code: .pictureNotFound, message: 'PICTURE property no found!'),
      );
    }
    final pic = AuPicture._fromPointer(pProps);
    // free
    _lib.taglib_complex_property_free(pProps);
    return Ok(pic);
  }

  /// save picture
  Result<bool, String> savePicture(String outpath, {bool isOverride = true}) {
    try {
      final f = File(outpath);
      if (isOverride == false && f.existsSync()) return Ok(true);

      final pRes = readPicture;
      if (pRes.isErr) {
        return Err(pRes.unwrapError().message);
      }
      final data = pRes.unwrap().data;
      f.writeAsBytesSync(data, flush: true);
    } catch (e) {
      Err(e.toString());
    }
    return Ok(true);
  }

  /// update tag
  Result<AuTag, String> updateTag(AuTag tag) {
    return tag.updateTag(_tagPtr);
  }

  /// update && save tag
  Result<bool, String> updateTagAndSave(AuTag tag) {
    return tag.updateTag(_tagPtr).flatMap((value) => save());
  }

  /// write Picture
  ///
  /// auto call save
  Result<bool, String> writePicturePath(
    String picturePath, {
    String mimeType = 'image/jpeg',
    String description = '',
    String pictureType = 'Front Cover',
  }) {
    try {
      final f = File(picturePath);

      final data = f.readAsBytesSync();
      return writePictureData(
        .new(
          description: description,
          mimeType: mimeType,
          pictureType: pictureType,
          data: data,
        ),
      );
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// write Picture
  ///
  /// auto call save
  Result<bool, String> writePictureData(AuPicture picture) {
    if (!opened) {
      return Err('file closed');
    }
    if (_file == nullptr) {
      return Err('file nullptr!');
    }
    return AuPictureWriter.writeAndSave(picture, _file);
  }

  /// Remove Picture
  ///
  /// auto call save
  Result<bool, String> removePicture() {
    if (!opened) {
      return Err('file closed');
    }
    if (_file == nullptr) {
      return Err('file nullptr!');
    }
    return AuPictureWriter.remove(_file).flatMap((_) => save());
  }

  /// ! Saves the \a file to disk.
  Result<bool, String> save() {
    if (_file == nullptr) {
      return Err('file closed!');
    }
    if (_file == nullptr) {
      return Err('file nullptr!');
    }
    final result = _lib.taglib_file_save(_file);

    if (result == 0) {
      return Err('Failed to save file');
    }
    return Ok(true);
  }

  /// free memory
  ///
  /// Frees and closes the file.
  void close() {
    if (_file != nullptr) {
      _lib.taglib_file_free(_file);
      _file = nullptr;
      _pros = nullptr;
      _tagPtr = nullptr;
    }
    _opened = false;
  }
}
