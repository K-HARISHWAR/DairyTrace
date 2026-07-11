-- seed.sql

-- Enable pgcrypto for password hashing if not already
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Insert Admin User (Password: Password123!)
DO $$
DECLARE
  admin_uid UUID := uuid_generate_v4();
BEGIN
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000', admin_uid, 'authenticated', 'authenticated', 'admin@dairytrace.com',
    crypt('Password123!', gen_salt('bf')),
    NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW(), '', '', '', ''
  );

  INSERT INTO auth.identities (id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (uuid_generate_v4(), admin_uid, format('{"sub":"%s","email":"%s"}', admin_uid::text, 'admin@dairytrace.com')::jsonb, 'email', NOW(), NOW(), NOW());

  INSERT INTO public.users (id, email, full_name, phone, role)
  VALUES (admin_uid, 'admin@dairytrace.com', 'System Admin', '+1234567890', 'admin');

  -- Seed a Collection Center Staff (Password: Password123!)
  DECLARE
    staff_uid UUID := uuid_generate_v4();
  BEGIN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', staff_uid, 'authenticated', 'authenticated', 'staff@dairytrace.com',
      crypt('Password123!', gen_salt('bf')),
      NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW(), '', '', '', ''
    );

    INSERT INTO auth.identities (id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), staff_uid, format('{"sub":"%s","email":"%s"}', staff_uid::text, 'staff@dairytrace.com')::jsonb, 'email', NOW(), NOW(), NOW());

    INSERT INTO public.users (id, email, full_name, phone, role)
    VALUES (staff_uid, 'staff@dairytrace.com', 'Collection Staff 1', '+1987654321', 'collection_staff');

    -- Seed a farm
    INSERT INTO public.farms (id, farmer_name, phone, address, location_lat, location_lng, registered_by)
    VALUES (uuid_generate_v4(), 'Green Valley Farm', '+1122334455', '123 Meadow Lane', 37.7749, -122.4194, staff_uid);
  END;

  -- Seed a Distributor (Password: Password123!)
  DECLARE
    dist_uid UUID := uuid_generate_v4();
  BEGIN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', dist_uid, 'authenticated', 'authenticated', 'distributor@dairytrace.com',
      crypt('Password123!', gen_salt('bf')),
      NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW(), '', '', '', ''
    );

    INSERT INTO auth.identities (id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), dist_uid, format('{"sub":"%s","email":"%s"}', dist_uid::text, 'distributor@dairytrace.com')::jsonb, 'email', NOW(), NOW(), NOW());

    INSERT INTO public.users (id, email, full_name, phone, role)
    VALUES (dist_uid, 'distributor@dairytrace.com', 'Fast Delivery Co', '+1555666777', 'distributor');
  END;
END $$;
