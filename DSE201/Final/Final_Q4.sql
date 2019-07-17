DROP VIEW IF EXISTS points_table; 

CREATE VIEW points_table(name, points) 
AS 
  SELECT t.name, 
         Coalesce(f.points, 0) AS points 
  FROM   teams t 
         LEFT JOIN (SELECT u.team            AS team, 
                           Sum(u.win_points) AS points 
                    FROM   (SELECT h.hteam            AS team, 
                                   COUNT(h.hteam) * 2 AS win_points 
                            FROM   matches h 
                            WHERE  h.hscore > h.vscore 
                            GROUP  BY h.hteam 
                            UNION ALL 
                            SELECT v.vteam            AS team, 
                                   COUNT(v.vteam) * 3 AS win_points 
                            FROM   matches v 
                            WHERE  v.vscore > v.hscore 
                            GROUP  BY v.vteam 
                            UNION ALL 
                            SELECT h.hteam            AS team, 
                                   COUNT(h.hteam) * 1 AS win_points 
                            FROM   matches h 
                            WHERE  h.hscore = h.vscore 
                            GROUP  BY h.hteam 
                            UNION ALL 
                            SELECT v.vteam            AS team, 
                                   COUNT(v.vteam) * 1 AS win_points 
                            FROM   matches v 
                            WHERE  v.vscore = v.hscore 
                            GROUP  BY v.vteam) u 
                    GROUP  BY u.team) f 
                ON t.name = f.team; 

DROP VIEW IF EXISTS defeated_team_and_defeated_by_team; 

CREATE VIEW defeated_team_and_defeated_by_team(defeated_team, defeated_by_team) 
AS 
  SELECT h.hteam AS defeated_team, 
         h.vteam AS defeated_by_team 
  FROM   matches h 
  WHERE  h.hscore < h.vscore 
  UNION ALL 
  SELECT v.vteam AS defeated_team, 
         v.hteam AS defeated_by_team 
  FROM   matches v 
  WHERE  v.vscore < v.hscore; 

SELECT C.defeated_team AS name 
FROM   (SELECT DISTINCT A.defeated_team 
        FROM   defeated_team_and_defeated_by_team A 
        WHERE  A.defeated_by_team IN (SELECT p.name 
                                      FROM   points_table p 
                                      WHERE  p.points IN (SELECT Max(points) 
                                                          FROM   points_table))) 
       C 
WHERE  C.defeated_team NOT IN (SELECT DISTINCT B.defeated_team 
                               FROM   defeated_team_and_defeated_by_team B 
                               WHERE  B.defeated_by_team NOT IN (SELECT p.name 
                                                                 FROM 
                                      points_table p 
                                                                 WHERE 
                                      p.points IN (SELECT Max(points) 
                                                   FROM   points_table))) 