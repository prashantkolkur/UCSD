drop table if exists comman_likes_count_table cascade;
CREATE TABLE comman_likes_count_table
(
  main_user int NOT NULL,
  user_id int NOT NULL,
  likes_count integer NOT NULL,
  log numeric NOT NULL
);

CREATE OR REPLACE FUNCTION comman_likes_count() RETURNS TRIGGER AS $comman_likes_count_table$
	DECLARE comman_user record;
    DECLARE l_count int;
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            FOR comman_user IN select * from likes where likes.video_id=NEW.video_id and likes.user_id!=NEW.user_id
            LOOP
            	l_count=(select m.likes_count from comman_likes_count_table m where m.main_user=NEW.user_id and m.user_id=comman_user.user_id);
            	IF l_count IS NOT NULL THEN
                	UPDATE comman_likes_count_table SET likes_count=l_count+1, log=log(l_count+1+1)
                    	where comman_likes_count_table.main_user=NEW.user_id and comman_likes_count_table.user_id=comman_user.user_id;
                    UPDATE comman_likes_count_table SET likes_count=l_count+1, log=log(l_count+1+1)
                    	where comman_likes_count_table.main_user=comman_user.user_id and comman_likes_count_table.user_id=NEW.user_id;
                ELSIF l_count IS NULL THEN
            		INSERT INTO comman_likes_count_table values (NEW.user_id, comman_user.user_id, 1, log(2));
                    INSERT INTO comman_likes_count_table values (comman_user.user_id, NEW.user_id, 1, log(2));
                END IF;
           	END LOOP;
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
        	FOR comman_user IN select * from likes where likes.video_id=OLD.video_id and likes.user_id!=OLD.user_id
            LOOP
            	l_count=(select m.likes_count from comman_likes_count_table m where m.main_user=OLD.user_id and m.user_id=comman_user.user_id);
                UPDATE comman_likes_count_table SET likes_count=l_count-1, log=log(l_count)
                    where comman_likes_count_table.main_user=OLD.user_id and comman_likes_count_table.user_id=comman_user.user_id;
                UPDATE comman_likes_count_table SET likes_count=l_count-1, log=log(l_count)
                    	where comman_likes_count_table.main_user=comman_user.user_id and comman_likes_count_table.user_id=OLD.user_id;
           	END LOOP;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$comman_likes_count_table$ LANGUAGE plpgsql;

drop trigger if exists trigger_comman_likes_count on likes;
CREATE TRIGGER trigger_comman_likes_count
AFTER INSERT OR DELETE ON likes
    FOR EACH ROW EXECUTE PROCEDURE comman_likes_count();