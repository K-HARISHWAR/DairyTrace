-- TRIGGER FOR UPDATED_AT
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_farms_updated_at
BEFORE UPDATE ON public.farms
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_batches_updated_at
BEFORE UPDATE ON public.batches
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FUNCTION TO GENERATE BATCH CODE AND TOKEN
CREATE OR REPLACE FUNCTION generate_batch_identifiers()
RETURNS TRIGGER AS $$
DECLARE
    new_code TEXT;
    new_token TEXT;
BEGIN
    IF NEW.batch_code IS NULL THEN
        -- Generate something like BATCH-YYYYMMDD-XXXX
        new_code := 'BATCH-' || to_char(NOW(), 'YYYYMMDD') || '-' || upper(substring(md5(random()::text) from 1 for 4));
        NEW.batch_code := new_code;
    END IF;

    IF NEW.qr_token IS NULL THEN
        -- Generate a secure random token
        new_token := encode(gen_random_bytes(16), 'hex');
        NEW.qr_token := new_token;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_batch_identifiers
BEFORE INSERT ON public.batches
FOR EACH ROW EXECUTE FUNCTION generate_batch_identifiers();

-- FUNCTION TO AUTO-RECORD JOURNEY ON STAGE CHANGE
CREATE OR REPLACE FUNCTION record_batch_journey()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.stage IS DISTINCT FROM NEW.stage THEN
        INSERT INTO public.batch_journeys (batch_id, stage, recorded_by, notes)
        VALUES (NEW.id, NEW.stage, NEW.updated_by_user_id, 'Stage automatically updated to ' || NEW.stage);
        -- Note: updated_by_user_id is a concept, but since we don't track who updated exactly in the trigger easily without passing it,
        -- we will just let the app insert journey records explicitly.
        -- So let's skip the auto-trigger for journey and rely on the app to insert journey records.
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- We won't use the auto-journey trigger, the app should insert into batch_journeys to attach lat/lng.
