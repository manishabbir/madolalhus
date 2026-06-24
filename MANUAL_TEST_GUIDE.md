# Posto POS — Manual Test Guide

This project is a **Flutter POS system** with onboarding, authentication, offline-aware dashboard, data sync, and super admin (plan management).  
**Supabase URL:** `https://lxwrwhsdauzryjtemfnq.supabase.co`

---

## How to Run

```bash
# In the project root
flutter run              # For mobile/desktop
flutter run -d chrome    # For web
```

---

## 1. Language/Locale — First Launch

| Step | Action | Expected Result |
|------|--------|----------------|
| 1.1 | Clear app data / install fresh | "Welcome to Posto POS" screen with English & Urdu options appears |
| 1.2 | Tap **English** | Navigates to Login page, UI is in English |
| 1.3 | Kill app & reopen | Goes directly to Login (locale persisted) |
| 1.4 | Repeat test: install fresh → tap **Urdu** | UI switches to Urdu (اردو), e.g. "سائن ان" instead of "Sign In" |

**Files:** `auth_gate.dart` (`_checkFirstLaunch`), `locale_state.dart`

---

## 2. Login Page

| Step | Action | Expected Result |
|------|--------|----------------|
| 2.1 | Tap language icon (top-right) | Language selector dialog opens with English/Urdu |
| 2.2 | Tap "Need help? Contact your administrator" | Bottom sheet opens with phone `+92 300 8932525` (WhatsApp) and email `imranafmdc@gmail.com` |
| 2.3 | Tap the phone tile | Copies number, opens WhatsApp link |
| 2.4 | Tap the email tile | Copies email, opens mailto: link |
| 2.5 | Leave email empty & tap **Sign In** | Validation: "Email is required" |
| 2.6 | Enter invalid email like `abc` & tap Sign In | Validation: "Please enter a valid email" |
| 2.7 | Leave password empty & tap Sign In | Validation: "Password is required" |
| 2.8 | Enter valid email + wrong password & tap Sign In | Red error banner: "Invalid login credentials" (from Supabase) |
| 2.9 | Enter valid email + valid password & tap Sign In | Navigates to /loading → /org-select or /dashboard |
| 2.10 | Check **Remember Me** checkbox | Checkbox is checked (visual only, no backend persistence) |
| 2.11 | Tap **Forgot Password?** without email | Snackbar: "Please enter your email address first" |
| 2.12 | Enter email & tap **Forgot Password?** | Supabase sends password reset email (green snackbar confirmation) |
| 2.13 | Tap **Create Account** link | Navigates to `/signup` |

**Files:** `login_page.dart`, `auth_service.dart`

---

## 3. Password Reset (Email Link)

| Step | Action | Expected Result |
|------|--------|----------------|
| 3.1 | Open password reset email from Supabase & click link | App opens to **Reset Password** page |
| 3.2 | Leave new password empty & tap **Reset Password** | Validation: "Password is required" |
| 3.3 | Enter password < 6 chars | Validation: "Password must be at least 6 characters" |
| 3.4 | Enter mismatched Confirm Password | Validation: "Passwords do not match" |
| 3.5 | Enter valid password + matching confirm & tap Reset | Success snackbar → navigates to `/login` |
| 3.6 | Open login page with expired/invalid reset link | Error: "Invalid or expired password reset link" |

**Files:** `reset_password_page.dart`, `auth_gate.dart` (_handlePasswordRecovery)

---

## 4. Sign Up / Create Workspace

| Step | Action | Expected Result |
|------|--------|----------------|
| 4.1 | From Login, tap **Create Account** | SignUp page with form fields appears |
| 4.2 | Leave all fields empty & tap **Create Workspace** | Validation errors for all required fields |
| 4.3 | Enter org name < 2 chars | "Name must be at least 2 characters" |
| 4.4 | Enter full name < 2 chars | "Name must be at least 2 characters" |
| 4.5 | Enter phone < 10 digits | "Please enter a valid phone number" |
| 4.6 | Enter invalid email format | "Please enter a valid email" |
| 4.7 | Enter password < 8 chars | "Password must be at least 8 characters" |
| 4.8 | Enter password without uppercase | "Must contain an uppercase letter" |
| 4.9 | Enter password without lowercase | "Must contain a lowercase letter" |
| 4.10 | Enter password without number | "Must contain a number" |
| 4.11 | Enter different passwords in confirm | "Passwords do not match" |
| 4.12 | Leave Terms checkbox unchecked & tap Create | Snackbar: "Please agree to the Terms & Conditions" |
| 4.13 | Fill all fields correctly, check Terms, tap **Create Workspace** | Navigates to Language Selection page (onboarding) |

**Files:** `signup_page.dart`

---

## 5. Onboarding Flow — Language Selection

| Step | Action | Expected Result |
|------|--------|----------------|
| 5.1 | From SignUp, fill data & tap Create → Language Selection page | Title: "Language Selection", English & Urdu cards |
| 5.2 | Tap **English** card | Navigates to Business Type page |

**Files:** `language_selection_page.dart`

---

## 6. Onboarding Flow — Business Module Selection

| Step | Action | Expected Result |
|------|--------|----------------|
| 6.1 | View available modules | Cards: Restaurant & Cafe, Retail & Fashion, Grocery & Supermarket, Health & Beauty / Pharmacy, General / Other |
| 6.2 | Tap any module card | Card highlights with blue border + check icon |
| 6.3 | Tap **Continue** without selecting | Button disabled (no action) |
| 6.4 | Select a module, tap **Continue** | Navigates to Operator Setup |

**Files:** `business_type_page.dart`, `business_module_template.dart`

---

## 7. Onboarding Flow — Operator Setup & Account Creation

| Step | Action | Expected Result |
|------|--------|----------------|
| 7.1 | View operator options | "Solo Operator" and "Multi-Operator" cards |
| 7.2 | Tap **Solo Operator** | Card highlights |
| 7.3 | Tap **Continue** | Supabase sign-up API called, organization created. Green snackbar: "Welcome to [org]! Your workspace is ready." → navigates to `/dashboard` |
| 7.4 | Repeat sign-up process, select **Multi-Operator** | Same flow but selected option tracked |

**Files:** `operator_selection_page.dart`, `auth_service.dart` (signUpWithEmail, createOrganizationAfterSignUp)

---

## 8. Organization Selection

| Step | Action | Expected Result |
|------|--------|----------------|
| 8.1 | Log in as user with **multiple organizations** | "Select your workspace" page with list of orgs |
| 8.2 | Each org shows name, role (e.g. "admin"), initial avatar | Cards with avatar (first letter), org name, role badge |
| 8.3 | Tap an organization | Navigates to Dashboard for that org |
| 8.4 | Tap **Logout** icon in AppBar | Signs out → navigates to `/login` |
| 8.5 | Log in as user with **single organization** | Auto-selects org → navigates directly to Dashboard (skips org-select) |

**Files:** `org_select_page.dart`, `organization_service.dart`

---

## 9. Dashboard — Main Features

| Step | Action | Expected Result |
|------|--------|----------------|
| 9.1 | Successfully log in & reach Dashboard | Connectivity banner at top (green "Online" or red "Offline") |
| 9.2 | Profile card | Shows org avatar (first letter), org name, email, role badge |
| 9.3 | Data Sync Status card | Shows pending sync count + online/offline status |
| 9.4 | **Quick Actions** > **Sync Now** | Triggers sync; shows loading spinner if syncing |
| 9.5 | **Quick Actions** > **Check Status** | Snackbar: "Connected to server" or "Working offline..." |
| 9.6 | Business Type card | Shows mapped business type name + status badge |
| 9.7 | **Free Plan upgrade banner** | Orange card: "You are on the Free plan. Upgrade to remove ads..." with "Upgrade Plan" button |
| 9.8 | Tap **Upgrade Plan** | Navigates to `/tenant/select-plan` (Plan Selection page) |
| 9.9 | **Refresh** icon in AppBar | Refreshes org info + sync count |

**Files:** `dashboard_page.dart`

---

## 10. Dashboard — Navigation Drawer

| Step | Action | Expected Result |
|------|--------|----------------|
| 10.1 | Open drawer (hamburger menu / swipe) | Drawer header shows "Posto POS" |
| 10.2 | Tap **Settings** | Snackbar: "Settings coming soon" |
| 10.3 | Tap **My Plan** | Navigates to `/tenant/select-plan` |
| 10.4 | **Admin Panel** (super admin only) | See step 12 |
| 10.5 | Tap **Logout** | Signs out → navigates to `/login` |

---

## 11. Dashboard — Offline Behavior

| Step | Action | Expected Result |
|------|--------|----------------|
| 11.1 | Disconnect internet while on Dashboard | Banner turns RED: "Offline — working locally" |
| 11.2 | Reconnect internet | Banner turns GREEN: "Online — connected to server" |
| 11.3 | While offline, auto-sync triggers when coming back online | If pending sync > 0, sync runs automatically |
| 11.4 | Pending count badge on banner | Shows count like "3 pending" when items queued |
| 11.5 | Start app while offline | Offline loading page: "You are offline — Data will sync when you're back online" → navigates to Dashboard |

**Files:** `connectivity_service.dart`, `template_app.dart` (`_OfflineAwareOrgLoadingPage`)

---

## 12. Data Sync — Offline Queue

| Step | Action | Expected Result |
|------|--------|----------------|
| 12.1 | Use `SupabaseRepository.create()` while offline | Data queued in SharedPreferences via `SyncService.queueForSync()` |
| 12.2 | `SyncService.syncPendingItems()` is called | Pending items sent to Supabase in order (insert, update, delete) |
| 12.3 | Queued item count appears on Dashboard | Sync Status card shows pending count |

**Files:** `sync_service.dart`, `data_repository.dart`

---

## 13. Super Admin — Access & Dashboard

| Step | Action | Expected Result |
|------|--------|----------------|
| 13.1 | Log in as a user with `super_admins` table entry | **Admin Panel** option appears in drawer |
| 13.2 | Tap **Admin Panel** | Bottom sheet: "Super Admin Panel" with "Plan Management" and "Tenant Plans" |
| 13.3 | Tap **Plan Management** | Navigates to Plan Management page |

**Files:** `dashboard_page.dart` (`_checkSuperAdmin`, `_openAdminPanel`)

---

## 14. Super Admin — Plan Management (CRUD)

| Step | Action | Expected Result |
|------|--------|----------------|
| 14.1 | View plan list | Cards showing plan name, price, billing interval, features, Active/Inactive label |
| 14.2 | Tap **FAB (+)** | Navigates to Plan Editor (new plan) |
| 14.3 | Leave name empty & save | Validation: "Plan name is required" |
| 14.4 | Leave price empty & save | Validation: "Price is required" |
| 14.5 | Enter negative price | Validation: "Enter a valid price" |
| 14.6 | Fill name, description, price $9.99, Monthly, select features & save | Plan created → list refreshes → green snackbar |
| 14.7 | Tap **Edit** icon on a plan | Navigates to Plan Editor pre-filled with plan data |
| 14.8 | Change fields & save | "Plan updated" snackbar |
| 14.9 | Tap **Toggle Active/Inactive** icon | Plan toggles between Active/Inactive state |
| 14.10 | Tap **Delete** icon | Confirmation dialog: "Are you sure?" → Delete → removed from list |
| 14.11 | Pull down to refresh | Plan list refreshes |

**Files:** `plan_management_page.dart`, `plan_editor_page.dart`, `plan_service.dart`

---

## 15. Super Admin — Tenant Plan Assignment

| Step | Action | Expected Result |
|------|--------|----------------|
| 15.1 | Open Tenant Plans from Admin Panel | List of ALL tenant organizations (not just your own) with their plan names and status |
| 15.2 | Each card shows: org name, plan name, custom features, disabled features, status badge | Data displayed correctly |
| 15.3 | Tap **Customize** | Dialog opens with feature toggles: "Enable Additional Features" + "Disable Features" |
| 15.4 | Toggle custom features & save | "Plan customized" snackbar, list refreshes |
| 15.5 | Tap **Disable** on an active tenant | Status toggles to suspended; button text changes to "Enable" |
| 15.6 | Tap **Enable** on a suspended tenant | Status toggles back to active |

**Files:** `tenant_plan_assignment_page.dart`, `tenant_plan_service.dart`

---

## 15b. Tenant Suspension Enforcement

| Step | Action | Expected Result |
|------|--------|----------------|
| 15b.1 | Super admin **Disables** a tenant plan (step 15.5) | Database status set to `suspended` |
| 15b.2 | User of that disabled tenant logs out → logs back in | Loading gate runs → detects suspended status → **blocks dashboard** → shows suspension page |
| 15b.3 | Suspension page shows | Red block icon, "Account Suspended" heading, "Your organization's plan has been suspended. Please contact support to regain access." message, "Sign Out" button |
| 15b.4 | Tap **Sign Out** on suspension page | Signs out → returns to login page |
| 15b.5 | Super admin **Enables** the tenant (step 15.6) | Database status set back to `active` |
| 15b.6 | User of that tenant logs in again | Suspension check passes → navigates to Dashboard normally |

**File:** `template_app.dart` (`_checkTenantSuspension`, `_SuspendedTenantPage`)

---

## 16. Tenant Plan Selection

| Step | Action | Expected Result |
|------|--------|----------------|
| 16.1 | Navigate to Plan Selection (`/tenant/select-plan` or Upgrade button) | Shows current plan card (if any) + available plans |
| 16.2 | View available plans | Plans show name, description, price (e.g. "$9.99/month"), feature chips |
| 16.3 | Tap **Choose Plan** on a plan (no current plan) | Confirmation dialog → "Plan selected successfully" |
| 16.4 | Tap **Choose Plan** on a different plan (has current plan) | Upgrade dialog → "Plan upgraded successfully" |
| 16.5 | If plan is already selected | Button shows "Selected" (disabled) |

**Files:** `tenant_plan_selection_page.dart`, `main.dart` (route `/tenant/select-plan`)

---

## 17. CustomTextField — Password Reveal

| Step | Action | Expected Result |
|------|--------|----------------|
| 17.1 | On any password field, the eye icon has **press-and-hold** behavior | Pressing down on eye icon reveals password; releasing hides it again |
| 17.2 | Tab away from password field | Password auto-hides |

**Files:** `custom_text_field.dart`

---

## 18. CustomButton — Loading State

| Step | Action | Expected Result |
|------|--------|----------------|
| 18.1 | Tap any submit button (Login, Create, Continue) | Button shows circular progress indicator, text hidden, button disabled |
| 18.2 | Wait for operation to complete | Button returns to normal state |

**Files:** `custom_button.dart`

---

## 19. Localization — English vs Urdu

| Step | Action | Expected Result |
|------|--------|----------------|
| 19.1 | Set locale to English | All text in English (login page, signup, dashboard, etc.) |
| 19.2 | Switch locale to Urdu via language selector | All text in Urdu (اردو) — right-to-left font applied (NotoNastaliqUrdu) |
| 19.3 | Verify specific keys: "Sign In" → "سائن ان", "Dashboard" → "ڈیش بورڈ", "Settings" → "سیٹنگز" | Translations match |

**Files:** `app_localization.dart`, `template_app.dart` (theme switching)

---

## 20. Feature Registry & Permissions

| Step | Action | Expected Result |
|------|--------|----------------|
| 20.1 | After org selection, check enabled features | Features for the business type are enabled (e.g., Restaurant gets Table Management, Kitchen Display, Waiter App) |
| 20.2 | Permissions checked per role | `admin` gets all permissions; `manager` gets view/create/edit; other roles restricted |
| 20.3 | Sync behavior varies by feature | "SECURE_AUTHENTICATION" = localFirst, "POS_REGISTER" = hybrid |

**Files:** `feature_registry.dart`, `permissions.dart`

---

## 21. SQLite Initialization (Drift)

| Step | Action | Expected Result |
|------|--------|----------------|
| 21.1 | App starts on native (Android/iOS/Windows) | SQLite database `madolalhus.sqlite` initialized via UniversalDriftSqlite |
| 21.2 | App starts on web | SQLite init silently fails (expected) — debugPrint: "SQLite initialization skipped (not supported on web)" |

**Files:** `main.dart`, `universal_drift_sqlite` package

---

## 22. Error Handling — Network/Server Errors

| Step | Action | Expected Result |
|------|--------|----------------|
| 22.1 | Start app with network errors during org loading | Error screen: "Unable to load your workspace" with error message + Retry + Sign out buttons |
| 22.2 | Tap **Retry** | Retries loading orgs |
| 22.3 | Tap **Sign out** | Signs out → navigates to `/login` |
| 22.4 | General auth errors on login | Red error banner with message + dismiss (X) button |
| 22.5 | Sign-up errors (e.g., duplicate email) | Red snackbar: "Error: [message]" |

**Files:** `template_app.dart` (_OfflineAwareOrgLoadingPage), `login_page.dart`, `operator_selection_page.dart`

---

## Summary: Test Environment

| Item | Value |
|------|-------|
| **Supabase Project** | `lxwrwhsdauzryjtemfnq.supabase.co` |
| **Auth Provider** | Email/Password (Supabase) |
| **Database Tables** | `plans`, `tenant_plans`, `organizations`, `organization_members`, `super_admins` |
| **Edge Function** | `create_organization` (RPC) |
| **Run Command** | `flutter run` or `flutter run -d chrome` |

---

## Edge Cases to Verify

1. **Rapid double-tap on submit buttons** — Button should be disabled while loading, preventing duplicate requests.
2. **Network toggle during org loading** — Should treat SocketException / connection errors as offline fallback.
3. **Empty states** — No orgs, no plans, no tenants: appropriate "not found" messages shown.
4. **Back navigation** — Onboarding flow uses `pushReplacementNamed`, so back button on Login does not return to auth gate normal flow.
5. **Language persistence** — Language survives app restart (SharedPreferences).
6. **Concurrent logins** — `AuthService` is a singleton; session state managed by Supabase.