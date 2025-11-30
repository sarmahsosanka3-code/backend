-- Create patients table
CREATE TABLE public.patients (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  contact TEXT NOT NULL,
  email TEXT,
  address TEXT,
  age INTEGER,
  gender TEXT,
  blood_group TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create appointments table
CREATE TABLE public.appointments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id UUID REFERENCES public.patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  contact TEXT NOT NULL,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  department TEXT,
  doctor_name TEXT,
  status TEXT DEFAULT 'scheduled',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create prescriptions table
CREATE TABLE public.prescriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id UUID REFERENCES public.patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  diagnosis TEXT NOT NULL,
  medicines TEXT NOT NULL,
  medicine_image_url TEXT,
  dosage TEXT,
  notes TEXT,
  prescribed_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create emergency_requests table
CREATE TABLE public.emergency_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_name TEXT NOT NULL,
  contact TEXT NOT NULL,
  pickup_location TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_requests ENABLE ROW LEVEL SECURITY;

-- Create policies for public read (for demo purposes - in production would be role-based)
CREATE POLICY "Allow public read on patients" ON public.patients FOR SELECT USING (true);
CREATE POLICY "Allow public insert on patients" ON public.patients FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on patients" ON public.patients FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on patients" ON public.patients FOR DELETE USING (true);

CREATE POLICY "Allow public read on appointments" ON public.appointments FOR SELECT USING (true);
CREATE POLICY "Allow public insert on appointments" ON public.appointments FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on appointments" ON public.appointments FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on appointments" ON public.appointments FOR DELETE USING (true);

CREATE POLICY "Allow public read on prescriptions" ON public.prescriptions FOR SELECT USING (true);
CREATE POLICY "Allow public insert on prescriptions" ON public.prescriptions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on prescriptions" ON public.prescriptions FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on prescriptions" ON public.prescriptions FOR DELETE USING (true);

CREATE POLICY "Allow public read on emergency_requests" ON public.emergency_requests FOR SELECT USING (true);
CREATE POLICY "Allow public insert on emergency_requests" ON public.emergency_requests FOR INSERT WITH CHECK (true);

-- Create storage bucket for prescription images
INSERT INTO storage.buckets (id, name, public) VALUES ('prescription-images', 'prescription-images', true);

-- Create storage policy
CREATE POLICY "Allow public upload to prescription-images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'prescription-images');
CREATE POLICY "Allow public read from prescription-images" ON storage.objects FOR SELECT USING (bucket_id = 'prescription-images');

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_prescriptions_updated_at BEFORE UPDATE ON public.prescriptions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();