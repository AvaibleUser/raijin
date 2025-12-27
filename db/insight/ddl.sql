CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS dim;

CREATE SCHEMA IF NOT EXISTS fact;

CREATE SCHEMA IF NOT EXISTS bridge;

CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE
    dim.users (
        user_id UUID PRIMARY KEY,
        full_name VARCHAR(200),
        email VARCHAR(100),
        role VARCHAR(50),
        active BOOLEAN,
        hired_at TIMESTAMP,
        terminated_at TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE
    dim.projects (
        project_id UUID PRIMARY KEY,
        name VARCHAR(100),
        client VARCHAR(100),
        closed BOOLEAN,
        start_date TIMESTAMP,
        end_date TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TYPE dim.sprint_status AS ENUM('PENDING', 'ACTIVE', 'FINISHED');

CREATE TABLE
    dim.sprints (
        sprint_id UUID PRIMARY KEY,
        name VARCHAR(100),
        status dim.sprint_status,
        start_date DATE,
        end_date DATE,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TYPE dim.story_priority AS ENUM('HIGH', 'MEDIUM', 'LOW');

CREATE TABLE
    dim.stories (
        story_id UUID PRIMARY KEY,
        name VARCHAR(200),
        stage VARCHAR(100),
        points INT DEFAULT 0,
        priority dim.story_priority,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE
    dim.dates (
        id BIGSERIAL PRIMARY KEY,
        date DATE,
        week_number INT,
        month INT,
        year INT
    );

CREATE TABLE
    bridge.members (
        project_id UUID REFERENCES dim.projects (project_id),
        user_id UUID REFERENCES dim.users (user_id),
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (project_id, user_id)
    );

CREATE TYPE fact.movement_category AS ENUM(
    'INCOME',
    'SALARY',
    'BONUS',
    'DISCOUNT',
    'OPERATIONAL_EXPENSE',
    'OTHER_EXPENSE'
);

CREATE TABLE
    fact.financial_movements (
        id BIGSERIAL PRIMARY KEY,
        project_id UUID REFERENCES dim.projects (project_id) NULL,
        employee_id UUID REFERENCES dim.users (user_id) NULL,
        transaction_date BIGINT REFERENCES dim.dates (id),
        amount NUMERIC(15, 2) NOT NULL,
        category fact.movement_category NOT NULL,
        description TEXT
    );

CREATE INDEX idx_finance_project_date ON fact.financial_movements (project_id, transaction_date);

CREATE INDEX idx_finance_date ON fact.financial_movements (transaction_date);

CREATE TABLE
    fact.employees (
        id BIGSERIAL PRIMARY KEY,
        employee_id UUID REFERENCES dim.users (user_id),
        first_contract_date BIGINT REFERENCES dim.dates (id),
        last_contract_date BIGINT REFERENCES dim.dates (id),
        terminated_at BIGINT REFERENCES dim.dates (id),
        role VARCHAR(50)
    );

CREATE INDEX idx_employees_role ON fact.employees (role, terminated_at DESC);

CREATE TABLE
    fact.story_activity (
        id BIGSERIAL PRIMARY KEY,
        project_id UUID REFERENCES dim.projects (project_id),
        story_id UUID REFERENCES dim.stories (story_id),
        sprint_id UUID REFERENCES dim.sprints (sprint_id) NULL,
        product_owner_id UUID REFERENCES dim.users (user_id) NULL,
        developer_id UUID REFERENCES dim.users (user_id) NULL,
        from_date BIGINT REFERENCES dim.dates (id),
        to_date BIGINT REFERENCES dim.dates (id),
        hours_spent NUMERIC(5, 2) DEFAULT 0,
        stage_changes INT DEFAULT 0
    );

CREATE INDEX idx_sprint_stories ON fact.story_activity (sprint_id, story_id);

CREATE INDEX idx_developer_stories ON fact.story_activity (developer_id, story_id);

CREATE INDEX idx_product_owner_stories ON fact.story_activity (product_owner_id, story_id);

CREATE TABLE
    fact.sprint_status (
        id BIGSERIAL PRIMARY KEY,
        project_id UUID REFERENCES dim.projects (project_id),
        sprint_id UUID REFERENCES dim.sprints (sprint_id),
        from_date BIGINT REFERENCES dim.dates (id),
        to_date BIGINT REFERENCES dim.dates (id),
        points_done INT DEFAULT 0,
        points_planned INT DEFAULT 0,
        percent_done NUMERIC(5, 2) DEFAULT 0.0,
        members INT DEFAULT 0
    );

CREATE INDEX idx_project_sprints ON fact.sprint_status (project_id, sprint_id);

CREATE TABLE
    audit.snapshots (
        id BIGSERIAL PRIMARY KEY,
        event_type VARCHAR(100) NOT NULL,
        aggregate_id UUID NOT NULL,
        actor_id UUID,
        occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        details JSONB,
        description TEXT
    );

CREATE INDEX idx_audit_aggregate ON audit.snapshots (aggregate_id);