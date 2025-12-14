# Supabase Database Schema

## Tables Overview

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| profiles | User profiles extending auth.users | References auth.users(id) |
| focus_areas | Predefined coaching categories | Referenced by mentor expertise |
| appointments | Booking records | References profiles (mentor & mentee) |
| messages | Chat messages | References profiles (sender & receiver) |
| reviews | Mentor ratings | References profiles & appointments |

## RLS Policies Summary

- **profiles**: Public read, owner write
- **appointments**: Private to participants
- **messages**: Private to sender/receiver, realtime enabled
- **reviews**: Public read, reviewer write
- **focus_areas**: Public read-only

## Functions

- `check_mentor_availability(mentor_id, start_time, end_time)`: Returns boolean
- `get_mentor_booked_slots(mentor_id, start_date, end_date)`: Returns booked slots

## Indexes

Optimized for:
- Mentor/mentee appointment lookups
- Message conversation queries
- Review aggregations by mentor

## Diagram

```mermaid
erDiagram
    auth_users ||--o{ profiles : "extends"
    profiles ||--o{ appointments : "mentor_id"
    profiles ||--o{ appointments : "mentee_id"
    profiles ||--o{ messages : "sender_id"
    profiles ||--o{ messages : "receiver_id"
    profiles ||--o{ reviews : "mentor_id"
    profiles ||--o{ reviews : "mentee_id"
    appointments ||--o| reviews : "appointment_id"
    
    profiles {
        uuid user_id PK
        text role
        text bio
        text avatar_url
        text_array expertise_areas
        timestamptz created_at
        timestamptz updated_at
    }
    
    focus_areas {
        uuid id PK
        text name
        text icon
        timestamptz created_at
    }
    
    appointments {
        uuid id PK
        uuid mentor_id FK
        uuid mentee_id FK
        timestamptz start_time
        timestamptz end_time
        text status
        text notes
        timestamptz created_at
        timestamptz updated_at
    }
    
    messages {
        uuid id PK
        uuid sender_id FK
        uuid receiver_id FK
        text content
        boolean is_read
        timestamptz created_at
    }
    
    reviews {
        uuid id PK
        uuid mentor_id FK
        uuid mentee_id FK
        uuid appointment_id FK
        integer rating
        text comment
        timestamptz created_at
    }
```
