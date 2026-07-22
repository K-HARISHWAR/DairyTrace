-- 1. Admin Dashboard Aggregate Stats
CREATE OR REPLACE FUNCTION get_admin_dashboard_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_stats JSONB;
BEGIN
  SELECT is_admin() INTO v_is_admin;
  IF NOT v_is_admin THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT jsonb_build_object(
    'totalActiveBatches', (SELECT count(*) FROM batches WHERE overall_status = 'in_progress'),
    'batchesCollectedToday', (SELECT count(*) FROM batches WHERE collection_time::date = current_date),
    'acceptedBatches', (SELECT count(*) FROM batches WHERE overall_status = 'accepted' OR overall_status = 'in_progress' OR overall_status = 'delivered'),
    'rejectedBatches', (SELECT count(*) FROM batches WHERE overall_status = 'rejected'),
    'inTransitDeliveries', (SELECT count(*) FROM deliveries WHERE status = 'in_transit'),
    'delayedDeliveries', (SELECT count(*) FROM deliveries WHERE status = 'delayed'),
    'unresolvedAlerts', (SELECT count(*) FROM alerts WHERE is_resolved = false),
    'highCriticalAlerts', (SELECT count(*) FROM alerts WHERE is_resolved = false AND severity IN ('high', 'critical'))
  ) INTO v_stats;

  RETURN v_stats;
END;
$$;

-- 2. Daily Collection Volume
CREATE OR REPLACE FUNCTION get_daily_collection_volume(days INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_result JSONB;
BEGIN
  SELECT is_admin() INTO v_is_admin;
  IF NOT v_is_admin THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT jsonb_agg(
    jsonb_build_object(
      'date', collection_date,
      'volume', total_volume
    )
  ) INTO v_result
  FROM (
    SELECT 
      collection_time::date AS collection_date, 
      COALESCE(SUM(quantity_litres), 0) AS total_volume
    FROM batches
    WHERE collection_time >= (NOW() - (days || ' days')::interval)
    GROUP BY collection_time::date
    ORDER BY collection_date ASC
  ) subquery;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- 3. Rejection Trend
CREATE OR REPLACE FUNCTION get_rejection_trend(days INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_result JSONB;
BEGIN
  SELECT is_admin() INTO v_is_admin;
  IF NOT v_is_admin THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT jsonb_agg(
    jsonb_build_object(
      'date', collection_date,
      'accepted', accepted_count,
      'rejected', rejected_count
    )
  ) INTO v_result
  FROM (
    SELECT 
      collection_time::date AS collection_date, 
      COUNT(*) FILTER (WHERE overall_status != 'rejected') AS accepted_count,
      COUNT(*) FILTER (WHERE overall_status = 'rejected') AS rejected_count
    FROM batches
    WHERE collection_time >= (NOW() - (days || ' days')::interval)
    GROUP BY collection_time::date
    ORDER BY collection_date ASC
  ) subquery;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- 4. Quality Standards constraint trigger
CREATE OR REPLACE FUNCTION ensure_single_active_quality_standard()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_active = true THEN
    UPDATE quality_standards 
    SET is_active = false 
    WHERE id != NEW.id AND is_active = true;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS single_active_quality_standard_trigger ON quality_standards;
CREATE TRIGGER single_active_quality_standard_trigger
  BEFORE INSERT OR UPDATE ON quality_standards
  FOR EACH ROW
  WHEN (NEW.is_active = true)
  EXECUTE FUNCTION ensure_single_active_quality_standard();
