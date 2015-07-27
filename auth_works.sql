-- underlying source table
CREATE TABLE "1".all_articles (
  body text,
  id serial NOT NULL,
  owner character NOT NULL,
  CONSTRAINT posts_pkey PRIMARY KEY (id)
) WITH ( OIDS=FALSE );

-- view for reading/writing
CREATE OR REPLACE VIEW "1".articles AS 
 SELECT all_articles.body,
    all_articles.id,
    all_articles.owner
   FROM "1".all_articles
  WHERE all_articles.owner = current_setting('user_vars.user_id');

GRANT ALL ON TABLE "1".articles TO author;

-- the trigger function to bookkeep owners
CREATE OR REPLACE FUNCTION postgrest.update_owner()
  RETURNS trigger AS
$BODY$
BEGIN
   NEW.owner = current_setting('user_vars.user_id'); 
   RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- activate it on all_articles
CREATE TRIGGER articles_owner_track
  BEFORE INSERT OR UPDATE
  ON "1".all_articles
  FOR EACH ROW
  EXECUTE PROCEDURE postgrest.update_owner();