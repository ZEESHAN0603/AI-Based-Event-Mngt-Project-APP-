-- Run this script in the Supabase SQL Editor to create the admin_settings table

CREATE TABLE IF NOT EXISTS public.admin_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL UNIQUE,
    display_name TEXT DEFAULT 'TN Admin',
    timezone TEXT DEFAULT 'IST (Chennai/Kolkata)',
    theme TEXT DEFAULT 'light',
    notifications_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS if needed
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to select/insert/update their own settings
CREATE POLICY "Allow authenticated users to read admin_settings" ON public.admin_settings
    FOR SELECT USING (auth.uid() = admin_id);

CREATE POLICY "Allow authenticated users to insert admin_settings" ON public.admin_settings
    FOR INSERT WITH CHECK (auth.uid() = admin_id);

CREATE POLICY "Allow authenticated users to update admin_settings" ON public.admin_settings
    FOR UPDATE USING (auth.uid() = admin_id);
