-- Storage Setup for batch-documents

-- Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public) 
VALUES ('batch-documents', 'batch-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Set up RLS for the bucket
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to view files in batch-documents
CREATE POLICY "Allow authenticated users to view batch-documents" 
ON storage.objects FOR SELECT 
TO authenticated 
USING (bucket_id = 'batch-documents');

-- Policy: Allow collection_staff and admin to insert files in batch-documents
CREATE POLICY "Allow collection staff and admin to upload batch-documents" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (
  bucket_id = 'batch-documents' 
  AND (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() AND profiles.role IN ('admin', 'collection_staff')
    )
  )
);

-- Policy: Allow collection_staff and admin to update files
CREATE POLICY "Allow collection staff and admin to update batch-documents" 
ON storage.objects FOR UPDATE
TO authenticated 
USING (
  bucket_id = 'batch-documents' 
  AND (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() AND profiles.role IN ('admin', 'collection_staff')
    )
  )
);

-- Policy: Allow admin to delete files
CREATE POLICY "Allow admin to delete batch-documents" 
ON storage.objects FOR DELETE
TO authenticated 
USING (
  bucket_id = 'batch-documents' 
  AND (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  )
);
