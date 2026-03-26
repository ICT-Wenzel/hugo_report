-- ============================================================
-- Bug Reporting System — PostgreSQL / Supabase Schema v2
-- ============================================================

-- ENUMS
CREATE TYPE severity_level AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE bug_type       AS ENUM ('bug', 'feature', 'improvement');
CREATE TYPE bug_category   AS ENUM ('client_management', 'inventory', 'xmc', 'toolbox', 'engineering');
CREATE TYPE bug_status     AS ENUM ('open', 'in_progress', 'closed');

-- BUGS
CREATE TABLE IF NOT EXISTS bugs (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title            TEXT NOT NULL CHECK (char_length(title) BETWEEN 3 AND 200),
    description      TEXT NOT NULL,
    severity         severity_level NOT NULL DEFAULT 'medium',
    type             bug_type       NOT NULL DEFAULT 'bug',
    category         bug_category   NOT NULL,
    status           bug_status     NOT NULL DEFAULT 'open',
    resolution       TEXT,
    attachment_urls  TEXT[]         NOT NULL DEFAULT '{}',
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    closed_at        TIMESTAMPTZ,
    CONSTRAINT resolution_required_when_closed
        CHECK (status <> 'closed' OR resolution IS NOT NULL),
    CONSTRAINT closed_at_set_when_closed
        CHECK (status <> 'closed' OR closed_at IS NOT NULL)
);

-- COMMENTS
CREATE TABLE IF NOT EXISTS comments (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bug_id     UUID NOT NULL REFERENCES bugs(id) ON DELETE CASCADE,
    comment    TEXT NOT NULL CHECK (char_length(comment) >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Storage Bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('bug-attachments', 'bug-attachments', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'bug-attachments');

CREATE POLICY "Public upload"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'bug-attachments');

-- AUTO-UPDATE updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER bugs_updated_at
    BEFORE UPDATE ON bugs
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- INDEXES
CREATE INDEX idx_bugs_status   ON bugs(status);
CREATE INDEX idx_bugs_severity ON bugs(severity);
CREATE INDEX idx_bugs_category ON bugs(category);
CREATE INDEX idx_bugs_created  ON bugs(created_at DESC);
CREATE INDEX idx_comments_bug  ON comments(bug_id);