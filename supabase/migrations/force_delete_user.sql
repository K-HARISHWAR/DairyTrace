DO $$
DECLARE
    v_staff_id UUID;
BEGIN
    -- Find the corrupted user
    SELECT id INTO v_staff_id FROM auth.users WHERE email = 'staff@dairytrace.com' LIMIT 1;
    
    IF v_staff_id IS NOT NULL THEN
        -- 1. Delete all dummy tracking events created by this user
        DELETE FROM public.tracking_events WHERE created_by = v_staff_id;
        
        -- 2. Delete all dummy quality checks checked by this user
        DELETE FROM public.quality_checks WHERE checked_by = v_staff_id;
        
        -- 3. Delete all dummy batches created by this user
        DELETE FROM public.batches WHERE created_by = v_staff_id;
        
        -- 4. Delete all dummy farms created by this user
        DELETE FROM public.farms WHERE created_by = v_staff_id;
        
        -- 5. Delete the user's profile
        DELETE FROM public.profiles WHERE id = v_staff_id;
        
        -- 6. Delete any partial identities
        DELETE FROM auth.identities WHERE user_id = v_staff_id;
        
        -- 7. FINALLY delete the actual user from auth.users
        DELETE FROM auth.users WHERE id = v_staff_id;
        
        RAISE NOTICE 'Successfully forcefully deleted the corrupted user and all associated data.';
    ELSE
        RAISE NOTICE 'User staff@dairytrace.com not found. Nothing to delete.';
    END IF;
END $$;
