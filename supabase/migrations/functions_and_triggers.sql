-- 10. DATABASE FUNCTIONS AND TRIGGERS

-- Updated-at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_collection_centres_modtime BEFORE UPDATE ON collection_centres FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_distributor_organisations_modtime BEFORE UPDATE ON distributor_organisations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_farms_modtime BEFORE UPDATE ON farms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quality_standards_modtime BEFORE UPDATE ON quality_standards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_batches_modtime BEFORE UPDATE ON batches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quality_checks_modtime BEFORE UPDATE ON quality_checks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_deliveries_modtime BEFORE UPDATE ON deliveries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_alerts_modtime BEFORE UPDATE ON alerts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Helper Functions
CREATE OR REPLACE FUNCTION current_profile_role()
RETURNS TEXT
LANGUAGE sql SECURITY DEFINER SET search_path = public
STABLE AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION current_collection_centre_id()
RETURNS UUID
LANGUAGE sql SECURITY DEFINER SET search_path = public
STABLE AS $$
  SELECT collection_centre_id FROM profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION current_distributor_organisation_id()
RETURNS UUID
LANGUAGE sql SECURITY DEFINER SET search_path = public
STABLE AS $$
  SELECT distributor_organisation_id FROM profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER SET search_path = public
STABLE AS $$
  SELECT current_profile_role() = 'admin';
$$;

-- Batch code generation
CREATE OR REPLACE FUNCTION generate_batch_code()
RETURNS TRIGGER AS $$
DECLARE
    date_prefix TEXT;
    seq_number INT;
BEGIN
    date_prefix := 'DTR-' || to_char(NEW.collection_time, 'YYYYMMDD') || '-';
    
    -- Find the highest sequence number for today
    SELECT COALESCE(MAX(NULLIF(regexp_replace(batch_code, '^.*-', ''), '')), '0')::INT 
    INTO seq_number
    FROM batches
    WHERE batch_code LIKE date_prefix || '%';
    
    NEW.batch_code := date_prefix || lpad((seq_number + 1)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_batch_code BEFORE INSERT ON batches FOR EACH ROW
WHEN (NEW.batch_code IS NULL OR NEW.batch_code = '')
EXECUTE FUNCTION generate_batch_code();

-- Quality Evaluation Function
CREATE OR REPLACE FUNCTION evaluate_quality()
RETURNS TRIGGER AS $$
DECLARE
    active_standard RECORD;
    is_passed BOOLEAN := true;
    has_warning BOOLEAN := false;
BEGIN
    -- Load active quality standard
    SELECT * INTO active_standard FROM quality_standards WHERE is_active = true LIMIT 1;
    
    IF NOT FOUND THEN
        NEW.evaluated_result := 'passed'; -- Default if no standard
        RETURN NEW;
    END IF;

    -- Evaluate Fat
    IF active_standard.minimum_fat_percentage IS NOT NULL AND NEW.fat_percentage IS NOT NULL THEN
        IF NEW.fat_percentage < active_standard.minimum_fat_percentage THEN
            is_passed := false;
        END IF;
    END IF;

    -- Evaluate SNF
    IF active_standard.minimum_snf_percentage IS NOT NULL AND NEW.snf_percentage IS NOT NULL THEN
        IF NEW.snf_percentage < active_standard.minimum_snf_percentage THEN
            is_passed := false;
        END IF;
    END IF;

    -- Evaluate Purity
    IF active_standard.require_purity_pass = true AND (NEW.purity_passed = false OR NEW.purity_passed IS NULL) THEN
        is_passed := false;
    END IF;

    -- Evaluate Temperature (warning)
    IF active_standard.maximum_temperature_c IS NOT NULL AND NEW.temperature_c IS NOT NULL THEN
        IF NEW.temperature_c > active_standard.maximum_temperature_c THEN
            has_warning := true;
        END IF;
    END IF;

    IF is_passed = false THEN
        NEW.evaluated_result := 'failed';
    ELSIF has_warning = true THEN
        NEW.evaluated_result := 'warning';
    ELSE
        NEW.evaluated_result := 'passed';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER evaluate_quality_trigger BEFORE INSERT ON quality_checks FOR EACH ROW EXECUTE FUNCTION evaluate_quality();

-- After quality check trigger to update batch status and create tracking event/alerts
CREATE OR REPLACE FUNCTION process_quality_check_after()
RETURNS TRIGGER 
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    new_overall_status TEXT;
    new_quality_status TEXT;
BEGIN
    -- Determine batch status based on evaluated result
    IF NEW.evaluated_result = 'failed' THEN
        new_quality_status := 'failed';
        new_overall_status := 'rejected';
    ELSIF NEW.evaluated_result = 'warning' THEN
        new_quality_status := 'passed';
        new_overall_status := 'accepted';
    ELSE
        new_quality_status := 'passed';
        new_overall_status := 'accepted';
    END IF;

    -- Update batch
    UPDATE batches SET 
        quality_status = new_quality_status,
        overall_status = new_overall_status
    WHERE id = NEW.batch_id;

    -- Insert tracking event
    INSERT INTO tracking_events (batch_id, stage, event_type, status, created_by, remarks)
    VALUES (
        NEW.batch_id, 
        NEW.checkpoint, 
        'quality_checked', 
        NEW.evaluated_result, 
        NEW.checked_by, 
        NEW.remarks
    );

    IF new_overall_status = 'rejected' THEN
        INSERT INTO tracking_events (batch_id, stage, event_type, status, created_by)
        VALUES (NEW.batch_id, NEW.checkpoint, 'rejected', 'rejected', NEW.checked_by);
    ELSIF new_overall_status = 'accepted' THEN
        INSERT INTO tracking_events (batch_id, stage, event_type, status, created_by)
        VALUES (NEW.batch_id, NEW.checkpoint, 'accepted', 'accepted', NEW.checked_by);
    END IF;

    -- Create alerts if failed or warning
    IF NEW.evaluated_result = 'failed' THEN
        INSERT INTO alerts (batch_id, alert_type, title, message, severity, deduplication_key)
        VALUES (
            NEW.batch_id, 
            'quality_failure', 
            'Quality Check Failed', 
            'Batch failed quality standards during ' || NEW.checkpoint || ' stage.', 
            'critical', 
            'quality_failure_' || NEW.batch_id
        ) ON CONFLICT (deduplication_key) WHERE is_resolved = false AND deduplication_key IS NOT NULL DO NOTHING;
    END IF;

    IF NEW.evaluated_result = 'warning' THEN
        INSERT INTO alerts (batch_id, alert_type, title, message, severity, deduplication_key)
        VALUES (
            NEW.batch_id, 
            'temperature_warning', 
            'Temperature Warning', 
            'Batch temperature exceeded recommended limits.', 
            'medium', 
            'temp_warning_' || NEW.batch_id
        ) ON CONFLICT (deduplication_key) WHERE is_resolved = false AND deduplication_key IS NOT NULL DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER after_quality_check AFTER INSERT ON quality_checks FOR EACH ROW EXECUTE FUNCTION process_quality_check_after();
