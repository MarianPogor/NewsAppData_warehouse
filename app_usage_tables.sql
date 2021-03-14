-- Database: biometrics

-- DROP DATABASE biometrics;

       DROP TABLE IF EXISTS app_usage_today;
	   DROP TABLE IF EXISTS app_usage_old;
	   DROP TABLE IF EXISTS new_app_usage;
       DROP TABLE IF EXISTS deleted_app_usage;
       DROP TABLE IF EXISTS modified_app_usage;
       DROP TABLE IF EXISTS sent_for_validation_app_usage;
       DROP TABLE IF EXISTS fixed_app_usage;
       DROP TABLE IF EXISTS rejected_app_usage;
	   DROP TABLE IF EXISTS sent_for_tranformation_app_usage;
	   DROP TABLE IF EXISTS transformed_app_usage;

      
    create table  app_usage_today as select * from app_usage where 1=0;
	
	insert into app_usage_today select * from app_usage;
	create table app_usage_old as select * from app_usage where 1=0;
	create table new_app_usage as select * from app_usage_today where 1=0;
	
	
	create table deleted_app_usage as select * from app_usage_today where 1=0; 
	create table modified_app_usage as select * from app_usage_today where 1=0; 

	create table sent_for_validation_app_usage as select * from app_usage_today where 1=0;
	alter table sent_for_validation_app_usage add change_type varchar(50) not null check (change_type in ('New','Modified','Deleted'));
	
	create table fixed_app_usage as select * from sent_for_validation_app_usage where 1=0;
	create table rejected_app_usage as select * from  sent_for_validation_app_usage where 1=0;
	create table sent_for_tranformation_app_usage as select * from sent_for_validation_app_usage where 1=0;
	
	
	
		create table transformed_app_usage(
		app_usage_id varchar(50) not null,
		user_id varchar(100) not null, 
		user_name varchar(100) not null,
		birthday date not null,
		heart_rate integer not null,
		heart_rate_state varchar(50) not null, 
		heart_rate_date date not null, 
		layout_type varchar(50) not null,
		app_open timestamp not null,
		app_closed timestamp not null,
	    change_type varchar(50) not null
	);
	
	create table transformed_with_keys_app_u as select * from F_App_Usage where 1=0;
	
commit; 



