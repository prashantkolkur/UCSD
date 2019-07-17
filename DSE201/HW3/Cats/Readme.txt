Note 1:
I have modified some of my queries to get performance. I have submitted the updated queries in on GitHub


Note 2: Below are the Index statements I used for performance tuning on my queries

CREATE INDEX idx_likes ON likes (user_id, video_id);
CREATE INDEX idx_friend ON friend (user_id);
CREATE INDEX idx_watch ON watch (user_id);

Note 3: Explanation
1. CREATE INDEX idx_likes ON likes (user_id, video_id);
   On Likes table indexes were created on user_id and video_id columns because in queries "where" condition statement was used on user_id column and "group by" statement was used on video_id column. 
	So if indexes where created on these columns then performance increased by a huge margin since index lookup and index scan was performed on these columns.
2. CREATE INDEX idx_friend ON friend (user_id);
   On friend table index was created on user_id because in queries "where" condition statement was used on user_id column. 
3. CREATE INDEX idx_watch ON watch (user_id);
   On watch table index was created on user_id because in queries "where" condition statement was used on user_id column. 

Note 4: Performance Measurements
Q1:
Without Index: 13.670ms
With Index: 6.337ms

Q2:
Without Index: 5.434ms
With Index: 0.064ms

Q3:
Without Index: 8.8211ms
With Index: 0.123ms

Q4:
Without Index: 8.885ms
With Index: 0.291ms

Q5:
Without Index: 13.982ms
With Index: 2.364ms



