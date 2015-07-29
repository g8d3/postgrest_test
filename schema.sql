--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.9
-- Dumped by pg_dump version 9.3.9
-- Started on 2015-07-29 09:43:12 COT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 8 (class 2615 OID 16717)
-- Name: 1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "1";


ALTER SCHEMA "1" OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 16705)
-- Name: postgrest; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA postgrest;


ALTER SCHEMA postgrest OWNER TO postgres;

--
-- TOC entry 176 (class 3079 OID 11833)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2045 (class 0 OID 0)
-- Dependencies: 176
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = postgrest, pg_catalog;

--
-- TOC entry 183 (class 1255 OID 16714)
-- Name: check_role_exists(); Type: FUNCTION; Schema: postgrest; Owner: postgres
--

CREATE FUNCTION check_role_exists() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin 
if not exists (select 1 from pg_roles as r where r.rolname = new.rolname) then
   raise foreign_key_violation using message = 'Cannot create user with unknown role: ' || new.rolname;
   return null;
 end if;
 return new;
end
$$;


ALTER FUNCTION postgrest.check_role_exists() OWNER TO postgres;

--
-- TOC entry 190 (class 1255 OID 16826)
-- Name: update_owner(); Type: FUNCTION; Schema: postgrest; Owner: postgres
--

CREATE FUNCTION update_owner() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.owner = current_setting('user_vars.user_id'); 
   RETURN NEW;
END;
$$;


ALTER FUNCTION postgrest.update_owner() OWNER TO postgres;

SET search_path = "1", pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 174 (class 1259 OID 16813)
-- Name: all_articles; Type: TABLE; Schema: 1; Owner: postgres; Tablespace: 
--

CREATE TABLE all_articles (
    body text,
    id integer NOT NULL,
    owner character(1) NOT NULL
);


ALTER TABLE "1".all_articles OWNER TO postgres;

--
-- TOC entry 173 (class 1259 OID 16811)
-- Name: all_articles_id_seq; Type: SEQUENCE; Schema: 1; Owner: postgres
--

CREATE SEQUENCE all_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "1".all_articles_id_seq OWNER TO postgres;

--
-- TOC entry 2047 (class 0 OID 0)
-- Dependencies: 173
-- Name: all_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: 1; Owner: postgres
--

ALTER SEQUENCE all_articles_id_seq OWNED BY all_articles.id;


--
-- TOC entry 175 (class 1259 OID 16822)
-- Name: articles; Type: VIEW; Schema: 1; Owner: postgres
--

CREATE VIEW articles AS
 SELECT all_articles.body,
    all_articles.id,
    all_articles.owner
   FROM all_articles
  WHERE ((all_articles.owner)::text = current_setting('user_vars.user_id'::text));


ALTER TABLE "1".articles OWNER TO postgres;

SET search_path = postgrest, pg_catalog;

--
-- TOC entry 172 (class 1259 OID 16706)
-- Name: auth; Type: TABLE; Schema: postgrest; Owner: postgres; Tablespace: 
--

CREATE TABLE auth (
    id character varying NOT NULL,
    rolname name NOT NULL,
    pass character(60) NOT NULL
);


ALTER TABLE postgrest.auth OWNER TO postgres;

SET search_path = "1", pg_catalog;

--
-- TOC entry 1919 (class 2604 OID 16816)
-- Name: id; Type: DEFAULT; Schema: 1; Owner: postgres
--

ALTER TABLE ONLY all_articles ALTER COLUMN id SET DEFAULT nextval('all_articles_id_seq'::regclass);


--
-- TOC entry 2036 (class 0 OID 16813)
-- Dependencies: 174
-- Data for Name: all_articles; Type: TABLE DATA; Schema: 1; Owner: postgres
--

COPY all_articles (body, id, owner) FROM stdin;
\.


--
-- TOC entry 2049 (class 0 OID 0)
-- Dependencies: 173
-- Name: all_articles_id_seq; Type: SEQUENCE SET; Schema: 1; Owner: postgres
--

SELECT pg_catalog.setval('all_articles_id_seq', 1, true);


SET search_path = postgrest, pg_catalog;

--
-- TOC entry 2034 (class 0 OID 16706)
-- Dependencies: 172
-- Data for Name: auth; Type: TABLE DATA; Schema: postgrest; Owner: postgres
--

COPY auth (id, rolname, pass) FROM stdin;
jdoe	postgres	$2y$04$U/i/PneF7BB1d3OdxJ9UPO5IKWSBWs7chNFOObqx9AGxPUBBPC9cW
juan	author	$2y$04$de.0BYoA9eVmb1/shLPJpuT3KoenPARJdRV/ZJoegXdmoNaSJb8.y
\.


SET search_path = "1", pg_catalog;

--
-- TOC entry 1923 (class 2606 OID 16821)
-- Name: posts_pkey; Type: CONSTRAINT; Schema: 1; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY all_articles
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


SET search_path = postgrest, pg_catalog;

--
-- TOC entry 1921 (class 2606 OID 16713)
-- Name: auth_pkey; Type: CONSTRAINT; Schema: postgrest; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth
    ADD CONSTRAINT auth_pkey PRIMARY KEY (id);


SET search_path = "1", pg_catalog;

--
-- TOC entry 1925 (class 2620 OID 16827)
-- Name: articles_owner_track; Type: TRIGGER; Schema: 1; Owner: postgres
--

CREATE TRIGGER articles_owner_track BEFORE INSERT OR UPDATE ON all_articles FOR EACH ROW EXECUTE PROCEDURE postgrest.update_owner();


SET search_path = postgrest, pg_catalog;

--
-- TOC entry 1924 (class 2620 OID 16716)
-- Name: ensure_auth_role_exists; Type: TRIGGER; Schema: postgrest; Owner: postgres
--

CREATE CONSTRAINT TRIGGER ensure_auth_role_exists AFTER INSERT OR UPDATE ON auth NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE check_role_exists();


--
-- TOC entry 2042 (class 0 OID 0)
-- Dependencies: 8
-- Name: 1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA "1" FROM PUBLIC;
REVOKE ALL ON SCHEMA "1" FROM postgres;
GRANT ALL ON SCHEMA "1" TO postgres;
GRANT USAGE ON SCHEMA "1" TO anon;


--
-- TOC entry 2044 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = "1", pg_catalog;

--
-- TOC entry 2046 (class 0 OID 0)
-- Dependencies: 174
-- Name: all_articles; Type: ACL; Schema: 1; Owner: postgres
--

REVOKE ALL ON TABLE all_articles FROM PUBLIC;
REVOKE ALL ON TABLE all_articles FROM postgres;
GRANT ALL ON TABLE all_articles TO postgres;
GRANT ALL ON TABLE all_articles TO author;


--
-- TOC entry 2048 (class 0 OID 0)
-- Dependencies: 175
-- Name: articles; Type: ACL; Schema: 1; Owner: postgres
--

REVOKE ALL ON TABLE articles FROM PUBLIC;
REVOKE ALL ON TABLE articles FROM postgres;
GRANT ALL ON TABLE articles TO postgres;
GRANT ALL ON TABLE articles TO author;


-- Completed on 2015-07-29 09:43:13 COT

--
-- PostgreSQL database dump complete
--

