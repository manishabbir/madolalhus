# Posto Onboarding Template

A Supabase-backed onboarding and empty dashboard template for Flutter apps. Drop it into any new Flutter project to get login, signup, language selection, business module selection, organization loading/selection, and an empty dashboard — ready to be extended with your own business logic.

## What this template provides

- Supabase-backed auth shell
- Login page
- Signup page (with business module selection)
- Language selection (English / Urdu)
- Business module selection (Restaurant, Retail, Grocery, Pharmacy, General)
- Organization loading / auto-redirect
- Organization selection (if multiple organizations exist)
- Empty dashboard page (ready for custom cards)
- `LocaleState` — reactive locale management
- `FeatureRegistry` — lightweight feature flag system
- `BusinessPack` extension points — add custom navigation items, dashboard cards, and POS overlays

### What it does **not** include

- Finished POS terminal
- Inventory management
- Order management
- Restaurant table management
- Kitchen display system
- Barcode scanning
- Offline sync engine UI

These features can be built on top of the template using the `BusinessPack` extension system or added as separate packages.

---

## Required folder structure

After you manually place the template, your new project should look like this:

```
my_new_app/
├── packages/
│   └── posto_onboarding_template/
│       ├── pubspec.yaml
│       ├── lib/
│       └── test/
├── lib/
│   └── main.dart
├── supabase/
│   └── migrations/
│       └── 20260614221844_onboarding_template_schema.sql
└── pubspec.yaml
```

---

## Step-by-step setup

### 1. Create a new Flutter project

```bash
flutter create my_new_app
cd my_new_app
```

### 2. Create the `packages/` directory

```bash
mkdir packages
```

### 3. Place `posto_onboarding_template` inside `packages/`

Copy the entire `posto_onboarding_template` folder (from wherever you downloaded it) into `packages/`. The result should be:

```
packages/posto_onboarding_template/pubspec.yaml
packages/posto_onboarding_template/lib/
packages/posto_onboarding_template/test/
```

### 4. Add the dependency to your app's `pubspec.yaml`

Open your app's root `pubspec.yaml` and add the following under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  posto_onboarding_template:
    path: packages/posto_onboarding_template
```

> Keep any existing dependencies you already have — just add the `posto_onboarding_template` line.

### 5. Install dependencies

```bash
flutter pub get
```

### 6. Copy the template migration

Copy the file:

```
packages/posto_onboarding_template/supabase/migrations/20260614221844_onboarding_template_schema.sql
```

into your project at:

```
supabase/migrations/20260614221844_onboarding_template_schema.sql
```

If the `supabase/migrations/` directory does not exist, create it.

### 7. Apply the migration in Supabase

**Option A — Supabase SQL Editor:**
1. Open your Supabase project dashboard.
2. Go to **SQL Editor**.
3. Open the file `20260614221844_onboarding_template_schema.sql` and copy its contents.
4. Paste into the SQL Editor and click **Run**.

**Option B — Supabase CLI:**
1. Make sure you have the Supabase CLI installed and linked to your project.
2. Run:

```bash
supabase db push
```

### 8. Replace `lib/main.dart`

Replace the contents of `lib/main.dart` with the following:

```dart
import 'package:flutter/material.dart';
import 'package:posto_onboarding_template/posto_onboarding_template.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    publishableKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  final localeState = LocaleState();
  await localeState.load();

  FeatureRegistry().initialize();

  runApp(
    PostoOnboardingTemplate(
      modules: DefaultBusinessModules.all(),
      localeState: localeState,
    ),
  );
}
```

> **Important:** Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with the actual values from your Supabase project settings (go to **Settings → API** in the Supabase dashboard).

### 9. Run the app

```bash
flutter run
```

The app should start at the login page. From there you can sign up, select a business module, and land on the empty dashboard.

---

## Default routes

The template registers the following routes automatically — **do not redefine them**:

| Route             | Page                    |
|-------------------|-------------------------|
| `/`               | `AuthGate` (auto-route) |
| `/login`          | Login page              |
| `/signup`         | Signup page             |
| `/loading`        | Organization loading    |
| `/org-select`     | Organization selection  |
| `/reset-password` | Reset password page     |
| `/dashboard`      | Empty dashboard         |

The `AuthGate` at `/` checks the user's auth state and redirects to the correct page automatically.

If you use `PostoOnboardingTemplate`, these routes are already registered via `MaterialApp.routes`. Do not call `MaterialApp` with your own route table that duplicates these paths.

---

## Optional: custom business pack

You can extend the dashboard with custom navigation items, dashboard cards, and POS features by subclassing `BusinessPack`.

### Example: Restaurant pack

Create a new file, for example `lib/my_restaurant_pack.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:posto_onboarding_template/posto_onboarding_template.dart';

class MyRestaurantPack extends BusinessPack {
  @override
  String get id => 'restaurant';

  @override
  String get name => 'Restaurant';

  @override
  String get description => 'Restaurant business pack';

  @override
  List<NavigationItem> buildNavigationItems({required String userRole}) {
    return const [
      NavigationItem(
        route: '/restaurant/tables',
        icon: Icons.table_restaurant,
        label: 'Tables',
      ),
    ];
  }
}
```

Then pass it to `PostoOnboardingTemplate`:

```dart
PostoOnboardingTemplate(
  modules: DefaultBusinessModules.all(),
  packs: [
    MyRestaurantPack(),
  ],
  localeState: localeState,
)
```

You can pass multiple packs at once:

```dart
packs: [
  MyRestaurantPack(),
  MyInventoryPack(),
  MyOrdersPack(),
],
```

---

## Verification commands

Run these to confirm everything is set up correctly:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To analyze or test only the template package:

```bash
flutter analyze packages/posto_onboarding_template
flutter test packages/posto_onboarding_template
```

---

## Troubleshooting

**Dependencies fail to resolve**
Run `flutter clean`, then `flutter pub get` again.

**Supabase auth fails (e.g., "Invalid API key")**
Double-check `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` in `main.dart`. Also confirm the migration was applied successfully — the tables and RPC functions must exist in your Supabase project.

**Route conflicts (`/login`, `/signup`, `/dashboard` already defined)**
If you are wrapping `PostoOnboardingTemplate` inside another `MaterialApp` or `Navigator`, remove any duplicate route definitions for these paths. The template already registers them.

**Dashboard stays on loading screen**
The loading page (`/loading`) calls an RPC to load organizations. If no organization exists, it redirects to signup. Make sure the migration was applied so that:
- The `create_organization` RPC function exists.
- The `organizations` table exists.
- The signup flow successfully calls the RPC and creates an organization.