ALTER TABLE collection_centres ENABLE ROW LEVEL SECURITY;
ALTER TABLE distributor_organisations ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_standards ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_notifications ENABLE ROW LEVEL SECURITY;

-- 12. ROW LEVEL SECURITY

-- Profiles
CREATE POLICY "Admin can read all profiles" ON profiles FOR SELECT USING (is_admin());
CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Admin can update profiles" ON profiles FOR UPDATE USING (is_admin());

-- Collection Centres
CREATE POLICY "Admin can read all centres" ON collection_centres FOR SELECT USING (is_admin());
CREATE POLICY "Admin can manage all centres" ON collection_centres FOR ALL USING (is_admin());
CREATE POLICY "Staff can read assigned centre" ON collection_centres FOR SELECT USING (id = current_collection_centre_id());

-- Distributor Organisations
CREATE POLICY "Admin can manage distributor orgs" ON distributor_organisations FOR ALL USING (is_admin());
CREATE POLICY "Distributor can read own org" ON distributor_organisations FOR SELECT USING (id = current_distributor_organisation_id());

-- Farms
CREATE POLICY "Admin can manage farms" ON farms FOR ALL USING (is_admin());
CREATE POLICY "Staff can read farms in their centre" ON farms FOR SELECT USING (collection_centre_id = current_collection_centre_id());
CREATE POLICY "Staff can insert farms for their centre" ON farms FOR INSERT WITH CHECK (collection_centre_id = current_collection_centre_id() AND created_by = auth.uid());
CREATE POLICY "Staff can update farms in their centre" ON farms FOR UPDATE USING (collection_centre_id = current_collection_centre_id());

-- Quality Standards
CREATE POLICY "Admin can manage quality standards" ON quality_standards FOR ALL USING (is_admin());
CREATE POLICY "Anyone authenticated can read quality standards" ON quality_standards FOR SELECT USING (auth.role() = 'authenticated');

-- Batches
CREATE POLICY "Admin can manage batches" ON batches FOR ALL USING (is_admin());
CREATE POLICY "Staff can read batches in their centre" ON batches FOR SELECT USING (collection_centre_id = current_collection_centre_id());
CREATE POLICY "Staff can create batches for their centre" ON batches FOR INSERT WITH CHECK (collection_centre_id = current_collection_centre_id() AND created_by = auth.uid());
CREATE POLICY "Staff can update batches in their centre" ON batches FOR UPDATE USING (collection_centre_id = current_collection_centre_id());
CREATE POLICY "Distributors can view assigned batches" ON batches FOR SELECT USING (
  EXISTS (SELECT 1 FROM deliveries WHERE deliveries.batch_id = batches.id AND deliveries.assigned_to = auth.uid())
);

-- Quality checks
CREATE POLICY "Admin can manage quality checks" ON quality_checks FOR ALL USING (is_admin());
CREATE POLICY "Staff can read quality checks in their centre" ON quality_checks FOR SELECT USING (
  EXISTS (SELECT 1 FROM batches WHERE batches.id = quality_checks.batch_id AND batches.collection_centre_id = current_collection_centre_id())
);
CREATE POLICY "Staff can insert quality checks" ON quality_checks FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM batches WHERE batches.id = batch_id AND batches.collection_centre_id = current_collection_centre_id())
  AND checked_by = auth.uid()
);
CREATE POLICY "Distributors can view quality checks of assigned batches" ON quality_checks FOR SELECT USING (
  EXISTS (SELECT 1 FROM deliveries WHERE deliveries.batch_id = quality_checks.batch_id AND deliveries.assigned_to = auth.uid())
);

-- Tracking Events
CREATE POLICY "Admin can manage tracking events" ON tracking_events FOR ALL USING (is_admin());
CREATE POLICY "Staff can read tracking events for their centre" ON tracking_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM batches WHERE batches.id = tracking_events.batch_id AND batches.collection_centre_id = current_collection_centre_id())
);
CREATE POLICY "Staff can insert tracking events for their centre" ON tracking_events FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM batches WHERE batches.id = batch_id AND batches.collection_centre_id = current_collection_centre_id())
  AND created_by = auth.uid()
);
CREATE POLICY "Distributors can read tracking events of assigned batches" ON tracking_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM deliveries WHERE deliveries.batch_id = tracking_events.batch_id AND deliveries.assigned_to = auth.uid())
);

-- Deliveries
CREATE POLICY "Admin can manage deliveries" ON deliveries FOR ALL USING (is_admin());
CREATE POLICY "Distributor can read assigned deliveries" ON deliveries FOR SELECT USING (assigned_to = auth.uid());
CREATE POLICY "Staff can read deliveries for their batches" ON deliveries FOR SELECT USING (
  EXISTS (SELECT 1 FROM batches WHERE batches.id = deliveries.batch_id AND batches.collection_centre_id = current_collection_centre_id())
);

-- Alerts
CREATE POLICY "Admin can manage alerts" ON alerts FOR ALL USING (is_admin());
CREATE POLICY "Staff can read alerts for their centre" ON alerts FOR SELECT USING (collection_centre_id = current_collection_centre_id());
CREATE POLICY "Distributors can read alerts for their deliveries" ON alerts FOR SELECT USING (
  EXISTS (SELECT 1 FROM deliveries WHERE deliveries.id = alerts.delivery_id AND deliveries.assigned_to = auth.uid())
);

-- App Notifications
CREATE POLICY "Users can read own notifications" ON app_notifications FOR SELECT USING (recipient_profile_id = auth.uid());
CREATE POLICY "Users can update own notifications" ON app_notifications FOR UPDATE USING (recipient_profile_id = auth.uid());
CREATE POLICY "Admin can read all notifications" ON app_notifications FOR SELECT USING (is_admin());
