create table if not exists public.leads (
  lead_id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  phone text,
  company text,
  service text,
  budget text,
  timeline text,
  message text not null,
  status text not null default 'NEW',
  lead_score integer,
  lead_classification text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  follow_up_required boolean not null default false,
  next_follow_up timestamptz,
  follow_up_count integer not null default 0,
  appointment_date date,
  appointment_time time,
  calendar_event_id text,
  appointment_status text,
  constraint leads_email_unique unique (email),
  constraint leads_status_check check (status in ('NEW', 'ANALYZED', 'QUALIFIED', 'CONTACTED', 'FOLLOW_UP', 'BOOKED', 'CLOSED')),
  constraint leads_classification_check check (lead_classification is null or lead_classification in ('HOT', 'WARM', 'NEEDS_INFORMATION'))
);

create index if not exists leads_status_idx on public.leads (status);
create index if not exists leads_created_at_idx on public.leads (created_at desc);
