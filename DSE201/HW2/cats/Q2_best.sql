prepare Q2_best (int) as
select l.video_id as vid, count(l.video_id) as rank from friend f
join likes l on l.user_id=f.friend_id
where f.user_id=$1 and l.video_id not in (select uv.video_id from likes uv where uv.user_id=$1) and l.video_id not in (select w.video_id from watch w where w.user_id=$1)
group by l.video_id
order by count(l.video_id) desc
Limit 10;
Execute Q2_best(10);
