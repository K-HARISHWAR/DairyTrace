# DairyTrace

DairyTrace is a Flutter application designed for tracking and managing the dairy supply chain, from collection to delivery, with role-based access for Admins, Collection Staff, and Distributors.

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Supabase project for backend services

### Database Setup

Run the migrations in `supabase/migrations/` in your Supabase project to create the required tables, RPCs, and Row Level Security (RLS) policies.

You can also run `supabase/seed.sql` to populate your database with dummy collection centres, farms, distributor organisations, batches, quality checks, deliveries, and alerts. Note that `seed.sql` does **not** insert fake authentication users for security reasons.

### First Admin Setup (Safe Bootstrap)

To bootstrap the application and create your first administrative user safely, follow these steps:

1. **Create Auth User:** Open your Supabase Dashboard, navigate to **Authentication -> Users -> Add user -> Create new user**, and create a user with a secure password.
2. **Copy UUID:** Once created, copy the newly generated user's **User UID**.
3. **Insert Admin Profile:** Open the **SQL Editor** in Supabase and run the following snippet, replacing the placeholder with the UUID from step 2:

```sql
INSERT INTO public.profiles (
  id,
  full_name,
  email,
  role,
  is_active
)
VALUES (
  'REPLACE_WITH_AUTH_USER_UUID',
  'DairyTrace Admin',
  'admin@example.com',
  'admin',
  true
);
```

4. **Login:** You can now log into the Flutter application using the credentials created in step 1. Because your profile has the `admin` role, you will be routed to the Admin Dashboard.
5. **Subsequent Users:** Use the protected "User Management" screen within the Admin dashboard to safely create further staff and distributor accounts.

### Running the App

```bash
flutter pub get
flutter run
```

## Testing

To verify code quality and tests, run:
```bash
dart format .
flutter analyze
flutter test
```
