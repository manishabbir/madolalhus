# Changelog

All notable changes to the `super_admin` package are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `audit_logs` SQL table with RLS policy for super-admin-only access
- `flutter_riverpod` dependency and `di/super_admin_module.dart` with providers
- `LoadingState` and `ErrorState` shared presentation widgets
- `add_audit_logs_table.sql` migration
- `tighten_rls_policies.sql` migration
- `equatable` and `mocktail` to dev dependencies

### Changed
- All 5 pages migrated from `StatefulWidget`-owned state to Riverpod `Consumer` + `ProviderScope.containerOf`
- `PlanEditorPage` now takes injected `SupabaseClient` instead of calling `Supabase.instance.client`
- `AppException.toString()` now includes underlying cause for better debugging
- SQL migration `update_get_all_tenant_plans_rpc.sql` now drops the old function before creating the new one

### Fixed
- **CRITICAL:** `hasFeature()` — was checking `customFeatures` twice, never checking `featureFlags` from the `plans` table. Fixed to read joined plan data via `getTenantPlanWithFeatures()`.
- **CRITICAL:** `assignPlanToTenant` — super admin guard removed so tenants can self-subscribe. Guard remains on admin-only actions (`customize`, `disable`, `enable`, `remove`, `setExpiry`).
- Replaced all deprecated `Color.withValues(alpha: ...)` with `Color.withAlpha(0x...)` across 4 widget files
- `AuditLogService` now logs failures in debug mode instead of silently swallowing

## [0.1.0] - Initial structured release

### Added
- Domain layer: `Plan`, `TenantPlan`, `TenantPlanWithOrg`, `TenantPlanWithFeatures` entities
- Domain layer: `BillingInterval`, `TenantPlanStatus` enums
- Domain layer: `AppException`, `PermissionException`, `NotFoundException`, `ValidationException`
- Domain layer: `PlanRepository`, `TenantPlanRepository` interfaces
- Data layer: `SupabasePlanDataSource`, `SupabaseTenantPlanDataSource`
- Data layer: `SupabasePlanRepositoryImpl`, `SupabaseTenantPlanRepositoryImpl`
- Services: `PlanService`, `TenantPlanService` with constructor-injected `SupabaseClient`
- Services: `SuperAdminGuard` for middleware-style admin checks
- Services: `AuditLogService` for compliance tracking
- Services: `ApiResponse<T>` type replacing raw returns
- SQL migrations: `super_admin_schema.sql`, `add_get_all_tenant_plans_rpc.sql`
- Pages: `SuperAdminDashboardPage`, `PlanManagementPage`, `PlanEditorPage`, `TenantPlanAssignmentPage`, `TenantPlanSelectionPage`
- Widgets: `PlanCard`, `FeatureToggleChip`
- Feature registry extracted from widget file to `domain/constants/feature_registry.dart`
- README updated with layered architecture and usage examples
