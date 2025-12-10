CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE
    roles (
        id BIGSERIAL PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT,
        active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        role_id BIGINT NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
        verified BOOLEAN DEFAULT FALSE,
        banned BOOLEAN DEFAULT FALSE,
        active BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE UNLOGGED TABLE
    user_codes (
        code CHAR(6) PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        expiration TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '1 hour'
    );