-- Table: public.article

-- DROP TABLE public.article;

       DROP TABLE IF EXISTS today_articles;
	   DROP TABLE IF EXISTS old_articles;
	   DROP TABLE IF EXISTS new_articles;
       DROP TABLE IF EXISTS deleted_articles;
       DROP TABLE IF EXISTS modified_articles;
       DROP TABLE IF EXISTS sent_for_validation_articles;
       DROP TABLE IF EXISTS fixed_articles;
       DROP TABLE IF EXISTS rejected_articles;
	   DROP TABLE IF EXISTS sent_for_transformation_articles;
	   DROP TABLE IF EXISTS transformed_article;
	   
	   


    create table today_articles as select * from article where 1=0;
	create table old_articles as select * from article where 1=0;
	create table new_articles as select * from today_articles where 1=0;
	
	
	create table deleted_articles as select * from today_articles where 1=0; 
	create table modified_articles as select * from today_articles where 1=0; 

	create table sent_for_validation_articles as select * from today_articles where 1=0;
	alter table sent_for_validation_articles add change_type varchar(50) not null check (change_type in ('New','Modified','Deleted'));
	
	create table fixed_articles as select * from sent_for_validation_articles where 1=0;
	create table rejected_articles as select * from  sent_for_validation_articles where 1=0;
	create table sent_for_transformation_articles as select * from sent_for_validation_articles where 1=0;
	
	create table transformed_article(
		article_id varchar(50) not null,
		title varchar(100) not null, 
		content varchar(100) not null,
		author varchar(50) not null,
		video text not null,
		audio text not null, 
		category varchar(50) not null, 
		publish_date date not null,
		change_type varchar(50) not null
	);   
	