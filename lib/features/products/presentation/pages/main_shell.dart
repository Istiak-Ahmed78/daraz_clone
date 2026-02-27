import 'package:daraz_clone/features/products/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

/// Tracks which bottom nav tab is active.
final _shellIndexProvider = StateProvider<int>((ref) => 0);

/// [MainShell] is the root scaffold that holds:
///   • [BottomNavigationBar] — persistent across all tabs
///   • [IndexedStack]        — keeps each tab's state alive (no rebuild on switch)
///
/// NAVIGATION STRUCTURE
/// ─────────────────────
///   0 → Home      (ProductsHomeScreen with collapsible header)
///   1 → Cart      (placeholder — extend later)
///   2 → Wishlist  (placeholder — extend later)
///   3 → Profile   (placeholder — extend later)
///
/// WHY IndexedStack?
/// ──────────────────
/// Unlike Navigator.push, IndexedStack keeps all tab widgets mounted.
/// This means the scroll position, loaded products, and active tab index
/// in HomeScreen are preserved when switching between bottom nav tabs.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_shellIndexProvider);

    return Scaffold(
      // ── Body: IndexedStack keeps all tabs alive ───────────────────
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(), // tab 0
            _PlaceholderTab(label: 'Cart', icon: Icons.shopping_cart_outlined),
            _PlaceholderTab(label: 'Wishlist', icon: Icons.favorite_border),
            _PlaceholderTab(label: 'Profile', icon: Icons.person_outline),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(_shellIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surface,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Generic placeholder for tabs not yet implemented.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              '$label — Coming Soon',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
