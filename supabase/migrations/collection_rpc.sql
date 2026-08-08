-- Collection Dashboard Aggregate Stats
CREATE OR REPLACE FUNCTION get_collection_dashboard_stats(p_centre_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_stats JSONB;
BEGIN
  -- We don't strict-enforce caller ID here so admins can also view a centre's stats if needed,
  -- but RLS already protects table access if they aren't admin or staff of this centre.
  -- To be safe, let's just aggregate data the caller is allowed to see (which RLS normally handles, 
  -- but SECURITY DEFINER bypasses RLS. So we manually check auth).
  
  IF NOT is_admin() AND current_collection_centre_id() != p_centre_id THEN
    RAISE EXCEPTION 'Unauthorized to view stats for this collection centre';
  END IF;

  SELECT jsonb_build_object(
    'todayTotalLitres', COALESCE((SELECT SUM(quantity_litres) FROM batches WHERE collection_centre_id = p_centre_id AND collection_time::date = current_date), 0),
    'todayBatchCount', (SELECT count(*) FROM batches WHERE collection_centre_id = p_centre_id AND collection_time::date = current_date),
    'acceptedCount', (SELECT count(*) FROM batches WHERE collection_centre_id = p_centre_id AND overall_status IN ('accepted', 'in_progress', 'delivered')),
    'rejectedCount', (SELECT count(*) FROM batches WHERE collection_centre_id = p_centre_id AND overall_status = 'rejected'),
    'pendingQualityCount', (SELECT count(*) FROM batches WHERE collection_centre_id = p_centre_id AND quality_status = 'pending'),
    'unresolvedAlerts', (SELECT count(*) FROM alerts a JOIN batches b ON a.batch_id = b.id WHERE b.collection_centre_id = p_centre_id AND a.is_resolved = false)
  ) INTO v_stats;

  RETURN v_stats;
END;
$$;
