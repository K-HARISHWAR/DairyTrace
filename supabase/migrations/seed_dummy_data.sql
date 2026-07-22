-- SEED DUMMY DATA FOR COLLECTION MODULE
-- This script will dynamically find the staff user, their collection centre, 
-- and insert 3 farms, 15 batches, and the associated quality/tracking events.
-- 1. Fix Database Schema Bug (Missing Unique Constraint on Alerts)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'alerts_deduplication_key_key'
    ) THEN
        ALTER TABLE public.alerts ADD CONSTRAINT alerts_deduplication_key_key UNIQUE (deduplication_key);
    END IF;
END $$;

-- 2. Seed Data Script
DO $$
DECLARE
    v_staff_id UUID;
    v_centre_id UUID;
    v_farm_1 UUID := gen_random_uuid();
    v_farm_2 UUID := gen_random_uuid();
    v_farm_3 UUID := gen_random_uuid();
BEGIN
    -- 1. Try to find the staff user
    SELECT id INTO v_staff_id FROM auth.users WHERE email = 'staff@dairytrace.com' LIMIT 1;
    
    -- 2. If staff isn't found, instruct the user to create them via the app!
    IF v_staff_id IS NULL THEN
        RAISE EXCEPTION 'Staff user not found! Please log in as admin@dairytrace.com and use the Create User UI to create staff@dairytrace.com before running this script.';
    END IF;

    -- 2. Find the collection centre for this staff member
    SELECT collection_centre_id INTO v_centre_id FROM public.profiles WHERE id = v_staff_id LIMIT 1;
    
    IF v_centre_id IS NULL THEN
        RAISE EXCEPTION 'Staff user does not have an assigned collection centre.';
    END IF;

    -- 3. Delete existing dummy farms (and batches) so script is idempotent
    DELETE FROM public.batches WHERE farm_id IN (
        SELECT id FROM public.farms WHERE farm_code IN ('FRM-7832', 'FRM-4412', 'FRM-9910')
    );
    DELETE FROM public.farms WHERE farm_code IN ('FRM-7832', 'FRM-4412', 'FRM-9910');

    -- 4. Insert 3 Dummy Farms
    INSERT INTO public.farms (id, farm_code, farm_name, owner_name, phone, village, district, state, collection_centre_id, created_by, is_active)
    VALUES 
    (v_farm_1, 'FRM-7832', 'Green Valley Dairy', 'Rajesh Kumar', '9876543210', 'Kondapur', 'Hyderabad', 'Telangana', v_centre_id, v_staff_id, true),
    (v_farm_2, 'FRM-4412', 'Sunrise Milks', 'Anita Desai', '9876543211', 'Madhapur', 'Hyderabad', 'Telangana', v_centre_id, v_staff_id, true),
    (v_farm_3, 'FRM-9910', 'Heritage Farm', 'Srinivas Rao', '9876543212', 'Gachibowli', 'Hyderabad', 'Telangana', v_centre_id, v_staff_id, true);

    -- 5. Loop to insert 15 Batches
    FOR i IN 1..15 LOOP
        DECLARE
            v_batch_id UUID := gen_random_uuid();
            v_farm_id UUID;
            v_qty DECIMAL;
            v_fat DECIMAL;
            v_snf DECIMAL;
            v_temp DECIMAL;
        BEGIN
            -- Pick one of the 3 farms in a round-robin way
            IF i % 3 = 0 THEN 
                v_farm_id := v_farm_1;
            ELSIF i % 3 = 1 THEN 
                v_farm_id := v_farm_2;
            ELSE 
                v_farm_id := v_farm_3;
            END IF;

            -- Generate random metrics
            v_qty := floor(random() * 400 + 100); -- 100L to 500L
            v_fat := floor(random() * 4 + 3);     -- 3% to 7%
            v_snf := floor(random() * 2 + 7.5);   -- 7.5% to 9.5%
            v_temp := floor(random() * 5 + 2);    -- 2°C to 7°C

            -- Insert the batch
            INSERT INTO public.batches (
                id, batch_code, farm_id, collection_centre_id, quantity_litres, 
                collection_time, created_by, current_stage, overall_status, quality_status
            ) VALUES (
                v_batch_id, 
                'BCH-' || to_char(now(), 'YYYYMMDD') || '-' || lpad(i::text, 4, '0') || '-' || substr(md5(random()::text), 1, 4), 
                v_farm_id, 
                v_centre_id, 
                v_qty, 
                now() - (i || ' hours')::interval, -- Space them out in time
                v_staff_id, 
                'collection', 
                'in_progress', 
                'pending'
            );

            -- Insert Initial Tracking Event (Batch registered)
            INSERT INTO public.tracking_events (batch_id, stage, event_type, status, created_by, remarks, occurred_at)
            VALUES (v_batch_id, 'collection', 'batch_created', 'registered', v_staff_id, 'Seeded dummy batch', now() - (i || ' hours')::interval);

            -- Insert Quality Check (This automatically fires the evaluate_quality() trigger to update batch quality_status)
            INSERT INTO public.quality_checks (
                batch_id, checkpoint, fat_percentage, snf_percentage, temperature_c, purity_passed, checked_by, checked_at
            ) VALUES (
                v_batch_id, 'collection', v_fat, v_snf, v_temp, true, v_staff_id, now() - (i || ' hours')::interval + interval '10 minutes'
            );

            -- Progress some batches to the 'chilling' and 'processing' stages
            IF i % 2 = 0 THEN
                UPDATE public.batches SET current_stage = 'chilling' WHERE id = v_batch_id;
                
                INSERT INTO public.tracking_events (batch_id, stage, event_type, status, created_by, remarks, occurred_at)
                VALUES (v_batch_id, 'chilling', 'standard_chill', 'completed', v_staff_id, 'Chilling process complete', now() - (i || ' hours')::interval + interval '1 hour');
            END IF;

            IF i % 4 = 0 THEN
                UPDATE public.batches SET current_stage = 'processing' WHERE id = v_batch_id;
                
                INSERT INTO public.tracking_events (batch_id, stage, event_type, status, created_by, remarks, occurred_at)
                VALUES (v_batch_id, 'processing', 'pasteurization', 'completed', v_staff_id, 'Pasteurization complete', now() - (i || ' hours')::interval + interval '3 hours');
            END IF;
            
        END;
    END LOOP;

END $$;
