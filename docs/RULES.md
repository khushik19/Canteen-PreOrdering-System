# Canteen Crave: Working Rules (read this first, every new chat)

> Works with any AI model (Gemini, Claude, etc.). Paste or attach this file **once at the start of each new chat**, together with `docs/PROJECT_CONTEXT.md` and the context file for the current task.
> These rules **add to** PROJECT_CONTEXT.md. If the two ever disagree, ask me which one wins.

---

## 1. How you must talk to me (I'm a beginner)

1. **Start every reply with one line:** `Now building: <what> (<which task>)`. Example: `Now building: the responsive bottom/side navigation (Home task, step 2 of 5)`.
2. Use **very simple language**. No jargon without a one-line explanation. Use small analogies when helpful.
3. Give **numbered steps**. For each step say: **what** we're doing, **why** it's needed, and **which file**.
4. After the code, tell me **how to check it worked**: the exact command to run, and what I should *see* on screen.
5. If something might confuse a beginner (a Flutter word like `Provider`, `Consumer`, `async`), explain it in **one sentence** the first time.
6. Don't lecture. Keep explanations short and the steps concrete.
7. If you need to ask me something, ask **at most 2 questions**, and only if you're truly blocked. Otherwise state your assumption in one line and continue.

## 2. How you must deliver code

1. **Put the full file path above every code block**, like `lib/src/screens/home/home_screen.dart`.
2. For **new files and files under ~150 lines: give the complete file** so I can copy and paste it whole.
3. For edits to bigger files: show the **complete changed widget or method** plus 2-3 lines around it, and say exactly where it goes ("replace the `build` method").
4. **Never** give "... rest of your code here" placeholders. Never remove my existing code silently.
5. Before writing code, **look at the files that already exist** (theme, router, constants, models) and reuse them. Don't recreate things. Tell me which existing files you looked at.
6. Tell me **every terminal command** to run (for example `flutter pub get`) and when.
7. End each finished step with a **"Commit time"** block: the exact `git add .` / `git commit -m "..."` commands with a good message.
8. Don't repeat code I already have, and don't re-explain the whole project each time.

## 3. Token-saving rules (I'm on a free tier)

- One step at a time. Do **only** the step I name. Don't "helpfully" build the next screen.
- Don't paste long summaries of what you just did. Two or three lines is enough.
- If a task needs more than ~6 files, tell me and propose splitting it into smaller steps.
- If you're unsure of a Flutter API, say so rather than guessing. Check `pubspec.yaml` for the package version.
- When fixing an error, change the **smallest possible thing** and explain it in 2-3 sentences.

## 4. Scope and ownership

- I'm **Person A**: core, auth, home, menu. Never edit files that belong to Persons B (cart, payment, favourites), C (vendor) or D (flash sale, profile, notifications, `core/widgets/`).
- If I need something from them, **leave a stub and a comment** like `// TODO(personB): replace with real cart call` and tell me what to ask them.
- **No new packages** without asking me first, and tell me *why* it's needed. Preferred list is in PROJECT_CONTEXT.md.
- State management is **`provider`**. Don't introduce another one.
- Build with **mock data first**. Firestore comes later, after the screen works.
- Don't redesign. Use the tokens in `core/theme/` and keep visuals **simple and clean**. I'll polish later. Functionality, layout and responsiveness come first.

---

## 5. Responsive design (REQUIRED: phone, tablet and laptop)

The website must work on every screen from a small phone to a wide laptop monitor.

### Breakpoints (define once in `core/layout/breakpoints.dart`, never repeat the numbers)

| Name | Width | Typical device |
|---|---|---|
| mobile | under 600 | phones |
| tablet | 600 to 1023 | tablets, small windows |
| desktop | 1024 and up | laptops, monitors |

```dart
enum ScreenSize { mobile, tablet, desktop }
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double maxContentWidth = 1200; // content never gets wider than this
}
ScreenSize screenSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;   // use .sizeOf, not .of(context).size
  if (w < Breakpoints.mobile) return ScreenSize.mobile;
  if (w < Breakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.desktop;
}
```

### Rules

1. **Never** give main layouts fixed pixel widths (`Container(width: 300)`). Use `Expanded`, `Flexible`, `Wrap`, `LayoutBuilder`, `ConstrainedBox(maxWidth)`.
2. On wide screens, **center the content with a max width of 1200** (`CenteredContent` wrapper). Text lines stretching across a 1920px monitor look broken.
3. **Navigation changes by size:** phone → bottom navigation bar; tablet/desktop → side navigation rail (extended with labels on desktop).
4. **Grids adapt:** use `crossAxisCount` or `maxCrossAxisExtent` based on screen size. Don't hardcode one column count for all sizes (except where the spec says so, such as the mobile 3×3 category grid).
5. Use `SafeArea`, and make forms scrollable so the keyboard never causes an overflow error.
6. Text must **never overflow**: use `maxLines` + `overflow: TextOverflow.ellipsis`, or let it wrap. Don't give text-holding boxes a fixed height.
7. **Laptop specifics:**
   - Mouse users can't swipe. Horizontal lists need **mouse-drag enabled** (custom `ScrollBehavior` with `PointerDeviceKind.mouse`) **and left/right arrow buttons** on desktop.
   - Show a hover effect and the pointer cursor on clickable cards (`InkWell` does most of this).
   - Everything must work with **keyboard only** (Tab, Enter, Space) with a visible focus highlight.
   - Use a `Scrollbar` on long scrollable areas on desktop.
8. **Test these sizes** before calling any screen done: 360×640 (small phone), 412×915 (phone), 768×1024 (tablet), 1366×768 (laptop), 1920×1080 (large monitor). Also with the OS text size set to large (text scale 1.3). Live-resize the Chrome window to check nothing breaks in between.

---

## 6. Accessibility (REQUIRED)

1. **Touch targets at least 48×48.** Icon buttons need a `tooltip` or a `Semantics` label.
2. **Contrast:** normal text needs at least 4.5:1 against its background. **Heads-up:** white text on our orange `#FF6B35` is only about 2.8:1 (fails). For text on orange, use dark text (`textDark`), or use a deeper orange such as `#C2410C` (about 5:1 with white) for button backgrounds. Flag this to me if a screen uses white-on-orange.
3. **Never use color alone to carry meaning.** The veg/non-veg dot must also have a semantic label ("Vegetarian" / "Non-vegetarian"). "Unavailable" must be text, not just greyed out.
4. **Images:** give meaningful ones a `semanticLabel` (the item name); mark purely decorative ones with `excludeFromSemantics: true`.
5. **Forms:** use real `labelText`, not just hints (hints disappear). Error messages are text under the field.
6. **Text scaling:** layouts must survive 130-150% font size. No fixed-height text containers.
7. **Keyboard/focus:** logical Tab order; every interactive element reachable and activatable by keyboard.
8. Respect reduced-motion: keep animations short (under 400ms) and optional-feeling. Nothing should flash.
9. Use plain, short, friendly language in every label and message.

---

## 7. Performance (the site must load fast)

1. Use **`const`** constructors wherever possible.
2. Long lists/grids **must be lazy**: `ListView.builder`, `GridView.builder`, or slivers (`CustomScrollView`). Never build 100 widgets up front.
3. **Never do heavy work or fetch data inside `build()`**. Load in the controller (`initState` or an `init()`/`load()` method).
4. Rebuild as little as possible: use `context.select`, `Selector`, or small `Consumer`s, not one giant `watch` at the top of a screen.
5. **Images:** use `CachedNetworkImage`, give every image a **fixed aspect ratio** (so the layout doesn't jump), and set `memCacheWidth`. Vendors should upload compressed images (under about 150 KB, max about 800px wide).
6. Use at most **2 font weights** from `google_fonts` (regular + semi-bold) to keep downloads small.
7. **Firestore:** only fetch the current campus's data; use `limit()` on lists; use one-time `get()` for the menu (it rarely changes) and live listeners only where live updates matter (orders).
8. **Judging speed:** a Flutter *debug* run feels slow. Judge real performance with `flutter run -d chrome --release` (or `--profile`).
9. Show **skeleton/placeholder boxes** while loading so the page feels instant.

---

## 8. User-friendliness rules

1. **Every screen that loads data handles 3 states:** loading, empty ("Nothing here yet" with a helpful message), and error (friendly text + **Retry** button).
2. **Tap feedback within 100ms:** ripple, snackbar or visual change on every tap.
3. **Ordering path is short:** from Home to adding an item should take **3 taps or fewer**.
4. Bottom/side navigation **always shows text labels**, not just icons.
5. The **selected campus is always visible** on Home and Menu.
6. Money format: `NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)` from `intl`. Put it in one helper.
7. **No dead ends:** every screen has a clear way back or home.
8. **Web behaves like a website:** every page has its own URL, the browser Back button works, and refreshing keeps you on the same page.
9. **Guests can browse; ordering needs login.** Details in `GUEST_MODE_CONTEXT.md`.
10. Friendly, human error messages. Never show raw exception text.

---

## 9. Code quality (Flutter/Dart)

1. Files: `snake_case.dart`. Classes: `PascalCase`. Variables and functions: `camelCase`.
2. Keep each file under about **250 lines**. Split big screens into small widget files in a `widgets/` folder.
3. **No business logic in widgets.** Widgets show things; controllers and repositories do things.
4. After any `await`, before using `context`: `if (!context.mounted) return;`
5. Avoid the `!` null operator unless you're sure. Handle nulls properly.
6. Use `debugPrint`, never `print`. Remove commented-out junk.
7. TODO format: `// TODO(personB): what needs doing`.
8. Run `dart format .` and `flutter analyze`. **Zero new warnings.**
9. Don't name a class `MenuController`. Flutter already has one, and it clashes. Use `MenuPageController`.

### Modern Flutter: avoid these old APIs (the AI often suggests them by mistake)

| Old (deprecated) | Use instead |
|---|---|
| `color.withOpacity(0.5)` | `color.withValues(alpha: 0.5)` |
| `MaterialStateProperty` | `WidgetStateProperty` |
| `WillPopScope` | `PopScope` |
| `textScaleFactor` | `textScaler` |
| `ColorScheme.background` / `onBackground` | `surface` / `onSurface` |
| `CardTheme` / `DialogTheme` in `ThemeData` | `CardThemeData` / `DialogThemeData` |
| `MediaQuery.of(context).size` | `MediaQuery.sizeOf(context)` |

If unsure whether an API exists in our Flutter version, say so.

---

## 10. Definition of done (a task is finished only when ALL are true)

- [ ] App runs with `flutter run -d chrome` with no red errors
- [ ] `flutter analyze` shows no new warnings
- [ ] Looks right at all 5 test sizes (Section 5.8) and with large text
- [ ] Loading, empty and error states exist (if the screen loads data)
- [ ] Keyboard-only navigation works; icon buttons have labels/tooltips
- [ ] No hardcoded colors/spacing; no files edited outside my ownership
- [ ] Guest and logged-in behavior checked (if the screen is affected)
- [ ] Committed with a clear message and pushed
