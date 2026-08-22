import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

final lib = getTag();

class TagLibPicture {
  final ffi.Pointer<TagLib_File> file;
  TagLibPicture(this.file);

  CoverArt? read() {
    final keyPtr = 'PICTURE'.toNativeUtf8();
    try {
      final properties = lib.taglib_complex_property_get(file, keyPtr.cast());
      if (properties == ffi.nullptr) {
        return null;
      }
      try {
        final picture = calloc<TagLib_Complex_Property_Picture_Data>();
        try {
          lib.taglib_picture_from_complex_property(properties, picture);
          final dataPtr = picture.ref.data;
          final size = picture.ref.size;
          if (dataPtr == ffi.nullptr || size == 0) {
            return null;
          } // Native memory ကနေ Dart memory ထဲ copy.
          final data = Uint8List.fromList(
            dataPtr.cast<ffi.Uint8>().asTypedList(size),
          );
          return CoverArt(
            data: data,
            mimeType: _readString(picture.ref.mimeType),
            description: _readString(picture.ref.description),
            pictureType: _readString(picture.ref.pictureType),
          );
        } finally {
          calloc.free(picture);
        }
      } finally {
        lib.taglib_complex_property_free(properties);
      }
    } finally {
      calloc.free(keyPtr);
    }
  }

  void write(
    Uint8List imageData, {
    String mimeType = 'image/jpeg',
    String description = '',
    String pictureType = 'Front Cover',
  }) {
    if (imageData.isEmpty) {
      throw ArgumentError('imageData cannot be empty');
    }
    final keyPtr = 'PICTURE'.toNativeUtf8();
    final dataPtr = calloc<ffi.Uint8>(imageData.length);
    final mimePtr = mimeType.toNativeUtf8();
    final descriptionPtr = description.toNativeUtf8();
    final pictureTypePtr = pictureType.toNativeUtf8();
    final attrs = calloc<ffi.Pointer<TagLib_Complex_Property_Attribute>>(5);
    final dataAttr = calloc<TagLib_Complex_Property_Attribute>();
    final mimeAttr = calloc<TagLib_Complex_Property_Attribute>();
    final descriptionAttr = calloc<TagLib_Complex_Property_Attribute>();
    final pictureTypeAttr = calloc<TagLib_Complex_Property_Attribute>();
    final dataKeyPtr = 'data'.toNativeUtf8();
    final mimeKeyPtr = 'mimeType'.toNativeUtf8();
    final descriptionKeyPtr = 'description'.toNativeUtf8();
    final pictureTypeKeyPtr = 'pictureType'.toNativeUtf8();
    try {
      // Copy image bytes.
      dataPtr
          .asTypedList(imageData.length)
          .setAll(0, imageData); // NULL terminated attribute array.
      attrs[0] = dataAttr;
      attrs[1] = mimeAttr;
      attrs[2] = descriptionAttr;
      attrs[3] = pictureTypeAttr;
      attrs[4] = ffi.nullptr;
      // data
      _setByteVector(
        dataAttr,
        key: dataKeyPtr.cast(),
        data: dataPtr.cast(),
        size: imageData.length,
      ); // mimeType
      _setString(
        mimeAttr,
        key: mimeKeyPtr.cast(),
        value: mimePtr.cast(),
      ); // description
      _setString(
        descriptionAttr,
        key: descriptionKeyPtr.cast(),
        value: descriptionPtr.cast(),
      ); // pictureType
      _setString(
        pictureTypeAttr,
        key: pictureTypeKeyPtr.cast(),
        value: pictureTypePtr.cast(),
      );
      final result = lib.taglib_complex_property_set(
        file,
        keyPtr.cast(),
        attrs,
      );
      if (result == 0) {
        throw StateError('TagLib failed to set PICTURE property');
      }
    } finally {
      /* * IMPORTANT: * * TagLib has already consumed/copied the * values by the time complex_property_set() * returns. * * So our temporary native memory can now * be released. */
      calloc.free(dataKeyPtr);
      calloc.free(mimeKeyPtr);
      calloc.free(descriptionKeyPtr);
      calloc.free(pictureTypeKeyPtr);
      calloc.free(dataAttr);
      calloc.free(mimeAttr);
      calloc.free(descriptionAttr);
      calloc.free(pictureTypeAttr);
      calloc.free(attrs);
      calloc.free(dataPtr);
      calloc.free(mimePtr);
      calloc.free(descriptionPtr);
      calloc.free(pictureTypePtr);
      calloc.free(keyPtr);
    }
  }

  void remove() {
    final keyPtr = 'PICTURE'.toNativeUtf8();
    try {
      final result = lib.taglib_complex_property_set(
        file,
        keyPtr.cast(),
        ffi.nullptr,
      );
      if (result == 0) {
        throw StateError('TagLib failed to remove PICTURE property');
      }
    } finally {
      calloc.free(keyPtr);
    }
  }

  static void _setString(
    ffi.Pointer<TagLib_Complex_Property_Attribute> attribute, {
    required ffi.Pointer<ffi.Char> key,
    required ffi.Pointer<ffi.Char> value,
  }) {
    attribute.ref.key = key;
    attribute.ref.value.type = TagLib_Variant_Type.TagLib_Variant_String;
    attribute.ref.value.size = 0;
    attribute.ref.value.value.stringValue = value;
  }

  static void _setByteVector(
    ffi.Pointer<TagLib_Complex_Property_Attribute> attribute, {
    required ffi.Pointer<ffi.Char> key,
    required ffi.Pointer<ffi.Char> data,
    required int size,
  }) {
    attribute.ref.key = key;
    attribute.ref.value.type = TagLib_Variant_Type.TagLib_Variant_ByteVector;
    attribute.ref.value.size = size;
    attribute.ref.value.value.byteVectorValue = data;
  }

  static String _readString(ffi.Pointer<ffi.Char> pointer) {
    if (pointer == ffi.nullptr) {
      return '';
    }
    return pointer.cast<Utf8>().toDartString();
  }
}
