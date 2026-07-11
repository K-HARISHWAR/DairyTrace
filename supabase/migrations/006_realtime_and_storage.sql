-- 006_realtime_and_storage.sql

-- Enable Realtime for batches and alerts
ALTER PUBLICATION supabase_realtime ADD TABLE public.batches;
ALTER PUBLICATION supabase_realtime ADD TABLE public.alerts;

-- Set up storage (optional, e.g. for farm photos later)
INSERT INTO storage.buckets (id, name, public) VALUES ('farm_images', 'farm_images', true) ON CONFLICT DO NOTHING;

CREATE POLICY "Public Access to farm images" ON storage.objects FOR SELECT USING (bucket_id = 'farm_images');
CREATE POLICY "Authenticated users can upload farm images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'farm_images' AND auth.uid() IS NOT NULL);
