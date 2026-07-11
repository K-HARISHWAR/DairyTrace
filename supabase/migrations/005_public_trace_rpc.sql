-- 005_public_trace_rpc.sql
-- Function to fetch safe public data using qr_token
CREATE OR REPLACE FUNCTION public.get_public_batch_trace(p_qr_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_batch RECORD;
    v_journeys JSONB;
    v_result JSONB;
BEGIN
    -- Find batch
    SELECT 
        b.id, b.batch_code, b.quantity_liters, b.quality_result, b.stage, b.created_at, b.temperature_celsius, b.fat_percentage, b.snf_percentage,
        f.farmer_name
    INTO v_batch
    FROM public.batches b
    JOIN public.farms f ON b.farm_id = f.id
    WHERE b.qr_token = p_qr_token;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- Find journeys
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'stage', j.stage,
            'recorded_at', j.recorded_at,
            'location_lat', NULL, -- Omit for privacy
            'location_lng', NULL  -- Omit for privacy
        ) ORDER BY j.recorded_at ASC
    ), '[]'::jsonb)
    INTO v_journeys
    FROM public.batch_journeys j
    WHERE j.batch_id = v_batch.id;

    -- Build result
    v_result := jsonb_build_object(
        'batch_code', v_batch.batch_code,
        'quantity_liters', v_batch.quantity_liters,
        'quality_result', v_batch.quality_result,
        'stage', v_batch.stage,
        'created_at', v_batch.created_at,
        'temperature_celsius', v_batch.temperature_celsius,
        'fat_percentage', v_batch.fat_percentage,
        'snf_percentage', v_batch.snf_percentage,
        -- Obfuscate farmer name for privacy
        'farmer_name', SUBSTRING(v_batch.farmer_name FROM 1 FOR 1) || '***',
        'journeys', v_journeys
    );

    RETURN v_result;
END;
$$;
