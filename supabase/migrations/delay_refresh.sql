-- Delay refresh function
CREATE OR REPLACE FUNCTION refresh_delayed_deliveries()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER := 0;
  v_delivery RECORD;
BEGIN
  -- Verify caller is admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Only administrators can refresh delayed deliveries';
  END IF;

  FOR v_delivery IN
    SELECT id, batch_id, expected_delivery_at
    FROM deliveries
    WHERE status = 'in_transit' 
      AND expected_delivery_at < NOW()
  LOOP
    -- Mark as delayed
    UPDATE deliveries 
    SET status = 'delayed', 
        delay_reason = 'Automatically marked delayed - expected delivery time exceeded' 
    WHERE id = v_delivery.id;

    -- Update batch overall status
    UPDATE batches
    SET overall_status = 'delayed',
        current_stage = 'distribution'
    WHERE id = v_delivery.batch_id;

    -- Insert Deduplicated Alert
    INSERT INTO alerts (batch_id, delivery_id, alert_type, title, message, severity, deduplication_key)
    VALUES (
      v_delivery.batch_id, 
      v_delivery.id, 
      'delivery_delay', 
      'Delivery Delayed (Auto)', 
      'Delivery exceeded expected delivery time of ' || v_delivery.expected_delivery_at, 
      'high', 
      'delay_auto_' || v_delivery.id
    ) ON CONFLICT (deduplication_key) DO NOTHING;

    -- Insert tracking event
    INSERT INTO tracking_events (batch_id, stage, event_type, status, remarks, created_by)
    VALUES (
      v_delivery.batch_id, 
      'distribution', 
      'delay_reported', 
      'delayed', 
      'System automatically flagged delivery as delayed', 
      auth.uid()
    );

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;
