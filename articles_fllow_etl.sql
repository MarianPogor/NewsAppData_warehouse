truncate table old_articles;
insert into old_articles select * from today_articles;

truncate table today_articles; 
truncate table new_articles;
truncate table deleted_articles;
truncate table modified_articles;
truncate table sent_for_validation_articles;
truncate table sent_for_transformation_articles;
truncate table transformed_article;


	
/*Copy from source the articles  from today*/
INSERT INTO today_articles SELECT * FROM article;

/*Comparing the articles from yesterday with the ones today and finding the NEW added articles*/
insert into new_articles select * from today_articles where article_id
in
 (
   select article_id from today_articles
   except
  select article_id from old_articles
 );

 
 
/*Comparing the articles from yesterday with the ones today and finding the DELETED articles*/

 insert into deleted_articles
 select * from old_articles where article_id 
 in
 (
 select article_id from old_articles
except
 select article_id from today_articles
 )
;

commit;

	

/*Comparing the articles from yesterday with the ones today and finding the articles that have some of their data modified*/

insert into modified_articles
select * from 
(
 select * from today_articles
 except
 select * from old_articles
 ) as modified
 where not article_id in
 ( select article_id from today_articles
except
 select article_id from old_articles
 )
;


select * from today_articles;


/*Sending the NEW, MODIFIED and DELETED articles for validation */

insert into sent_for_validation_articles select article_id,title, content, author, video, audio, category, published, 'New' from new_articles;
insert into sent_for_validation_articles  select article_id,title, content,author,video,audio,category,published,'Deleted' from deleted_articles;
insert into sent_for_validation_articles select article_id,title,content,author,video,audio,category,published, 'Modified' from modified_articles;


CREATE OR REPLACE FUNCTION valitdate_test_articles()
RETURNS SETOF text AS $$
DECLARE curs1
 CURSOR  for select * from sent_for_validation_articles;
 status integer:=0;/*0 not changed send it for transformation, 1 send to rejected , 2 send to fix send it for transformation*/
 ArticleID varchar(50):='';
 Title varchar(100)   :='';
 Content text         :='';
 Author varchar(50)   :='';
 Video varchar(50)    :='';
 Audio varchar(50)    :='';
 Category varchar(50) :='';
 Published date        :=current_date;
ChangeType     varchar(50) :='';
 
 begin
 FOR x IN curs1 LOOP 
 
 status:=0;
 ArticleID :=x.article_id;
 Title     :=x.title;
 Content   :=x.content;
 Author    :=x.author;
 Video     :=x.video;
 Audio     :=x.audio;
 Category  :=x.category;
 Published :=x.published;
 ChangeType    :=x.change_type;
 
    if ArticleID is null then
	ArticleID:='unknown';
	status:=2;
 	end if;

	if TRIM(ArticleID) = '' then
	 ArticleID:='unknown';
	 status:=2;
	 end if;
 
	 
	  if Title is null then
	Title:='unknown';
	status:=2;
 	end if;

	if TRIM(Title) = '' then
	 Title:='unknown';
	 status:=2;
	 end if;
 
	   if Content is null then
	Content:='unknown';
	status:=2;
 	end if;

	if TRIM(Content) = '' then
	 Content:='unknown';
	 status:=2;
	 end if;
 
	   if Author is null then
	Author:='unknown';
	status:=2;
 	end if;

	if TRIM(Author) = '' then
	 Author:='unknown';
	 status:=2;
	 end if;
	 
	 
		   if Video is null then
	Video:='unknown';
	status:=2;
 	end if;

	if TRIM(Video) = '' then
	 Video:='unknown';
	 status:=2;
	 end if;
	
	 
	
	 	   if Audio is null then
	Audio:='unknown';
	status:=2;
 	end if;

	if TRIM(Audio) = '' then
	 Audio:='unknown';
	 status:=2;
	 end if;
	 
	if Category is null then
	Category:='unknown';
	status:=2;
 	end if;

	if TRIM(Category) = '' then
	 Category:='unknown';
	 status:=2;
	 end if;
	 

	  if Published > CURRENT_DATE then
     Published=CURRENT_DATE;
	 status:=2;
	 end if;
	 
	 
	 if status=2 then  
 INSERT INTO fixed_articles( article_id, title, content, author, video, audio, category, published,change_type)
 VALUES (ArticleID, Title, Content, Author,  Video, Audio,Category, Published, ChangeType );
 
 INSERT INTO sent_for_transformation_articles(article_id, title, content, author, video, audio, category, published,change_type)
 VALUES (ArticleID, Title, Content, Author, Video, Audio,Category, Published, ChangeType );
 end if; 
 
 	if status=0 then  
 INSERT INTO sent_for_transformation_articles(article_id, title, content, author, video, audio, category, published,change_type)
  VALUES (ArticleID, Title, Content, Author,  Video, Audio,Category, Published, ChangeType );
 end if; 
 
   if status=1 then  
 INSERT INTO rejected_articles(article_id, title, content, author, video, audio, category, published,change_type)
 VALUES (ArticleID, Title, Content, Author,  Video, Audio,Category, Published, ChangeType );
 end if; 

 END LOOP;
 
 END; $$ LANGUAGE plpgsql;


select valitdate_test_articles();



/* insert transformed article from sent to transformation*/

INSERT
INTO transformed_article
SELECT 
article_id,
COALESCE(title,'unknown'),
COALESCE(content,'unknown'),
COALESCE(author,'unknown'),
COALESCE(video,'unknown'),
COALESCE (audio,'unknown'),
COALESCE(category,'unknown'),
published,
change_type
FROM sent_for_transformation_articles;
  
/*Loading Data into Dimensional Model*/

/*loading all  articles into the D_Article*/

insert  
    into D_Article SELECT 
	nextval('sqDHW'),
	transformed_article.title,
	transformed_article.content,
	transformed_article.author,
	transformed_article.video,
	transformed_article.audio,
	transformed_article.category,
	transformed_article.publish_date
FROM (SELECT title,content,author,video,audio,category,publish_date FROM transformed_article) transformed_article;



truncate table transformed_article; 


truncate table sent_for_transformation_articles; 
