CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS project;

CREATE SCHEMA IF NOT EXISTS sprint;

CREATE SCHEMA IF NOT EXISTS story;

CREATE
OR REPLACE FUNCTION soft_delete () RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP != 'UPDATE' OR NOT NEW.deleted) THEN
        RETURN NULL;
    END IF;

    CASE TG_TABLE_NAME
        WHEN 'projects' THEN
            UPDATE sprint.sprints
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                project_id = NEW.id;
        WHEN 'sprints' THEN
            UPDATE sprint.story_stages
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                sprint_id = NEW.id;
        WHEN 'story_stages' THEN
            UPDATE story.stories
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                stage_id = NEW.id;
        WHEN 'stories' THEN
            UPDATE story.acceptance_criteria
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                story_id = NEW.id;
    END CASE;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

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

CREATE TRIGGER soft_delete_project_trigger
AFTER
UPDATE OF deleted ON project.projects FOR EACH ROW
EXECUTE PROCEDURE soft_delete ();

CREATE TABLE
    project.users (
        id UUID PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL,
        role VARCHAR(100) NOT NULL,
        color VARCHAR(100) NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
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
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
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

CREATE TRIGGER soft_delete_sprint_trigger
AFTER
UPDATE OF deleted ON sprint.sprints FOR EACH ROW
EXECUTE PROCEDURE soft_delete ();

CREATE TABLE
    sprint.story_stages (
        id BIGSERIAL PRIMARY KEY,
        sprint_id UUID REFERENCES sprint.sprints (id),
        name VARCHAR(100) NOT NULL,
        description TEXT,
        order_index INT NOT NULL,
        is_default BOOLEAN DEFAULT FALSE,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TRIGGER soft_delete_story_stage_trigger
AFTER
UPDATE OF deleted ON sprint.story_stages FOR EACH ROW
EXECUTE PROCEDURE soft_delete ();

CREATE TYPE story.story_priority AS ENUM('HIGH', 'MEDIUM', 'LOW');

CREATE TABLE
    story.stories (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
        stage_id BIGINT REFERENCES sprint.story_stages (id) NULL,
        project_id UUID REFERENCES project.projects (id),
        product_owner_id UUID REFERENCES project.users (id) NULL,
        developer_id UUID REFERENCES project.users (id) NULL,
        name VARCHAR(200) NOT NULL,
        description TEXT,
        points INT NOT NULL CHECK (points > 0),
        priority story.story_priority NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TRIGGER soft_delete_story_trigger
AFTER
UPDATE OF deleted ON story.stories FOR EACH ROW
EXECUTE PROCEDURE soft_delete ();

CREATE TABLE
    story.acceptance_criteria (
        id BIGSERIAL PRIMARY KEY,
        story_id UUID REFERENCES story.stories (id),
        description TEXT NOT NULL,
        reached BOOLEAN DEFAULT FALSE,
        required BOOLEAN DEFAULT FALSE,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );