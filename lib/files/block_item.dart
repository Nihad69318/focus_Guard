import 'package:flutter/material.dart';

enum BlockKind {
  /// Whole app is blocked by package name (works now).
  wholeApp,

  /// Part of an app (Reels, Shorts, search) or websites. Needs extra work.
  feature,
}

class BlockItem {
  const BlockItem({
    required this.id,
    required this.title,
    required this.icon,
    this.iconColor = Colors.white,
    this.packages = const [],
    this.featureKey,
    this.kind = BlockKind.wholeApp,
    this.isFree = true,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> packages;

  /// Key of a screen-level rule on the Android side (see FeatureRules in
  /// BlockerAccessibilityService.kt). Used for Reels / Shorts.
  final String? featureKey;
  final BlockKind kind;
  final bool isFree;

  /// Supported = whole-app (has packages) OR has a Reels/Shorts rule.
  bool get isSupported => packages.isNotEmpty || featureKey != null;
}

const List<BlockItem> blockItems = [
  BlockItem(
    id: 'facebook',
    title: 'Facebook',
    icon: Icons.public,
    packages: ['com.facebook.katana', 'com.facebook.lite'],
  ),
  BlockItem(
    id: 'facebook_reels',
    title: 'Facebook Reels',
    icon: Icons.facebook,
    featureKey: 'facebook_reels',
    kind: BlockKind.feature,
  ),
  BlockItem(
    id: 'youtube',
    title: 'YouTube',
    icon: Icons.smart_display,
    packages: ['com.google.android.youtube'],
  ),
  BlockItem(
    id: 'youtube_shorts',
    title: 'YouTube Shorts',
    icon: Icons.smart_display,
    featureKey: 'youtube_shorts',
    kind: BlockKind.feature,
  ),
  BlockItem(
    id: 'instagram',
    title: 'Instagram',
    icon: Icons.camera_alt,
    packages: ['com.instagram.android'],
  ),
  BlockItem(
    id: 'instagram_reels',
    title: 'Instagram Reels',
    icon: Icons.camera_alt,
    featureKey: 'instagram_reels',
    kind: BlockKind.feature,
  ),
  BlockItem(
    id: 'telegram',
    title: 'Telegram',
    icon: Icons.telegram,
    packages: ['org.telegram.messenger', 'org.telegram.messenger.web'],
  ),
  BlockItem(
    id: 'telegram_search',
    title: 'Telegram Search',
    icon: Icons.search,
    featureKey: 'telegram_search',
    kind: BlockKind.feature,
  ),
  BlockItem(
    id: 'adult_site',
    title: 'Adult Site',
    icon: Icons.no_adult_content,
    iconColor: Colors.red,
    featureKey: 'adult_site',
    kind: BlockKind.feature,
  ),
];