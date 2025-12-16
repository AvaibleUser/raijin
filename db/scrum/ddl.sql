CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS project;

CREATE SCHEMA IF NOT EXISTS sprint;

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

CREATE TABLE
    project.users (
        id UUID PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL,
        role VARCHAR(100) NOT NULL,
        color VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    project.members (
        project_id UUID REFERENCES project.projects (id),
        user_id UUID REFERENCES project.users (id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (project_id, user_id)
    );

CREATE TYPE sprint.sprint_status AS ENUM('PENDING', 'ACTIVE', 'FINISHED');

CREATE TABLE
    sprint.sprints (
        id BIGSERIAL PRIMARY KEY,
        project_id UUID REFERENCES project.projects (id),
        name VARCHAR(100) NOT NULL,
        description TEXT,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        status sprint.sprint_status DEFAULT 'PENDING',
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    sprint.story_stages (
        id BIGSERIAL PRIMARY KEY,
        sprint_id BIGINT REFERENCES sprint.sprints (id),
        name VARCHAR(100) NOT NULL,
        description TEXT,
        order_index INT NOT NULL,
        is_default BOOLEAN DEFAULT FALSE,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );