-- Database: biometrics

-- DROP DATABASE biometrics;

/* flow of the app usage*/ 


truncate table app_usage_old;
insert into app_usage_old select * from app_usage_today;


truncate table app_usage_today; 
truncate table new_app_usage;
truncate table deleted_app_usage;
truncate table modified_app_usage;
truncate table sent_for_validation_app_usage;
truncate table sent_for_tranformation_app_usage;
truncate table transformed_app_usage;

INSERT INTO app_usage_today SELECT * FROM app_usage;
commit;
/*Comparing the app_usage from yesterday with the ones from  today and finding the NEW added app_usage*/
insert into new_app_usage select * from app_usage_today
where app_usage_id
in
 (
   select  app_usage_id from app_usage_today
   except
  select app_usage_id from app_usage_old
 );
 
 commit;
 
 select * from app_usage_today;
 
 select * from new_app_usage;
 
  /*Comparing the app_usge from yesterday with the ones today and finding the DELETED app_usage*/
/* insert into deleted_app_usage
 select * from app_usage_old where app_usage_id 
 in
 (
 select app_usage_id from app_usage_old
 except
 select app_usage_id from app_usage_today
 )
;
commit;*/




/*Comparing the app_usage from yesterday with the ones today and finding the app_usage that have some of their data modified*/
insert into modified_app_usage
select * from 
(
 select * from app_usage_today
 except
 select * from app_usage_old
 ) as modified
 where not app_usage_id in
 ( select app_usage_id from app_usage_today
except
 select app_usage_id from app_usage_old
 )
;

commit;


/*Sending the NEW, MODIFIED and DELETED app_usage for validation */
insert into sent_for_validation_app_usage 
      select app_usage_id,user_id,user_name,birthday,heart_rate,heart_rate_state,heart_rate_date,layout_type,app_open,app_closed,'New'
             from new_app_usage;
insert into sent_for_validation_app_usage
      select app_usage_id,user_id,user_name,birthday,heart_rate,heart_rate_state,heart_rate_date,layout_type,app_open,app_closed,'Deleted'
             from deleted_app_usage;
insert into sent_for_validation_app_usage 
      select app_usage_id,user_id,user_name,birthday,heart_rate,heart_rate_state,heart_rate_date,layout_type,app_open,app_closed,'Modified'
	        from fixed_app_usage;



commit;


CREATE OR REPLACE FUNCTION valitdate_test_app_usage()
RETURNS SETOF text AS $$
DECLARE curs2
 CURSOR  for select * from sent_for_validation_app_usage;
 status         integer:= 0;/*0 not changed send it for transformation, 1 send to rejected , 2 send to fix send it for transformation*/
 AppUsageId     varchar(50)      :='';
 UserID         varchar(50)      :='';
 UserName       varchar(50) :='';
 Birthday       date        :=current_date ;
 HeartRate      integer     :=0;
 HeartRateState varchar(50) :='';
 HeartRateDate  date        :=current_date;
 LayoutType     varchar(50) :='';
 AppOpen        timestamp   :=CURRENT_TIMESTAMP ;
 AppClosed      timestamp   :=CURRENT_TIMESTAMP ;
 ChangeType     varchar(50) :='';
 
 
 begin 

 FOR r in curs2 LOOP 
 status:=0;
 AppUsageId    :=r.app_usage_id;
 UserID        :=r.user_id;
 UserName      :=r.user_name;
 Birthday      :=r.birthday;
 HeartRate     :=r.heart_rate;
 HeartRateState:=r.heart_rate_state;
 HeartRateDate :=r.heart_rate_date;
 LayoutType    :=r.layout_type;
 AppOpen       :=r.app_open;
 AppClosed     :=r.app_closed;
 ChangeType    :=r.change_type;
 

	 
	if AppUsageId is null then
	AppUsageId:='unknown';
	status:=2;
 	end if;

	if TRIM(AppUsageId) = '' then
	 AppUsageId:='unknown';
	 status:=2;
	 end if;
 
 	
	 
 if UserID is null then
	UserID:='unknown';
	status:=2;
 	end if;
	
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
	 

	 if HeartRate <60 then
	 HeartRate:=60;
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
	 

	 
	  if TRIM(LayoutType) = '' then
	 LayoutType:='unknown';
	 status:=2;
	 end if;
	 
	 if LayoutType is null then
	LayoutType:='unknown';
	status:=2;
 	end if;
	 
	 
	
	  if AppOpen > CURRENT_TIMESTAMP  then
	 AppOpen:= CURRENT_TIMESTAMP ;
	 status:=2;
	 end if;
	 
	 
	   if AppClosed > CURRENT_TIMESTAMP   then
	 AppClosed:= CURRENT_TIMESTAMP ;
	 status:=2;
	 end if;
	 
	
	 
	 if status=2 then  
 INSERT INTO fixed_app_usage(app_usage_id, user_id, user_name, birthday,heart_rate, heart_rate_state, heart_rate_date,layout_type,app_open,app_closed,change_type)
 VALUES (AppUsageId, UserID,  UserName , Birthday,HeartRate,HeartRateState,HeartRateDate,LayoutType, AppOpen ,AppClosed,ChangeType );
 
 INSERT INTO sent_for_tranformation_app_usage(app_usage_id, user_id, user_name, birthday,heart_rate, heart_rate_state, heart_rate_date,layout_type,app_open,app_closed,change_type)
 VALUES (AppUsageId, UserID,  UserName , Birthday,HeartRate,HeartRateState,HeartRateDate,LayoutType, AppOpen ,AppClosed,ChangeType );


end if; 
 
 	if status=0 then 
 INSERT INTO sent_for_tranformation_app_usage(app_usage_id, user_id, user_name, birthday,heart_rate, heart_rate_state, heart_rate_date,layout_type,app_open,app_closed,change_type)
 VALUES (AppUsageId, UserID,  UserName , Birthday,HeartRate,HeartRateState,HeartRateDate,LayoutType, AppOpen ,AppClosed,ChangeType );
 end if;
 
  /* if status=1 then 
 INSERT INTO deleted_app_usage(app_usage_id, user_id, user_name, birthday,heart_rate, heart_rate_state, heart_rate_date,layout_type,app_open,app_closed,change_type)
 VALUES (AppUsageId, UserID,  UserName , Birthday,HeartRate,HeartRateState,HeartRateDate,LayoutType, AppOpen ,AppClosed,ChangeType );
 end if;
 END LOOP;
 END; $$ LANGUAGE plpgsql;
 commit;*/

 SELECT valitdate_test_app_usage();
 
 
select * from sent_for_tranformation_app_usage;
 
/*Inserting the new app_usage into the app_usage dimension of the DWH*/

 insert into transformed_app_usage 
 select nextval('sqDHW'), user_id, user_name, birthday,heart_rate, heart_rate_state, heart_rate_date,layout_type,app_open,app_closed,change_type
   from sent_for_tranformation_app_usage;
   
   app_usage_id, user_id, user_name, birthday,heart_rate, heart_rate_state, heart_rate_date,layout_type,app_open,app_closed,change_type
   
INSERT
INTO transformed_app_usage
SELECT 
COALESCE(app_usage_id,'unknown'),
COALESCE(user_id,'unknown'),
COALESCE(user_name,'unknown') ,
birthday,
heart_rate,
COALESCE (heart_rate_state,'unknown'),
heart_rate_date,
COALESCE(layout_type,'unknown') ,
app_open,
app_closed,
change_type
FROM sent_for_tranformation_app_usage;
   
ALTER TABLE transformed_app_usage ADD COLUMN age_p  integer;
 /* add column age to transformed_article_usage*/ 

 /* extract age from birthday and update the column*/   
UPDATE transformed_app_usage SET age_p= EXTRACT(year FROM age(current_date,birthday));
select * from transformed_app_usage;
  
/*Loading Data into Dimensional Model*/
/*loading all distinct layout into the D_Layout*/

insert  
    into D_Layout SELECT nextval('sqDHW'),transformed_app_usage.layout_type
FROM (SELECT  layout_type FROM transformed_app_usage) transformed_app_usage;

/*loading users into the D_User*/

insert  
    into D_User SELECT nextval('sqDHW'),transformed_app_usage.user_name,transformed_app_usage.birthday
FROM (SELECT user_name,birthday FROM transformed_app_usage) transformed_app_usage;

/*loading all  layouts into the D_State*/

insert  
    into D_State SELECT nextval('sqDHW'),transformed_app_usage.heart_rate_state
FROM (SELECT  heart_rate_state FROM transformed_app_usage) transformed_app_usage;



/*select * from transformed_app_usage
as select * from transformed_article_usage 
where transformed_article_usage.user_id = transformed_app_usage.user_id
and from transformed_article_usage.age_id = transformed_app_usage.age_id
and from transformed_article_usage.from_date > transformed_article_usage.from_date
and from transformed_article_usage.to_date > transformed_article_usage.to_date
and from tr*/


insert into transformed_with_keys_app_u
             select
			 coalesce(u.user_id,0),
			 coalesce(p.age_id,0),
			 coalesce(u.app_usage_state_group_id,0),
			 coalesce(h.heart_rate_group_id,0),  
			 coalesce(a.article_usage_group_id,0),
			 coalesce(l.layout_group_id,0),
			 coalesce(c.from_date_id,0),
			 coalesce(b.to_date_id,0)
			 from transformed_app_usage t 
			 left outer join D_Age p 
			 on(p.age= t.age_p)
			  left outer join D_User u
			 on (u.name_d=t.user_name and u.birthdate=t.birthday) 
			/* D_Article_Group_Bridge*/
			/* D_Layout_Group_Bridge*/
			/* D_State_Group_Bridge*/
			/* D_Heart_Rate_Group_Bridge*/
			
			 left outer join D_DateTime b
			on (b.date_d=t.app_open)
			 left outer join D_DateTime c
			 on (c.date_d = t.app_closed);

