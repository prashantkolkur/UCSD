drop table if exists scoreboard cascade;
CREATE TABLE scoreboard
(
  name character varying(50) references teams (name) NOT NULL,
  points int NOT NULL
);

CREATE OR REPLACE FUNCTION scoreboard_update() RETURNS TRIGGER AS $scoreboard$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
        	IF NEW.hteam NOT IN (SELECT scoreboard.name from scoreboard) THEN
            	INSERT INTO scoreboard (name, points) VALUES (NEW.hteam, 0);
            END IF;
            IF NEW.vteam NOT IN (SELECT scoreboard.name from scoreboard) THEN
            	INSERT INTO scoreboard (name, points) VALUES (NEW.vteam, 0);
			END IF;
        	IF NEW.hscore>NEW.vscore THEN
            	UPDATE scoreboard SET points=points+2 where scoreboard.name=NEW.hteam;
            ELSIF NEW.vscore>NEW.hscore THEN
            	UPDATE scoreboard SET points=points+3 where scoreboard.name=NEW.vteam;
            ELSIF NEW.vscore=NEW.hscore THEN
            	UPDATE scoreboard SET points=points+1 where scoreboard.name=NEW.hteam;
            	UPDATE scoreboard SET points=points+1 where scoreboard.name=NEW.vteam;
            END IF;

        ELSIF (TG_OP = 'UPDATE') THEN
        	/*IF home team changed or visitior team changed or both changed or the hscore changed or the vscore changed
            	Then remove points on both both hteam and vteam based on win, lose or draw*/
        	IF OLD.hscore>OLD.vscore THEN UPDATE scoreboard SET points=points-2 where scoreboard.name=OLD.hteam;
            ELSIF OLD.hscore<OLD.vscore THEN UPDATE scoreboard SET points=points-3 where scoreboard.name=OLD.vteam;
            ELSIF OLD.hscore=OLD.vscore THEN UPDATE scoreboard SET points=points-1 where scoreboard.name=OLD.hteam;
                						     UPDATE scoreboard SET points=points-1 where scoreboard.name=OLD.vteam;
            END IF;
            /*After removing the points update the points table based on new data*/
            IF NEW.hteam NOT IN (SELECT scoreboard.name from scoreboard) THEN
            	INSERT INTO scoreboard (name, points) VALUES (NEW.hteam, 0);
            END IF;
            IF NEW.vteam NOT IN (SELECT scoreboard.name from scoreboard) THEN
            	INSERT INTO scoreboard (name, points) VALUES (NEW.vteam, 0);
			END IF;
			IF NEW.hscore>NEW.vscore THEN UPDATE scoreboard SET points=points+2 where scoreboard.name=NEW.hteam;
            ELSIF NEW.vscore>NEW.hscore THEN UPDATE scoreboard SET points=points+3 where scoreboard.name=NEW.vteam;
            ELSIF NEW.vscore=NEW.hscore THEN UPDATE scoreboard SET points=points+1 where scoreboard.name=NEW.hteam;
            								 UPDATE scoreboard SET points=points+1 where scoreboard.name=NEW.vteam;
            END IF;				
        END IF;
        RETURN NULL; 
    END;
$scoreboard$ LANGUAGE plpgsql;

drop trigger if exists trigger_scoreboard_update on matches;
CREATE TRIGGER trigger_scoreboard_update
AFTER INSERT OR UPDATE ON matches
    FOR EACH ROW EXECUTE PROCEDURE scoreboard_update();

