-- SCHEMA: public

-- DROP SCHEMA public ;

truncate table article_usage_yesterday;
insert into article_usage_yesterday select * from article_usage_today;

truncate table article_usage_today; 
truncate table new_article_usage;
truncate table deleted_article_usage;
truncate table modified_article_usage;
truncate table sent_for_validation_article_usage;
truncate table sent_for_tranformation_article_usage;
truncate table transformed_article_usage;

select * from article_usage_today;
INSERT INTO article_usage_today SELECT * FROM article_usage;

/*Comparing the article_usage from yesterday with the ones from  today and finding the NEW added article_usage*/


insert into new_article_usage 
select * from article_usage_today
where article_usage_id
in
 (
   select  article_usage_id from article_usage_today
   except
  select article_usage_id from article_usage_yesterday
 );
 
 
  /*Comparing the article_usge from yesterday with the ones today and finding the DELETED app_usage*/
 insert into deleted_article_usage
 select * from article_usage_yesterday where article_usage_id 
 in
 (
 select article_usage_id from article_usage_yesterday
 except
 select article_usage_id from article_usage_today
 )
;

/*Comparing the article_usage from yesterday with the ones today and finding the article_usage that have some of their data modified*/
insert into modified_article_usage
select * from 
(
 select * from article_usage_today
 except
 select * from article_usage_yesterday
 ) as modified_a_u
 where not article_usage_id in
 ( select article_usage_id from article_usage_today
except
 select article_usage_id from article_usage_yesterday
 )
;
/*Sending the NEW, MODIFIED and DELETED article_usage for validation */
insert into sent_for_validation_article_usage 
      select article_usage_id,user_id,user_name,birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate,heart_rate_state,heart_rate_date,layout_type,'New'
             from new_article_usage;
insert into sent_for_validation_article_usage 
      select article_usage_id,user_id,user_name,birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate,heart_rate_state,heart_rate_date,layout_type,'Deleted'
             from deleted_article_usage;
insert into sent_for_validation_article_usage 
      select article_usage_id,user_id,user_name,birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate,heart_rate_state,heart_rate_date,layout_type,'Modified'
             from modified_article_usage;

/*Validating Fixing and Rejecting data and inserting them into the coresponding tables*/

CREATE OR REPLACE FUNCTION valitdate_test_article_usage()
RETURNS SETOF text AS $$
DECLARE curs3
 CURSOR  for select * from sent_for_validation_article_usage;
 status             integer     := 0;/*0 not changed send it for transformation, 1 send to rejected , 2 send to fix send it for transformation*/
 ArticleUsageId     varchar(50) :='';
 UserID             varchar(50) := '';
 Username           varchar(50) :='';
 Birthday           date        :=current_date ;
 ArticleID          varchar(50) :='';
 ArticleTitle       text        :='';
 ArticleContent     text        :='';
 ArticleAuthor      varchar(50) :='';
 ArticleCategory    varchar(50) :='';
 ArticlePublished   timestamp   :=LOCALTIMESTAMP ;
 ArticleVideo       varchar(100):='';
 ArticleAudio       varchar(100):='';
 HeartRate          integer     :=0;
 HeartRateState     varchar(50) :='';
 HeartRateDate      date        :=current_date;
 ArticleOpen        timestamp   :=LOCALTIMESTAMP ;
 ArticleClosed      timestamp   :=LOCALTIMESTAMP ;
 LayoutType         varchar(50) :='';
 ChangeType         varchar(50) :='';
 
 
 begin 

 FOR x in curs3 LOOP 
 status:=0;
 ArticleUsageId     :=x.article_usage_id;
 UserID             :=x.user_id;
 Username           :=x.user_name;
 Birthday           :=x.birthday;
 ArticleID          :=x.article_id;
 ArticleTitle       :=x.article_title;
 ArticleContent     :=x.article_content;
 ArticleAuthor      :=x.article_author;
 ArticleCategory    :=x.article_category;
 ArticlePublished   :=x.article_published ;
 ArticleVideo       :=x.article_video;
 ArticleAudio       :=x.article_audio;
 HeartRate          :=x.heart_rate;
 HeartRateState     :=x.heart_rate_state;
 HeartRateDate      :=x.heart_rate_date;
 LayoutType         :=x.layout_type;
 ArticleOpen        :=x.article_open;
 ArticleClosed      :=x.article_closed;
 ChangeType         :=x.change_type;
 

	 
	if ArticleUsageId is null then
		ArticleUsageId:='unknown';
		status:=2;
 	end if;

	if TRIM(ArticleUsageId) = '' then
	 	ArticleUsageId:='unknown';
		status:=2;
	 end if;
 
 	
	 
 /*if UserID is null then
		UserID:=-1;
		status:=2;
		
 	end if;*/
		if TRIM(UserID) = '' then
	 	UserID:='unknown';
		status:=2;
	 end if;
 
	 
if Username is null then
		Username:='unknown';
		status:=2;
 	end if;
	
if TRIM(Username) = '' then
	 	Username:='unknown';
	 	status:=2;
	 end if;

if Birthday > CURRENT_DATE then
    	 Birthday:=CURRENT_DATE;
	 	status:=2;
	 end if;
	 
if ArticleID is null then
		ArticleID:='unknown';
		status:=2;
 	end if;

if TRIM(ArticleID) = '' then
		 ArticleID:='unknown';
	 	status:=2;
	 end if;
	 
if ArticleTitle is null then
		ArticleTitle:='unknown';
		status:=2;
 	end if;

if TRIM(ArticleTitle) = '' then
	 	ArticleTitle:='unknown';
	 	status:=2;
	 end if;
	 
if ArticleContent is null then
		ArticleContent:='unknown';
		status:=2;
 	end if;

if TRIM(ArticleContent) = '' then
	 	ArticleContent:='unknown';
	 	status:=2;
	 end if;
	 
if ArticleAuthor is null then
		ArticleAuthor:='unknown';
		status:=2;
 	end if;

if TRIM(ArticleAuthor) = '' then
	 	ArticleAuthor:='unknown';
	 	status:=2;
	 end if;
	 
if ArticleCategory is null then
		ArticleCategory:='unknown';
		status:=2;
 	end if;

if TRIM(ArticleCategory) = '' then
		 ArticleCategory:='unknown';
	 	 status:=2;
	 end if;
	 
if ArticlePublished > LOCALTIMESTAMP then
	 	ArticlePublished:=LOCALTIMESTAMP;
	 	status:=2;
	 end if;
	 
	 
if ArticleVideo is null then
		ArticleVideo:='unknown';
		status:=2;
 	end if;

if TRIM(ArticleVideo) = '' then
		ArticleVideo:='unknown';
	 	status:=2;
	 end if;
	 
if ArticleAudio is null then
	ArticleAudio:='unknown';
	status:=2;
 end if;

if TRIM(ArticleAudio) = '' then
		ArticleAudio:='unknown';
	 	status:=2;
	end if;
	 
if ArticleOpen > LOCALTIMESTAMP then
	 	ArticleOpen:=LOCALTIMESTAMP;
	 	status:=2;
	 end if;
	 
if ArticleClosed > LOCALTIMESTAMP then
	 	ArticleClosed:=LOCALTIMESTAMP;
	 	status:=2;
end if;
	 
	 

if HeartRate <40 then
	 HeartRate:=50;
	 status:=2;
end if;
	 
if HeartRateState is null then
	HeartRateState:='unknown';
	status:=2;
end if;
	
if TRIM(HeartRateState) = '' then
	 HeartRateState:='unknown';
	 status:=2;
end if;
	 
	
if HeartRateDate > CURRENT_DATE then
	 HeartRateDate:=CURRENT_DATE;
	 status:=2;
end if;
	
	 /*cheking layout*/
	 
if TRIM(LayoutType) = '' then
	 LayoutType:='unknown';
	 status:=2;
	 end if;
	 
if LayoutType is null then
	LayoutType:='unknown';
	status:=2;
end if;
	
	 
	
	 
if status=2 then  
 	INSERT INTO fixed_article_usage(article_usage_id, user_id, user_name, birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate, heart_rate_state, heart_rate_date,layout_type,change_type)
 	VALUES(ArticleUsageId, UserID,  Username , Birthday, ArticleID, ArticleTitle,ArticleContent,ArticleAuthor,ArticleCategory,ArticlePublished,ArticleVideo,ArticleAudio, ArticleOpen, ArticleClosed,HeartRate,HeartRateState,HeartRateDate,LayoutType,ChangeType );
 
   INSERT INTO sent_for_tranformation_article_usage(article_usage_id, user_id, user_name, birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate, heart_rate_state, heart_rate_date,layout_type,change_type)
   VALUES (ArticleUsageId, UserID,  Username , Birthday, ArticleID, ArticleTitle,ArticleContent,ArticleAuthor,ArticleCategory,ArticlePublished,ArticleVideo,ArticleAudio, ArticleOpen, ArticleClosed,HeartRate,HeartRateState,HeartRateDate,LayoutType,ChangeType );
end if; 

if status=0 then 
 	INSERT INTO sent_for_tranformation_article_usage(article_usage_id, user_id, user_name, birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate, heart_rate_state, heart_rate_date,layout_type,change_type)
 	VALUES (ArticleUsageId, UserID,  Username , Birthday, ArticleID, ArticleTitle,ArticleContent,ArticleAuthor,ArticleCategory,ArticlePublished,ArticleVideo,ArticleAudio, ArticleOpen, ArticleClosed,HeartRate,HeartRateState,HeartRateDate,LayoutType,ChangeType );
end if; 

if status=1 then 
 INSERT INTO rejected_article_usage(article_usage_id, user_id, user_name, birthday,article_id,article_title,article_content,article_author,article_category,article_published,article_video,article_audio,article_open,article_closed,heart_rate, heart_rate_state, heart_rate_date,layout_type,change_type)
 VALUES (ArticleUsageId, UserID,  Username , Birthday, ArticleID, ArticleTitle,ArticleContent,ArticleAuthor,ArticleCategory,ArticlePublished,ArticleVideo,ArticleAudio, ArticleOpen, ArticleClosed,HeartRate,HeartRateState,HeartRateDate,LayoutType,ChangeType );
end if; 

END LOOP;
END; $$ 
LANGUAGE plpgsql;

/* run the function */ 

select valitdate_test_article_usage();

/* set user_id type integer*/ 
ALTER TABLE sent_for_tranformation_article_usage ALTER COLUMN user_id TYPE integer USING (user_id::integer);
 
 /* set article_published type date*/ 
ALTER TABLE sent_for_tranformation_article_usage ALTER COLUMN article_published TYPE date USING (article_published::date);
  
  select * from sent_for_tranformation_article_usage; 

INSERT 
INTO transformed_article_usage
SELECT
article_usage_id,
nextval('sqDHW'),
COALESCE(user_name,'unkwnown'),
birthday, 
article_id,
COALESCE(article_title,'unkwnown'), 
COALESCE(article_content,'unkwnown'),
COALESCE(article_author,'unkwnown'),
COALESCE(article_category,'unkwnown'), 
article_published,
COALESCE(article_video,'unkwnown'), 
COALESCE(article_audio,'unkwnown'),
article_open,
article_closed,
heart_rate,
COALESCE(heart_rate_state,'unkwnown'),
heart_rate_date,
COALESCE(layout_type,'unkwnown'),
change_type
FROM sent_for_tranformation_article_usage;

/*add column age to transformed_article_usage table*/

 ALTER TABLE transformed_article_usage ADD COLUMN age_p  integer;
 /* add column age to transformed_article_usage*/ 

 /* extract age from birthday and update the column*/   
UPDATE transformed_article_usage SET age_p= EXTRACT(year FROM age(current_date,birthday));
 
 			 
/* populate D_User*/ 
 
 insert into D_User(user_id,name_d,birthdate)
           select  nextval('sqDHW'),
			 user_name,
			 birthday
			 from transformed_article_usage;
			 
/* populate D_Article*/ 
 insert into D_Article(article_id,title,content,author,category,video,audio,published_date)
            select nextval('sqDHW'),article_title,article_content,article_author,article_category,article_video,article_audio,article_published 
			from transformed_article_usage;
			
/* populate D_Layout*/ 	
 insert into D_Layout(layout_id,layout)
 select nextval('sqDHW'),
         layout_type 
		 from transformed_article_usage;
		 
/* populate dimennsion D_State*/ 		
insert into D_State(state_id,state_d)
           select nextval('sqDHW'), 
		   heart_rate_state
		   from transformed_article_usage;
		   
  
/* key look up in Dimensional Model*/
insert into transformed_with_keys_a_u(age_id,user_id,state_id,heart_rate_id, article_id, layout_id,from_date_id,to_date_id)
             select 
			 coalesce(p.age_id,0),
			 coalesce(u.user_id,0),
			 coalesce(s.state_id,0), 
			 coalesce(h.heart_rate_id,0),  
			 coalesce(a.article_id,0),
			 coalesce(l.layout_id,0),
			 coalesce(c.from_date_id,0),
			 coalesce(b.to_date_id,0)
			 from transformed_article_usage t 
			 left outer join D_Age p 
			 on(p.age= t.age_p)
			 left outer join D_Article a 
			 on(a.title= t.article_title and a.content=t.article_content and 
				a.author=t.article_author and
				a.category=t.article_category and 
				a.video=t.article_video and 
				a.audio=t.article_audio and 
				a.published_date= t.article_published)
			 left outer join D_User u
			 on (u.name_d=t.user_name and u.birthdate=t.birthday)
			 left outer join D_State s 
			 on(s.state_d=t.heart_rate_state)
			 left outer join D_Heart_Rate h
			 on(h.heartrate=t.heart_rate)
			 left outer join D_Layout l
			 on (l.layout=t.layout_type)
			 left outer join D_DateTime b
			on (b.date_d=t.article_open)
			 left outer join D_DateTime c
			 on (c.date_d = t.article_closed);





commit; 		 

/* populate the fact table F_Article_Usage */ 
	
insert into F_Article_Usage (age_id,user_id,state_id,heart_rate_id,article_id,layout_id,from_date_id,to_date_id)
select 
                             age_id,user_id,state_id,heart_rate_id,article_id,layout_id,to_date_id,from_date_id from transformed_with_keys_a_u;

select count(date_id) from D_DateTime; 
select * from transformed_with_keys_a_u; 
 delete from transformed_with_keys_a_u;
delete from transformed_with_keys_a_u; 

delete from transformed_article_usage; 

delete from sent_for_tranformation_article_usage; 

commit; 

