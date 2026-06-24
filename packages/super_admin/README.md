# Super Admin

A super admin panel for controlling tenant plans and customizing plan features in the Posto ecosystem.

## Features

- Plan management (create, edit, activate/deactivate, delete)
- Tenant plan assignment
- Custom feature toggling per tenant
- Plan suspension/enabling per tenant
- Dedicated super admin dashboard with stats
- Super admin detection and automatic redirection

## Installation

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  super_admin:
    path: packages/super_admin
```

## Database Setup

Apply the migration SQL to your Supabase project:

```bash
supabase db push
```

Or run the SQL manually in Supabase SQL Editor:

```
packages/super_admin/supabase/migrations/super_admin_schema.sql
```

## Setup Super Admin User

After applying the migration, add yourself as a super admin in Supabase:

**Option 1 - SQL:**
```sql
insert into public.super_admins (user_id) values ('your-user-uuid');
```

**Option 2 - Via code (once authenticated):**
```dart
final superAdminService = SuperAdminService();
await superAdminService.grantSuperAdmin('user-uuid');
```

## Usage

### Automatic Super Admin Detection

The integration in `lib/main.dart` automatically:
1. Checks if the signed-in user is a super admin (via `super_admins` table)
2. If super admin: Shows `SuperAdminDashboardPage` instead of tenant dashboard
3. If regular user: Shows normal tenant onboarding flow

### Navigation Integration

The package provides standalone pages that can be integrated into your admin UI. Ensure your app is wrapped in a `ProviderScope` at the top level:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_admin/super_admin.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

Then navigate as usual:

```dart
import 'package:flutter/material.dart';
import 'package:super_admin/super_admin.dart';

// Super Admin Dashboard
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SuperAdminDashboardPage()),
);

// Plan Management Page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PlanManagementPage()),
);

// Tenant Plan Assignment Page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const TenantPlanAssignmentPage()),
);

// Tenant Plan Selection Page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => TenantPlanSelectionPage(organizationId: 'org-uuid')),
);
```

### Programmatic Usage

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:super_admin/super_admin.dart';

final supabase = Supabase.instance.client;
final planService = PlanService(supabase);
final tenantPlanService = TenantPlanService(supabase);

// Create a new plan
final plan = await planService.createPlan(
  name: 'Premium',
  description: 'Full feature access',
  priceCents: 9900, // $99.00
  billingInterval: BillingInterval.monthly,
  featureFlags: ['SECURE_AUTHENTICATION', 'INVENTORY_MANAGEMENT', 'POS_REGISTER', 'CUSTOMER_MANAGEMENT'],
);

// Assign plan to tenant
await tenantPlanService.assignPlanToTenant(
  orgId: 'organization-uuid',
  planId: plan.id,
);
```

### Super Admin Service

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:super_admin/super_admin.dart';

final superAdminService = SuperAdminService(Supabase.instance.client);

// Check if current user is super admin
final isSuperAdmin = await superAdminService.isSuperAdmin();

// Grant super admin to a user
await superAdminService.grantSuperAdmin('user-uuid');

// Revoke super admin from a user
await superAdminService.revokeSuperAdmin('user-uuid');
```

## Architecture

The package follows a layered architecture:

- `domain/` — Pure Dart entities, enums, exceptions, repository interfaces
- `data/` — Supabase datasource and repository implementations
- `services/` — Business logic with `ApiResponse<T>`, `SuperAdminGuard`, and audit logging
- `presentation/` — Flutter pages and widgets using Riverpod providers

All mutating operations are guarded by `SuperAdminGuard` and logged to the `audit_logs` table.

## Database Migrations

In addition to `super_admin_schema.sql`, apply these migrations:

- `add_audit_logs_table.sql` — Creates the `audit_logs` table for compliance tracking
- `update_get_all_tenant_plans_rpc.sql` — Adds pagination and search to the `get_all_tenant_plans` RPC
- `tighten_rls_policies.sql` — Restricts RLS on `plans` and `tenant_plans` to super admins only

## Dependencies

- `flutter_riverpod` — State management and DI
- `supabase_flutter` — Database access

The system supports these feature flags (matching `FeatureRegistry`):

- `SECURE_AUTHENTICATION` - User login and session management
- `INVENTORY_MANAGEMENT` - Product catalog and stock tracking
- `POS_REGISTER` - Product selection, cart, payments
- `CUSTOMER_MANAGEMENT` - Customer profiles and store credit

## Security Notes

- All tables have RLS policies enabled
- Adjust RLS policies in `super_admin_schema.sql` to restrict access to super admin roles only
- Super admin status is stored in `super_admins` table
- Consider adding additional role checks in your auth service before allowing access to these pages