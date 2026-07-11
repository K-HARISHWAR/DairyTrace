-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- Enable PostGIS for later location features if needed, though we will just use lat/lng floats for simplicity now.
-- CREATE EXTENSION IF NOT EXISTS "postgis";

-- ENUMS
CREATE TYPE user_role AS ENUM ('admin', 'collection_staff', 'distributor', 'customer');
CREATE TYPE batch_stage AS ENUM ('registered', 'quality_check', 'accepted', 'rejected', 'in_transit', 'delayed', 'delivered');
CREATE TYPE quality_result AS ENUM ('pending', 'pass', 'fail');
CREATE TYPE delivery_status AS ENUM ('pending', 'in_transit', 'delayed', 'delivered');
CREATE TYPE alert_severity AS ENUM ('low', 'medium', 'high', 'critical');
