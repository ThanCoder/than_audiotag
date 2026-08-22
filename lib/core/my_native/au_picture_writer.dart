part of 't_tag.dart';

class AuPictureWriter {
  static Result<bool, String> writeAndSave(
    AuPicture picture,
    Pointer<TagLib_File> file,
  ) {
    final keyPtr = 'PICTURE'.toNativeUtf8();
    final dataPtr = calloc<Uint8>(picture.data.length);

    final mimePtr = picture.mimeType.toNativeUtf8();
    final descriptionPtr = picture.description.toNativeUtf8();
    final pictureTypePtr = picture.pictureType.toNativeUtf8();

    // native mem ပြောင်းလဲရမယ်
    final dataAttr = calloc<TagLib_Complex_Property_Attribute>();
    final mimeAttr = calloc<TagLib_Complex_Property_Attribute>();
    final descriptionAttr = calloc<TagLib_Complex_Property_Attribute>();
    final pictureTypeAttr = calloc<TagLib_Complex_Property_Attribute>();

    // ဒါက key တွေ
    final dataKey = 'data'.toNativeUtf8();
    final mimeKey = 'mimeType'.toNativeUtf8();
    final descriptionKey = 'description'.toNativeUtf8();
    final pictureTypeKey = 'pictureType'.toNativeUtf8();

    final attrs = calloc<Pointer<TagLib_Complex_Property_Attribute>>(5);

    try {
      dataPtr.asTypedList(picture.data.length).setAll(0, picture.data);

      // set key
      dataAttr.ref.key = dataKey.cast<Char>();
      mimeAttr.ref.key = mimeKey.cast<Char>();
      descriptionAttr.ref.key = descriptionKey.cast<Char>();
      pictureTypeAttr.ref.key = pictureTypeKey.cast<Char>();

      // image data
      dataAttr.ref.value.type = .TagLib_Variant_ByteVector;
      dataAttr.ref.value.size = picture.data.length;
      dataAttr.ref.value.value.byteVectorValue = dataPtr.cast<Char>();

      // mime
      mimeAttr.ref.value.type = .TagLib_Variant_String;
      mimeAttr.ref.value.size = 0;
      mimeAttr.ref.value.value.stringValue = mimePtr.cast<Char>();

      // desc
      descriptionAttr.ref.value.type = .TagLib_Variant_String;
      descriptionAttr.ref.value.size = 0;
      descriptionAttr.ref.value.value.stringValue = descriptionPtr.cast<Char>();

      pictureTypeAttr.ref.value.type = .TagLib_Variant_String;
      pictureTypeAttr.ref.value.size = 0;
      pictureTypeAttr.ref.value.value.stringValue = pictureTypePtr.cast<Char>();

      attrs[0] = dataAttr;
      attrs[1] = mimeAttr;
      attrs[2] = descriptionAttr;
      attrs[3] = pictureTypeAttr;
      attrs[4] = nullptr;

      final result = _lib.taglib_complex_property_set(
        file,
        keyPtr.cast<Char>(),
        attrs,
      );

      if (result == 0) {
        //error
        return Err('failed to set picture');
      }
      // save
      final saveRes = _lib.taglib_file_save(file);
      if (saveRes == 0) {
        return Err('Failed to save file');
      }

      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    } finally {
      //free
      malloc.free(keyPtr);
      calloc.free(dataPtr);

      malloc.free(mimePtr);
      malloc.free(descriptionPtr);
      malloc.free(pictureTypePtr);
      // keys
      malloc.free(dataKey);
      malloc.free(mimeKey);
      malloc.free(descriptionKey);
      malloc.free(pictureTypeKey);
      //attrs
      calloc.free(dataAttr);
      calloc.free(mimeAttr);
      calloc.free(descriptionAttr);
      calloc.free(pictureTypeAttr);

      calloc.free(attrs);
    }
  }

  static Result<bool, String> remove(Pointer<TagLib_File> file) {
    final keyPtr = 'PICTURE'.toNativeUtf8();
    final result = _lib.taglib_complex_property_set(
      file,
      keyPtr.cast(),
      nullptr,
    );
    //free
    malloc.free(keyPtr);

    if (result == 0) {
      return Err('TagLib failed to remove PICTURE property');
    }
    return Ok(true);
  }
}
