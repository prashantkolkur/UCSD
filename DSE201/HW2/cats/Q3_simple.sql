prepare Q3 (int) as
select l.video_id as vid, count(l.video_id) as rank from likes l
where l.user_id in (select distinct f.friend_id from friend f
							where f.user_id in (select f1.friend_id from friend f1 where f1.user_id=$1) or f.user_id=$1)
      and l.user_id!=$1
group by l.video_id
order by count(l.video_id) desc
limit 10;
Execute Q3(1);