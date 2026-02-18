pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: hypertable
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: chunk
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: continuous_agg
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
--
-- PostgreSQL database dump
--

\restrict dx5qWWN5hsgzGqFwh2bMcJrYi6d53C91x9739NZ5Tj6WcHGVi7BHq9ZxwSacJ91

-- Dumped from database version 15.16 (Homebrew)
-- Dumped by pg_dump version 15.16 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    platform_project_id character varying NOT NULL,
    name character varying NOT NULL,
    enabled boolean DEFAULT true,
    scope_type character varying NOT NULL,
    scope_host_id uuid,
    scope_group_id uuid,
    scope_tags jsonb DEFAULT '{}'::jsonb,
    metric character varying NOT NULL,
    operator character varying NOT NULL,
    threshold double precision NOT NULL,
    aggregation character varying DEFAULT 'avg'::character varying,
    duration_seconds integer DEFAULT 300,
    mount_point character varying,
    interface character varying,
    severity character varying DEFAULT 'warning'::character varying,
    signal_alert_id uuid,
    last_triggered_at timestamp(6) without time zone,
    last_resolved_at timestamp(6) without time zone,
    currently_firing_hosts jsonb DEFAULT '[]'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    project_id uuid
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: container_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.container_metrics (
    container_id uuid NOT NULL,
    recorded_at timestamp(6) without time zone NOT NULL,
    cpu_usage_percent double precision,
    cpu_throttled_periods bigint,
    cpu_throttled_time_ns bigint,
    memory_used_bytes bigint,
    memory_limit_bytes bigint,
    memory_usage_percent double precision,
    memory_cache_bytes bigint,
    memory_rss_bytes bigint,
    network_rx_bytes bigint,
    network_tx_bytes bigint,
    network_rx_packets bigint,
    network_tx_packets bigint,
    block_read_bytes bigint,
    block_write_bytes bigint,
    pids_current integer,
    pids_limit integer
);


--
-- Name: containers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.containers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    container_id character varying NOT NULL,
    name character varying NOT NULL,
    image character varying,
    image_id character varying,
    runtime character varying,
    status character varying,
    started_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    exit_code integer,
    memory_limit_bytes bigint,
    cpu_limit double precision,
    network_mode character varying,
    port_mappings jsonb DEFAULT '[]'::jsonb,
    labels jsonb DEFAULT '{}'::jsonb,
    env_vars jsonb DEFAULT '{}'::jsonb,
    last_seen_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: disk_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disk_metrics (
    host_id uuid NOT NULL,
    recorded_at timestamp(6) without time zone NOT NULL,
    device character varying NOT NULL,
    mount_point character varying NOT NULL,
    filesystem character varying,
    total_bytes bigint,
    used_bytes bigint,
    free_bytes bigint,
    usage_percent double precision,
    inodes_total bigint,
    inodes_used bigint,
    inodes_free bigint,
    inodes_usage_percent double precision,
    read_bytes bigint,
    write_bytes bigint,
    read_ops bigint,
    write_ops bigint,
    io_time_percent double precision
);


--
-- Name: host_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.host_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    platform_project_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    color character varying,
    auto_assign_rules jsonb DEFAULT '[]'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    project_id uuid
);


--
-- Name: host_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.host_metrics (
    host_id uuid NOT NULL,
    recorded_at timestamp(6) without time zone NOT NULL,
    cpu_usage_percent double precision,
    cpu_user_percent double precision,
    cpu_system_percent double precision,
    cpu_iowait_percent double precision,
    cpu_steal_percent double precision,
    load_1m double precision,
    load_5m double precision,
    load_15m double precision,
    memory_used_bytes bigint,
    memory_free_bytes bigint,
    memory_available_bytes bigint,
    memory_cached_bytes bigint,
    memory_buffers_bytes bigint,
    memory_usage_percent double precision,
    swap_used_bytes bigint,
    swap_free_bytes bigint,
    swap_usage_percent double precision,
    processes_total integer,
    processes_running integer,
    processes_blocked integer,
    processes_zombie integer,
    uptime_seconds bigint
);


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hosts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    platform_project_id character varying NOT NULL,
    name character varying NOT NULL,
    hostname character varying NOT NULL,
    agent_id character varying NOT NULL,
    os character varying,
    os_version character varying,
    kernel_version character varying,
    architecture character varying,
    cpu_cores integer,
    cpu_threads integer,
    cpu_model character varying,
    memory_total_bytes bigint,
    swap_total_bytes bigint,
    ip_addresses character varying[] DEFAULT '{}'::character varying[],
    public_ip character varying,
    private_ip character varying,
    mac_addresses character varying[] DEFAULT '{}'::character varying[],
    cloud_provider character varying,
    cloud_region character varying,
    cloud_zone character varying,
    instance_type character varying,
    instance_id character varying,
    agent_version character varying,
    agent_started_at timestamp(6) without time zone,
    last_seen_at timestamp(6) without time zone,
    status character varying DEFAULT 'unknown'::character varying,
    host_group_id uuid,
    environment character varying,
    role character varying,
    tags jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    project_id uuid
);


--
-- Name: network_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.network_metrics (
    host_id uuid NOT NULL,
    recorded_at timestamp(6) without time zone NOT NULL,
    interface character varying NOT NULL,
    bytes_sent bigint,
    bytes_received bigint,
    packets_sent bigint,
    packets_received bigint,
    errors_in bigint,
    errors_out bigint,
    drops_in bigint,
    drops_out bigint,
    tcp_connections integer,
    tcp_established integer,
    tcp_time_wait integer,
    tcp_close_wait integer
);


--
-- Name: process_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.process_snapshots (
    host_id uuid NOT NULL,
    recorded_at timestamp(6) without time zone NOT NULL,
    pid integer NOT NULL,
    ppid integer,
    name character varying NOT NULL,
    command character varying,
    "user" character varying,
    state character varying,
    cpu_percent double precision,
    memory_percent double precision,
    memory_rss_bytes bigint,
    memory_vms_bytes bigint,
    io_read_bytes bigint,
    io_write_bytes bigint,
    threads_count integer,
    fd_count integer,
    cpu_time_ms bigint,
    started_at timestamp(6) without time zone
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    platform_project_id character varying NOT NULL,
    name character varying NOT NULL,
    slug character varying,
    environment character varying DEFAULT 'production'::character varying,
    settings jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: solid_queue_blocked_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_blocked_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    concurrency_key character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_blocked_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_blocked_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_blocked_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_blocked_executions_id_seq OWNED BY public.solid_queue_blocked_executions.id;


--
-- Name: solid_queue_claimed_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_claimed_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    process_id bigint,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_claimed_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_claimed_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_claimed_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_claimed_executions_id_seq OWNED BY public.solid_queue_claimed_executions.id;


--
-- Name: solid_queue_failed_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_failed_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    error text,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_failed_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_failed_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_failed_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_failed_executions_id_seq OWNED BY public.solid_queue_failed_executions.id;


--
-- Name: solid_queue_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_jobs (
    id bigint NOT NULL,
    queue_name character varying NOT NULL,
    class_name character varying NOT NULL,
    arguments text,
    priority integer DEFAULT 0 NOT NULL,
    active_job_id character varying,
    scheduled_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    concurrency_key character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_jobs_id_seq OWNED BY public.solid_queue_jobs.id;


--
-- Name: solid_queue_pauses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_pauses (
    id bigint NOT NULL,
    queue_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_pauses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_pauses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_pauses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_pauses_id_seq OWNED BY public.solid_queue_pauses.id;


--
-- Name: solid_queue_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_processes (
    id bigint NOT NULL,
    kind character varying NOT NULL,
    last_heartbeat_at timestamp(6) without time zone NOT NULL,
    supervisor_id bigint,
    pid integer NOT NULL,
    hostname character varying,
    metadata text,
    created_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL
);


--
-- Name: solid_queue_processes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_processes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_processes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_processes_id_seq OWNED BY public.solid_queue_processes.id;


--
-- Name: solid_queue_ready_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_ready_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_ready_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_ready_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_ready_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_ready_executions_id_seq OWNED BY public.solid_queue_ready_executions.id;


--
-- Name: solid_queue_recurring_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_recurring_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    task_key character varying NOT NULL,
    run_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_recurring_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_recurring_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_recurring_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_recurring_executions_id_seq OWNED BY public.solid_queue_recurring_executions.id;


--
-- Name: solid_queue_recurring_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_recurring_tasks (
    id bigint NOT NULL,
    key character varying NOT NULL,
    schedule character varying NOT NULL,
    command character varying(2048),
    class_name character varying,
    arguments text,
    queue_name character varying,
    priority integer DEFAULT 0,
    static boolean DEFAULT true NOT NULL,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_recurring_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_recurring_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_recurring_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_recurring_tasks_id_seq OWNED BY public.solid_queue_recurring_tasks.id;


--
-- Name: solid_queue_scheduled_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_scheduled_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    scheduled_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_scheduled_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_scheduled_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_scheduled_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_scheduled_executions_id_seq OWNED BY public.solid_queue_scheduled_executions.id;


--
-- Name: solid_queue_semaphores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_semaphores (
    id bigint NOT NULL,
    key character varying NOT NULL,
    value integer DEFAULT 1 NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_semaphores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_semaphores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_semaphores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_semaphores_id_seq OWNED BY public.solid_queue_semaphores.id;


--
-- Name: solid_queue_blocked_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_blocked_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_blocked_executions_id_seq'::regclass);


--
-- Name: solid_queue_claimed_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_claimed_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_claimed_executions_id_seq'::regclass);


--
-- Name: solid_queue_failed_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_failed_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_failed_executions_id_seq'::regclass);


--
-- Name: solid_queue_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_jobs ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_jobs_id_seq'::regclass);


--
-- Name: solid_queue_pauses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_pauses ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_pauses_id_seq'::regclass);


--
-- Name: solid_queue_processes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_processes ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_processes_id_seq'::regclass);


--
-- Name: solid_queue_ready_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_ready_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_ready_executions_id_seq'::regclass);


--
-- Name: solid_queue_recurring_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_recurring_executions_id_seq'::regclass);


--
-- Name: solid_queue_recurring_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_tasks ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_recurring_tasks_id_seq'::regclass);


--
-- Name: solid_queue_scheduled_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_scheduled_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_scheduled_executions_id_seq'::regclass);


--
-- Name: solid_queue_semaphores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_semaphores ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_semaphores_id_seq'::regclass);


--
-- Name: alert_rules alert_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rules
    ADD CONSTRAINT alert_rules_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: containers containers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT containers_pkey PRIMARY KEY (id);


--
-- Name: host_groups host_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_groups
    ADD CONSTRAINT host_groups_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: solid_queue_blocked_executions solid_queue_blocked_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_blocked_executions
    ADD CONSTRAINT solid_queue_blocked_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_claimed_executions solid_queue_claimed_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_claimed_executions
    ADD CONSTRAINT solid_queue_claimed_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_failed_executions solid_queue_failed_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_failed_executions
    ADD CONSTRAINT solid_queue_failed_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_jobs solid_queue_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_jobs
    ADD CONSTRAINT solid_queue_jobs_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_pauses solid_queue_pauses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_pauses
    ADD CONSTRAINT solid_queue_pauses_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_processes solid_queue_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_processes
    ADD CONSTRAINT solid_queue_processes_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_ready_executions solid_queue_ready_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_ready_executions
    ADD CONSTRAINT solid_queue_ready_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_recurring_executions solid_queue_recurring_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_executions
    ADD CONSTRAINT solid_queue_recurring_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_recurring_tasks solid_queue_recurring_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_tasks
    ADD CONSTRAINT solid_queue_recurring_tasks_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_scheduled_executions solid_queue_scheduled_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_scheduled_executions
    ADD CONSTRAINT solid_queue_scheduled_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_semaphores solid_queue_semaphores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_semaphores
    ADD CONSTRAINT solid_queue_semaphores_pkey PRIMARY KEY (id);


--
-- Name: container_metrics_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX container_metrics_recorded_at_idx ON public.container_metrics USING btree (recorded_at DESC);


--
-- Name: disk_metrics_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disk_metrics_recorded_at_idx ON public.disk_metrics USING btree (recorded_at DESC);


--
-- Name: host_metrics_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX host_metrics_recorded_at_idx ON public.host_metrics USING btree (recorded_at DESC);


--
-- Name: index_alert_rules_on_platform_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alert_rules_on_platform_project_id ON public.alert_rules USING btree (platform_project_id);


--
-- Name: index_alert_rules_on_platform_project_id_and_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alert_rules_on_platform_project_id_and_enabled ON public.alert_rules USING btree (platform_project_id, enabled);


--
-- Name: index_alert_rules_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alert_rules_on_project_id ON public.alert_rules USING btree (project_id);


--
-- Name: index_container_metrics_on_container_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_container_metrics_on_container_id ON public.container_metrics USING btree (container_id);


--
-- Name: index_container_metrics_on_container_id_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_container_metrics_on_container_id_and_recorded_at ON public.container_metrics USING btree (container_id, recorded_at);


--
-- Name: index_containers_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_containers_on_host_id ON public.containers USING btree (host_id);


--
-- Name: index_containers_on_host_id_and_container_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_containers_on_host_id_and_container_id ON public.containers USING btree (host_id, container_id);


--
-- Name: index_containers_on_host_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_containers_on_host_id_and_status ON public.containers USING btree (host_id, status);


--
-- Name: index_disk_metrics_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disk_metrics_on_host_id ON public.disk_metrics USING btree (host_id);


--
-- Name: index_disk_metrics_on_host_id_and_mount_point_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disk_metrics_on_host_id_and_mount_point_and_recorded_at ON public.disk_metrics USING btree (host_id, mount_point, recorded_at);


--
-- Name: index_disk_metrics_on_host_id_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disk_metrics_on_host_id_and_recorded_at ON public.disk_metrics USING btree (host_id, recorded_at);


--
-- Name: index_host_groups_on_platform_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_host_groups_on_platform_project_id ON public.host_groups USING btree (platform_project_id);


--
-- Name: index_host_groups_on_platform_project_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_host_groups_on_platform_project_id_and_name ON public.host_groups USING btree (platform_project_id, name);


--
-- Name: index_host_groups_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_host_groups_on_project_id ON public.host_groups USING btree (project_id);


--
-- Name: index_host_metrics_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_host_metrics_on_host_id ON public.host_metrics USING btree (host_id);


--
-- Name: index_host_metrics_on_host_id_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_host_metrics_on_host_id_and_recorded_at ON public.host_metrics USING btree (host_id, recorded_at);


--
-- Name: index_hosts_on_host_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_host_group_id ON public.hosts USING btree (host_group_id);


--
-- Name: index_hosts_on_last_seen_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_last_seen_at ON public.hosts USING btree (last_seen_at);


--
-- Name: index_hosts_on_platform_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_platform_project_id ON public.hosts USING btree (platform_project_id);


--
-- Name: index_hosts_on_platform_project_id_and_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hosts_on_platform_project_id_and_agent_id ON public.hosts USING btree (platform_project_id, agent_id);


--
-- Name: index_hosts_on_platform_project_id_and_environment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_platform_project_id_and_environment ON public.hosts USING btree (platform_project_id, environment);


--
-- Name: index_hosts_on_platform_project_id_and_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_platform_project_id_and_role ON public.hosts USING btree (platform_project_id, role);


--
-- Name: index_hosts_on_platform_project_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_platform_project_id_and_status ON public.hosts USING btree (platform_project_id, status);


--
-- Name: index_hosts_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_project_id ON public.hosts USING btree (project_id);


--
-- Name: index_network_metrics_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_network_metrics_on_host_id ON public.network_metrics USING btree (host_id);


--
-- Name: index_network_metrics_on_host_id_and_interface_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_network_metrics_on_host_id_and_interface_and_recorded_at ON public.network_metrics USING btree (host_id, interface, recorded_at);


--
-- Name: index_network_metrics_on_host_id_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_network_metrics_on_host_id_and_recorded_at ON public.network_metrics USING btree (host_id, recorded_at);


--
-- Name: index_process_snapshots_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_process_snapshots_on_host_id ON public.process_snapshots USING btree (host_id);


--
-- Name: index_process_snapshots_on_host_id_and_name_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_process_snapshots_on_host_id_and_name_and_recorded_at ON public.process_snapshots USING btree (host_id, name, recorded_at);


--
-- Name: index_process_snapshots_on_host_id_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_process_snapshots_on_host_id_and_recorded_at ON public.process_snapshots USING btree (host_id, recorded_at);


--
-- Name: index_projects_on_platform_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_platform_project_id ON public.projects USING btree (platform_project_id);


--
-- Name: index_projects_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_slug ON public.projects USING btree (slug);


--
-- Name: index_solid_queue_blocked_executions_for_maintenance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_blocked_executions_for_maintenance ON public.solid_queue_blocked_executions USING btree (expires_at, concurrency_key);


--
-- Name: index_solid_queue_blocked_executions_for_release; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_blocked_executions_for_release ON public.solid_queue_blocked_executions USING btree (concurrency_key, priority, job_id);


--
-- Name: index_solid_queue_blocked_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_blocked_executions_on_job_id ON public.solid_queue_blocked_executions USING btree (job_id);


--
-- Name: index_solid_queue_claimed_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_claimed_executions_on_job_id ON public.solid_queue_claimed_executions USING btree (job_id);


--
-- Name: index_solid_queue_claimed_executions_on_process_id_and_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_claimed_executions_on_process_id_and_job_id ON public.solid_queue_claimed_executions USING btree (process_id, job_id);


--
-- Name: index_solid_queue_dispatch_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_dispatch_all ON public.solid_queue_scheduled_executions USING btree (scheduled_at, priority, job_id);


--
-- Name: index_solid_queue_failed_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_failed_executions_on_job_id ON public.solid_queue_failed_executions USING btree (job_id);


--
-- Name: index_solid_queue_jobs_for_alerting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_for_alerting ON public.solid_queue_jobs USING btree (scheduled_at, finished_at);


--
-- Name: index_solid_queue_jobs_for_filtering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_for_filtering ON public.solid_queue_jobs USING btree (queue_name, finished_at);


--
-- Name: index_solid_queue_jobs_on_active_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_active_job_id ON public.solid_queue_jobs USING btree (active_job_id);


--
-- Name: index_solid_queue_jobs_on_class_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_class_name ON public.solid_queue_jobs USING btree (class_name);


--
-- Name: index_solid_queue_jobs_on_finished_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_finished_at ON public.solid_queue_jobs USING btree (finished_at);


--
-- Name: index_solid_queue_pauses_on_queue_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_pauses_on_queue_name ON public.solid_queue_pauses USING btree (queue_name);


--
-- Name: index_solid_queue_poll_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_poll_all ON public.solid_queue_ready_executions USING btree (priority, job_id);


--
-- Name: index_solid_queue_poll_by_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_poll_by_queue ON public.solid_queue_ready_executions USING btree (queue_name, priority, job_id);


--
-- Name: index_solid_queue_processes_on_last_heartbeat_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_processes_on_last_heartbeat_at ON public.solid_queue_processes USING btree (last_heartbeat_at);


--
-- Name: index_solid_queue_processes_on_name_and_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_processes_on_name_and_supervisor_id ON public.solid_queue_processes USING btree (name, supervisor_id);


--
-- Name: index_solid_queue_processes_on_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_processes_on_supervisor_id ON public.solid_queue_processes USING btree (supervisor_id);


--
-- Name: index_solid_queue_ready_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_ready_executions_on_job_id ON public.solid_queue_ready_executions USING btree (job_id);


--
-- Name: index_solid_queue_recurring_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_recurring_executions_on_job_id ON public.solid_queue_recurring_executions USING btree (job_id);


--
-- Name: index_solid_queue_recurring_executions_on_task_key_and_run_at; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_recurring_executions_on_task_key_and_run_at ON public.solid_queue_recurring_executions USING btree (task_key, run_at);


--
-- Name: index_solid_queue_recurring_tasks_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_recurring_tasks_on_key ON public.solid_queue_recurring_tasks USING btree (key);


--
-- Name: index_solid_queue_recurring_tasks_on_static; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_recurring_tasks_on_static ON public.solid_queue_recurring_tasks USING btree (static);


--
-- Name: index_solid_queue_scheduled_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_scheduled_executions_on_job_id ON public.solid_queue_scheduled_executions USING btree (job_id);


--
-- Name: index_solid_queue_semaphores_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_semaphores_on_expires_at ON public.solid_queue_semaphores USING btree (expires_at);


--
-- Name: index_solid_queue_semaphores_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_semaphores_on_key ON public.solid_queue_semaphores USING btree (key);


--
-- Name: index_solid_queue_semaphores_on_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_semaphores_on_key_and_value ON public.solid_queue_semaphores USING btree (key, value);


--
-- Name: network_metrics_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX network_metrics_recorded_at_idx ON public.network_metrics USING btree (recorded_at DESC);


--
-- Name: process_snapshots_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX process_snapshots_recorded_at_idx ON public.process_snapshots USING btree (recorded_at DESC);


--
-- Name: alert_rules fk_rails_0b3fcf55ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rules
    ADD CONSTRAINT fk_rails_0b3fcf55ac FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: solid_queue_recurring_executions fk_rails_318a5533ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_executions
    ADD CONSTRAINT fk_rails_318a5533ed FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: hosts fk_rails_34f74a7c8e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT fk_rails_34f74a7c8e FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: solid_queue_failed_executions fk_rails_39bbc7a631; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_failed_executions
    ADD CONSTRAINT fk_rails_39bbc7a631 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: solid_queue_blocked_executions fk_rails_4cd34e2228; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_blocked_executions
    ADD CONSTRAINT fk_rails_4cd34e2228 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: solid_queue_ready_executions fk_rails_81fcbd66af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_ready_executions
    ADD CONSTRAINT fk_rails_81fcbd66af FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: hosts fk_rails_85f776936a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT fk_rails_85f776936a FOREIGN KEY (host_group_id) REFERENCES public.host_groups(id);


--
-- Name: solid_queue_claimed_executions fk_rails_9cfe4d4944; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_claimed_executions
    ADD CONSTRAINT fk_rails_9cfe4d4944 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: host_groups fk_rails_ba34d60ac6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_groups
    ADD CONSTRAINT fk_rails_ba34d60ac6 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: solid_queue_scheduled_executions fk_rails_c4316f352d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_scheduled_executions
    ADD CONSTRAINT fk_rails_c4316f352d FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: containers fk_rails_fef1a2b02c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT fk_rails_fef1a2b02c FOREIGN KEY (host_id) REFERENCES public.hosts(id);


--
-- PostgreSQL database dump complete
--

\unrestrict dx5qWWN5hsgzGqFwh2bMcJrYi6d53C91x9739NZ5Tj6WcHGVi7BHq9ZxwSacJ91

