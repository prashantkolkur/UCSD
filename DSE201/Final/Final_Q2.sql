SELECT t.NAME, 
       COALESCE(f.points, 0) AS points 
FROM   teams t 
       LEFT JOIN (SELECT u.team            AS team, 
                         Sum(u.win_points) AS points 
                  FROM   (SELECT h.hteam            AS team, 
                                 Count(h.hteam) * 2 AS win_points 
                          FROM   matches h 
                          WHERE  h.hscore > h.vscore 
                          GROUP  BY h.hteam 
                          UNION ALL 
                          SELECT v.vteam            AS team, 
                                 Count(v.vteam) * 3 AS win_points 
                          FROM   matches v 
                          WHERE  v.vscore > v.hscore 
                          GROUP  BY v.vteam 
                          UNION ALL 
                          SELECT h.hteam            AS team, 
                                 Count(h.hteam) * 1 AS win_points 
                          FROM   matches h 
                          WHERE  h.hscore = h.vscore 
                          GROUP  BY h.hteam 
                          UNION ALL 
                          SELECT v.vteam            AS team, 
                                 Count(v.vteam) * 1 AS win_points 
                          FROM   matches v 
                          WHERE  v.vscore = v.hscore 
                          GROUP  BY v.vteam) u 
                  GROUP  BY u.team) f 
              ON t.NAME = f.team 