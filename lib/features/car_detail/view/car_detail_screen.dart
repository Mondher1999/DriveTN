import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/agency.dart';
import '../../../data/models/car.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Car detail screen — Sunset Tunisia light theme.
/// Structure adapted from Getaround mockups (dark) into our parchment palette.
class CarDetailScreen extends StatefulWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final ScrollController _scroll = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scroll.offset > 80;
    if (shouldShow != _showTitle) {
      setState(() => _showTitle = shouldShow);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  // ---------------- helpers ----------------

  Widget _circleAction(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }

  Widget _sectionDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      color: AppColors.border,
    );
  }

  Widget _sectionHeader(String text, {double size = 18}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(
        text,
        style: AppTypography.h2(size: size, weight: FontWeight.w800),
      ),
    );
  }

  Widget _stars(double rating, {double size = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating.round()
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: AppColors.accent,
          ),
      ],
    );
  }

  Widget _proPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PRO',
        style: AppTypography.caps(
          size: 9,
          letterSpacing: 1.2,
          color: AppColors.surface,
        ),
      ),
    );
  }

  Widget _inlineStat(IconData icon, String label, {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor ?? AppColors.ink),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.body(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: AppTypography.body(
          size: 14,
          weight: FontWeight.w800,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  String _quartierFromLocation(double lat, double lng) {
    // Rough mapping of mock LatLng → Tunis neighborhoods.
    if (lat > 36.87) return 'La Marsa';
    if (lng > 10.30) return 'Carthage';
    if (lng > 10.22 && lat > 36.83) return 'Les Berges du Lac';
    if (lat < 36.78) return 'Ben Arous';
    if (lng < 10.16) return 'Manouba';
    return 'Tunis Centre';
  }

  // ---------------- sections ----------------

  Widget _buildHeroSection(Car car, Agency? agency) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '${car.brand} ${car.model} (${car.year})',
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: 26,
                weight: FontWeight.w800,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.softWarm,
                backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                ),
                onBackgroundImageError: (_, __) {},
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Propriétaire : ${agency?.name ?? "DriveTN Pro"}',
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _proPill(),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _inlineStat(LucideIcons.mapPin, '550 m'),
              _dot(),
              _inlineStat(
                LucideIcons.bluetooth,
                'Sans clé',
                iconColor: AppColors.accent,
              ),
              _dot(),
              _inlineStat(LucideIcons.fuel, car.fuelLabel),
              _dot(),
              _inlineStat(LucideIcons.cog, car.transmissionLabel),
              _dot(),
              _inlineStat(LucideIcons.parkingCircle, 'Parking réservé'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(Car car) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: car.photoUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 280,
            child: CachedNetworkImage(
              imageUrl: car.photoUrls[i],
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.car,
                    size: 56,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSplit(Car car) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  car.rating.toStringAsFixed(1),
                  style: AppTypography.numeric(
                    size: 28,
                    weight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                _stars(car.rating, size: 14),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${car.reviewsCount}',
                  style: AppTypography.numeric(
                    size: 28,
                    weight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ÉVALUATIONS',
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildLocationSection(Car car) {
    final quartier = _quartierFromLocation(
      car.location.latitude,
      car.location.longitude,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dates card
          _infoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATES DE LOCATION',
                  style: AppTypography.caps(
                    size: 10,
                    letterSpacing: 1.8,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.arrowRight,
                        size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'mer 5 août à 13:00',
                      style: AppTypography.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.arrowLeft,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'mer 5 août à 14:00',
                      style: AppTypography.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Parking card with mini map
          _infoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: AbsorbPointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: car.location,
                          initialZoom: 14,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.drivetn.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: car.location,
                                width: 22,
                                height: 22,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surface,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Place de parking réservée',
                        style: AppTypography.h2(
                          size: 14,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quartier, Tunis',
                        style: AppTypography.body(
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bluetooth card
          _infoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.softWarm,
                            AppColors.softWarm.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.smartphone,
                        size: 36,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Déverrouillez avec votre smartphone',
                            style: AppTypography.h2(
                              size: 14,
                              weight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ouvrez la voiture avec l'app, les clés sont à l'intérieur.",
                            style: AppTypography.body(
                              size: 12,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'En savoir plus →',
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.accent,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _includedRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.ink),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h2(
                    size: 14,
                    weight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncluded() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _includedRow(
            LucideIcons.milestone,
            '40 km inclus',
            'Ajout de km disponible au paiement',
          ),
          _includedRow(
            LucideIcons.shield,
            'Assurance multirisque véhicule et passager',
            'Couverture complète pendant toute la location',
          ),
          _includedRow(
            LucideIcons.truck,
            'Assistance routière 24/24, 7j/7',
            'Une équipe disponible à tout moment',
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 14,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(
                size: 14,
                color: AppColors.ink,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _checkRow('Conducteurs additionnels gratuits'),
          _checkRow('Prise en charge et retour 24/7'),
          _checkRow("Prolongez facilement votre location depuis l'app"),
          _checkRow('30 minutes de marge pour les retours tardifs'),
        ],
      ),
    );
  }

  Widget _buildCancellation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.successSoft,
              AppColors.success.withValues(alpha: 0.18),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.successSoft),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.smile,
                size: 20,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annulation gratuite',
                    style: AppTypography.h2(
                      size: 14,
                      weight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Jusqu'à 48 heures avant le début de votre location",
                    style: AppTypography.body(
                      size: 12,
                      color: AppColors.success.withValues(alpha: 0.85),
                      height: 1.4,
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

  Widget _gridItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.ink),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.ink,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _subHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: AppTypography.h2(size: 14, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildAbout(Car car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _subHeader("Capacité d'accueil"),
          Row(
            children: [
              const Icon(LucideIcons.users, size: 18, color: AppColors.ink),
              const SizedBox(width: 12),
              Text(
                '${car.seats} sièges avec ceinture',
                style: AppTypography.body(
                  size: 14,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _subHeader('Caractéristiques techniques'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 12,
            children: [
              _gridItem(LucideIcons.cog, car.transmissionLabel),
              _gridItem(LucideIcons.fuel, car.fuelLabel),
              _gridItem(LucideIcons.gauge, '100-150 000 km'),
              _gridItem(LucideIcons.calendar, 'Année ${car.year}'),
            ],
          ),
          const SizedBox(height: 24),
          _subHeader('Équipements et options'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 12,
            children: [
              _gridItem(LucideIcons.bluetooth, 'Audio Bluetooth'),
              _gridItem(LucideIcons.navigation, 'GPS'),
              _gridItem(LucideIcons.snowflake, 'Climatisation'),
              _gridItem(LucideIcons.shield, 'Caméra recul'),
              _gridItem(LucideIcons.headphones, 'Entrée audio'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Car car) {
    final desc =
        "🚗✨ Location : ${car.brand} ${car.model} ${car.year}\n\n"
        "Mise en circulation en ${car.year}. Parfaitement entretenue et équipée d'une caméra de recul 📷.\n\n"
        "Caractéristiques :\n"
        "• Modèle : ${car.brand} ${car.model}\n"
        "• Année : ${car.year}\n"
        "• Boîte : ${car.transmissionLabel}\n"
        "• Carburant : ${car.fuelLabel}";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            desc,
            style: AppTypography.body(
              size: 14,
              color: AppColors.ink,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Voir plus',
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.accent,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Il est interdit de fumer dans le véhicule.',
        style: AppTypography.body(
          size: 14,
          color: AppColors.ink,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _ratingBar(String label, double pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              label,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatings(Car car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.rating.toStringAsFixed(1),
                style: AppTypography.numeric(
                  size: 36,
                  weight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 4),
              _stars(car.rating, size: 14),
              const SizedBox(height: 4),
              Text(
                '${car.reviewsCount} avis',
                style: AppTypography.body(
                  size: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _ratingBar('5', 1.0),
                _ratingBar('4', 0.12),
                _ratingBar('3', 0.0),
                _ratingBar('2', 0.08),
                _ratingBar('1', 0.04),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard({
    required String name,
    required String date,
    required int rating,
    required List<String> tags,
    required String comment,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.softWarm,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1),
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      date,
                      style: AppTypography.body(
                        size: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _stars(rating.toDouble(), size: 13),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.softWarm,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    t,
                    style: AppTypography.caps(
                      size: 9,
                      letterSpacing: 1,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _reviewCard(
            name: 'Sami B.',
            date: 'Il y a 3 jours',
            rating: 5,
            tags: const ['Propre', 'Ponctuel'],
            comment:
                'Voiture impeccable, prise en main super rapide avec le déverrouillage Bluetooth. Je recommande.',
          ),
          const SizedBox(width: 12),
          _reviewCard(
            name: 'Yasmine T.',
            date: 'Il y a 1 semaine',
            rating: 5,
            tags: const ['Fiable', 'Confort'],
            comment:
                'Service au top. Communication fluide et la caution a été libérée le jour-même.',
          ),
          const SizedBox(width: 12),
          _reviewCard(
            name: 'Karim L.',
            date: 'Il y a 2 semaines',
            rating: 4,
            tags: const ['Bon rapport'],
            comment:
                'Voiture propre, conforme aux photos. Petit retard à la prise en main mais rien de grave.',
          ),
        ],
      ),
    );
  }

  Widget _buildOwner(Car car, Agency? agency) {
    if (agency == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.softWarm,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -4,
                  child: _proPill(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              agency.name,
              style: AppTypography.h2(size: 18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stars(agency.rating, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${agency.rating}(${agency.totalRentals})',
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Locations sur DriveTN',
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${agency.totalRentals}',
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Membre depuis',
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'juin 2019',
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _insuranceMainRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.ink),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(
                size: 14,
                color: AppColors.ink,
                weight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsurance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _insuranceMainRow(
            LucideIcons.truck,
            "Tous les véhicules sont couverts par l'assistance routière",
          ),
          _insuranceMainRow(
            LucideIcons.shieldCheck,
            "Une assurance est toujours incluse quand vous louez sur DriveTN",
          ),
          const SizedBox(height: 8),
          _checkRow('Accidents'),
          _checkRow('Vol et tentative de vol'),
          _checkRow('Incendie'),
          _checkRow('Bris de glace'),
          _checkRow('Responsabilité civile'),
        ],
      ),
    );
  }

  Widget _buildInsuranceConditions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _insuranceMainRow(
            LucideIcons.creditCard,
            '18 ans et 2 ans de permis minimum.',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.globe, size: 22, color: AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rester dans les pays suivants',
                      style: AppTypography.body(
                        size: 14,
                        color: AppColors.ink,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tunisie, Algérie, Maroc, Libye…',
                      style: AppTypography.body(
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'En savoir plus →',
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.accent,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Car car) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'À PARTIR DE',
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                PriceTag(price: car.dailyPrice, size: 26, perDay: true),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Réserver',
                icon: LucideIcons.zap,
                variant: ButtonVariant.gradient,
                onPressed: () =>
                    context.push('/booking/${car.id}/eligibility'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- build ----------------

  @override
  Widget build(BuildContext context) {
    final Car? car = MockData.carById(widget.carId);
    if (car == null) {
      return const Scaffold(
        body: Center(child: Text('Voiture introuvable')),
      );
    }
    final Agency? agency = MockData.agencyById(car.agencyId);

    final List<Widget> sections = [
      _buildHeroSection(car, agency),
      const SizedBox(height: 20),
      _buildPhotoGallery(car),
      const SizedBox(height: 20),
      _buildStatsSplit(car),
      _sectionDivider(),
      _sectionHeader('Votre location'),
      _buildLocationSection(car),
      _sectionDivider(),
      _sectionHeader('Inclus dans le prix'),
      _buildIncluded(),
      _sectionDivider(),
      _sectionHeader('Les avantages à chaque location'),
      _buildAdvantages(),
      const SizedBox(height: 16),
      _buildCancellation(),
      _sectionDivider(),
      _sectionHeader('À propos de la voiture'),
      _buildAbout(car),
      _sectionDivider(),
      _sectionHeader('Description par le propriétaire'),
      _buildDescription(car),
      _sectionDivider(),
      _sectionHeader("Conditions du propriétaire", size: 16),
      _buildConditions(),
      _sectionDivider(),
      _sectionHeader('Évaluations'),
      _buildRatings(car),
      const SizedBox(height: 16),
      _buildReviews(),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Voir les ${car.reviewsCount} évaluations →',
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w800,
                color: AppColors.accent,
              ).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.accent,
              ),
            ),
          ),
        ),
      ),
      _sectionDivider(),
      _sectionHeader('À propos du propriétaire'),
      _buildOwner(car, agency),
      _sectionDivider(),
      _sectionHeader('Assurance'),
      _buildInsurance(),
      _sectionDivider(),
      _sectionHeader("Conditions de l'assurance", size: 16),
      _buildInsuranceConditions(),
      const SizedBox(height: 32),
    ];

    final List<Widget> animated = [
      for (int i = 0; i < sections.length; i++)
        sections[i].animate().fadeIn(
              delay: (i * 80).ms,
              duration: 400.ms,
            ).slideY(
              begin: 0.06,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            toolbarHeight: 64,
            leadingWidth: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
              child: _circleAction(
                LucideIcons.x,
                () => context.pop(),
              ),
            ),
            title: AnimatedOpacity(
              opacity: _showTitle ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${car.displayName} (${car.year})',
                style: AppTypography.h2(
                  size: 15,
                  weight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                child: _circleAction(
                  LucideIcons.share2,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partage — mode démo')),
                    );
                  },
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(animated),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(car),
    );
  }
}
