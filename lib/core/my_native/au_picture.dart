// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 't_tag.dart';

class AuPicture {
  final String description;
  final String mimeType;
  final String pictureType;
  final Uint8List data;
  const AuPicture({
    required this.description,
    required this.mimeType,
    required this.pictureType,
    required this.data,
  });

  factory AuPicture._fromPointer(
    Pointer<Pointer<Pointer<TagLib_Complex_Property_Attribute>>> props,
  ) {
    final picture = calloc<TagLib_Complex_Property_Picture_Data>();
    _lib.taglib_picture_from_complex_property(props, picture);

    final description = picture.ref.description.cast<Utf8>().toDartString();
    final mimeType = picture.ref.mimeType.cast<Utf8>().toDartString();
    final pictureType = picture.ref.pictureType.cast<Utf8>().toDartString();

    final data = Uint8List.fromList(
      picture.ref.data.cast<Uint8>().asTypedList(picture.ref.size),
    );

    //free
    calloc.free(picture);

    final pic = AuPicture(
      description: description,
      mimeType: mimeType,
      pictureType: pictureType,
      data: data,
    );

    return pic;
  }

  @override
  String toString() {
    return 'AuPicture(description: $description, mimeType: $mimeType, pictureType: $pictureType)';
  }
}
