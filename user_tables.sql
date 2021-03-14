-- Database: biometrics

-- DROP DATABASE biometrics;
     /*step 1*/ 
	 
	 
	DROP TABLE IF EXISTS today_Users;
	DROP TABLE IF EXISTS yesterday_Users;
	DROP TABLE IF EXISTS new_Users;
	DROP TABLE IF EXISTS deleted_Users;
	/*step 2*/
	
	DROP TABLE IF EXISTS modified_Users;
	DROP TABLE IF EXISTS fixed_user_Data;
	DROP TABLE IF EXISTS rejected_user_Data;
	/*step 3*/
	
	DROP TABLE IF EXISTS sent_for_validation_users;
	DROP TABLE IF EXISTS sent_for_transformation_users;
			


	/* step 4 */
	
	DROP TABLE IF EXISTS transformed_users;	
	
	truncate table users;
	create table today_Users as select * from users where 1=0;
	create table yesterday_Users as select * from users where 1=0;
	
	
	create table new_Users as select * from today_Users where 1=0;
	create table deleted_Users as select * from today_Users where 1=0;
	create table modified_Users as select * from today_Users where 1=0;
	create table sent_for_validation_users as select * from today_Users where 1=0;
	
   alter table sent_for_validation_users add change_type varchar(50) not null check (change_type in ('New','Deleted','Changed'));
   
   create table fixed_user_Data as select * from sent_for_validation_users where 1=0;
   create table rejected_user_Data as select * from sent_for_validation_users where 1=0;
   create table sent_for_transformation_users as select * from sent_for_validation_users where 1=0;
   
   create table transformed_users(
	   user_id integer  not null,
	   user_name VARCHAR(50) not null,
	   birthday  date not null,
	   change_type varchar(50) not null
   );
   

   
   commit;
   
	

	