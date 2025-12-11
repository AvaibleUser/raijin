CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS project;

CREATE TYPE project.project_status AS ENUM('ACTIVE', 'CLOSED');

CREATE TABLE
    project.projects (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
        name VARCHAR(100) NOT NULL,
        description TEXT,
        client VARCHAR(100),
        status project.project_status DEFAULT 'ACTIVE',
        monthly_income NUMERIC(10, 2) DEFAULT 0.0,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        closed_at TIMESTAMP,
        deleted_at TIMESTAMP
    );