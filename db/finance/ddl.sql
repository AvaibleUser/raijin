CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS employee;

CREATE SCHEMA IF NOT EXISTS finance;

CREATE SCHEMA IF NOT EXISTS salary;

CREATE
OR REPLACE FUNCTION soft_delete () RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP != 'UPDATE' OR NOT NEW.deleted) THEN
        RETURN NULL;
    END IF;

    CASE TG_TABLE_NAME
        WHEN 'employees' THEN
            UPDATE employee.contracts
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                employee_id = NEW.id;
            UPDATE salary.suspensions
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                employee_id = NEW.id;
            UPDATE salary.bonuses
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                employee_id = NEW.id;
            UPDATE salary.discounts
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                employee_id = NEW.id;
            UPDATE finance.expenses
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                employee_id = NEW.id;
            UPDATE finance.payroll
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                employee_id = NEW.id;
        WHEN 'projects' THEN
            UPDATE finance.project_income
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                project_id = NEW.id;
            UPDATE finance.expenses
            SET
                deleted = TRUE,
                deleted_at = CURRENT_TIMESTAMP
            WHERE
                project_id = NEW.id;
    END CASE;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE
    employee.employees (
        id UUID PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL,
        hired BOOLEAN DEFAULT FALSE,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TRIGGER soft_delete_employee_trigger
AFTER
UPDATE OF deleted ON employee.employees FOR EACH ROW
EXECUTE PROCEDURE soft_delete ();

CREATE TABLE
    employee.projects (
        id UUID PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        client VARCHAR(100),
        monthly_income NUMERIC(10, 2) DEFAULT 0.0,
        closed BOOLEAN DEFAULT FALSE,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TRIGGER soft_delete_project_trigger
AFTER
UPDATE OF deleted ON employee.projects FOR EACH ROW
EXECUTE PROCEDURE soft_delete ();

CREATE TABLE
    employee.members (
        employee_id UUID REFERENCES employee.employees (id),
        project_id UUID REFERENCES employee.projects (id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (employee_id, project_id)
    );

CREATE TYPE employee.contract_status AS ENUM('ACTIVE', 'SUSPENDED', 'TERMINATED');

CREATE TABLE
    employee.contracts (
        id BIGSERIAL PRIMARY KEY,
        employee_id UUID REFERENCES employee.employees (id),
        base_salary NUMERIC(10, 2) NOT NULL,
        role VARCHAR(100) NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE,
        status employee.contract_status DEFAULT 'ACTIVE',
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    salary.suspensions (
        id BIGSERIAL PRIMARY KEY,
        employee_id UUID REFERENCES employee.employees (id),
        reason TEXT NOT NULL,
        amount NUMERIC(10, 2) NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    salary.bonuses (
        id BIGSERIAL PRIMARY KEY,
        employee_id UUID REFERENCES employee.employees (id),
        amount NUMERIC(10, 2) NOT NULL,
        reason TEXT NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    salary.discounts (
        id BIGSERIAL PRIMARY KEY,
        employee_id UUID REFERENCES employee.employees (id),
        amount NUMERIC(10, 2) NOT NULL,
        reason TEXT NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TYPE finance.income_type AS ENUM('FIXED_PRICE', 'HOURLY_RATE');

CREATE TABLE
    finance.project_income (
        id BIGSERIAL PRIMARY KEY,
        project_id UUID REFERENCES employee.projects (id),
        amount NUMERIC(10, 2) NOT NULL,
        type finance.income_type NOT NULL,
        description TEXT,
        billing_date DATE NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TYPE finance.expense_type AS ENUM('OPERATIONAL', 'SALARY', 'OTHER');

CREATE TABLE
    finance.expenses (
        id BIGSERIAL PRIMARY KEY,
        project_id UUID REFERENCES employee.projects (id) NULL,
        employee_id UUID REFERENCES employee.employees (id) NULL CHECK (
            project_id IS NOT NULL
            OR employee_id IS NULL
        ),
        description TEXT NOT NULL,
        amount NUMERIC(10, 2) NOT NULL,
        type finance.expense_type NOT NULL,
        expense_date DATE NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );

CREATE TABLE
    finance.payroll (
        id BIGSERIAL PRIMARY KEY,
        employee_id UUID REFERENCES employee.employees (id),
        base_salary NUMERIC(10, 2) NOT NULL,
        total_bonuses NUMERIC(10, 2) NOT NULL,
        total_discounts NUMERIC(10, 2) NOT NULL,
        total_paid NUMERIC(10, 2) NOT NULL,
        payment_date DATE NOT NULL,
        from_date DATE NOT NULL,
        to_date DATE NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP
    );