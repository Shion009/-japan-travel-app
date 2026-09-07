import 'package:flutter/material.dart';
import '../models/spot.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Attraction card. The image always sits behind a dark gradient scrim
/// so the overlaid text stays readable no matter how bright the photo is —
/// this keeps the foreground content from "melting into" the background image.
class SpotCard extends StatelessWidget {
  final Spot spot;
  final String regionLabel;
  final VoidCallback onTap;

  const SpotCard({
    super.key,
    required this.spot,
    required this.regionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (spot.imageUrl != null && spot.imageUrl!.isNotEmpty)
                  Image.network(
                    spot.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.line,
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) {
                      // กรณีติดปัญหา CORS หรือ Hotlink ให้ดึงผ่าน Backend Proxy อัตโนมัติ
                      if (!spot.imageUrl!.contains('/api/proxy-image')) {
                        final proxyUrl = '${ApiService.baseUrl}/api/proxy-image?url=${Uri.encodeComponent(spot.imageUrl!)}';
                        return Image.network(
                          proxyUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => _fallbackPlaceholder(),
                        );
                      }
                      return _fallbackPlaceholder();
                    },
                  )
                else
                  _fallbackPlaceholder(),
                // Gradient scrim: guarantees text contrast regardless of photo brightness.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.65),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                // Region tag, top-left, on its own solid chip (not just text on image).
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      regionLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ai,
                      ),
                    ),
                  ),
                ),
                // Name + season, bottom, sitting on the dark scrim.
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        spot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.eco_outlined, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              spot.season,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackPlaceholder() {
    return Container(
      color: AppColors.ai.withOpacity(0.08),
      child: const Center(
        child: Icon(
          Icons.photo_camera_back_outlined,
          color: AppColors.ai,
          size: 30,
        ),
      ),
    );
  }
}
