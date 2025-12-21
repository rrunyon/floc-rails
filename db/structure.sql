\restrict 7Z18fEMmtba5MmYOHzhgJfT09bXfaH3ZWGweHU4N2E8bCbeeBj3iCgkPwvpBbWf

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: matchups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matchups (
    id bigint NOT NULL,
    espn_raw jsonb NOT NULL,
    week_id bigint NOT NULL,
    season_id bigint NOT NULL,
    home_team_id bigint NOT NULL,
    away_team_id bigint NOT NULL,
    home_score numeric,
    away_score numeric,
    playoff_tier_type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: matchups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.matchups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matchups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.matchups_id_seq OWNED BY public.matchups.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons (
    id bigint NOT NULL,
    year character varying NOT NULL,
    first_place_id bigint,
    second_place_id bigint,
    third_place_id bigint,
    last_place_id bigint,
    buy_in integer,
    payouts integer[],
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    espn_raw jsonb NOT NULL,
    espn_id character varying NOT NULL,
    user_id bigint NOT NULL,
    season_id bigint NOT NULL,
    name character varying NOT NULL,
    avatar_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    espn_raw jsonb NOT NULL,
    espn_id character varying NOT NULL,
    first_name character varying,
    last_name character varying,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weeks (
    id bigint NOT NULL,
    season_id bigint NOT NULL,
    recap_author_id bigint,
    week integer NOT NULL,
    playoff boolean DEFAULT false NOT NULL,
    recap text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weeks_id_seq OWNED BY public.weeks.id;


--
-- Name: matchups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchups ALTER COLUMN id SET DEFAULT nextval('public.matchups_id_seq'::regclass);


--
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks ALTER COLUMN id SET DEFAULT nextval('public.weeks_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: matchups matchups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT matchups_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weeks weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT weeks_pkey PRIMARY KEY (id);


--
-- Name: index_matchups_on_away_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matchups_on_away_team_id ON public.matchups USING btree (away_team_id);


--
-- Name: index_matchups_on_home_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matchups_on_home_team_id ON public.matchups USING btree (home_team_id);


--
-- Name: index_matchups_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matchups_on_season_id ON public.matchups USING btree (season_id);


--
-- Name: index_matchups_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matchups_on_week_id ON public.matchups USING btree (week_id);


--
-- Name: index_matchups_on_week_season_and_teams; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_matchups_on_week_season_and_teams ON public.matchups USING btree (week_id, season_id, home_team_id, away_team_id);


--
-- Name: index_seasons_on_first_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seasons_on_first_place_id ON public.seasons USING btree (first_place_id);


--
-- Name: index_seasons_on_last_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seasons_on_last_place_id ON public.seasons USING btree (last_place_id);


--
-- Name: index_seasons_on_second_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seasons_on_second_place_id ON public.seasons USING btree (second_place_id);


--
-- Name: index_seasons_on_third_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seasons_on_third_place_id ON public.seasons USING btree (third_place_id);


--
-- Name: index_seasons_on_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_seasons_on_year ON public.seasons USING btree (year);


--
-- Name: index_teams_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_season_id ON public.teams USING btree (season_id);


--
-- Name: index_teams_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_user_id ON public.teams USING btree (user_id);


--
-- Name: index_teams_on_user_id_and_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_user_id_and_season_id ON public.teams USING btree (user_id, season_id);


--
-- Name: index_users_on_espn_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_espn_id ON public.users USING btree (espn_id);


--
-- Name: index_weeks_on_recap_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_recap_author_id ON public.weeks USING btree (recap_author_id);


--
-- Name: index_weeks_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_season_id ON public.weeks USING btree (season_id);


--
-- Name: index_weeks_on_week_and_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_weeks_on_week_and_season_id ON public.weeks USING btree (week, season_id);


--
-- Name: weeks fk_rails_0143d7e830; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT fk_rails_0143d7e830 FOREIGN KEY (recap_author_id) REFERENCES public.teams(id);


--
-- Name: seasons fk_rails_079f46ff40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT fk_rails_079f46ff40 FOREIGN KEY (first_place_id) REFERENCES public.teams(id);


--
-- Name: matchups fk_rails_30a9a6d0f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT fk_rails_30a9a6d0f1 FOREIGN KEY (home_team_id) REFERENCES public.teams(id);


--
-- Name: seasons fk_rails_377052c80e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT fk_rails_377052c80e FOREIGN KEY (third_place_id) REFERENCES public.teams(id);


--
-- Name: weeks fk_rails_3999a6f8b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT fk_rails_3999a6f8b3 FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: teams fk_rails_45096701b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_45096701b6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: teams fk_rails_5fef1fc74c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_5fef1fc74c FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: matchups fk_rails_991534a368; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT fk_rails_991534a368 FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: seasons fk_rails_b414668b36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT fk_rails_b414668b36 FOREIGN KEY (last_place_id) REFERENCES public.teams(id);


--
-- Name: seasons fk_rails_d2f322ea8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT fk_rails_d2f322ea8c FOREIGN KEY (second_place_id) REFERENCES public.teams(id);


--
-- Name: matchups fk_rails_e4b507f1fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT fk_rails_e4b507f1fc FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: matchups fk_rails_fcb63cf491; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT fk_rails_fcb63cf491 FOREIGN KEY (away_team_id) REFERENCES public.teams(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 7Z18fEMmtba5MmYOHzhgJfT09bXfaH3ZWGweHU4N2E8bCbeeBj3iCgkPwvpBbWf

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20230127040105');


