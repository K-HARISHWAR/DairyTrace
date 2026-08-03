# SQL Verification Tests

These manual SQL tests verify the correctness of the Row Level Security (RLS) policies and business logic implemented via triggers and RPCs in the DairyTrace database.

Execute these queries in the Supabase SQL Editor. You will need to substitute `auth.uid()` or impersonate specific roles to verify isolation rules.

## 1. Role-Based Isolation

### Collection Staff Isolation
**Objective**: Ensure collection staff can only see their center's batches.
```sql
-- Impersonate a Collection Staff member
SET request.jwt.claim.sub = '<STAFF_UUID>';
SET request.jwt.claim.role = 'authenticated';

-- Attempt to read all batches
SELECT count(*) FROM public.batches;
-- Expected: The count should strictly match only the batches assigned to their `collection_centre_id`.

-- Attempt to read farms from another center
SELECT count(*) FROM public.farms;
-- Expected: Should only see farms they registered or are assigned to their center.
```

### Distributor Isolation
**Objective**: Ensure distributors can only see deliveries assigned to them.
```sql
-- Impersonate a Distributor
SET request.jwt.claim.sub = '<DISTRIBUTOR_UUID>';
SET request.jwt.claim.role = 'authenticated';

-- Attempt to view deliveries
SELECT count(*) FROM public.deliveries;
-- Expected: Should only count deliveries assigned to their `distributor_organisation_id`.
```

## 2. Anonymous Access Restrictions

### Prevent Anonymous Table Access
**Objective**: Ensure unauthenticated users cannot read private tables directly.
```sql
-- Ensure anon role is used
SET role anon;

-- Attempt to read batches directly
SELECT * FROM public.batches LIMIT 1;
-- Expected: Error (permission denied) or 0 rows returned due to RLS.

-- Attempt to read profiles
SELECT * FROM public.profiles LIMIT 1;
-- Expected: Error or 0 rows returned.
```

### Allow Public Trace via RPC
**Objective**: Anonymous users should only access trace data through the specific RPC function.
```sql
-- Using anon role
SET role anon;

-- Execute trace RPC
SELECT * FROM public.get_public_batch_trace('VALID_QR_UUID');
-- Expected: Successful execution returning public trace data, without exposing private tables directly.
```

## 3. Data Integrity & Validation

### Batch-Code Uniqueness
**Objective**: Ensure the system prevents duplicate batch codes.
```sql
-- As an Admin or authenticated user
-- Insert batch 1
INSERT INTO public.batches (batch_code, collection_centre_id, farm_id, quantity_litres, stage, status) 
VALUES ('TEST-DUP-01', '<CC_ID>', '<FARM_ID>', 100, 'collection', 'pending_quality');

-- Attempt to insert batch 2 with same code
INSERT INTO public.batches (batch_code, collection_centre_id, farm_id, quantity_litres, stage, status) 
VALUES ('TEST-DUP-01', '<CC_ID>', '<FARM_ID>', 200, 'collection', 'pending_quality');
-- Expected: Database constraint violation error on `batch_code`.
```

### Self-Role Escalation Prevention
**Objective**: Users cannot change their own role or bypass admin creation checks.
```sql
-- Impersonate a regular user
SET request.jwt.claim.sub = '<USER_UUID>';

-- Attempt to update own role to admin
UPDATE public.profiles SET role = 'admin' WHERE id = '<USER_UUID>';
-- Expected: Operation fails due to RLS restriction (only admins can update roles).
```

### Delivery Transition Enforcement
**Objective**: A delivery cannot be marked as "delivered" unless it was previously "in_transit" or assigned.
```sql
-- Attempt to execute status update via RPC (assuming RPC implements this logic)
SELECT update_delivery_status('<DELIVERY_UUID>', 'delivered', null, 'Target', 0.0, 0.0, null);
-- Note: Check the specific implementation logic. If implemented, invalid state jumps should throw an exception.
```

### Duplicate Alert Prevention
**Objective**: Avoid spamming identical active alerts.
```sql
-- Assuming a trigger or RPC creates alerts on failure:
-- Repeatedly inserting a failed quality check for the same batch should ideally either update the existing unresolved alert or not create an identical duplicate if constrained. 
```
