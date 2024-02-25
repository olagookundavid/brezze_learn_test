import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CachedImageHelper extends StatelessWidget {
  const CachedImageHelper({
    super.key,
    required this.url,
  });
  final String url;

  @override
  Widget build(BuildContext context) {
    return FastCachedImage(
      url: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(seconds: 1),
      errorBuilder: (context, exception, stacktrace) {
        return Stack(
          children: [
            Image.asset('lib/assets/images/placeholderimage.png',
                fit: BoxFit.fill),
            Center(
                child: Text(
              url.isEmpty
                  ? 'Please tap to \nchoose an image'
                  : 'Couldn\'t load image',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ))
          ],
        );
      },
      loadingBuilder: (context, progress) {
        debugPrint(
            'Progress: ${progress.isDownloading} ${progress.downloadedBytes} / ${progress.totalBytes}');
        return Stack(
          alignment: Alignment.center,
          children: [
            if (progress.isDownloading && progress.totalBytes != null)
              Text(
                  '${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb',
                  style: const TextStyle(color: Colors.black)),
            CircularProgressIndicator(
                color: Colors.blue, value: progress.progressPercentage.value),
          ],
        );
      },
    );
  }
}
