-- update_delivery_status RPC
CREATE OR REPLACE FUNCTION update_delivery_status(
  p_delivery_id UUID,
  p_status TEXT,
  p_delay_reason TEXT DEFAULT NULL,
  p_location_name TEXT DEFAULT NULL,
  p_latitude DOUBLE PRECISION DEFAULT NULL,
  p_longitude DOUBLE PRECISION DEFAULT NULL,
  p_notes TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_delivery deliveries%ROWTYPE;
  v_user_id UUID := auth.uid();
  v_is_admin BOOLEAN;
  v_batch_stage TEXT;
  v_batch_overall_status TEXT;
  v_event_type TEXT;
BEGIN
  -- Verify caller
  SELECT is_admin() INTO v_is_admin;
  
  SELECT * INTO v_delivery FROM deliveries WHERE id = p_delivery_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Delivery not found';
  END IF;

  IF NOT v_is_admin AND v_delivery.assigned_to != v_user_id THEN
    RAISE EXCEPTION 'Not authorized to update this delivery';
  END IF;

  -- Allowed transition validation
  IF p_status = 'picked_up' AND v_delivery.status != 'assigned' THEN
    RAISE EXCEPTION 'Can only mark as picked up from assigned state';
  ELSIF p_status = 'in_transit' AND v_delivery.status NOT IN ('picked_up', 'delayed') THEN
    RAISE EXCEPTION 'Can only mark in transit from picked up or delayed state';
  ELSIF p_status = 'delayed' AND v_delivery.status NOT IN ('in_transit') THEN
    RAISE EXCEPTION 'Can only mark delayed from in transit state';
  ELSIF p_status = 'delivered' AND v_delivery.status NOT IN ('in_transit', 'delayed') THEN
    RAISE EXCEPTION 'Can only mark delivered from in transit or delayed state';
  END IF;

  -- Update delivery timestamps
  IF p_status = 'picked_up' THEN
    UPDATE deliveries SET actual_pickup_at = NOW(), status = p_status, delivery_notes = COALESCE(p_notes, delivery_notes) WHERE id = p_delivery_id;
    v_batch_stage := 'distribution';
    v_batch_overall_status := 'in_progress';
    v_event_type := 'picked_up';
  ELSIF p_status = 'in_transit' THEN
    UPDATE deliveries SET status = p_status, delivery_notes = COALESCE(p_notes, delivery_notes) WHERE id = p_delivery_id;
    v_batch_stage := 'distribution';
    v_batch_overall_status := 'in_progress';
    v_event_type := 'in_transit';
  ELSIF p_status = 'delayed' THEN
    UPDATE deliveries SET status = p_status, delay_reason = p_delay_reason, delivery_notes = COALESCE(p_notes, delivery_notes) WHERE id = p_delivery_id;
    v_batch_stage := 'distribution';
    v_batch_overall_status := 'delayed';
    v_event_type := 'delay_reported';
  ELSIF p_status = 'delivered' THEN
    UPDATE deliveries SET actual_delivery_at = NOW(), status = p_status, delivery_notes = COALESCE(p_notes, delivery_notes) WHERE id = p_delivery_id;
    v_batch_stage := 'delivered';
    v_batch_overall_status := 'delivered';
    v_event_type := 'delivered';
  END IF;

  -- Update batch stage and status
  UPDATE batches SET current_stage = v_batch_stage, overall_status = v_batch_overall_status WHERE id = v_delivery.batch_id;

  -- Insert tracking event
  INSERT INTO tracking_events (batch_id, stage, event_type, status, location_name, latitude, longitude, remarks, created_by)
  VALUES (
    v_delivery.batch_id, 
    'distribution', 
    v_event_type, 
    p_status, 
    p_location_name, 
    p_latitude, 
    p_longitude, 
    COALESCE(p_notes, p_delay_reason), 
    v_user_id
  );

  -- Create alert if delayed
  IF p_status = 'delayed' THEN
    INSERT INTO alerts (batch_id, delivery_id, alert_type, title, message, severity, deduplication_key)
    VALUES (
      v_delivery.batch_id, 
      v_delivery.id, 
      'delivery_delay', 
      'Delivery Delayed', 
      'Delivery delayed. Reason: ' || COALESCE(p_delay_reason, 'Unknown'), 
      'high', 
      'delay_' || v_delivery.id || '_' || EXTRACT(EPOCH FROM NOW())::TEXT
    );
  END IF;

  SELECT row_to_json(d) INTO v_delivery FROM deliveries d WHERE id = p_delivery_id;
  RETURN to_jsonb(v_delivery);
END;
$$;
