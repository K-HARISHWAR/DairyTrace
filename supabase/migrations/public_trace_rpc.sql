-- 11. PUBLIC CUSTOMER TRACE RPC
-- get_public_batch_trace(p_public_token uuid)

CREATE OR REPLACE FUNCTION get_public_batch_trace(p_public_token UUID)
RETURNS JSONB
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT CASE WHEN b.id IS NULL THEN '{}'::jsonb ELSE
    jsonb_build_object(
      'verified', true,
      'batch', jsonb_build_object(
        'batch_code', b.batch_code,
        'farm_name', f.farm_name,
        'farm_village', f.village,
        'collection_centre_name', cc.name,
        'collection_time', b.collection_time,
        'current_stage', b.current_stage,
        'overall_status', b.overall_status,
        'quality_status', b.quality_status
      ),
      'qualityChecks', (
          SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
              'checkpoint', qc.checkpoint,
              'evaluated_result', qc.evaluated_result,
              'purity_passed', qc.purity_passed,
              'checked_at', qc.checked_at
            ) ORDER BY qc.checked_at DESC
          ), '[]'::jsonb)
          FROM quality_checks qc WHERE qc.batch_id = b.id
      ),
      'journey', (
          SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
              'stage', te.stage,
              'event_type', te.event_type,
              'status', te.status,
              'location_name', te.location_name,
              'occurred_at', te.occurred_at,
              'public_remarks', te.remarks
            ) ORDER BY te.occurred_at DESC
          ), '[]'::jsonb)
          FROM tracking_events te WHERE te.batch_id = b.id
      ),
      'delivery', (
          SELECT jsonb_build_object(
            'status', d.status,
            'expected_delivery_at', d.expected_delivery_at,
            'actual_delivery_at', d.actual_delivery_at
          )
          FROM deliveries d WHERE d.batch_id = b.id AND d.status != 'cancelled' LIMIT 1
      )
    )
  END
  FROM batches b
  JOIN farms f ON b.farm_id = f.id
  JOIN collection_centres cc ON b.collection_centre_id = cc.id
  WHERE b.public_token = p_public_token;
$$;
