# Implementation Plan — Person C (Vendor Interface & Operations)

**Branch**: `achal`  
**Role**: Person C — Vendor Interface, Menu & Cooking Time, Stock Management, Live Order Pipeline, Analytics/Reports, and Flash Sale Triggers.

---

## 1. Overview & Core Mission

As **Person C**, you own the entire **Vendor Operating System** for Canteen Crave. Your interface allows canteen operators to:
1. Authenticate and manage their canteen profile & operational status (Open/Closed).
2. Manage their digital menu with real-time availability toggles and **Cooking Time (Preparation Time)** settings.
3. Track packaged food inventory (chips, drinks, snacks) with real-time stock counters and low-stock alerts.
4. Run a high-velocity **Live Order Pipeline** (`Placed` → `Accepted` → `Preparing` → `Ready for Pickup` → `Completed`).
5. Handle uncollected food orders and trigger automated or 1-tap **Flash Sales** (linking directly with Person D's flash sale system).
6. View real-time **Vendor Analytics & Business Reports** (daily revenue, active orders, top sellers, hourly peak demand).

---

## 2. Firestore Collection Architecture (Person C Focus)

Here is the exact schema and collection structure Person C will read from and write to in Cloud Firestore:

### `vendors/{vendorId}`
```json
{
  "vendorId": "string (matches FirebaseAuth uid)",
  "canteenName": "string (e.g., Main Campus Canteen)",
  "campusId": "string (e.g., campus_north)",
  "ownerName": "string",
  "email": "string",
  "phone": "string",
  "isOpen": true,
  "openingTime": "08:00 AM",
  "closingTime": "08:00 PM",
  "rating": 4.8,
  "totalOrders": 1250,
  "createdAt": "ISO8601 String"
}
```

### `menu_items/{itemId}` (Coordinated with Person A)
```json
{
  "id": "string",
  "vendorId": "string",
  "campusId": "string",
  "name": "string (e.g., Paneer Butter Masala)",
  "description": "string",
  "price": 120.0,
  "imageUrl": "string",
  "category": "string (e.g., Meals, Snacks, Beverages)",
  "isAvailable": true,
  "cookingTimeMinutes": 15, // CRITICAL: Person C sets this, Cart & User browse consumes it
  "isVeg": true,
  "createdAt": "ISO8601 String",
  "updatedAt": "ISO8601 String"
}
```

### `stock_items/{stockId}` (Packaged Food Inventory)
```json
{
  "id": "string",
  "vendorId": "string",
  "name": "string (e.g., Lays Classic 50g)",
  "category": "string (Packaged Snacks, Cold Drinks)",
  "price": 20.0,
  "quantity": 35,
  "lowStockThreshold": 10,
  "isAvailable": true,
  "imageUrl": "string",
  "updatedAt": "ISO8601 String"
}
```

### `orders/{orderId}` (Coordinated with Person B & D)
```json
{
  "id": "string",
  "userId": "string",
  "userName": "string",
  "userPhone": "string",
  "vendorId": "string",
  "campusId": "string",
  "items": [
    {
      "itemId": "string",
      "name": "string",
      "price": 120.0,
      "quantity": 2,
      "cookingTimeMinutes": 15
    }
  ],
  "totalAmount": 240.0,
  "status": "placed", // 'placed' | 'accepted' | 'preparing' | 'ready' | 'completed' | 'cancelled' | 'uncollected'
  "paymentStatus": "paid", // 'paid' | 'pending' | 'cod'
  "orderOtp": "4921",
  "pickupEstimatedAt": "ISO8601 String",
  "createdAt": "ISO8601 String",
  "updatedAt": "ISO8601 String"
}
```

### `flash_sales/{flashSaleId}` (Coordination with Person D)
```json
{
  "orderId": "string (optional if from surplus stock)",
  "itemId": "string",
  "itemName": "string",
  "imageUrl": "string",
  "originalPrice": 120.0,
  "discountPercent": 40,
  "campusId": "string",
  "vendorId": "string",
  "createdAt": "ISO8601 String",
  "expiresAt": "ISO8601 String",
  "status": "active", // 'active' | 'claimed' | 'expired'
  "claimedByUserId": null
}
```

---

## 3. Directory & File Breakdown for Person C

```
lib/src/
├── models/
│   ├── vendor_model.dart             <-- Person C
│   ├── stock_item_model.dart         <-- Person C
│   ├── report_model.dart             <-- Person C
│   ├── menu_item_model.dart          <-- (Person A owns schema, C implements cookingTime & availability)
│   └── order_model.dart              <-- (Person B owns schema, C implements vendor status lifecycle)
│
├── datasources/
│   ├── vendor_remote_datasource.dart <-- Person C (Firestore vendor profile, menu & stock CRUD)
│   ├── vendor_order_datasource.dart  <-- Person C (Real-time live orders streams & status updates)
│   └── report_remote_datasource.dart  <-- Person C (Revenue & analytics aggregation)
│
├── repositories/
│   ├── vendor_repository.dart        <-- Person C
│   ├── stock_repository.dart         <-- Person C
│   └── report_repository.dart        <-- Person C
│
├── screens/
│   ├── vendor_auth/
│   │   ├── vendor_login_screen.dart
│   │   ├── vendor_register_screen.dart
│   │   └── widgets/vendor_auth_form.dart
│   │
│   ├── vendor_dashboard/
│   │   ├── vendor_dashboard_screen.dart   <-- Order Kanban / Pipeline tab
│   │   ├── vendor_main_nav_screen.dart    <-- Vendor Bottom Navigation Shell
│   │   └── widgets/
│   │       ├── live_order_card.dart
│   │       ├── order_status_badge.dart
│   │       ├── order_details_sheet.dart
│   │       └── unpicked_order_flash_modal.dart <-- 1-tap Flash Sale trigger
│   │
│   ├── vendor_menu/
│   │   ├── vendor_menu_screen.dart
│   │   ├── add_edit_menu_item_screen.dart
│   │   └── widgets/
│   │       ├── cooking_time_dropdown.dart  <-- Cooking time selector (5m, 10m, 15m, 20m, 30m, 45m)
│   │       ├── menu_item_tile.dart
│   │       └── availability_toggle.dart
│   │
│   ├── vendor_stock/
│   │   ├── vendor_stock_screen.dart
│   │   ├── add_edit_stock_item_dialog.dart
│   │   └── widgets/
│   │       ├── stock_counter_widget.dart
│   │       └── low_stock_alert_badge.dart
│   │
│   ├── vendor_flash_sale/
│   │   ├── vendor_flash_sale_screen.dart
│   │   └── widgets/create_flash_sale_sheet.dart
│   │
│   └── vendor_reports/
│       ├── vendor_reports_screen.dart
│       └── widgets/
│           ├── metric_kpi_card.dart
│           ├── sales_chart_widget.dart
│           └── top_selling_items_list.dart
```

---

## 4. Feature-by-Feature Specification

### A. Vendor Authentication & Profile (`screens/vendor_auth/`)
- **Vendor Sign In & Registration**: Email/Password login or registration with Canteen Name, Campus dropdown, Phone number, and Operating Hours.
- **Vendor Store Toggle**: Master switch to toggle Canteen status: `Open (Accepting Orders)` vs `Closed (Paused)`.

### B. Menu Management & Cooking Time (`screens/vendor_menu/`)
- **Category Filter & Item Grid**: Filter by Meals, Snacks, Drinks, Desserts.
- **Live In-Stock Toggle**: Switch `isAvailable` instantly with 1 tap.
- **Add / Edit Item Form**:
  - Item Title, Description, Price, Image URL (or upload).
  - Category selector.
  - **Cooking Time Dropdown**: Options: `5 mins`, `10 mins`, `15 mins`, `20 mins`, `30 mins`, `45 mins`.
  - Dietary Tag (Veg / Non-Veg).
- **Delete / Archive Item**.

### C. Packaged Stock Management (`screens/vendor_stock/`)
- List packaged items (beverages, chips, chocolates, instant noodles).
- Quick increment/decrement buttons (`+` / `-`) for counter staff during checkout.
- Automated `Low Stock Warning` when `quantity <= lowStockThreshold`.
- Out-of-Stock auto-badge.

### D. Real-Time Order Pipeline (`screens/vendor_dashboard/`)
- **Live Stream via Firestore**: `snapshots()` query where `vendorId == currentVendorId` and `status != 'completed'`.
- Visual Tabs / Filter:
  1. **New Orders (`placed`)**: Audio chime / badge counter, `Accept Order` or `Reject` buttons.
  2. **In Kitchen (`preparing`)**: Shows elapsed timer, cooking time, and button `Mark Ready`.
  3. **Ready for Pickup (`ready`)**: OTP verification field, button `Complete Order`.
  4. **Uncollected / Stale**: If ready for > 30 minutes with no pickup, button triggers **"Convert to Flash Sale"**.

### E. Flash Sale Integration (Coordinated with Person D)
- When food is prepared but customer didn't pick it up (or excess daily food):
- Tap **"Push to Flash Sale"**:
  - Opens modal with auto-filled Item Name and Original Price.
  - Choose Discount: `20%`, `30%`, `50%`, `70%`.
  - Choose Expiry: `15 mins`, `30 mins`, `60 mins`.
  - Writes directly to `flash_sales` collection in Firestore.
  - Person D's notification service notifies all campus students!

### F. Analytics & Business Reports (`screens/vendor_reports/`)
- Today's Revenue & Total Completed Orders.
- Average preparation time performance.
- Top 5 Bestselling items with quantity sold.
- Payment breakdown: Razorpay (Online) vs Cash on Counter.

---

## 5. Coordination & Interface Handshakes

| Collaborator | Interface Points & Shared Dependencies |
|---|---|
| **Person A** | • **`menu_item_model.dart`**: Person A defines the model class. Person C adds the `cookingTimeMinutes` and `isAvailable` fields.<br>• **`auth_service.dart`**: Shared Firebase Auth session to detect vendor role. |
| **Person B** | • **`order_model.dart`**: Person B places orders with `status: 'placed'`. Person C streams and updates the status to `'accepted'`, `'preparing'`, `'ready'`, `'completed'`.<br>• Cart pickup time relies on maximum `cookingTimeMinutes` set by Person C. |
| **Person D** | • **`flash_sales` collection**: Person C creates flash sale records from uncollected orders; Person D's popup and list display them to students.<br>• **Push Notifications**: When Person C sets status to `'ready'`, notification triggers to student via FCM. |

---

## 6. Recommended Step-by-Step Implementation Sequence

1. **Step 1 — Foundation & Models**:
   - Create `vendor_model.dart`, `stock_item_model.dart`, `report_model.dart`.
   - Ensure `menu_item_model.dart` and `order_model.dart` have vendor-required fields (`cookingTimeMinutes`, order status enum).
2. **Step 2 — DataSources & Repositories**:
   - Implement `vendor_remote_datasource.dart`, `vendor_order_datasource.dart`, `stock_remote_datasource.dart`, `report_remote_datasource.dart`.
   - Implement repository contracts for easy UI binding and state management.
3. **Step 3 — Vendor Menu & Stock UI**:
   - Build `vendor_menu_screen.dart` with `cooking_time_dropdown.dart` and `availability_toggle.dart`.
   - Build `vendor_stock_screen.dart` with fast stock adjustments and low stock flags.
4. **Step 4 — Live Order Pipeline**:
   - Build `vendor_dashboard_screen.dart` with real-time stream, status progression buttons, OTP verification, and order countdown.
5. **Step 5 — Flash Sale Trigger**:
   - Implement the `unpicked_order_flash_modal.dart` to publish directly to Firestore `flash_sales` collection.
6. **Step 6 — Vendor Reports & Analytics**:
   - Build `vendor_reports_screen.dart` with metric cards, revenue summaries, and charts.
7. **Step 7 — Vendor Navigation & Auth Shell**:
   - Connect `vendor_main_nav_screen.dart` (Bottom navigation with Orders, Menu, Stock, Flash Sale, Reports).
