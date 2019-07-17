

1. cats_Q5_precomputed.sql has 
	a. cats schema 
	b. create statement to create precomputed table
	c. Create trigger statements and the trigger function  
	d. Dataset used 

2. cats_precomputed_table_trigger_statment.sql has
	a. Create trigger statements and the trigger function 
		cats_Q5_precomputed.sql already has everything. I have explicitly provided separate sql for create statement of precomputed table for reference. 

3. indices used:
	a. Indices.sql has all the indices created for cats including index on precomputed table
	b. Create index statement on precomputed table:
		CREATE INDEX idx_comman_likes_count_table on comman_likes_count_table(main_user);

4. Original query without Precomputed table: 
prepare Q5_best (int) as
select p.video_id, sum(log) as rank from
(select o.video_id,T.user1, T.user_id, T.count, log(1+T.count) as log from
(select A.user_id as user1,B.user_id,count(A.video_id) as count from
(select m.user_id,m.video_id from likes m where m.user_id=$1) A,
(select n.user_id,n.video_id from likes n where n.user_id in (select u.user_id from users u) and not n.user_id=$1) B
where A.video_id=B.video_id 
group by A.user_id,B.user_id) T

join (select l.user_id,l.video_id from likes l where l.video_id in (select v.video_id from video v) 
      and l.video_id not in (select w.video_id from watch w where w.user_id=$1)
      and l.video_id not in (select uv.video_id from likes uv where uv.user_id=$1)) o 
 	  on T.user_id=o.user_id) p
group by p.video_id
order by rank desc
limit 10;
Execute Q5_best(1);

Performance without use of Precomputed table: 2.769ms

5. NEW QUERY WITH Precomputed Table:
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
explain analyze Execute Q5_best_precomputed(1);

Performance with use of  Precomputed table: 0.109ms

6. Explanation:
	a. Precomputed tables has:
		a. For every user_id total count of common likes are calculated between that user and every other user
		b. Log of likes count is calculated for the likes count between that user and every other user
	b. NOTE: The likes count column and log(likes_count+1) changes in precomputed whenever an user likes a video or unlikes(row deletion in likes table) a video. 


NOTE:
Performance without use of Precomputed table: 2.769ms
Performance with use of  Precomputed table:   0.109ms
