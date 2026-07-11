-- USERS TABLE
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role user_role NOT NULL DEFAULT 'customer'::user_role,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- FARMS TABLE
CREATE TABLE public.farms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    registered_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- BATCHES TABLE
CREATE TABLE public.batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_code TEXT UNIQUE, -- Human readable
    qr_token TEXT UNIQUE, -- Secure token for public access
    farm_id UUID REFERENCES public.farms(id) ON DELETE CASCADE,
    created_by UUID REFERENCES public.users(id),
    distributor_id UUID REFERENCES public.users(id),
    quantity_liters DOUBLE PRECISION NOT NULL,
    temperature_celsius DOUBLE PRECISION,
    fat_percentage DOUBLE PRECISION,
    snf_percentage DOUBLE PRECISION,
    quality_result quality_result NOT NULL DEFAULT 'pending'::quality_result,
    stage batch_stage NOT NULL DEFAULT 'registered'::batch_stage,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- BATCH JOURNEYS TABLE
CREATE TABLE public.batch_journeys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    stage batch_stage NOT NULL,
    recorded_by UUID REFERENCES public.users(id),
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    notes TEXT,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ALERTS TABLE
CREATE TABLE public.alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_id UUID REFERENCES public.batches(id) ON DELETE CASCADE,
    severity alert_severity NOT NULL DEFAULT 'low'::alert_severity,
    message TEXT NOT NULL,
    is_resolved BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);
