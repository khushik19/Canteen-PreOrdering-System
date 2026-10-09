# Canteen Crave: Auth Feature Context (Person A)

> **Instructions for the AI assistant:** This file covers ONLY the authentication feature.
> First read `docs/PROJECT_CONTEXT.md` for the general rules, design tokens and team split. Those rules apply here too.
> The developer is a **beginner at Flutter**. Explain simply, comment the code, one small step at a time, and **give a file plan and wait for my OK before writing code**.

Branch: `feature/auth-signup-signin`
Prerequisite: `feature/core-setup` is merged (or at least Firebase is initialized and `AppColors`/`AppSpacing`/`AppRadius` exist).

---

## 1. Goal

Let a student **sign up, sign in, reset a forgotten password, stay logged in across app restarts**, and let the rest of the app know **who is logged in and whether they are a `student` or a `vendor`**.

### In scope (v1)
- Email and password sign up (with name and phone collected as profile fields)
- Email and password sign in
- Forgot password (Firebase reset email)
- Sign out (exposed as a method; Person D's Profile screen will call it)
- Persistent login and role-based redirect
- `users/{uid}` Firestore document created on sign up

### Out of scope (v1). Do NOT build
- Phone OTP verification (the phone is a plain validated field)
- Google or social sign-in
- Email-verification gating
- Vendor sign-up UI. Vendors are created manually (see Section 8). Person C owns `screens/vendor_auth/`
- Edit Profile (Person D)

---

## 2. Who depends on this

| Consumer | Needs from auth |
|---|---|
| Router (me) | Is the user signed in? What's their role? Still loading? |
| Person B (cart/orders) | `uid`, `name`, `phone` to attach to orders |
| Person C (vendor) | `role == 'vendor'` to gate vendor routes |
| Person D (profile, notifications) | `currentUser`, `signOut()`, writes `fcmToken` into `users/{uid}` |

So **keep the public surface small and stable** (Section 5). Announce changes to the team.

---

## 3. Files to create (inside `lib/src/`)

```
models/user_model.dart
datasources/auth_remote_datasource.dart     # raw FirebaseAuth + Firestore calls
services/auth_service.dart                  # thin wrapper around FirebaseAuth
repositories/auth_repository.dart           # combines service + datasource, returns UserModel
screens/auth/
  auth_controller.dart                      # ChangeNotifier (provider), UI-facing state
  sign_in_screen.dart
  sign_up_screen.dart
  forgot_password_screen.dart
  widgets/
    auth_text_field.dart                    # styled TextFormField (use shared widget if D has one)
    auth_header.dart                        # logo + title + subtitle
    password_field.dart                     # show/hide toggle
core/utils/validators.dart                  # pure functions, easy to test
core/errors/auth_error_mapper.dart          # FirebaseAuthException code -> friendly text
```

Folders may be reorganized (see PROJECT_CONTEXT.md Section 3), but keep the **responsibility split** below.

### Responsibility split (important for a clean codebase)

| Layer | Allowed to | Must NOT |
|---|---|---|
| Screen | Show UI, call the controller, read its state | Touch Firebase directly |
| Controller | Hold `isLoading`/`error`/`currentUser`, call the repository | Contain widgets or `BuildContext` use after async gaps |
| Repository | Combine auth + Firestore, return `UserModel` | Know about UI |
| Service/Datasource | Talk to Firebase | Format messages for users |

---

## 4. Data

### Firestore: `users/{uid}`

```
name:        string
phone:       string   // 10 digits, no +91 stored; add the prefix when displaying
email:       string
role:        'student' | 'vendor'     // default 'student'
campusId:    string   // 'pimr_ug' | 'pimr_pg' | 'piemr' | 'pimr_law', set from the campus the user picks (can be changed later)
createdAt:   timestamp (serverTimestamp)
fcmToken:    string?  // written later by Person D
```

### `UserModel`

Fields as above (`createdAt` as `DateTime`, `fcmToken` nullable). Needs:
- `factory UserModel.fromMap(Map<String, dynamic> map, String uid)`
- `Map<String, dynamic> toMap()` (use `FieldValue.serverTimestamp()` for `createdAt` on create)
- `copyWith(...)`
- `bool get isVendor => role == 'vendor';` and `bool get isStudent => role == 'student';`

Use a small `enum UserRole { student, vendor }` with safe parsing (unknown value falls back to `student`) instead of raw strings in app code.

---

## 5. Public API (the contract. Keep it stable)

### `AuthService`
```dart
Stream<User?> authStateChanges();            // wraps FirebaseAuth.instance.authStateChanges()
User? get currentFirebaseUser;
Future<UserCredential> signUp(String email, String password);
Future<UserCredential> signIn(String email, String password);
Future<void> sendPasswordReset(String email);
Future<void> signOut();
```

### `AuthRepository`
```dart
Future<UserModel> signUp({required String name, required String phone,
    required String email, required String password, required String campusId});
Future<UserModel> signIn({required String email, required String password});
Future<void> sendPasswordReset(String email);
Future<void> signOut();
Future<UserModel?> fetchUser(String uid);     // reads users/{uid}
```

### `AuthController` (`ChangeNotifier`, provided at app root via `provider`)
```dart
enum AuthStatus { unknown, unauthenticated, authenticated }

AuthStatus status;          // 'unknown' while the first auth check is running
UserModel? currentUser;     // null when signed out
bool isLoading;             // true during sign in/up calls (for button spinners)
String? errorMessage;       // friendly text, null when no error

Future<bool> signUp(...);   // returns true on success
Future<bool> signIn(...);
Future<bool> sendPasswordReset(String email);
Future<void> signOut();
void clearError();
```

Everyone else only reads `context.read<AuthController>()` / `context.watch<AuthController>()`. They never touch FirebaseAuth.

---

## 6. Flows

### 6.1 App start (persistent login)
1. `AuthController` subscribes to `authStateChanges()` once, in its constructor or an `init()` method.
2. Status starts as `unknown`, and the router shows a **splash/loading screen** (logo plus spinner). This prevents a flash of the login page for already-logged-in users.
3. If a Firebase user exists, call `fetchUser(uid)`.
   - Doc found → `status = authenticated`, `currentUser = model`.
   - **Doc missing** (edge case, see 6.4) → create a default student doc, or sign out with a clear error. Don't crash.
4. If no Firebase user → `status = unauthenticated`.

Firebase persists the session itself (mobile: automatic; web: local persistence by default). No manual token storage is needed.

### 6.2 Sign up
1. Validate the form (Section 7).
2. `createUserWithEmailAndPassword`.
3. Immediately write `users/{uid}` with `role: 'student'`. Also call `user.updateDisplayName(name)`.
4. If the Firestore write fails after the auth account was created, show a retry message and **don't leave a half-created account**: delete the auth user (`user.delete()`) or retry the write once.
5. Update the controller state, and the router redirects to `/home` automatically.

### 6.3 Sign in
1. Validate email and password are non-empty and well-formed.
2. `signInWithEmailAndPassword` → `fetchUser(uid)` → update the controller.
3. Router redirects by role.

### 6.4 Edge cases to handle
- User exists in Auth but not in Firestore (signup was interrupted).
- Network offline → "No internet connection. Please check and try again."
- Double taps on the submit button (ignore while `isLoading`).
- User navigates away mid-request → don't use `BuildContext` after `await` without a `mounted` check.
- `role` field missing or unknown → treat as `student`.

---

## 7. Validation rules (`core/utils/validators.dart`, pure functions)

| Field | Rule | Error text |
|---|---|---|
| Name | required, 2-50 chars, trimmed | "Please enter your name" |
| Phone | regex `^[6-9]\d{9}$` (Indian mobile, 10 digits) | "Enter a valid 10-digit mobile number" |
| Email | required, standard email pattern, trimmed, lowercased before sending | "Enter a valid email address" |
| Password | min 8 chars (Firebase's own minimum is 6) | "Password must be at least 8 characters" |
| Confirm password | equals password | "Passwords don't match" |

Phone field: numeric keyboard, `FilteringTextInputFormatter.digitsOnly`, `maxLength: 10`, with a fixed "+91" prefix shown in the UI.

---

## 8. Roles and security

- Every sign-up from the app creates `role: 'student'`. The client must **never** let a user choose their own role.
- **Vendors for v1:** an admin (a developer) creates the vendor account by signing up normally, then manually changing `role` to `'vendor'` in the Firebase Console (Firestore → `users/{uid}`). Document this in the README so Person C and the canteen staff know.
- Redirect rule: `role == 'vendor'` → the vendor dashboard route (defined by Person C; use a placeholder like `/vendor` until it exists). `role == 'student'` → `/home`.
- A student typing a vendor URL must be redirected away. Role checks live in the **router redirect**, not scattered in screens.

### Firestore rules to aim for before launch (not now)
- A user can read and write only their own `users/{uid}`.
- A user cannot change their own `role` field.
- Only authenticated users can read `menu_items`; only vendors can write them.

---

## 9. Router integration (works with `app/routes/`)

Use `go_router` with `refreshListenable: authController` so it re-evaluates when auth changes.

```
redirect logic (pseudo):
  if status == unknown                -> '/splash'
  if unauthenticated and not on /login,/signup,/forgot-password -> '/login'
  if authenticated and on an auth page -> role == vendor ? '/vendor' : '/home'
  if route requires vendor and role != vendor -> '/home'
  otherwise no redirect
```

Routes owned by auth: `/splash`, `/login`, `/signup`, `/forgot-password`.

---

## 10. UI / design specs

Use only the tokens from `core/theme/`. No hardcoded colors. Vibe: warm, friendly, appetizing.

### Sign In screen
- Top: app logo placeholder (a food icon in a circular orange-tinted container) + "Canteen Crave" title + tagline "Order ahead. Skip the queue."
- Fields: Email, Password (with show/hide eye icon).
- "Forgot password?" aligned right, as a text button.
- Full-width primary button "Sign In" (height 52, radius `AppRadius.button`), with a spinner inside while loading.
- Bottom: "New here? **Sign up**" text link.
- Inline error text below the form (not only a snackbar), with `AppColors.error`.

### Sign Up screen
- Back arrow, title "Create your account".
- Fields in order: Full name, Mobile (+91 prefix), Email, Password, Confirm password.
- **Campus dropdown** (PIMR UG / PIMR PG / PIEMR / PIMR Law), required, which sets `campusId`.
- Primary button "Create Account". Link: "Already have an account? **Sign in**".
- Wrap the form in a `SingleChildScrollView` so the keyboard doesn't cause overflow errors.

### Forgot Password screen
- One email field plus "Send reset link". On success, show a success state ("Check your inbox") instead of just a snackbar.

### General UX
- Keyboard: correct `keyboardType`, `textInputAction` (next/done), and submit on the keyboard's done key.
- Autofill hints (`AutofillHints.email`, `.password`, `.newPassword`, `.telephoneNumber`, `.name`).
- Disable all inputs and the button while loading.
- Responsive: on wide screens (web), center the form in a card with max width about 420.
- Motion: gentle fade/slide-in of the form on load (200-400ms). Don't overdo it.

### Friendly error mapping (`auth_error_mapper.dart`)

| Firebase code | Message |
|---|---|
| `invalid-email` | "That email address doesn't look right." |
| `user-not-found` / `wrong-password` / `invalid-credential` | "Incorrect email or password." |
| `email-already-in-use` | "An account with this email already exists. Try signing in." |
| `weak-password` | "Please choose a stronger password." |
| `too-many-requests` | "Too many attempts. Please wait a bit and try again." |
| `network-request-failed` | "No internet connection. Please try again." |
| `user-disabled` | "This account has been disabled. Contact the canteen." |
| anything else | "Something went wrong. Please try again." |

(Never show raw Firebase error text to users.)

---

## 11. Step-by-step task breakdown (one Antigravity prompt each)

Do these in order. Run the app and commit after each.

1. **Model + validators:** `UserModel`, `UserRole`, `validators.dart`, `auth_error_mapper.dart` (pure Dart, easy win).
2. **Service + datasource + repository:** Firebase calls, no UI yet.
3. **Controller:** `AuthController` with `provider` registered at the app root; handles the `unknown` → `authenticated`/`unauthenticated` flow.
4. **Sign In screen UI** (using mock/stub controller calls first), then wire to the real controller.
5. **Sign Up screen UI**, then wire up (including the Firestore doc creation).
6. **Forgot Password screen.**
7. **Router redirects + splash screen** (persistent login, role routing).
8. **Polish:** loading states, error states, animations, small-screen and web-width checks.

### Prompt template per step
```
Read docs/PROJECT_CONTEXT.md and docs/AUTH_CONTEXT.md.
Task: Step [N] from Section 11 of AUTH_CONTEXT.md: [name].
Give me the file plan first and wait for my OK. Keep the public API from
Section 5 exactly. Add beginner-friendly comments. Tell me how to test it.
```

---

## 12. Manual test checklist (before opening the PR)

- [ ] Sign up with valid data → lands on Home; `users/{uid}` exists in Firestore with `role: 'student'`
- [ ] Sign up with an existing email → friendly "already exists" message
- [ ] Every validator rejects bad input with the right message
- [ ] Wrong password → friendly error, no crash
- [ ] Close and reopen the app → still logged in, no flash of the login page
- [ ] Sign out → returns to Login; the back button can't return to protected pages
- [ ] Forgot password → reset email arrives
- [ ] Manually set `role: 'vendor'` in Firestore → login redirects to the vendor route
- [ ] Airplane mode → friendly offline message
- [ ] Small phone (360px) and wide browser window → no overflow errors
- [ ] `flutter analyze` reports no new warnings
- [ ] No hardcoded colors or sizes; no Firebase calls inside screens

---

## 13. Things to tell the team when this merges

- **Person B / D:** how to read the logged-in user (`context.read<AuthController>().currentUser`) and its fields.
- **Person C:** vendor accounts are created manually via the role field; the vendor route placeholder name to replace.
- **Person D:** `signOut()` is on `AuthController`; `fcmToken` should be written to `users/{uid}` by `notification_service`.
