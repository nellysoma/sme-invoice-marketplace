CREATE TABLE users (
    id                    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email                 VARCHAR(255) NOT NULL,
    password_hash         VARCHAR(100) NOT NULL,
    role                  VARCHAR(20)  NOT NULL,
    status                VARCHAR(30)  NOT NULL DEFAULT 'PENDING_VERIFICATION',
    email_verified        BOOLEAN      NOT NULL DEFAULT FALSE,
    failed_login_attempts INTEGER      NOT NULL DEFAULT 0,
    last_login_at         TIMESTAMPTZ,
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_users_role   CHECK (role IN ('SME', 'INVESTOR', 'ADMIN')),
    CONSTRAINT chk_users_status CHECK (status IN ('PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED'))
);

-- Emails are unique regardless of letter case.
CREATE UNIQUE INDEX uq_users_email_lower ON users (lower(email));
CREATE INDEX idx_users_role ON users (role);

CREATE TABLE sme_profiles (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID         NOT NULL UNIQUE REFERENCES users (id),
    business_name       VARCHAR(200) NOT NULL,
    registration_number VARCHAR(50)  NOT NULL UNIQUE,
    tax_id              VARCHAR(50),
    industry            VARCHAR(100),
    business_address    VARCHAR(300),
    city                VARCHAR(100),
    state               VARCHAR(100),
    contact_person      VARCHAR(150) NOT NULL,
    phone               VARCHAR(30)  NOT NULL,
    verification_status VARCHAR(20)  NOT NULL DEFAULT 'UNVERIFIED',
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_sme_verification CHECK (verification_status IN ('UNVERIFIED', 'VERIFIED', 'REJECTED'))
);

CREATE TABLE investor_profiles (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID         NOT NULL UNIQUE REFERENCES users (id),
    full_name           VARCHAR(150) NOT NULL,
    investor_type       VARCHAR(20)  NOT NULL,
    organisation_name   VARCHAR(200),
    phone               VARCHAR(30)  NOT NULL,
    risk_appetite       VARCHAR(10)  NOT NULL DEFAULT 'MEDIUM',
    verification_status VARCHAR(20)  NOT NULL DEFAULT 'UNVERIFIED',
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_investor_type         CHECK (investor_type IN ('INDIVIDUAL', 'INSTITUTION')),
    CONSTRAINT chk_investor_risk         CHECK (risk_appetite IN ('LOW', 'MEDIUM', 'HIGH')),
    CONSTRAINT chk_investor_verification CHECK (verification_status IN ('UNVERIFIED', 'VERIFIED', 'REJECTED'))
);