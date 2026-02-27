# Daraz-Style Product Listing — Flutter

A Flutter application that mimics a Daraz-style product listing screen, built with a focus on **scroll architecture**, **gesture coordination**, and **clean separation of concerns**.

---

## 🚀 Run Instructions

```bash
# 1. Clone the repository
git clone https://github.com/Istiak-Ahmed78/daraz_clone.git
cd daraz_clone

# 2. Install dependencies
flutter pub get

# 3. Generate freezed/json files (if needed)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```


## 📱 Features

- Login with FakeStore API credentials
- Authenticated user profile shown in a side drawer
- Collapsible banner/header on scroll
- Sticky tab bar with category-based product filtering
- Shimmer loading skeleton while products fetch
- Pull-to-refresh on every tab
- Smooth horizontal tab switching via tap or swipe
- Single vertical scroll — no jitter, no conflicts

---

## 🏗️ Architecture Overview

The project follows a **feature-first folder structure** with clear separation between data, domain, presentation, and state layers — consistent with industry-standard Flutter architecture.

```
lib/
├── core/
│   ├── network/         # Dio HTTP client
│   └── theme/           # App-wide theme
└── features/
    ├── auth/
    │   ├── data/        # API calls, models
    │   ├── domain/      # Freezed domain models
    │   ├── presentation/ # Login screen
    │   └── providers/   # Riverpod auth state
    └── products/
        ├── data/        # Product repository
        ├── domain/      # Freezed product model
        ├── presentation/
        │   ├── pages/   # MainShell, HomeScreen
        │   └── widgets/ # ProductCard, ProductList, etc.
        └── providers/   # Riverpod product providers
```

---

## 1. How Horizontal Swipe Was Implemented

Horizontal navigation is handled by a **`PageView`** (inside `product_page_view.dart`) paired with a **`TabController`**.

- The `TabController` is the **single source of truth** for the current tab index
- `TabBar` listens to the controller for tap-based switching
- `PageView` listens to the same controller for swipe-based switching
- Both are kept in sync via `TabController.addListener()` and `PageController.jumpToPage()` — ensuring neither gets out of sync with the other

This approach was deliberately chosen over alternatives like `DefaultTabController` + `TabBarView` because:

- `TabBarView` internally creates its own scroll physics that can **conflict** with the outer `CustomScrollView`
- A standalone `PageView` with `NeverScrollableScrollPhysics` on the outer axis gives **explicit, predictable gesture ownership**
- The `PageView` only responds to horizontal gestures — vertical scroll is fully delegated upward to the parent `CustomScrollView`

---

## 2. Who Owns the Vertical Scroll — and Why

**The `CustomScrollView` in `HomeScreen` is the sole owner of vertical scrolling.**

This was a deliberate architectural decision. The screen is composed entirely of Slivers:

| Sliver | Role |
|---|---|
| `SliverPersistentHeader` (flexible) | Collapsible banner/header |
| `SliverPersistentHeader` (pinned) | Sticky tab bar |
| `SliverFillRemaining` | Product grid via `PageView` |

The product grid (`ProductList`) renders items using a **`Wrap` widget** — not a `ListView` or `GridView`. This is intentional: `Wrap` is not scrollable, so it never competes with the outer `CustomScrollView` for vertical scroll events.

By keeping a single `ScrollController` at the top level, the entire screen behaves as **one unified scroll surface** — which is exactly what enables:

- Pull-to-refresh from anywhere on the screen
- No scroll jitter when switching tabs
- No nested scroll conflicts
- Correct sticky/collapsible header behavior

---

## 3. Trade-offs & Limitations

### ✅ What works well
- Zero scroll conflicts — verified across tab switches, swipes, and pull-to-refresh
- Tab switching preserves the vertical scroll position (no jump-to-top)
- Clean, maintainable code with no magic numbers or global state hacks
- Riverpod's `keepAlive` caches product data per category — no redundant API calls

### ⚠️ Known Limitations
- **`Wrap` vs `GridView`**: Using `Wrap` means all products are rendered at once (no lazy loading). For a real production app with hundreds of products, a `SliverGrid` with a custom scroll coordination strategy (e.g., `NestedScrollView` with careful physics tuning) would be preferred. However, for this scope, `Wrap` provides the cleanest scroll ownership with zero risk of conflicts.
- **`NestedScrollView` was intentionally avoided**: While `NestedScrollView` is a common approach, it introduces its own set of scroll coordination bugs (especially with `PageView` and pull-to-refresh) that require fragile workarounds. The Sliver-based flat approach used here is more predictable and easier to reason about.
- **Horizontal swipe sensitivity**: On some devices, diagonal swipes near the `PageView` boundary may occasionally trigger horizontal navigation. This is a known Flutter `PageView` behavior and can be tuned via custom `ScrollPhysics` if needed.

---

## 🔐 Test Credentials

Uses [FakeStore API](https://fakestoreapi.com/) for authentication and product data.

```
Username: kminchelle
Password: 0lelplR
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `riverpod_annotation` | Code generation for providers |
| `freezed` | Immutable domain models |
| `json_serializable` | JSON serialization |
| `dio` | HTTP client |
| `shimmer` | Loading skeleton animation |

---

## 👤 Author

Built as part of a Flutter technical assessment — focusing on scroll architecture, gesture coordination, and production-quality code structure.
