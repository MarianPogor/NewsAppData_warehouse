-- SCHEMA: public

-- DROP SCHEMA public ;

       DROP TABLE IF EXISTS article_usage_today;
	   DROP TABLE IF EXISTS article_usage_yesterday;
	   DROP TABLE IF EXISTS new_article_usage;
       DROP TABLE IF EXISTS deleted_article_usage;
	   
       DROP TABLE IF EXISTS modified_article_usage;
	   DROP TABLE IF EXISTS fixed_article_usage;
	   DROP TABLE IF EXISTS rejected_article_usage;
		 
       DROP TABLE IF EXISTS sent_for_validation_article_usage;
	   DROP TABLE IF EXISTS sent_for_tranformation_article_usage;
	   
	   DROP TABLE IF EXISTS transformed_article_usage;

/* cretoing tables*/
  
    create table  article_usage_today as select * from article_usage where 1=0;
	create table article_usage_yesterday as select * from article_usage where 1=0;
	
	
	
	create table new_article_usage as select * from article_usage_today where 1=0;
	create table deleted_article_usage as select * from article_usage_today where 1=0; 
	create table modified_article_usage as select * from article_usage_today where 1=0; 
	
	 

	create table sent_for_validation_article_usage as select * from article_usage_today where 1=0;
	alter table sent_for_validation_article_usage add change_type varchar(50) not null check (change_type in ('New','Modified','Deleted'));
	
	create table fixed_article_usage as select * from sent_for_validation_article_usage where 1=0;
	create table rejected_article_usage as select * from  sent_for_validation_article_usage where 1=0;
	create table sent_for_tranformation_article_usage as select * from sent_for_validation_article_usage where 1=0;
	
	create table transformed_article_usage(
		article_usage_id varchar(50) not null,
		user_id varchar(100) not null, 
		user_name varchar(100) not null,
		birthday date not null,
		article_id varchar(50) not null,
		article_title text not null,
		article_content text not null,
		article_author varchar(50) not null,
		article_category varchar(50) not null,
		article_published date not null,
		article_video text not null,
		article_audio text not null,
		article_open timestamp not null,
		article_closed timestamp not null,
		heart_rate integer not null,
		heart_rate_state varchar(50) not null,
		heart_rate_date timestamp not null, 
		layout_type varchar(50) not null,
        change_type varchar(50) not null
	
	);
	
			   
	
create table transformed_with_keys_a_u(age_id integer not null,
										user_id integer not null,
										state_id integer not null, 
										heart_rate_id integer not null,
										article_id integer not null,
										layout_id  integer not null,
										from_date_id integer not null,
										to_date_id integer not null);



	
	