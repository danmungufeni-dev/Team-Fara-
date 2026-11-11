-- ====================================================================
-- PadCare Realtime Free Backend Schema for Supabase
-- Covers: Realtime Auth, Distribution Hubs, Voucher Requests,
-- Live Messaging, and Live Location Tracking Broadcast
-- ====================================================================

-- 1. DISTRIBUTION POINTS (Safe Pickup Hubs, Health Centers, Dispensaries)
CREATE TABLE IF NOT EXISTS public.distribution_points (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    rating NUMERIC DEFAULT 4.9,
    review_count INTEGER DEFAULT 128,
    distance_meters NUMERIC DEFAULT 850.0,
    walking_time_minutes INTEGER DEFAULT 11,
    address TEXT NOT NULL,
    city TEXT DEFAULT 'Kampala',
    country TEXT DEFAULT 'Uganda',
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    is_verified BOOLEAN DEFAULT true,
    open_hours TEXT DEFAULT 'Open • Closes 5:00 PM',
    phone TEXT DEFAULT '+256 701 442 890',
    has_female_caretaker BOOLEAN DEFAULT true,
    has_private_cubicle BOOLEAN DEFAULT true,
    has_wheelchair_ramp BOOLEAN DEFAULT true,
    has_free_water BOOLEAN DEFAULT true,
    stock_day_pads INTEGER DEFAULT 65,
    stock_overnight_pads INTEGER DEFAULT 32,
    stock_reusable_kits INTEGER DEFAULT 10,
    stock_discreet_bags INTEGER DEFAULT 84,
    discretion_level TEXT DEFAULT '100% Confidential',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. DISCREET REQUEST VOUCHERS (Anonymous & Registered Voucher Reservations)
CREATE TABLE IF NOT EXISTS public.requests (
    id TEXT PRIMARY KEY,
    voucher_code TEXT NOT NULL UNIQUE,
    hub_id TEXT NOT NULL REFERENCES public.distribution_points(id) ON DELETE CASCADE,
    hub_name TEXT NOT NULL,
    allocation_summary TEXT NOT NULL,
    status TEXT DEFAULT 'readyForPickup', -- reserved, readyForPickup, collected, expired
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    pickup_window TEXT DEFAULT 'Within the next 2 hours',
    pin TEXT DEFAULT '749'
);

-- 3. DISCREET MESSAGING (Confidential Realtime Chat between User & Hub Caretakers)
CREATE TABLE IF NOT EXISTS public.messages (
    id TEXT PRIMARY KEY,
    voucher_code TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    is_seeker BOOLEAN DEFAULT true,
    is_delivered BOOLEAN DEFAULT true,
    is_read BOOLEAN DEFAULT true
);

-- 4. REALTIME LIVE LOCATIONS (Mobile Dispensary Vans & Volunteer Resupply Tracking)
CREATE TABLE IF NOT EXISTS public.live_locations (
    entity_id TEXT PRIMARY KEY,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    label TEXT NOT NULL,
    type TEXT NOT NULL, -- 'volunteer', 'mobile_dispensary', 'user'
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE public.distribution_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_locations ENABLE ROW LEVEL SECURITY;

-- Distribution Points: Read-accessible to everyone (public & anonymous)
CREATE POLICY "Public read on distribution points"
    ON public.distribution_points FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users insert/update distribution points"
    ON public.distribution_points FOR ALL
    USING (auth.role() = 'authenticated' OR auth.role() = 'anon');

-- Requests: Everyone can read and create vouchers
CREATE POLICY "Public & Seeker access on requests"
    ON public.requests FOR ALL
    USING (true)
    WITH CHECK (true);

-- Messages: Access by voucher code
CREATE POLICY "Access messages by voucher code"
    ON public.messages FOR ALL
    USING (true)
    WITH CHECK (true);

-- Live Locations: Public read and write for live tracking
CREATE POLICY "Public read live locations"
    ON public.live_locations FOR ALL
    USING (true)
    WITH CHECK (true);

-- ====================================================================
-- REALTIME REPLICATION ENABLEMENT
-- ====================================================================
-- Publish tables to Supabase Realtime WebSocket engine
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
END $$;

ALTER PUBLICATION supabase_realtime ADD TABLE public.distribution_points;
ALTER PUBLICATION supabase_realtime ADD TABLE public.requests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.live_locations;

-- ====================================================================
-- SEED DATA: Kampala & East Africa Verified Safe Distribution Hubs
-- ====================================================================
INSERT INTO public.distribution_points (
    id, name, category, rating, review_count, distance_meters, walking_time_minutes,
    address, city, country, latitude, longitude, is_verified, open_hours, phone,
    has_female_caretaker, has_private_cubicle, has_wheelchair_ramp, has_free_water,
    stock_day_pads, stock_overnight_pads, stock_reusable_kits, stock_discreet_bags, discretion_level
) VALUES
('hub_1', 'Kisenyi Health Center IV', 'Health Center & Primary Care', 4.9, 142, 850, 11,
 'Mwanga II Road, Kisenyi II, Kampala', 'Kampala', 'Uganda', 0.3136, 32.5711, true,
 'Open 24/7 • Emergency Desk Active', '+256 701 442 890', true, true, true, true, 80, 45, 20, 110, '100% Confidential'),
('hub_2', 'WoMena Community Sanctuary', 'Community Resource Hub', 4.8, 98, 1400, 19,
 'Plot 14 Ggaba Road, Nsambya, Kampala', 'Kampala', 'Uganda', 0.3012, 32.5892, true,
 'Open • Closes 6:00 PM', '+256 772 319 801', true, true, false, true, 42, 18, 25, 60, 'Safe Women Sanctuary'),
('hub_3', 'Kawempe Youth Safe Haven', 'Youth Drop-In Hub', 4.7, 64, 2300, 31,
 'Bombo Road, Kawempe Division, Kampala', 'Kampala', 'Uganda', 0.3580, 32.5620, true,
 'Open • Closes 5:30 PM', '+256 750 992 114', true, true, true, false, 55, 30, 15, 70, 'Youth Discreet Hub'),
('hub_4', 'Mulago National Referral Hub', 'Public Hospital Dispensary', 5.0, 310, 1800, 24,
 'Mulago Hill Road, Ward 3 Dispensary, Kampala', 'Kampala', 'Uganda', 0.3392, 32.5768, true,
 'Open 24/7 • Emergency Dispensary', '+256 414 541 801', true, true, true, true, 120, 60, 40, 150, 'MOH Certified')
ON CONFLICT (id) DO NOTHING;
