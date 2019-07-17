prepare Q1 (int) as
select l.video_id as vid, count(l.video_id) as rank from likes l
where l.user_id!=$1
group by l.video_id
order by count(l.video_id) desc
limit 10;
Execute Q1(10);