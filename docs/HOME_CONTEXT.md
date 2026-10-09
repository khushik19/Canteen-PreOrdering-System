# Task: Home Page Scaffold (plus the shared app frame)

> **Read first:** `docs/RULES.md`, `docs/PROJECT_CONTEXT.md`. Branch: `feature/home-page`
> Prerequisites: core-setup, auth and guest mode are done (theme tokens, router, auth controller exist).
> **Goal of this task: see the Home page running with fake data. Not pretty, but working, responsive and clean.**

## Plain-English summary (for me, the human)

This task builds the **front door of the app**: the Home page, and the **frame around it** (the navigation bar with Home / Menu / Favs / Cart).

**What's being built, in order:**
1. The **data blueprints** (models) for categories and menu items, plus some **fake data** so we can build without Firebase.
2. The **responsive frame**: a bottom bar on phones, a side bar on laptops.
3. The **campus dropdown + top bar** (which Menu will reuse).
4. The **Home page itself**: bestsellers row, category grid, "Meet the Team" footer.

Favs, Cart, Team and Profile don't exist yet (other people are building them), so we'll put simple "Coming soon" placeholder pages there.

---

## 1. Look before you build

Before writing any code, **look at what already exists** and tell me what you found: `pubspec.yaml`, `app/app.dart`, the router file, `core/theme/`, `core/constants/` (campuses), `AuthController`.
- If a file I ask for already exists, **edit it, don't recreate it**.
- If `go_router` is not in `pubspec.yaml`, stop and tell me before continuing.

## 2. Files for this task (create or update)

```
lib/src/
  core/
    layout/breakpoints.dart           # ScreenSize enum + screenSizeOf() (see RULES.md Section 5)
    layout/centered_content.dart      # wrapper: centers child, max width 1200
    state/campus_controller.dart      # selected campus (ChangeNotifier)
    utils/formatters.dart             # rupee formatter helper
  app/
    shell/app_shell.dart              # responsive navigation frame
    routes/...                        # UPDATE: shell route with 4 tabs + /team + placeholders
  models/
    category_model.dart
    menu_item_model.dart
  datasources/mock/mock_menu_data.dart  # the fake data lives ONLY here
  repositories/menu_repository.dart     # returns mock data now, Firestore later
  screens/
    shared/campus_dropdown.dart
    shared/campus_app_bar.dart        # top bar: campus dropdown (left) + profile/login (right)
    shared/food_image.dart            # image with placeholder + error fallback
    shared/state_views.dart           # LoadingView, EmptyView, ErrorView(with Retry)
    placeholder/placeholder_screen.dart  # "Coming soon" page for Favs, Cart, Team, Profile
    home/home_screen.dart
    home/home_controller.dart
    home/widgets/bestseller_carousel.dart
    home/widgets/bestseller_card.dart
    home/widgets/category_grid.dart
    home/widgets/category_tile.dart
    home/widgets/team_footer.dart
```

Also: register `CampusController` and `HomeController` in the existing `provider` setup. Use `ChangeNotifierProxyProvider` so `HomeController` **reloads automatically when the campus changes**.
Also: in `MaterialApp.router`, set a `scrollBehavior` that allows **mouse dragging** (`PointerDeviceKind.mouse`, `touch`, `trackpad`, `stylus`) so carousels work with a mouse.

---

## 3. Models (blueprints for data)

Each needs `fromMap(Map<String, dynamic>, String id)`, `toMap()`, `copyWith()`.

```
CategoryModel:  id, name, imageUrl, sortOrder
MenuItemModel:  id, name, description, price (double, rupees), imageUrl,
                categoryId, campusId, cookingTimeMinutes (int),
                isAvailable (bool), isBestseller (bool), isVeg (bool)
```
These match the Firestore schema in PROJECT_CONTEXT.md Section 6. **Don't change field names.** Other people will rely on them.

## 4. Mock data (fake data to build with)

In `datasources/mock/mock_menu_data.dart`. Leave `imageUrl` as an **empty string** (no broken links, faster). `FoodImage` shows a neutral placeholder with a food icon when the URL is empty.

**Categories (9):** `sandwiches`, `maggi`, `south_indian`, `beverages`, `snacks`, `chinese`, `rice_biryani`, `desserts`, `combos`. Give each a display name and `sortOrder`.

**Items:** about **18 items for `pimr_ug`**, and **6-8 different items for each of the other campuses** (`pimr_pg`, `piemr`, `pimr_law`), so that switching campus visibly changes the menu. Use real canteen food and Indian rupee prices:
Chilli Cheese Garlic Maggi (₹70), Masala Maggi, Indori Sandwich (₹80), Veg Grilled Sandwich, Masala Dosa (₹90), Idli Sambar, Cold Coffee (₹60), Masala Chai (₹20), Fries (₹70), Samosa (₹20), Veg Biryani (₹120, 20 min), Chicken Biryani, Veg Hakka Noodles, Gulab Jamun, Sev Tamatar Combo (₹110).
- Cooking times must be **5, 10, 15, 20 or 25** minutes. Maggi 10, biryani 20, chai 5, etc.
- Mark **4-6 items per campus as `isBestseller`**.
- Mark **at least one item as `isAvailable: false`**, and include both veg and non-veg.

## 5. Repository (the "waiter")

`MenuRepository` exposes these methods. Screens only talk to this class, never to the mock file directly:

```dart
Future<List<CategoryModel>> getCategories();
Future<List<MenuItemModel>> getBestsellers(String campusId);
Future<List<MenuItemModel>> getItems(String campusId, {String? categoryId});
```

For now they return mock data after a **short fake delay (about 400ms)**, so the loading state is visible and properly tested. Later we replace the inside with Firestore without touching any screen.

## 6. Campus state

`CampusController` (ChangeNotifier): `String campusId`, `String campusName`, `setCampus(String id)`.
- Default: the logged-in user's `campusId` if they have one, otherwise `pimr_ug`.
- Reuse the campus constants if they already exist in `core/constants/`.
- In-memory for now. **Remembering the choice across restarts** (using `shared_preferences`) is a later optional step, so don't add that package yet.

## 7. Responsive app frame (`app/shell/app_shell.dart`)

- Use go_router's **`StatefulShellRoute.indexedStack`** with 4 tabs: **Home `/home`, Menu `/menu`, Favs `/favs`, Cart `/cart`**. (This keeps each tab's scroll position when switching.)
- **Mobile (<600):** `Scaffold` + `NavigationBar` at the bottom, labels always visible.
- **Tablet (600-1023):** `NavigationRail` on the left, labels visible.
- **Desktop (1024+):** `NavigationRail` **extended** (icon + text), content to its right.
- The page content is wrapped in `CenteredContent` (max width 1200).
- The currently selected tab is clearly highlighted; every destination has a tooltip/semantic label.
- Also add simple routes: `/team`, `/profile` → `PlaceholderScreen`. Favs and Cart tabs also show `PlaceholderScreen` (text: "Coming soon" and who owns it). Don't build them.

## 8. Shared top bar (`campus_app_bar.dart`, `campus_dropdown.dart`)

- **Left:** campus dropdown showing the current campus name, with options PIMR UG, PIMR PG, PIEMR, PIMR Law. Changing it calls `CampusController.setCampus` and the data reloads.
- **Right:** if logged in → profile icon button → `/profile`. If guest → a **"Log in"** button (text + icon on wide screens, icon with tooltip on phones) → `/login`. If guest, also show a small "Browsing as guest" chip (see GUEST_MODE_CONTEXT.md).
- The dropdown must be keyboard-usable and at least 48px tall.
- **Menu will reuse this bar**, so keep it generic.

## 9. Home page layout (`home_screen.dart`)

Use **one `CustomScrollView` with slivers** so the whole page scrolls as one lazy list (fast, no nested-scroll problems).

Top to bottom:
1. **Top bar** (shared `CampusAppBar`).
2. **Section title "Bestsellers"** + the **carousel**: horizontal scrolling cards (image area, name, price in ₹, "10 min" cooking chip, small veg/non-veg marker). Data: `getBestsellers(campusId)`.
   - Card width about 170 on phone, about 220 on laptop.
   - On **tablet/desktop** show **left/right arrow buttons** so mouse users can scroll.
   - Unavailable items aren't shown here.
3. **Section title "Categories"** + **grid of image tiles** (icon/placeholder image + name). Data: `getCategories()`.
   - **Mobile: exactly 3 columns** (so 3×3 for 9 categories). **Tablet: 4 columns. Desktop: 6 columns.**
   - Tiles are square-ish with a fixed aspect ratio. Tapping a tile goes to `context.go('/menu?category=<categoryId>')`.
4. **Footer:** a "Meet The Team" button → `/team`.

Tapping a bestseller card → `context.go('/menu?category=<its categoryId>')` for now (item details aren't designed yet).

**States:** while loading show simple grey placeholder boxes (`LoadingView`); if the list is empty show `EmptyView` ("No bestsellers on this campus yet"); on failure show `ErrorView` with a **Retry** button. Test these by temporarily making the repository throw.

**Styling:** keep it **simple and clean**. Use theme tokens only, rounded corners (`AppRadius.card`), 16px page padding, 8-multiple spacing. No fancy animation yet.

## 10. Steps (one AI prompt each, in this order)

1. **Models + mock data + repository.** (No UI yet. I can check by printing the list.)
2. **Layout helpers + responsive shell + placeholder pages + routes.** (App opens with working navigation on all sizes.)
3. **Campus controller + dropdown + top bar** (+ the mouse-drag scroll behavior).
4. **Home screen: bestsellers carousel** (with states).
5. **Home screen: category grid + footer** (with states).
6. **Test + fix** (checklist below), then commit.

Each step ends with a **Commit time** block.

## 11. Test checklist

- [ ] `flutter run -d chrome` shows Home inside the frame; the bottom bar on a narrow window and the side rail on a wide window; resizing live switches smoothly
- [ ] Campus dropdown changes the bestsellers (different items per campus)
- [ ] Bestsellers scroll with touch, mouse drag, and arrow buttons (wide screens)
- [ ] Category grid is 3 / 4 / 6 columns at mobile / tablet / desktop; tapping a tile opens `/menu?category=...` (placeholder is fine until Menu exists)
- [ ] Loading, empty and error states each seen at least once
- [ ] Guest sees the "Log in" button and chip; logged-in user sees the profile icon
- [ ] Tab key moves through everything; Enter activates; focus is visible
- [ ] No yellow/black overflow stripes at 360×640, 768×1024, 1366×768, 1920×1080, or at large text size
- [ ] `flutter analyze` clean
