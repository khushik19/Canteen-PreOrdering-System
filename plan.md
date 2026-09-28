# Canteen Crave — Project Details

## Overview

Canteen Crave is a food pre-ordering platform built to solve a simple but real problem: students only get a 20-minute break, which isn't enough time to wait in line, order, and eat. The app lets students pre-order food from their campus canteen, schedule a pickup time, pay in advance, and walk in right when the food is ready.

On the other side, the canteen (vendor) receives the order request along with the requested pickup time, can approve or reject it, and starts preparing the food based on that schedule.

## Tech Stack

| Layer | Technology |
|---|---|
| App Framework | Flutter |
| Backend / Database | Firebase / Supabase |
| Payments | Razorpay |
| Deployment | Cloudflare |

## Supported Campuses

- PIMR UG
- PIMR PG
- PIEMR
- PIMR Law

---

## Core Concepts

### Scheduled Pickup Based on Cooking Time
When the vendor adds a menu item, they set a cooking duration (via a dropdown) for that item. When a student orders that item, they can only select a pickup time that is *at least* that duration away.

> Example: If Maggi has a cooking time of 10 minutes, a student ordering Maggi can only pick a pickup slot 10+ minutes from the order time.

### Flash Sale (Food Waste Reduction)
If a student doesn't pick up their order and the vendor is unable to reach them within a predefined time window, the vendor can put that order up for sale at a discount. All users in that campus receive a notification about the discounted item, first-come-first-served style.

---

## User-Facing Screens

### Home Page
- **Top bar:** Campus location dropdown (top-left) to switch between PIMR UG / PG / PIEMR / Law; profile icon (top-right)
- **Bestsellers:** Horizontal scrolling carousel (e.g., Chilli Cheese Garlic Maggi, Sev Tamatar Combo, Fries, Indori Sandwich)
- **Categories:** 3×3 grid of image boxes (Sandwiches, Maggi, South Indian, Beverages, etc.) — tapping a category opens the Menu page filtered to that category
- **Bottom navigation bar** *(fixed)*: Home, Menu, Favs, Cart
- **Footer:** "Meet The Team" button → opens a separate team page (to be designed later)

### Menu Page
- Left panel: list of categories
- Right panel: items belonging to the selected category

### Favourites Page
- **Liked by You:** items the user has favourited
- **Order Again:** items the user has previously ordered

### Cart Page
- Standard cart/checkout experience (similar to Swiggy)

### Payment
- Integrated via Razorpay

### Flash Sale Popup
- Notifies the user when a flash sale item becomes available

### Profile
- Edit Profile
- Order Dashboard (live order updates + order history)
- Help

---

## Vendor-Facing Screens (Canteen Interface)

- **Sign Up / Sign In**
- **Menu Management:** Add/edit items with an availability toggle and cooking-time dropdown
- **Packaged Food Stock:** Manage pre-packaged inventory items
- **Order Dashboard:** Track orders through stages — Accepted → Preparing → Ready → Completed
- **Reports:** Orders, payments, top sellers, customer feedback
- **Flash Sale Management:** Configure the no-pickup/no-contact time window and discount % for unclaimed orders

---

## Feature Summary

### User Interface
- [ ] Sign up / Sign in
- [ ] Home Page
- [ ] Menu Page
- [ ] Favourites Page
- [ ] Cart
- [ ] Payment (Razorpay)
- [ ] Flash Sale Popup
- [ ] Profile (Edit Profile, Order Dashboard, Help)

### Vendor Interface
- [ ] Sign up / Sign in
- [ ] Menu Page with availability toggle
- [ ] Packaged Food Stock management
- [ ] Order Dashboard (Accepted / Preparing / Ready / Completed)
- [ ] Reports (Orders, Payments, Top Sellers, Feedback)
- [ ] Flash Sale Management

---

## Open Items / To Be Designed Later
- "Meet The Team" page (linked from footer)