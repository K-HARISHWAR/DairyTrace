-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 9.1 Collection centres
CREATE TABLE collection_centres (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    centre_code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    address TEXT,
    village TEXT,
    district TEXT,
    state TEXT,
    postal_code TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_collection_centres_code ON collection_centres(centre_code);
CREATE INDEX idx_collection_centres_name ON collection_centres(name);
CREATE INDEX idx_collection_centres_active ON collection_centres(is_active);

-- 9.2 Distributor organisations
CREATE TABLE distributor_organisations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    distributor_code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    address TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9.3 Profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL CHECK (role IN ('admin', 'collection_staff', 'distributor')),
    collection_centre_id UUID REFERENCES collection_centres(id),
    distributor_organisation_id UUID REFERENCES distributor_organisations(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_collection_staff CHECK (role != 'collection_staff' OR collection_centre_id IS NOT NULL),
    CONSTRAINT valid_distributor CHECK (role != 'distributor' OR distributor_organisation_id IS NOT NULL)
);

-- 9.4 Farms
CREATE TABLE farms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_code TEXT UNIQUE NOT NULL,
    farm_name TEXT NOT NULL,
    owner_name TEXT NOT NULL,
    phone TEXT,
    village TEXT NOT NULL,
    district TEXT,
    state TEXT,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    collection_centre_id UUID NOT NULL REFERENCES collection_centres(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9.5 Quality standards
CREATE TABLE quality_standards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    minimum_fat_percentage NUMERIC(5,2),
    minimum_snf_percentage NUMERIC(5,2),
    maximum_temperature_c NUMERIC(5,2),
    require_purity_pass BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_unique_active_standard ON quality_standards(is_active) WHERE is_active = true;

-- 9.6 Batches
CREATE TABLE batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_code TEXT UNIQUE NOT NULL,
    public_token UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    farm_id UUID NOT NULL REFERENCES farms(id),
    collection_centre_id UUID NOT NULL REFERENCES collection_centres(id),
    quantity_litres NUMERIC(12,2) NOT NULL CHECK (quantity_litres > 0),
    collection_time TIMESTAMPTZ NOT NULL,
    current_stage TEXT NOT NULL DEFAULT 'collection' CHECK (current_stage IN ('collection', 'chilling', 'processing', 'packaging', 'distribution', 'delivered')),
    overall_status TEXT NOT NULL DEFAULT 'pending_quality' CHECK (overall_status IN ('pending_quality', 'accepted', 'rejected', 'in_progress', 'delayed', 'spoiled', 'delivered')),
    quality_status TEXT NOT NULL DEFAULT 'pending' CHECK (quality_status IN ('pending', 'passed', 'failed')),
    notes TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_batches_code ON batches(batch_code);
CREATE INDEX idx_batches_token ON batches(public_token);
CREATE INDEX idx_batches_farm ON batches(farm_id);
CREATE INDEX idx_batches_centre ON batches(collection_centre_id);
CREATE INDEX idx_batches_time ON batches(collection_time);
CREATE INDEX idx_batches_stage ON batches(current_stage);
CREATE INDEX idx_batches_status ON batches(overall_status);
CREATE INDEX idx_batches_quality ON batches(quality_status);

-- 9.7 Quality checks
CREATE TABLE quality_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    checkpoint TEXT NOT NULL CHECK (checkpoint IN ('collection', 'chilling', 'processing', 'packaging', 'distribution')),
    fat_percentage NUMERIC(5,2),
    snf_percentage NUMERIC(5,2),
    temperature_c NUMERIC(5,2),
    purity_passed BOOLEAN,
    manual_result TEXT,
    evaluated_result TEXT NOT NULL CHECK (evaluated_result IN ('passed', 'failed', 'warning')),
    remarks TEXT,
    checked_by UUID NOT NULL REFERENCES profiles(id),
    checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9.8 Tracking events
CREATE TABLE tracking_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    stage TEXT NOT NULL CHECK (stage IN ('collection', 'chilling', 'processing', 'packaging', 'distribution', 'delivered')),
    event_type TEXT NOT NULL,
    status TEXT NOT NULL,
    location_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    remarks TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id),
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_tracking_batch ON tracking_events(batch_id);
CREATE INDEX idx_tracking_stage ON tracking_events(stage);
CREATE INDEX idx_tracking_type ON tracking_events(event_type);
CREATE INDEX idx_tracking_occurred ON tracking_events(occurred_at);

-- 9.9 Deliveries
CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES batches(id),
    distributor_organisation_id UUID NOT NULL REFERENCES distributor_organisations(id),
    assigned_to UUID NOT NULL REFERENCES profiles(id),
    vehicle_number TEXT,
    driver_name TEXT,
    driver_phone TEXT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expected_pickup_at TIMESTAMPTZ,
    actual_pickup_at TIMESTAMPTZ,
    expected_delivery_at TIMESTAMPTZ,
    actual_delivery_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'picked_up', 'in_transit', 'delayed', 'delivered', 'cancelled')),
    delay_reason TEXT,
    delivery_notes TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_active_delivery ON deliveries(batch_id) WHERE status != 'cancelled';

-- 9.10 Alerts
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
    delivery_id UUID REFERENCES deliveries(id) ON DELETE CASCADE,
    collection_centre_id UUID REFERENCES collection_centres(id),
    alert_type TEXT NOT NULL CHECK (alert_type IN ('quality_failure', 'temperature_warning', 'purity_failure', 'batch_rejected', 'batch_spoiled', 'delivery_delay', 'system')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('info', 'low', 'medium', 'high', 'critical')),
    is_resolved BOOLEAN NOT NULL DEFAULT false,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES profiles(id),
    deduplication_key TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_unresolved_alerts_dedup ON alerts(deduplication_key) WHERE is_resolved = false AND deduplication_key IS NOT NULL;

-- 9.11 App notifications
CREATE TABLE app_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL,
    related_batch_id UUID REFERENCES batches(id),
    related_alert_id UUID REFERENCES alerts(id),
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
