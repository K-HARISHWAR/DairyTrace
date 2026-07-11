-- 007_dashboard_functions.sql
CREATE OR REPLACE FUNCTION public.get_admin_dashboard_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_batches INT;
    v_active_alerts INT;
    v_total_farms INT;
    v_rejected_batches INT;
BEGIN
    IF public.get_auth_role() != 'admin' THEN
        RAISE EXCEPTION 'Access denied';
    END IF;

    SELECT COUNT(*) INTO v_total_batches FROM public.batches;
    SELECT COUNT(*) INTO v_active_alerts FROM public.alerts WHERE is_resolved = false;
    SELECT COUNT(*) INTO v_total_farms FROM public.farms;
    SELECT COUNT(*) INTO v_rejected_batches FROM public.batches WHERE quality_result = 'fail';

    RETURN jsonb_build_object(
        'total_batches', v_total_batches,
        'active_alerts', v_active_alerts,
        'total_farms', v_total_farms,
        'rejected_batches', v_rejected_batches
    );
END;
$$;
