drop  table D_Age cascade;
drop table  D_User cascade ;
drop  table D_DateTime cascade;
drop  table D_Article cascade;
drop  table D_Layout cascade;
drop  table D_Article_Group cascade;
drop  table D_State cascade;
drop table  D_State_Group_Bridge cascade ;
drop  table D_Heart_Rate_Group cascade;
drop  table D_Heart_Rate_Group_Bridge cascade;
drop  table D_Article_Group_Bridge cascade;
drop  table D_State_Group cascade;
drop  table D_Layout_Group_Bridge cascade;
drop  table D_Heart_Rate_Group_Bridge cascade;
drop  table D_Heart_Rate cascade;
drop  table F_Article_Usage cascade;
drop  table F_App_Usage cascade;





create sequence sqDHW
  start with 1
  increment by 1
  cache 20
  ;

 create table D_Age(age_id integer not null primary key, 
				    age integer not null);
					

create table D_User(user_id integer not null primary key, 
				    name_d varchar(50) not null,
				    birthdate date not null);
					
create table D_DateTime( date_id integer not null primary key, 
					     date_d date not null,
					   	 day_d integer not null, 
					   	 month_d integer not null, 
					   	 year_d integer,
						 time_d time,
					     hour_d integer,
					     minute_d integer,
					     second_d integer);		
						 
create table D_Article(article_id integer not null primary key,
					   title varchar(50) not null,
					   content text not null,
					   author varchar(50) not null, 
					   category varchar(50), 
					   video text not null,
					   audio text not null,
					   published_date date not null);
					   
create table D_Article_Group(article_usage_group_id integer not null primary key);	

create table D_Article_Group_Bridge(article_id integer not null,
									article_usage_group_id integer not null,
									foreign key(article_id) references D_Article(article_id),
									 foreign key(article_usage_group_id) references D_Article_Group(article_usage_group_id));
									 
									 
									 
									 
									 

					   
					   
create table D_State(state_id integer not null primary key,
					 state_d varchar(50) not null);

									 
create table D_State_Group(app_usage_state_group_id integer not null primary key);


create table D_State_Group_Bridge(state_id integer not null, 
							 app_usage_state_group_id integer not null, 
							 foreign key(state_id) references D_State(state_id),
							 foreign key(app_usage_state_group_id) references D_State_Group(app_usage_state_group_id));
 

					 



create table D_Layout(layout_id integer not null primary key, 
				       layout varchar(50) not null);
					  
create table D_Layout_Group(layout_group_id integer not null primary key);


create table D_Layout_Group_Bridge(layout_id  integer not null,
								   layout_group_id integer not null,
								   foreign key(layout_id) references D_Layout(layout_id), 
								   foreign key(layout_group_id) references D_Layout_Group(layout_group_id));
								
								
create table D_Heart_Rate(heart_rate_id integer not null primary key,
						   heartrate integer not null);
						   
						   
 create table D_Heart_Rate_Group(heart_rate_group_id integer not null primary key);	
 
 
create table D_Heart_Rate_Group_Bridge(heart_rate_id integer not null, 
									  heart_rate_group_id integer  not null, 
									 foreign key(heart_rate_id) references D_Heart_Rate(heart_rate_id),
							        foreign key(heart_rate_group_id) references D_Heart_Rate_Group(heart_rate_group_id));
									
									
									
									
	
create table F_App_Usage(user_id integer references D_User(user_id),
						 age_id integer references D_Age(age_id),
						 app_usage_state_group_id integer references D_State_Group(app_usage_state_group_id),
						 heart_rate_group_id integer references D_Heart_Rate_Group(heart_rate_group_id),
						 article_usage_group_id integer references D_Article_Group(article_usage_group_id),
						 layout_group_id integer references D_Layout_Group(layout_group_id),
						 from_date_id integer references D_DateTime(date_id),
						 to_date_id integer references D_DateTime(date_id),
						 primary key(user_id,age_id,app_usage_state_group_id, heart_rate_group_id,article_usage_group_id, layout_group_id,from_date_id,to_date_id));
						 

create table F_Article_Usage(
							 age_id integer references D_Age(age_id),
							 user_id integer references D_User(user_id),
							 state_id integer references D_State(state_id),
	                         heart_rate_id integer references D_Heart_Rate(heart_rate_id),
	                         article_id integer references D_Article(article_id),
							 layout_id integer references D_Layout(layout_id),
							 from_date_id integer references D_DateTime(date_id),
							 to_date_id integer references D_DateTime(date_id)
							/* primary key(age_id,user_id, state_id, heart_rate_id,article_id,layout_id,from_date_id,to_date_id )*/);
							  
							




