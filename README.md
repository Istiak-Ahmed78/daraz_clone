# Daraz-Style Product Listing — Flutter

A production-quality Flutter app demonstrating clean scroll architecture,
gesture coordination, and feature-first project structure.

---

## 🚀 Run Instructions

```bash
git clone <repo-url>
cd daraz_clone
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Demo credentials (pre-filled on login screen):**
- Username: `mor_2314`
- Password: `83r5^_`

---

## 🏗️ Architecture Decisions

### 1. How Horizontal Swipe Was Implemented

The `PageView` inside `ProductPageView` uses `NeverScrollableScrollPhysics`,
completely disabling its built-in scroll handling. A `GestureDetector` wraps
the entire widget and listens to `onHorizontalDragEnd`. Only when:

- The drag velocity exceeds **200 px/s** (intentional, not accidental)
- The gesture is primarily horizontal (handled by Flutter's gesture arena)

...does it call `pageController.animateToPage(...)` to switch tabs.

This approach gives **full control** over when a horizontal swipe triggers
a page change, preventing any conflict with vertical scrolling.

---

### 2. Who Owns the Vertical Scroll and Why

**The single `CustomScrollView` in `HomeScreen` owns ALL vertical scrolling.**

Reasoning:
- There is exactly **one `ScrollController`