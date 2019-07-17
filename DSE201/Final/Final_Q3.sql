/*a team has played at least one game.*/ 
SELECT t.coach 
FROM   teams t 
WHERE  t.NAME NOT IN (SELECT h.hteam 
                      FROM   matches h 
                      WHERE  h.hscore < h.vscore) 
       AND t.NAME NOT IN (SELECT v.vteam 
                          FROM   matches v 
                          WHERE  v.vscore < v.hscore) 
       AND t.NAME IN (SELECT DISTINCT hteam 
                      FROM   matches 
                      UNION 
                      SELECT DISTINCT vteam 
                      FROM   matches) 