
prepare Q5_best_precomputed (int) as
select p.video_id, sum(log) as rank from
(select o.video_id,T.main_user, T.user_id, T.likes_count, T.log from
(select * from comman_likes_count_table c
where c.main_user=$1) T

join (select l.user_id,l.video_id from likes l where l.video_id in (select v.video_id from video v) 
      and l.video_id not in (select w.video_id from watch w where w.user_id=$1)
      and l.video_id not in (select uv.video_id from likes uv where uv.user_id=$1)) o 
 	  on T.user_id=o.user_id) p
group by p.video_id
order by rank desc
limit 10;
Execute Q5_best_precomputed(2);
