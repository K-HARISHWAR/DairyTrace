-- 004_row_level_security.sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batch_journeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

-- Helper function to get current user role
CREATE OR REPLACE FUNCTION public.get_auth_role() RETURNS public.user_role AS $$
DECLARE
  v_role public.user_role;
BEGIN
  SELECT role INTO v_role FROM public.users WHERE id = auth.uid();
  RETURN COALESCE(v_role, 'customer'::public.user_role);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Policies for users
CREATE POLICY "Users can read all users if admin" ON public.users FOR SELECT USING (public.get_auth_role() = 'admin');
CREATE POLICY "Users can read own record" ON public.users FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update own record" ON public.users FOR UPDATE USING (id = auth.uid());

-- Policies for farms
CREATE POLICY "Anyone authenticated can read farms" ON public.farms FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admins and staff can insert farms" ON public.farms FOR INSERT WITH CHECK (public.get_auth_role() IN ('admin', 'collection_staff'));
CREATE POLICY "Admins and staff can update farms" ON public.farms FOR UPDATE USING (public.get_auth_role() IN ('admin', 'collection_staff'));

-- Policies for batches
CREATE POLICY "Admins can do everything on batches" ON public.batches FOR ALL USING (public.get_auth_role() = 'admin');
CREATE POLICY "Staff can read all batches" ON public.batches FOR SELECT USING (public.get_auth_role() IN ('collection_staff', 'distributor'));
CREATE POLICY "Staff can insert batches" ON public.batches FOR INSERT WITH CHECK (public.get_auth_role() = 'collection_staff');
CREATE POLICY "Staff can update batches" ON public.batches FOR UPDATE USING (public.get_auth_role() IN ('collection_staff', 'distributor'));

-- Policies for batch_journeys
CREATE POLICY "Authenticated can read journeys" ON public.batch_journeys FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated can insert journeys" ON public.batch_journeys FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Policies for alerts
CREATE POLICY "Authenticated can read alerts" ON public.alerts FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated can insert alerts" ON public.alerts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Admins can update alerts" ON public.alerts FOR UPDATE USING (public.get_auth_role() = 'admin');
