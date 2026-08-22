// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

class CoverArt {
  final Uint8List data;
  final String mimeType;
  final String description;
  final String pictureType;

  const CoverArt({
    required this.data,
    this.mimeType = 'image/jpeg',
    this.description = '',
    this.pictureType = 'Front Cover',
  });

  bool get isJpeg =>
      mimeType.toLowerCase() == 'image/jpeg' ||
      mimeType.toLowerCase() == 'image/jpg';

  bool get isPng => mimeType.toLowerCase() == 'image/png';

  void saveAsPathSync(String path, {bool isOverride = false}) {
    if (data.isEmpty) return;
    final f = File(path);
    // override မဖြစ်နေပဲနဲ့ file လည်းမရှိဘူးဆိုရင်
    // တားလိုက်မယ်
    if (!isOverride && f.existsSync()) return;
    f.writeAsBytesSync(data);
  }

  Future<void> saveAsPath(String path, {bool isOverride = false}) async {
    if (data.isEmpty) return;
    final f = File(path);
    // override မဖြစ်နေပဲနဲ့ file လည်းမရှိဘူးဆိုရင်
    // တားလိုက်မယ်
    if (!isOverride && f.existsSync()) return;
    await f.writeAsBytes(data);
  }

  @override
  String toString() {
    return 'CoverArt(mimeType: $mimeType, description: $description, pictureType: $pictureType)';
  }
}
