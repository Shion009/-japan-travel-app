import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/spot.dart';
import '../services/api_service.dart';

// ── Dark theme colors (สอดคล้องกับ HomeScreen และ LoginScreen) ────────────────
const _bg1   = Color(0xFF0D0D1A);
const _bg2   = Color(0xFF1A1035);
const _bg3   = Color(0xFF0D1F3C);
const _red   = Color(0xFFE53E3E);
const _redLt = Color(0xFFFC8181);
const _purp  = Color(0xFF6B46C1);
const _matcha= Color(0xFF38A169);
const _gold  = Color(0xFFECC94B);

class DetailScreen extends StatefulWidget {
  final Spot spot;
  final String regionLabel;
  final String? categoryLabel;

  const DetailScreen({
    super.key,
    required this.spot,
    required this.regionLabel,
    this.categoryLabel,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBookmarked = false;

  Spot get spot => widget.spot;

  String get _categoryDisplayName {
    if (widget.categoryLabel != null && widget.categoryLabel!.isNotEmpty) {
      return widget.categoryLabel!;
    }
    final catMap = {
      'shrine': 'วัด-ศาลเจ้า',
      'nature': 'ธรรมชาติ',
      'castle': 'ปราสาท',
      'city': 'ย่านเมือง',
      'onsen': 'ออนเซ็น',
      'island': 'เกาะ-ชายหาด',
      'garden': 'สวน',
    };
    return catMap[spot.category] ?? spot.category;
  }

  IconData get _categoryIcon {
    switch (spot.category) {
      case 'shrine':
        return Icons.temple_buddhist_rounded;
      case 'nature':
        return Icons.landscape_rounded;
      case 'castle':
        return Icons.fort_rounded;
      case 'city':
        return Icons.location_city_rounded;
      case 'onsen':
        return Icons.hot_tub_rounded;
      case 'island':
        return Icons.beach_access_rounded;
      case 'garden':
        return Icons.park_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E36),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? _redLt : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _isBookmarked ? 'บันทึก "${spot.name}" ในรายการโปรดแล้ว' : 'นำออกจากรายการโปรดแล้ว',
              style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 13.5),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E36),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: _matcha, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'คัดลอก $label เรียบร้อยแล้ว',
                style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 13.5),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showShareModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16122C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.share_rounded, color: _redLt, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'แชร์สถานที่นี้',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        spot.name,
                        style: GoogleFonts.notoSansThai(fontSize: 13, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🇯🇵 ${spot.name} (${spot.nameJp})\n📍 ${spot.address}\n⭐ คะแนน: ${spot.rating}/5.0\n💡 จุดเด่น: ${spot.highlight}',
                      style: GoogleFonts.notoSansThai(color: Colors.white70, fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final shareText = '${spot.name} (${spot.nameJp}) - ${spot.highlight}\nที่อยู่: ${spot.address}\nการเดินทาง: ${spot.access}';
                    _copyToClipboard(shareText, 'ข้อมูลสถานที่');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text('คัดลอกข้อความแชร์', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMapModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16122C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _matcha.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.map_rounded, color: _matcha, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ตำแหน่งและแผนที่',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'พิกัด GPS: ${spot.coordinates}',
                        style: GoogleFonts.notoSansThai(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ที่อยู่ทางการ:', style: GoogleFonts.notoSansThai(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(spot.address, style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Text('การเดินทาง:', style: GoogleFonts.notoSansThai(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(spot.access, style: GoogleFonts.notoSansThai(color: Colors.white70, fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _copyToClipboard(spot.coordinates, 'พิกัด GPS');
                      },
                      icon: const Icon(Icons.gps_fixed_rounded, size: 18, color: Colors.white),
                      label: Text('คัดลอกพิกัด GPS', style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _copyToClipboard(spot.address, 'ที่อยู่');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text('คัดลอกที่อยู่', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _matcha,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      body: Stack(
        children: [
          // ── Background gradient (Dark Japanese) ───────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bg1, _bg2, _bg3],
              ),
            ),
          ),

          // ── Ambient glows ─────────────────────────────────────────────────
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_purp.withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_red.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Main Scrollable Content ───────────────────────────────────────
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 18),
                      _buildTagsRow(),
                      const SizedBox(height: 24),
                      _buildHighlightCard(),
                      const SizedBox(height: 24),
                      _buildOverviewSection(),
                      const SizedBox(height: 28),
                      _buildTravelInfoGrid(),
                      const SizedBox(height: 28),
                      _buildActivitiesSection(),
                      const SizedBox(height: 28),
                      _buildTipsSection(),
                      const SizedBox(height: 24),
                      _buildSeasonalAdviceSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Action Bar ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // ── Hero SliverAppBar ───────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 330,
      backgroundColor: const Color(0xFF120E24),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _frostedCircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: _frostedCircleButton(
            icon: Icons.share_outlined,
            onTap: _showShareModal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
          child: _frostedCircleButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            iconColor: _isBookmarked ? _redLt : Colors.white,
            onTap: _toggleBookmark,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: spot.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF1E1A33),
                child: const Center(child: CircularProgressIndicator(color: _red, strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) {
                if (spot.imageUrl != null && spot.imageUrl!.isNotEmpty && !spot.imageUrl!.contains('/api/proxy-image')) {
                  final proxyUrl = '${ApiService.baseUrl}/api/proxy-image?url=${Uri.encodeComponent(spot.imageUrl!)}';
                  return Image.network(
                    proxyUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E1A33),
                      child: const Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 50),
                    ),
                  );
                }
                return Container(
                  color: const Color(0xFF1E1A33),
                  child: const Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 50),
                );
              },
            ),
            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      _bg1.withOpacity(0.95),
                      _bg1,
                    ],
                    stops: const [0.0, 0.25, 0.55, 0.88, 1.0],
                  ),
                ),
              ),
            ),
            // Rating & Status Badges
            Positioned(
              left: 20,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _gold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: _gold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          spot.rating.toStringAsFixed(1),
                          style: GoogleFonts.notoSansThai(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _red.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: _redLt, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'จุดหมายยอดนิยม',
                          style: GoogleFonts.notoSansThai(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frostedCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // ── Title & Japanese Name ───────────────────────────────────────────────────
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              spot.nameJp,
              style: GoogleFonts.notoSerif(
                color: _gold,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          spot.name,
          style: GoogleFonts.notoSerifThai(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          spot.blurb,
          style: GoogleFonts.notoSansThai(
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ── Tags Row ────────────────────────────────────────────────────────────────
  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _infoChip(
          icon: _categoryIcon,
          label: _categoryDisplayName,
          accentColor: _purp,
        ),
        _infoChip(
          icon: Icons.location_on_rounded,
          label: widget.regionLabel,
          accentColor: _red,
        ),
        _infoChip(
          icon: Icons.wb_sunny_rounded,
          label: spot.season,
          accentColor: _matcha,
        ),
        _infoChip(
          icon: Icons.timer_outlined,
          label: spot.recommendedDuration,
          accentColor: const Color(0xFF319795),
        ),
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.notoSansThai(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Highlight Card (จุดเด่นที่ไม่ควรพลาด) ──────────────────────────────────
  Widget _buildHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _red.withOpacity(0.16),
            _purp.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _red.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: _red.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: _redLt.withOpacity(0.4)),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: _redLt, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'จุดเด่นที่ไม่ควรพลาด',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _redLt,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  spot.highlight,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview Section ────────────────────────────────────────────────────────
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'เกี่ยวกับสถานที่', icon: Icons.menu_book_rounded),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            spot.detail,
            style: GoogleFonts.notoSansThai(
              fontSize: 14.5,
              color: Colors.white.withOpacity(0.85),
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  // ── Travel Information Grid (ข้อมูลสำคัญสำหรับการท่องเที่ยว) ────────────────
  Widget _buildTravelInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'ข้อมูลสำคัญสำหรับนักท่องเที่ยว', icon: Icons.info_outline_rounded),
        const SizedBox(height: 14),
        _travelInfoItem(
          icon: Icons.access_time_rounded,
          iconColor: _gold,
          title: 'เวลาทำการ / เวลาเปิด-ปิด',
          content: spot.openingHours,
        ),
        const SizedBox(height: 10),
        _travelInfoItem(
          icon: Icons.confirmation_number_outlined,
          iconColor: _matcha,
          title: 'อัตราค่าเข้าชม',
          content: spot.fee,
        ),
        const SizedBox(height: 10),
        _travelInfoItem(
          icon: Icons.train_rounded,
          iconColor: const Color(0xFF63B3ED),
          title: 'การเดินทางและสถานีใกล้เคียง',
          content: spot.access,
        ),
        const SizedBox(height: 10),
        _travelInfoItem(
          icon: Icons.place_outlined,
          iconColor: _redLt,
          title: 'ที่ตั้ง / พิกัด',
          content: spot.address,
          trailing: IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 18),
            tooltip: 'คัดลอกที่อยู่',
            onPressed: () => _copyToClipboard(spot.address, 'ที่อยู่'),
          ),
        ),
        const SizedBox(height: 10),
        _travelInfoItem(
          icon: Icons.wb_twilight_rounded,
          iconColor: const Color(0xFFF6AD55),
          title: 'ช่วงเวลาที่แนะนำให้ไป',
          content: spot.bestTime,
        ),
      ],
    );
  }

  Widget _travelInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ── Must-Do Activities Section ──────────────────────────────────────────────
  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'กิจกรรมไฮไลท์ที่ไม่ควรพลาด', icon: Icons.checklist_rounded),
        const SizedBox(height: 14),
        ...spot.activities.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final activity = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _purp.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: _purp.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB794F4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13.5,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Tips Section (คำแนะนำสำหรับนักท่องเที่ยว) ──────────────────────────────
  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'คำแนะนำและข้อควรรู้', icon: Icons.lightbulb_outline_rounded),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tips_and_updates_rounded, color: _gold, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คำแนะนำสำหรับนักเดินทาง',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spot.tips,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13.5,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Seasonal Advice Section ─────────────────────────────────────────────────
  Widget _buildSeasonalAdviceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'ฤดูกาลและสภาพอากาศ', icon: Icons.thermostat_rounded),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _matcha.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _matcha.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _matcha.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, color: _matcha, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ฤดูท่องเที่ยวแนะนำ: ${spot.season}',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF68D391),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spot.seasonalAdvice,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13.5,
                        color: Colors.white.withOpacity(0.88),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: _redLt),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.notoSansThai(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Bottom Floating Action Bar ──────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF100D22).withOpacity(0.92),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Favorite button
          GestureDetector(
            onTap: _toggleBookmark,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isBookmarked ? _red.withOpacity(0.2) : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isBookmarked ? _red : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isBookmarked ? _redLt : Colors.white70,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Open map button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showMapModal,
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: Text(
                'ดูพิกัด & นำทาง',
                style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: _red.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
