prepare Q5 (int) as
select p.video_id, sum(log) as rank from
(select o.video_id,T.user1, T.user_id, T.count, log(1+T.count) as log from
(select A.user_id as user1,B.user_id,count(A.video_id) as count from
(select m.user_id,m.video_id from likes m where m.user_id=$1 ) A,
(select n.user_id,n.video_id from likes n where n.user_id in (select u.user_id from users u) and not n.user_id=$1) B
where A.video_id=B.video_id
group by A.user_id,B.user_id) T

join (select l.user_id,l.video_id from likes l where l.video_id in (select v.video_id from video v)) o on T.user_id=o.user_id
) p
group by p.video_id
order by rank desc
limit 10;
Execute Q5(1);