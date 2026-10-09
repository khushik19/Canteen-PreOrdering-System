# Task: Guest Mode ("Explore as guest")

> **Read first:** `docs/RULES.md` and `docs/PROJECT_CONTEXT.md` (and `docs/AUTH_CONTEXT.md` for how auth works today).
> Branch: `feature/guest-mode`
> **Do this task BEFORE Home and Menu**, because it changes the router that they rely on.

## Plain-English summary (for me, the human)

Right now, anyone who opens the app must sign in. We want a button on the sign-in page, **"Explore as guest"**, that lets someone browse the website without an account. They can look around freely, but when they try to **do something that needs an account** (place an order, favourite an item, open their profile), a friendly pop-up asks them to log in or sign up.

**What's being built:** a small change to the existing sign-in screen, the auth controller and the router, plus one reusable "please log in" pop-up. No new pages.

---

## 1. Behavior

| Action | Guest | Logged in |
|---|---|---|
| Open Home, Menu | ✅ | ✅ |
| Switch campus | ✅ | ✅ |
| Add items to cart | ✅ (cart is Person B's, so for now a stub) | ✅ |
| Open Cart and view it | ✅ | ✅ |
| **Place order / pay (checkout)** | ❌ asks to log in | ✅ |
| Favourite (heart) an item | ❌ asks to log in | ✅ |
| Open Profile / order history | ❌ asks to log in | ✅ |
| See Favs tab | Shows "Log in to see your favourites" message | ✅ |

Why let guests add to the cart? People are far more likely to sign up at the last moment, when they already have food they want. So: **browse freely → log in only at checkout.**

Guest state is **in memory only**. Closing the tab or app returns the user to the sign-in page, where "Explore as guest" is one tap away. That's fine for v1.

---

## 2. Changes to make

### 2.1 `AuthController` (existing file in `screens/auth/`)

- Add a new status: `AuthStatus.guest` (the enum is now `unknown, unauthenticated, guest, authenticated`).
- Add:
  ```dart
  void continueAsGuest();        // sets status = guest, clears errors
  bool get isGuest;              // status == AuthStatus.guest
  bool get isLoggedIn;           // status == AuthStatus.authenticated
  ```
- `signOut()` must reset to `unauthenticated` (so a signed-out user lands on login, not guest).
- If a Firebase user appears (the person signs in or up), status becomes `authenticated`, even if they were a guest before.
- Do **not** change the public methods that Persons B, C and D already use.

### 2.2 Sign In screen (existing)

- Under the **Sign In** button, add a divider with the word **"or"**, then an **outlined/secondary button: "Explore as guest"**.
- Tapping it calls `continueAsGuest()`, and the router moves them to `/home` (no manual navigation needed if the redirect is set up right).
- Same size and shape as the other buttons. At least 48px tall. Needs a `Semantics` label.
- Don't add it to the Sign Up screen.

### 2.3 Router redirects (existing router in `app/routes/`)

Update the redirect rules like this:

```
status == unknown                                  -> '/splash'
status == unauthenticated and page is not login/signup/forgot-password -> '/login'
status == authenticated and on an auth page        -> vendor ? '/vendor' : '/home'
status == guest and on '/splash'                   -> '/home'
status == guest and on '/profile' (or any "logged-in only" page) -> stay put and let the screen show the login prompt (see 2.5)
guest is ALLOWED on: /home, /menu, /favs, /cart, /team, /login, /signup, /forgot-password
vendor-only routes: unchanged (guests are redirected to /home)
```

Keep one clear list in code: `guestAllowedPaths`. Guests visiting `/login` or `/signup` must **not** be bounced away, because they might want to sign in.

### 2.4 The reusable "please log in" helper

Create `lib/src/core/utils/auth_guard.dart`:

```dart
/// Returns true if the user is logged in and may continue.
/// If not, shows the "Log in to continue" sheet and returns false.
Future<bool> requireLogin(BuildContext context, {String? message});
```

Behavior:
- Reads `AuthController`. If `isLoggedIn`, return `true` immediately (no UI).
- Otherwise show a **modal bottom sheet**, with a **maximum width of 480** so it looks right on laptops:
  - Title: **"Log in to continue"**
  - Message: the `message` parameter, or the default "You need an account to do this."
  - Buttons: **Log in** (primary) → `context.go('/login')`, **Create account** (secondary) → `context.go('/signup')`, **Maybe later** (text button) → closes the sheet.
  - Return `false`.
- Must be keyboard-accessible and screen-reader friendly (see RULES.md Section 6).

Example uses (others will write these lines in their own screens):
```dart
if (!await requireLogin(context, message: 'Log in to place your order.')) return;
```

### 2.5 Guest-aware UI details (only the pieces I own)

- **Top bar profile icon** (Home/Menu, built in the Home task): guests see a **"Log in"** button (icon + text on laptop, icon only with tooltip on phone) instead of the profile avatar. Logged-in users see the avatar → `/profile`.
- **Guest hint:** a small, unobtrusive chip near the campus dropdown: "Browsing as guest". It disappears once they log in.
- Any place **I** build that needs an account (for example a heart button on a menu item later) must call `requireLogin`.

---

## 3. Things I must tell the team after merging

- **Person B (cart/checkout):** call `requireLogin(context, message: ...)` at the "Place order / Pay" button. Guests may fill their cart.
- **Person D (profile):** Profile screen must handle `isGuest` (show "Log in" prompt instead of crashing on a null user). Favourites tab for guests: show the login message.
- **Person C:** no change; vendor routes still need `role == 'vendor'`.

## 4. Firestore security note (for when we connect real data)

Guests are **not signed in to Firebase**, so Firestore rules that require sign-in would block them from reading the menu. When we connect Firestore, the rules should be:
- `categories` and `menu_items`: **anyone can read**; only vendors can write.
- `users/{uid}`, orders, favourites: only the signed-in owner can read/write.

(This replaces the earlier note in AUTH_CONTEXT.md that said "only authenticated users can read `menu_items`".)

---

## 5. Steps (one AI prompt each)

1. **Controller:** add `guest` status, `continueAsGuest()`, `isGuest`, `isLoggedIn`; make `signOut()` reset correctly.
2. **Router:** update redirect rules and `guestAllowedPaths`.
3. **Sign In screen:** add the "or" divider and the "Explore as guest" button.
4. **`requireLogin` helper + bottom sheet.**
5. **Test** (checklist below) and commit.

## 6. Test checklist

- [ ] Sign in page shows "Explore as guest" below Sign In; tapping it opens `/home` (placeholder is fine until Home exists)
- [ ] As a guest, typing `/login` in the browser address bar works (not bounced away)
- [ ] After signing in from guest, you land on Home as a logged-in user; the "guest" chip is gone
- [ ] Sign out → Login page (not guest mode)
- [ ] Refreshing the browser as a guest returns to Login (expected, in-memory only)
- [ ] `requireLogin` sheet: shows on phone width and laptop width; Log in / Create account / Maybe later all work; works with keyboard (Tab, Enter, Esc)
- [ ] Existing sign-up, sign-in and persistent login still work
- [ ] `flutter analyze` clean
