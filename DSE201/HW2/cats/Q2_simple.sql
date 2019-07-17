prepare Q2 (int) as
select l.video_id as vid, count(l.video_id) as rank from friend f
join likes l on l.user_id=f.friend_id
where f.user_id=$1
group by l.video_id
order by count(l.video_id) desc
Limit 10;
Execute Q2(10);
