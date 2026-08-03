-- seed.sql

-- Safe First-Admin Bootstrap Approach
-- ---------------------------------------------------------------------------------
-- 1. Create your first authentication user manually in the Supabase Dashboard
--    (Authentication -> Users -> Add user -> Create new user).
-- 2. Copy the newly created user's UUID.
-- 3. Run the following SQL block in the Supabase SQL Editor, replacing the placeholder
--    with the UUID from step 2 to create the Admin profile:
--
-- INSERT INTO public.profiles (id, full_name, email, role, is_active, created_at)
-- VALUES (
--   'REPLACE_WITH_AUTH_USER_UUID',
--   'DairyTrace Admin',
--   'admin@dairytrace.com',
--   'admin',
--   true,
--   NOW()
-- );
-- ---------------------------------------------------------------------------------

DO $$
DECLARE
  cc_1_id UUID := uuid_generate_v4();
  cc_2_id UUID := uuid_generate_v4();
  dist_1_id UUID := uuid_generate_v4();
  dist_2_id UUID := uuid_generate_v4();
  farm_1_id UUID := uuid_generate_v4();
  farm_2_id UUID := uuid_generate_v4();
  farm_3_id UUID := uuid_generate_v4();
  batch_1_id UUID := uuid_generate_v4();
  batch_2_id UUID := uuid_generate_v4();
  batch_3_id UUID := uuid_generate_v4();
  batch_4_id UUID := uuid_generate_v4();
  batch_5_id UUID := uuid_generate_v4();
  delivery_1_id UUID := uuid_generate_v4();
  delivery_2_id UUID := uuid_generate_v4();
BEGIN
  -- Insert Collection Centres
  INSERT INTO public.collection_centres (id, name, location, contact_number, manager_name) VALUES
  (cc_1_id, 'North Valley Collection Hub', 'North Valley Region', '+1234567890', 'Manager One'),
  (cc_2_id, 'South Hill Dairy Center', 'South Hill Region', '+1234567891', 'Manager Two');

  -- Insert Distributor Organisations
  INSERT INTO public.distributor_organisations (id, name, location, contact_number, manager_name) VALUES
  (dist_1_id, 'Fresh Dairy Logistics', 'City Center', '+1987654321', 'Dist Manager One'),
  (dist_2_id, 'Regional Supply Chain Co.', 'West Side', '+1987654322', 'Dist Manager Two');

  -- Insert Farms
  INSERT INTO public.farms (id, farm_name, farmer_name, phone, address, location_lat, location_lng, is_active) VALUES
  (farm_1_id, 'Green Pastures', 'John Doe', '+1122334455', 'Route 1', 37.1, -122.1, true),
  (farm_2_id, 'Sunny Acres', 'Jane Smith', '+1122334456', 'Route 2', 37.2, -122.2, true),
  (farm_3_id, 'Valley View Farm', 'Bob Brown', '+1122334457', 'Route 3', 37.3, -122.3, true);

  -- Insert Quality Standard (Demonstration)
  INSERT INTO public.quality_standards (id, name, min_fat, max_fat, min_snf, max_snf, min_density, max_density, min_temperature, max_temperature, is_active) VALUES
  (uuid_generate_v4(), 'Standard Grade A', 3.0, 5.5, 8.0, 10.0, 1.026, 1.034, 2.0, 8.0, true);

  -- Insert Batches (various statuses)
  -- 1. Pending Quality
  INSERT INTO public.batches (id, batch_code, collection_centre_id, farm_id, quantity_litres, stage, status, collected_at) VALUES
  (batch_1_id, 'B-PEND-001', cc_1_id, farm_1_id, 100.5, 'collection', 'pending_quality', NOW() - INTERVAL '2 hours');
  
  -- 2. Accepted (Quality Checked)
  INSERT INTO public.batches (id, batch_code, collection_centre_id, farm_id, quantity_litres, stage, status, collected_at) VALUES
  (batch_2_id, 'B-ACC-001', cc_1_id, farm_2_id, 250.0, 'quality_check', 'accepted', NOW() - INTERVAL '5 hours');
  
  INSERT INTO public.quality_checks (id, batch_id, checked_at, fat_percentage, snf_percentage, density, temperature, status) VALUES
  (uuid_generate_v4(), batch_2_id, NOW() - INTERVAL '4 hours', 4.2, 8.5, 1.028, 4.0, 'passed');

  -- 3. Rejected
  INSERT INTO public.batches (id, batch_code, collection_centre_id, farm_id, quantity_litres, stage, status, collected_at) VALUES
  (batch_3_id, 'B-REJ-001', cc_2_id, farm_3_id, 50.0, 'quality_check', 'rejected', NOW() - INTERVAL '1 day');
  
  INSERT INTO public.quality_checks (id, batch_id, checked_at, fat_percentage, snf_percentage, density, temperature, status, remarks) VALUES
  (uuid_generate_v4(), batch_3_id, NOW() - INTERVAL '23 hours', 2.0, 7.0, 1.020, 10.0, 'failed', 'Low fat and high temperature');

  -- 4. In Progress (Delivery assigned)
  INSERT INTO public.batches (id, batch_code, collection_centre_id, farm_id, quantity_litres, stage, status, collected_at) VALUES
  (batch_4_id, 'B-PROG-001', cc_1_id, farm_1_id, 500.0, 'transit', 'in_progress', NOW() - INTERVAL '2 days');

  INSERT INTO public.deliveries (id, batch_id, distributor_organisation_id, assigned_at, status, vehicle_number) VALUES
  (delivery_1_id, batch_4_id, dist_1_id, NOW() - INTERVAL '1 day', 'in_transit', 'TRUCK-123');

  -- 5. Delivered
  INSERT INTO public.batches (id, batch_code, collection_centre_id, farm_id, quantity_litres, stage, status, collected_at) VALUES
  (batch_5_id, 'B-DEL-001', cc_2_id, farm_2_id, 300.0, 'delivered', 'delivered', NOW() - INTERVAL '3 days');

  INSERT INTO public.deliveries (id, batch_id, distributor_organisation_id, assigned_at, status, vehicle_number, delivered_at) VALUES
  (delivery_2_id, batch_5_id, dist_2_id, NOW() - INTERVAL '2 days', 'delivered', 'TRUCK-456', NOW() - INTERVAL '1 day');

  -- Insert Tracking Events
  INSERT INTO public.tracking_events (id, batch_id, stage, occurred_at, location_name) VALUES
  (uuid_generate_v4(), batch_4_id, 'collection', NOW() - INTERVAL '2 days', 'North Valley Hub'),
  (uuid_generate_v4(), batch_4_id, 'quality_check', NOW() - INTERVAL '1 day', 'North Valley Hub'),
  (uuid_generate_v4(), batch_4_id, 'transit', NOW() - INTERVAL '12 hours', 'On Route A');

  -- Insert Alerts
  INSERT INTO public.alerts (id, title, message, severity, alert_type, batch_id, is_resolved, created_at) VALUES
  (uuid_generate_v4(), 'Quality Check Failed', 'Batch B-REJ-001 failed quality check due to temperature.', 'high', 'quality', batch_3_id, true, NOW() - INTERVAL '23 hours'),
  (uuid_generate_v4(), 'Delivery Delayed', 'Truck-123 reporting traffic delay.', 'medium', 'delivery', batch_4_id, false, NOW() - INTERVAL '1 hour');
END $$;
