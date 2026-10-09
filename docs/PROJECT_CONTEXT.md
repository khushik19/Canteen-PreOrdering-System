# Canteen Crave: Project Context (Person A)

> **Instructions for the AI assistant:** Read this whole file before doing anything.
> The developer (Person A) is a **beginner at Flutter and UI design**. Explain simply, comment the code, and go one small step at a time.

---

## 0. Rules for the AI (short version)

1. **Plan first.** Before writing code, list the files you will create or edit and wait for my OK.
2. **One screen or feature per task.** Never build the whole app in one go.
3. **Comment the code** for a Flutter beginner: say what each major widget does and why.
4. **Never hardcode colors, font sizes, spacing or radii.** Use the tokens in `core/theme/` (Section 5).
5. **Reuse shared widgets** from `import 'package:canteen_crave/src/core/widgets/widgets.dart';` (owned by Person D). If a widget you need doesn't exist yet, create a simple placeholder inside my own screen folder and tell me, and don't edit `core/widgets/`.
6. **State management is `provider`** (already in pubspec.yaml). Don't introduce Riverpod, Bloc or GetX.
7. **Mock data first.** Build every screen with hardcoded fake data (same shape as the models in Section 6), then swap in Firestore once the UI works.
8. **Stay in my lane** (Section 3). Never edit files owned by Persons B, C or D. If I need something from them, tell me what to ask them.
9. **Ask before adding a package** to `pubspec.yaml` and explain why it's needed. Prefer packages listed in Section 2.
10. **After each step**, tell me how to run and verify it, and remind me to run `flutter analyze`.
11. **If something errors**, explain the error in plain language before fixing it.
12. Small, working, committable steps. Suggest a commit message after each one.

---

## 1. What we're building

**Canteen Crave** is a food pre-ordering app for a multi-campus college. Students only get a 20-minute break, and food takes 10-25 minutes to prepare. So students order from anywhere (even during class), pay online, pick a **pickup time**, and walk in when the food is ready.

- Students: browse menu, order, pay (Razorpay), schedule pickup, get notifications.
- Vendors (canteen staff): accept or reject orders, prepare, mark ready, manage menu and stock.
- Each item has a **cooking time** set by the vendor. A student can only pick a pickup slot at least that many minutes away (the slot must respect the *longest* cooking time in the cart).
- **Flash Sale:** unclaimed orders can be sold at a discount to everyone on that campus.
- Users should **stay logged in** and receive **push notifications**. The app targets **mobile and web (PWA)**. Hosting is Cloudflare.

### Campuses

| campusId | Display name |
|---|---|
| `pimr_ug` | PIMR UG |
| `pimr_pg` | PIMR PG |
| `piemr` | PIEMR |
| `pimr_law` | PIMR Law |

Users pick a campus from a dropdown, and the menu shown is that campus's menu. Future plan: a separate dashboard per campus, so **always filter data by `campusId`**.

---

## 2. Tech stack

**Already in `pubspec.yaml`:**
`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_storage`, `razorpay_flutter`, `provider`, `intl`, `cached_network_image`, `flutter_local_notifications`, `image_picker`, `cupertino_icons`.

**Packages I'm likely to need (ask me and confirm with the team before adding):**

| Package | Why |
|---|---|
| `go_router` | Named routes, redirects for auth, bottom-nav shell (`ShellRoute`) |
| `google_fonts` | Consistent typography |
| `shared_preferences` | Remember the selected campus |
| `flutter_animate` | One-line fade and slide animations |
| `shimmer` | Skeleton loading placeholders |

Backend: **Firebase** (Auth and Firestore). Payments: Razorpay (Person B). Push: FCM (Person D).

---

## 3. Team split and MY responsibilities (Person A)

| Person | Owns |
|---|---|
| **A (me)** | Core infra, Auth, Home, Menu (browse) |
| B | Cart, Payment (Razorpay), Favourites |
| C | Entire vendor interface (menu mgmt, stock, dashboard, reports) |
| D | Flash sale, Profile and order dashboard, Notifications, shared `core/widgets/`, Meet the Team |

### What I own

- **`app/`**: `app.dart`, `routes/`, `config/`
- **`core/theme/`**: colors, typography, spacing, `ThemeData`
- **`core/network/`**: Firebase setup, shared client wrappers
- **`core/constants/`** and **`core/errors/`**
- **Auth:** `screens/auth/`, `models/user_model.dart`, `repositories/auth_repository.dart`, `services/auth_service.dart`, auth datasource
- **Home:** `screens/home/` (campus dropdown, bestsellers carousel, category grid, bottom-nav shell)
- **Menu:** `screens/menu/`, `models/menu_item_model.dart`, `models/category_model.dart`, `repositories/menu_repository.dart`, menu datasource

### What others depend on from me (keep these stable, and announce changes to the team)

1. `menu_item_model.dart` (B uses it for cart and pickup-time logic, C writes to it).
2. `AppColors`, `AppTextStyles`, `AppSpacing` (everyone).
3. Route names/paths (everyone navigates with them).
4. `auth_service.dart` exposing the current user **and role** (`student` or `vendor`).
5. The selected-campus state (a `CampusProvider`, everyone reads `campusId` from it).

### Folder structure

**This structure is a starting point, not fixed.** I may reorganize (for example move to feature-first folders). If a change touches shared paths, we must update this file and notify the team. Current plan:

```
lib/
  main.dart
  firebase_options.dart          # generated by flutterfire configure
  src/
    app/           app.dart, routes/, config/
    core/          theme/, network/, constants/, errors/, storage/, utils/, widgets/ (D)
    models/        user_model, menu_item_model, category_model, ...
    repositories/  auth_repository, menu_repository, ...
    datasources/   auth + menu remote sources
    services/      auth_service, ...
    screens/       auth/, home/, menu/, cart/, payment/, favourites/, profile/, ...
```

Each screen folder is typically: `<screen>_screen.dart` (UI), `<screen>_controller.dart` (a `ChangeNotifier`), and `widgets/` (small pieces used only there).

---

## 4. Git workflow

- Never commit to `main`. Feature branches only: `feature/core-setup`, `feature/auth-signup-signin`, `feature/home-page`, `feature/menu-page`.
- Small commits with prefixes: `feat:`, `fix:`, `style:`, `refactor:`, `docs:`.
- Open a Pull Request for each branch and get a teammate's review before merging.
- Before starting new work: `git fetch origin && git merge origin/main`.

---

## 5. Design system (single source of truth)

**Vibe:** warm, appetizing, friendly, modern (think Swiggy/Zomato-level polish, but with our own identity). Big food photos, rounded cards, soft shadows, generous whitespace.

### Tokens (put in `core/theme/`, never hardcode elsewhere)

```dart
class AppColors {
  static const primary     = Color(0xFFFF6B35); // main accent: buttons, highlights
  static const primaryDark = Color(0xFFE5541F); // pressed state
  static const background  = Color(0xFFFFF8F3); // page background
  static const surface     = Color(0xFFFFFFFF); // cards
  static const textDark    = Color(0xFF1E1E1E);
  static const textMuted   = Color(0xFF7A7A7A);
  static const success     = Color(0xFF2E9E5B);
  static const error       = Color(0xFFD64545);
}

class AppSpacing {          // multiples of 8 only
  static const xs = 4.0, s = 8.0, m = 16.0, l = 24.0, xl = 32.0;
}

class AppRadius {
  static const card = 16.0, button = 12.0, chip = 999.0;
}
```

### Rules

- **One accent color.** Orange only for primary buttons, active states and highlights.
- **One font family** via `google_fonts` (Poppins or Inter). Three text sizes: title (20-24, bold), body (14-16), caption (12).
- **Spacing:** 8, 16, 24, 32 only. Screen edge padding: 16.
- **Cards:** white surface, radius 16, soft shadow (blur about 12, 8% black opacity).
- **Touch targets** at least 48px tall. Use `InkWell`/ripples for tap feedback.
- **Images:** always `CachedNetworkImage` with a placeholder and an error fallback.
- **Support small phones** (360px wide) and web widths. Use `Expanded`, `Flexible` and `LayoutBuilder`, never fixed pixel widths for main layouts.

### Motion (subtle, fast, purposeful)

- Fade and slide-in on first load of lists (`flutter_animate`, 200-400ms).
- `Hero` animation from an item card image to its detail view.
- Shimmer skeletons instead of spinners while loading.
- `AnimatedContainer` for the selected-category highlight.
- Light haptic feedback on key taps (add to cart, select campus).

---

## 6. Data model (Firestore): I own this schema

Announce any change to Persons B and C.

```
users/{uid}
  name, phone, email, role: 'student' | 'vendor', campusId, createdAt, fcmToken?

campuses/{campusId}            // optional; constants may be enough for v1
  name

categories/{categoryId}
  name, imageUrl, sortOrder

menu_items/{itemId}
  name, description, price (number, in rupees), imageUrl,
  categoryId, campusId,
  cookingTimeMinutes (int: 5 | 10 | 15 | 20 | 25),
  isAvailable (bool), isBestseller (bool), isVeg (bool), createdAt
```

Dart models need `fromMap`/`fromFirestore`, `toMap`, and `copyWith`. Keep them dumb (no UI code). Everything is filtered by `campusId`.

**Pickup rule (used by Person B in cart):** earliest pickup = order time + the max `cookingTimeMinutes` of all items in the cart.

---

## 7. Screen specs (my screens)

### 7.1 Auth: `screens/auth/`

- **Sign Up:** name, phone (10-digit India), email, password, confirm password. Validation and inline error messages. Creates the Firebase Auth user **and** the `users/{uid}` doc (`role: 'student'` by default).
- **Sign In:** email and password, with a "Forgot password?" link (Firebase reset email).
- Loading state on buttons, friendly error messages (map Firebase error codes to human text).
- **Persistent login:** on app start, listen to `authStateChanges()`. Signed in → fetch user doc → route by `role` (student → `/home`, vendor → vendor dashboard route, which Person C provides). Signed out → `/login`.
- `AuthService` wraps `FirebaseAuth`. `AuthRepository` reads and writes Firestore. `AuthController` (`ChangeNotifier` via `provider`) exposes `currentUser`, `isLoading`, `error`.
- Phone OTP verification is **out of scope for v1** (plain phone field).

### 7.2 Home: `screens/home/`

- **Top bar:** campus dropdown (left), profile icon (right, goes to `/profile`, which is Person D's).
- Changing campus updates `CampusProvider`, persists to `shared_preferences`, and reloads menu data.
- **Bestsellers:** horizontal scrolling carousel of cards (image, name, price, cooking time chip). Source: items where `isBestseller == true` for the campus.
- **Categories:** 3×3 grid of image tiles (Sandwiches, Maggi, South Indian, Beverages, etc.). Tapping goes to `/menu?category=<categoryId>`.
- **Bottom navigation (fixed):** Home, Menu, Favs, Cart, built as a shell so the bar persists across those four tabs.
- **Footer:** "Meet The Team" button → `/team` (Person D builds the page).

### 7.3 Menu: `screens/menu/`

- **Left panel:** vertical list of categories (selected one highlighted). **Right panel:** items in the selected category (image, name, veg/non-veg dot, price, cooking time, "Add" button).
- Opening with `?category=` preselects that category.
- Unavailable items (`isAvailable == false`) show greyed out with "Unavailable" and a disabled Add button.
- "Add" calls into Person B's cart. Until B's cart exists, keep a **TODO stub**, don't build a cart yourself.

### 7.4 Routes (paths are a contract with the team)

`/login`, `/signup`, `/home`, `/menu`, `/favs`, `/cart`, `/profile`, `/team`, plus vendor routes defined by Person C (a hidden `/admin` entry is under discussion). Auth redirects are handled in the router, not inside individual screens.

---

## 8. Firebase setup notes

- The Firebase project already exists, and I'm an **Editor**.
- `lib/firebase_options.dart` is generated by `flutterfire configure`. Check whether it already exists in the repo **before** running the command, and don't re-run it if a teammate already did.
- Firebase Console needs **Authentication → Email/Password enabled** and **Firestore Database created**.
- Initialize in `main.dart`: `WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`
- Don't write production security rules yet. Keep the project in test mode for development, but remember rules must be locked down before launch (students can only edit their own `users/{uid}`, only vendors write `menu_items`).

---

## 9. Open decisions (raise with the team, don't decide alone)

1. Vendor access: the original brief wanted a separate `www.ourdomain.com/admin` login. Flutter can serve this as a role-gated route or a separate entry point. Person C and I must agree.
2. Folder structure: whether to keep layer-first (`models/`, `repositories/`) or move to feature-first.
3. `go_router` vs `Navigator 2.0` or other routing: I propose `go_router`.
4. Web/PWA: confirm Flutter web is the deployment target for students on Cloudflare.

---

## 10. Build order and task checklist

- [ ] **core-setup:** Firebase init, `AppColors`/`AppTextStyles`/`AppSpacing`/`ThemeData`, constants (campuses, collection names), router with placeholder screens, app shell
- [ ] **auth:** models, service, repository, controller, Sign Up and Sign In screens, auth-based redirect, persistent login
- [ ] **home:** bottom-nav shell, top bar with campus dropdown, bestsellers carousel, category grid (mock data)
- [ ] **menu:** category list + item list, category filtering via query param (mock data)
- [ ] Swap mock data for Firestore (`menu_repository` and datasource)
- [ ] Polish: shimmer loading, Hero transitions, empty and error states

---

## 11. Prompt templates I will use

**Start a task:**
```
Read docs/PROJECT_CONTEXT.md. Task: [one screen or feature].
Follow the rules in Section 0. First give me a file plan and wait for my OK.
Then implement with beginner-friendly comments and mock data.
```

**With a design reference:**
```
Here is a reference screenshot. Copy the layout and spacing, but use our
AppColors/AppSpacing tokens and orange palette. Don't copy their branding.
```

**When stuck:**
```
I got this exact error: [paste full error]. Explain what it means in simple
words, then fix it with the smallest possible change.
```

**Review before commit:**
```
Review my changes for: hardcoded colors or sizes, files outside my ownership,
missing loading/empty/error states, and flutter analyze warnings.
```
