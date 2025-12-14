-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('mentor', 'mentee')),
  bio TEXT,
  avatar_url TEXT,
  expertise_areas TEXT[], -- Array of expertise tags
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Focus areas table (predefined coaching categories)
CREATE TABLE focus_areas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  icon TEXT, -- Icon identifier or URL
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Appointments table
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mentor_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  mentee_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_time_range CHECK (end_time > start_time),
  CONSTRAINT no_self_appointment CHECK (mentor_id != mentee_id)
);

-- Messages table (for chat functionality)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT no_self_message CHECK (sender_id != receiver_id)
);

-- Reviews table
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mentor_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  mentee_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  appointment_id UUID REFERENCES appointments(id) ON DELETE SET NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_flagged BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT no_self_review CHECK (mentor_id != mentee_id),
  UNIQUE(appointment_id, mentee_id) -- One review per appointment per mentee
);

-- Profiles indexes
CREATE INDEX idx_profiles_role ON profiles(role);

-- Appointments indexes
CREATE INDEX idx_appointments_mentor_id ON appointments(mentor_id);
CREATE INDEX idx_appointments_mentee_id ON appointments(mentee_id);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_mentor_status ON appointments(mentor_id, status);

-- Messages indexes
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_conversation ON messages(sender_id, receiver_id, created_at DESC);

-- Reviews indexes
CREATE INDEX idx_reviews_mentor_id ON reviews(mentor_id);
CREATE INDEX idx_reviews_mentee_id ON reviews(mentee_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_flagged ON reviews(is_flagged) WHERE is_flagged = TRUE;

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE focus_areas ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Appointments policies
CREATE POLICY "Users can view their own appointments" ON appointments
  FOR SELECT USING (
    auth.uid() = mentor_id OR auth.uid() = mentee_id
  );

CREATE POLICY "Mentees can create appointments" ON appointments
  FOR INSERT WITH CHECK (auth.uid() = mentee_id);

CREATE POLICY "Users can update their own appointments" ON appointments
  FOR UPDATE USING (
    auth.uid() = mentor_id OR auth.uid() = mentee_id
  );

CREATE POLICY "Users can delete their own appointments" ON appointments
  FOR DELETE USING (
    auth.uid() = mentor_id OR auth.uid() = mentee_id
  );

-- Messages policies
CREATE POLICY "Users can view their own messages" ON messages
  FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

CREATE POLICY "Users can send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Receivers can update read status" ON messages
  FOR UPDATE USING (auth.uid() = receiver_id);

-- Reviews policies
CREATE POLICY "Anyone can view reviews" ON reviews
  FOR SELECT USING (true);

CREATE POLICY "Mentees can create reviews for their appointments" ON reviews
  FOR INSERT WITH CHECK (
    auth.uid() = mentee_id AND
    EXISTS (
      SELECT 1
      FROM appointments
      WHERE appointments.id = reviews.appointment_id
        AND appointments.mentee_id = auth.uid()
        AND appointments.status = 'completed'
    )
  );

CREATE POLICY "Mentees can update their own reviews" ON reviews
  FOR UPDATE USING (auth.uid() = mentee_id);

CREATE POLICY "Mentees can delete their own reviews" ON reviews
  FOR DELETE USING (auth.uid() = mentee_id);

-- Focus areas policies (read-only for all users)
CREATE POLICY "Anyone can view focus areas" ON focus_areas
  FOR SELECT USING (true);

-- Enable Realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Function to check if a mentor is available for a given time slot
CREATE OR REPLACE FUNCTION check_mentor_availability(
  p_mentor_id UUID,
  p_start_time TIMESTAMPTZ,
  p_end_time TIMESTAMPTZ
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if there are any overlapping appointments
  RETURN NOT EXISTS (
    SELECT 1
    FROM appointments
    WHERE mentor_id = p_mentor_id
      AND status IN ('pending', 'confirmed')
      AND (
        -- New appointment starts during existing appointment
        (p_start_time >= start_time AND p_start_time < end_time)
        OR
        -- New appointment ends during existing appointment
        (p_end_time > start_time AND p_end_time <= end_time)
        OR
        -- New appointment completely overlaps existing appointment
        (p_start_time <= start_time AND p_end_time >= end_time)
      )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function to get mentor's upcoming availability slots (helper for UI)
CREATE OR REPLACE FUNCTION get_mentor_booked_slots(
  p_mentor_id UUID,
  p_start_date TIMESTAMPTZ,
  p_end_date TIMESTAMPTZ
)
RETURNS TABLE (
  appointment_id UUID,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  status TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    id,
    appointments.start_time,
    appointments.end_time,
    appointments.status
  FROM appointments
  WHERE mentor_id = p_mentor_id
    AND appointments.status IN ('pending', 'confirmed')
    AND appointments.end_time > p_start_date 
    AND appointments.start_time < p_end_date
  ORDER BY appointments.start_time;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to appointments
CREATE TRIGGER update_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Seed Initial Focus Areas Data
INSERT INTO focus_areas (name, icon) VALUES
  ('Career Guidance', 'work'),
  ('Academic Support', 'school'),
  ('Mental Wellness', 'favorite'),
  ('Life Skills', 'lightbulb'),
  ('Relationship Advice', 'people'),
  ('Financial Planning', 'attach_money')
ON CONFLICT (name) DO NOTHING;
