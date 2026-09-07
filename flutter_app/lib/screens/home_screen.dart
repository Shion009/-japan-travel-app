import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/spot.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/spot_card.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

// ── สีธีม dark (เหมือน Login) ────────────────────────────────────────────────
const _bg1   = Color(0xFF0D0D1A);
const _bg2   = Color(0xFF1A1035);
const _bg3   = Color(0xFF0D1F3C);
const _red   = Color(0xFFE53E3E);
const _redLt = Color(0xFFFC8181);
const _purp  = Color(0xFF6B46C1);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api               = ApiService();
  final _searchCtrl        = TextEditingController();
  final _regionScrollCtrl  = ScrollController();
  final _categoryScrollCtrl = ScrollController();
  Timer? _debounce;

  List<Region>       _regions    = [];
  List<SpotCategory> _categories = [];
  List<Spot>         _spots      = [];

  String? _selectedRegion;
  String? _selectedCategory;
  String  _search = '';

  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _regionScrollCtrl.dispose();
    _categoryScrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.getRegions(),
        _api.getCategories(),
        _api.getSpots(),
      ]);
      setState(() {
        _regions    = results[0] as List<Region>;
        _categories = results[1] as List<SpotCategory>;
        _spots      = results[2] as List<Spot>;
        _loading    = false;
      });
    } catch (e) {
      setState(() {
        _error   = 'เชื่อมต่อ API ไม่สำเร็จ กรุณาตรวจสอบว่าเซิร์ฟเวอร์กำลังทำงานอยู่';
        _loading = false;
      });
    }
  }

  Future<void> _refetchSpots() async {
    setState(() => _loading = true);
    try {
      final spots = await _api.getSpots(
        region:   _selectedRegion,
        category: _selectedCategory,
        search:   _search,
      );
      setState(() { _spots = spots; _loading = false; _error = null; });
    } catch (e) {
      setState(() { _error = 'เชื่อมต่อ API ไม่สำเร็จ'; _loading = false; });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search = value;
      _refetchSpots();
    });
  }

  String _regionLabel(String id) =>
      _regions.firstWhere((r) => r.id == id, orElse: () => Region(id: id, th: id, jp: '')).th;

  String _categoryLabel(String id) =>
      _categories.firstWhere((c) => c.id == id, orElse: () => SpotCategory(id: id, th: id)).th;

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      body: Stack(
        children: [
          // ── Background gradient (เหมือน Login) ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
                colors: [_bg1, _bg2, _bg3],
              ),
            ),
          ),

          // ── Decorative glowing circles ───────────────────────────────────────
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _red.withOpacity(0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -100, left: -80,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _purp.withOpacity(0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────────
          SafeArea(
            child: RefreshIndicator(
              onRefresh:   _loadAll,
              color:       _red,
              backgroundColor: const Color(0xFF1A1035),
              child: CustomScrollView(
                slivers: [
                  // AppBar
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                      child: _buildSearchField(),
                    ),
                  ),

                  // Region filter
                  SliverToBoxAdapter(child: _regionFilterRow()),

                  // Category filter
                  SliverToBoxAdapter(child: _categoryFilterRow()),

                  // Count label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                      child: Text(
                        _loading ? 'กำลังโหลด...' : 'พบ ${_spots.length} สถานที่',
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white38,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  if (_error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _errorState(),
                    )
                  else if (_loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _red,
                        ),
                      ),
                    )
                  else if (_spots.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _emptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:  2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final spot = _spots[i];
                            return SpotCard(
                              spot:        spot,
                              regionLabel: _regionLabel(spot.region),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(
                                    spot:          spot,
                                    regionLabel:   _regionLabel(spot.region),
                                    categoryLabel: _categoryLabel(spot.category),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _spots.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (AppBar แบบ custom) ───────────────────────────────────────────────

  Widget _buildHeader() {
    final user = AuthService().currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
      child: Row(
        children: [
          // Logo + Title
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [_red, _redLt],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:      _red.withOpacity(0.35),
                  blurRadius: 12,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🇯🇵 เที่ยวญี่ปุ่น',
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'ค้นหาสถานที่ท่องเที่ยว',
                style: GoogleFonts.notoSansThai(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),

          // User avatar + menu
          PopupMenuButton<String>(
            icon: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Center(
                child: Text(
                  user != null ? user.username[0].toUpperCase() : '?',
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            color: const Color(0xFF1C1C32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? '',
                      style: GoogleFonts.notoSansThai(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: _red, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'ออกจากระบบ',
                      style: GoogleFonts.notoSansThai(
                        color: _redLt,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (val) async {
              if (val == 'logout') {
                await AuthService().logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder:        (_, __, ___) => const LoginScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                  (_) => false,
                );
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── Search field ─────────────────────────────────────────────────────────────

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText:       'ค้นหาสถานที่ เช่น เกียวโต, ปราสาท...',
          hintStyle:      GoogleFonts.notoSansThai(color: Colors.white38, fontSize: 14),
          prefixIcon:     const Icon(Icons.search, color: Colors.white38, size: 20),
          filled:         false,
          border:         InputBorder.none,
          enabledBorder:  InputBorder.none,
          focusedBorder:  InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Region filter chips ──────────────────────────────────────────────────────

  Widget _regionFilterRow() {
    return SizedBox(
      height: 52,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _regionScrollCtrl.animateTo(
              (_regionScrollCtrl.offset + event.scrollDelta.dy).clamp(
                0.0, _regionScrollCtrl.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 80),
              curve:    Curves.easeOut,
            );
          }
        },
        child: ListView(
          controller:      _regionScrollCtrl,
          scrollDirection: Axis.horizontal,
          clipBehavior:    Clip.none,
          physics:         const BouncingScrollPhysics(),
          padding:         const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: [
            _darkChip(
              label:    'ทุกภูมิภาค',
              selected: _selectedRegion == null,
              onTap:    () { setState(() => _selectedRegion = null); _refetchSpots(); },
            ),
            const SizedBox(width: 8),
            ..._regions.map((r) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _darkChip(
                label:    r.th,
                selected: _selectedRegion == r.id,
                onTap:    () {
                  setState(() => _selectedRegion = _selectedRegion == r.id ? null : r.id);
                  _refetchSpots();
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Category filter chips ────────────────────────────────────────────────────

  Widget _categoryFilterRow() {
    return SizedBox(
      height: 52,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _categoryScrollCtrl.animateTo(
              (_categoryScrollCtrl.offset + event.scrollDelta.dy).clamp(
                0.0, _categoryScrollCtrl.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 80),
              curve:    Curves.easeOut,
            );
          }
        },
        child: ListView(
          controller:      _categoryScrollCtrl,
          scrollDirection: Axis.horizontal,
          clipBehavior:    Clip.none,
          physics:         const BouncingScrollPhysics(),
          padding:         const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: [
            _darkChip(
              label:    'ทุกหมวดหมู่',
              selected: _selectedCategory == null,
              accent:   _purp,
              onTap:    () { setState(() => _selectedCategory = null); _refetchSpots(); },
            ),
            const SizedBox(width: 8),
            ..._categories.map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _darkChip(
                label:    c.th,
                selected: _selectedCategory == c.id,
                accent:   _purp,
                onTap:    () {
                  setState(() => _selectedCategory = _selectedCategory == c.id ? null : c.id);
                  _refetchSpots();
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Dark-theme chip ──────────────────────────────────────────────────────────

  Widget _darkChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color accent = _red,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? accent : Colors.white.withOpacity(0.12),
          ),
          boxShadow: selected
              ? [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSansThai(
            fontSize:   12.5,
            fontWeight: FontWeight.w600,
            color:      selected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  // ── Error / empty states ──────────────────────────────────────────────────────

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red.withOpacity(0.1),
                border: Border.all(color: _red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: _redLt),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansThai(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: Text('ลองใหม่', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.search_off_rounded, size: 36, color: Colors.white38),
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่พบสถานที่ที่ตรงกับเงื่อนไข',
              style: GoogleFonts.notoSansThai(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
