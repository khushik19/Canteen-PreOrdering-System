# Task: Menu Page Scaffold

> **Read first:** `docs/RULES.md`, `docs/PROJECT_CONTEXT.md`. Branch: `feature/menu-page`
> Prerequisites: **Home task is finished**. That means the models, `MenuRepository` (mock data), `CampusController`, the responsive app shell, `CampusAppBar`, `FoodImage` and `state_views.dart` already exist. **Reuse them. Don't recreate.**
> **Goal: see the Menu page running with fake data, working and responsive. Not pretty yet.**

## Plain-English summary (for me, the human)

The Menu page is where people **browse everything the canteen sells**. It has **two parts side by side**: a list of categories on the left (Maggi, Sandwiches, ...) and the items in the chosen category on the right. Tapping a category on Home should open this page already on that category.

**What's being built, in order:**
1. A **controller** (the brain) that loads the items for the chosen category and campus.
2. The **two-panel layout**, which adapts: compact on phones, roomy on laptops.
3. The **item row/card** (name, price, veg marker, cooking time, Add button).
4. **Loading / empty / error** states and the **link from Home**.

The "Add" button can't really add to a cart yet, because the cart is Person B's job. For now it shows a small message.

---

## 1. Look before you build

Tell me what you found in: the router, `MenuRepository`, `CampusController`, `shared/` widgets, models. **Edit existing files, don't duplicate.** Name the controller **`MenuPageController`** (not `MenuController`, which clashes with a Flutter class).

## 2. Files for this task

```
lib/src/screens/menu/
  menu_screen.dart
  menu_page_controller.dart
  widgets/category_panel.dart        # left side list
  widgets/category_list_item.dart
  widgets/menu_item_tile.dart        # row layout (phone)
  widgets/menu_item_card.dart        # card layout (tablet/laptop grid)
  widgets/veg_marker.dart            # green/red square-dot symbol WITH a text/semantic label
  widgets/cooking_time_chip.dart     # "⏱ 10 min"
```
Also: **update the router** so `/menu` passes the `category` query parameter to `MenuScreen`; register `MenuPageController` with `ChangeNotifierProxyProvider` on `CampusController` so it reloads when the campus changes.

## 3. Controller: `MenuPageController`

State: `categories`, `items` (for the selected category), `selectedCategoryId`, `isLoading`, `errorMessage`.

Methods:
- `init(String? initialCategoryId)`: load categories; select `initialCategoryId` if valid, otherwise the first category; load its items.
- `selectCategory(String id)`: update the selection and load that category's items.
- `updateCampus(String campusId)`: when the campus changes, **keep the same category selected** and reload the items.
- `retry()`.

Data comes from `MenuRepository.getCategories()` and `getItems(campusId, categoryId: ...)`. No Firebase calls in the controller or screen.

## 4. Layout (`menu_screen.dart`)

**Top:** the shared `CampusAppBar`, and below it a small heading with the selected category name.

**Body: a `Row` with two panels:**

| | Mobile (<600) | Tablet (600-1023) | Desktop (1024+) |
|---|---|---|---|
| Left category panel width | about 96 (icon/image on top, name below, 2-line max) | about 180 (icon + name side by side) | about 240 |
| Right item area | single-column **list of rows** (`menu_item_tile`) | **grid** of cards, 2 columns | **grid** of cards, 3 columns (use `maxCrossAxisExtent` about 300) |

- The left panel is a **scrollable list** with the selected category clearly highlighted (accent color + bold + a visible marker, not color alone).
- The right side uses a **lazy** `ListView.builder` / `GridView.builder`. Each panel scrolls **independently**.
- Whole body wrapped in `CenteredContent` (max width 1200).
- When the selected category changes, the item area scrolls back to the top.

## 5. Item row/card contents

- `FoodImage` (fixed aspect ratio, so no layout jumping)
- **Veg marker** (green or red square symbol) with a semantic label "Vegetarian" or "Non-vegetarian"
- **Name** (2 lines max, ellipsis), short description (2 lines max)
- **Price** in rupees via the shared formatter (e.g. ₹70)
- **Cooking time chip**: "10 min". This matters to students who plan pickup time.
- **Add button** (min 48px tall). On tap, show a snackbar: "Cart is coming soon". Leave `// TODO(personB): call cart add here`. Guests are allowed to tap it.
- **Unavailable items** (`isAvailable == false`): faded look **plus a text label "Unavailable"**, and the Add button is disabled.
- The whole tile has a `Semantics` label such as "Masala Maggi, 50 rupees, vegetarian, ready in 10 minutes".

## 6. Query parameter and a tricky bug to avoid

Home sends users to `/menu?category=<id>`. **Important:** because the shell keeps each tab alive (`indexedStack`), `MenuScreen`'s `initState` does **not** run again when the user comes back from Home with a different category. So:
- Pass the query value into `MenuScreen` as `initialCategoryId`.
- Handle changes in `didUpdateWidget` (or equivalent) by calling `selectCategory`.
- Test this exactly: Home → tap "Maggi" → Menu shows Maggi → go back to Home → tap "Beverages" → Menu must now show Beverages.

When a user taps a category on the Menu itself, it's fine to update only the controller state (no need to change the URL), as long as refreshing the page doesn't crash.

## 7. States

- **Loading:** placeholder boxes (`LoadingView`), shown in the item area only. The left panel stays visible if categories are already loaded.
- **Empty:** `EmptyView`: "Nothing in this category on {campus name} yet. Try another category."
- **Error:** `ErrorView` with a friendly message and a **Retry** button.
- Test each (temporarily make the repository throw, or return an empty list).

## 8. Not now (do not build)

Search, veg-only filter, item detail page, cart logic, favourites heart, animations, shimmer, real images. They come in later iterations.

## 9. Steps (one AI prompt each, in this order)

1. **`MenuPageController`**, with a quick check by printing results.
2. **Menu screen skeleton:** two-panel layout + category panel (responsive widths), no items yet.
3. **Item widgets** (`veg_marker`, `cooking_time_chip`, `menu_item_tile`, `menu_item_card`) + show items in the right panel.
4. **States + router link from Home** (query parameter + the `didUpdateWidget` fix).
5. **Test + fix** (checklist), then commit.

Each step ends with a **Commit time** block.

## 10. Test checklist

- [ ] Menu tab opens with the first category selected and its items shown
- [ ] Tapping categories on the left changes the items on the right
- [ ] Home → category tile → Menu opens on that exact category, **including the second time with a different category** (Section 6 bug)
- [ ] Changing campus changes the items; the same category stays selected
- [ ] Phone: category panel is narrow with a single-column list. Tablet: 2-column grid. Laptop: 3+ column grid. No overflow stripes at 360×640, 768×1024, 1366×768, 1920×1080, and at large text size
- [ ] The unavailable item shows an "Unavailable" label and a disabled Add button
- [ ] Add shows the "coming soon" message for both guests and logged-in users
- [ ] Loading, empty and error states each seen at least once
- [ ] Keyboard: Tab through categories and items, Enter selects/activates; visible focus
- [ ] `flutter analyze` clean
