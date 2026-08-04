# DairyTrace

DairyTrace is a Flutter-based supply chain transparency application designed specifically for the dairy industry. It provides real-time tracking, quality assurance, and role-based management from raw milk collection at the farm to final delivery to distribution centers.

## Features
- **Collection Workflow:** Staff can register farms, log batches, input quantities, and record quality parameters (fat %, SNF %, temperature, purity).
- **Automated Quality Evaluation:** The database securely evaluates batch quality against standard thresholds.
- **QR Code Generation & Public Traceability:** Generates opaque QR codes. Consumers can scan these codes to view a sanitized public journey of their milk without exposing private farm details.
- **Distribution Management:** Admins can assign approved batches to distributors. Distributors manage delivery statuses (pickup, in transit, delayed, delivered).
- **Role-Based Access Control:** Distinct workflows for Admins, Collection Staff, Distributors, and anonymous consumers.
- **Real-Time Alerts:** Automated real-time notifications for quality failures, delays, or temperature warnings.

## Architecture
The application uses a robust client-server architecture:
- **Frontend:** Flutter (Dart) using Riverpod for reactive state management, GoRouter for role-based navigation, and Material Design 3.
- **Backend:** Supabase (PostgreSQL).
- **Security:** Strict Row Level Security (RLS) handles authorization entirely at the database layer. No backend secrets are exposed to the Flutter app.
- **API Access:** Supabase SDK handles real-time subscriptions, standard queries, and secure Remote Procedure Calls (RPCs) for complex operations.

## User Roles
1. **Admin:** Full oversight. Can view all metrics, manage quality standards, create staff users, assign deliveries, and resolve alerts.
2. **Collection Staff:** Operates at a specific collection centre. Can register farms, log batches, and run quality checks for their assigned centre.
3. **Distributor:** Handles logistics. Can only view deliveries specifically assigned to them and update transit statuses.
4. **Consumer (Public):** Anonymous users who scan QR codes. They only have read-only access to a sanitized public trace view via a secure RPC.

## Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- Android Studio or standard Android SDK tools (for running the Android app)
- A Supabase Project (Create one for free at [supabase.com](https://supabase.com))

---

## Supabase Setup

### 1. Supabase Project Setup
Log in to your Supabase dashboard and create a new project. 
Take note of your **Project URL** and **anon public key** (Found under Project Settings -> API).

### 2. Supabase CLI Setup
Open a terminal in the root of the project.
```bash
# Login to Supabase CLI (this will open a browser window to authenticate)
supabase login

# Link the local project to your remote Supabase project
# You can find your PROJECT_REF in your Supabase dashboard URL (e.g., https://supabase.com/dashboard/project/YOUR_PROJECT_REF)
supabase link --project-ref YOUR_PROJECT_REF
```

### 3. Applying Migrations
Apply the database schema, functions, triggers, and RLS policies to your live project:
```bash
supabase db push
```
*Note: We handle storage manually via the dashboard. Please go to your Supabase Storage dashboard, create a bucket named `batch-documents`, and mark it as Private. The migrations will have already attached the security policies to it.*

### 4. Seeding Development Data (Optional but Recommended)
To populate dummy collection centres, farms, distributor organisations, batches, quality checks, deliveries, and alerts, copy the contents of `supabase/seed.sql` and run it manually in the **SQL Editor** on your Supabase web dashboard.

### 5. Deploying the Edge Function
The admin user-creation function runs securely on Supabase Edge Functions. Deploy it using:
```bash
supabase functions deploy admin-create-user --no-verify-jwt
```
*(Ensure you have set the `SUPABASE_SERVICE_ROLE_KEY` secret in your edge function environment if required by your setup).*

---

## Bootstrap & Environment Setup

### 1. Bootstrapping the First Admin
Because the app strictly prevents self-role escalation, you must manually create your first admin user.
1. In the Supabase Dashboard, go to **Authentication -> Users -> Add user -> Create new user**. Create an account (e.g., `admin@dairytrace.com`) with a password.
2. Copy the newly generated **User UID**.
3. Open the **SQL Editor** in the dashboard and run:
```sql
INSERT INTO public.profiles (id, full_name, email, role, is_active)
VALUES ('PASTE_UID_HERE', 'System Admin', 'admin@dairytrace.com', 'admin', true);
```

### 2. Creating Staff Users
Once you log in to the Flutter app using the admin account created above, you can use the protected **User Management** screen within the Admin dashboard to safely invite and create further staff and distributor accounts using the Edge Function.

### 3. Environment Variables
You do not need to hardcode API keys in the source code. Pass them directly when building or running the app using `--dart-define`.

---

## Running the Android App

```bash
flutter pub get

# Run the app, injecting your Supabase credentials securely
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_ANON_KEY
```

### Required Android Permissions
The Android application (`android/app/src/main/AndroidManifest.xml`) requires the following permissions for full functionality:
- `android.permission.INTERNET` (API connectivity)
- `android.permission.CAMERA` (QR Code scanning)
- `android.permission.ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION` (Geotagging journey events)
- `android.permission.POST_NOTIFICATIONS` (Local background alerts)

---

## Security Model

### RLS Security Model
- **Mandatory RLS:** Row Level Security is enabled on **all** exposed tables.
- **Minimum Privileges:** Users can only query data matching their explicit assignments (e.g., staff can only read/write batches corresponding to their `collection_centre_id`). Distributors can only read batches assigned to them via the `deliveries` table.
- **Append-Only History:** Journey tracking events and quality checks are strictly append-only for ordinary users. Only admins have delete privileges.
- **Database-Authoritative:** Quality evaluations (Pass/Fail) are enforced via database constraints and triggers, not relying on the client application to make authoritative decisions.
- **Explicit Functions:** RPCs specify strict `search_path` and `SECURITY DEFINER` constraints where needed.

### Public QR Privacy Model
- **Opaque Public Token:** The QR code embeds an opaque UUID (`public_token`) rather than an easily guessable sequential ID.
- **Sanitized RPC:** Direct table access by anonymous users is blocked. Consumers fetch data via the `get_public_batch_trace` RPC, which deliberately strips out private data like exact farm owner names, precise coordinates, or internal business notes.
- **No Precise GPS:** The public output sanitizes GPS data to a generic string or rounds coordinates to protect farm privacy.

### Demonstration Quality-Standard Disclaimer
> **Disclaimer:** The active quality standard seeded by default (e.g., 3.5% Fat, 8.5% SNF) is strictly for **demonstration purposes**. In a production deployment, an Admin must log in and adjust the Quality Standards module to reflect the actual regulatory or business requirements of the dairy operation.

---

## Testing & Quality Assurance

Run the included tests and static analysis:
```bash
# Formats all dart code
dart format .

# Checks for logic/syntax errors (must pass with 0 errors)
flutter analyze

# Runs widget and unit tests
flutter test
```

---

## Demo Workflow
1. Launch the app and log in as the Admin.
2. Navigate to **Quality Standards** and ensure one is active.
3. Log out, log in as a Collection Staff member.
4. From the Collection Dashboard, tap **Create Batch**. Select a farm, input quantity, and complete a quality check (ensuring it passes the active standard).
5. Open the **Batch Details** of your new batch to generate the QR code.
6. Open the app on a separate device without logging in, tap **Scan QR Trace**, and scan the code.
7. Log back in as Admin, assign the batch to a Distributor.
8. Log in as the Distributor and update the transit status to "Delivered".

## Common Troubleshooting

- **Error: 42P01: relation "public.users" does not exist**
  Ensure you are querying `public.profiles` in your SQL commands, as Supabase manages `auth.users` separately from our public profile table.
- **"Must be owner of table objects" during storage migrations**
  Supabase handles RLS on `storage.objects` natively. Create the bucket via the dashboard instead of using raw SQL `ALTER TABLE` statements on storage.
- **App hangs on Splash Screen**
  Ensure you passed the `--dart-define` flags correctly when running the app. The routing readiness provider blocks navigation until it can ping the Supabase client.

## Future Improvements
- **Offline Sync:** Implementing a local SQLite cache (e.g., Drift) to allow collection staff to log batches in areas without cellular connectivity, syncing when online.
- **Push Notifications:** Migrating from local notifications to FCM (Firebase Cloud Messaging) for remote alerts via Supabase Edge Functions.
- **Hardware Integrations:** Connecting the app to Bluetooth-enabled milk analyzers or weighing scales to prevent manual data entry errors.
- **Advanced Analytics:** Adding predictive ML models for milk spoilage based on transit delays and temperature data.
