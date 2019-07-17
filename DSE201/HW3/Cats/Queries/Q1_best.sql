prepare Q1_best (int) as
select l.video_id as vid, count(l.video_id) as rank from likes l
where l.user_id!=$1 and l.video_id not in (select uv.video_id from likes uv where uv.user_id=$1) and l.video_id not in (select w.video_id from watch w where w.user_id=$1)
group by l.video_id
order by count(l.video_id) desc
limit 10;
Execute Q1_best(10);