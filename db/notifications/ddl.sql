CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE
    public.users (
        id UUID PRIMARY KEY,
        full_name VARCHAR(200),
        email VARCHAR(100),
        role VARCHAR(50),
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );