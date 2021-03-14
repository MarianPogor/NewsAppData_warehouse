-- SCHEMA: public

-- DROP SCHEMA public ;

truncate table yesterday_users;
insert into yesterday_users select * from today_users;

truncate table today_users; 
truncate table new_users;
truncate table deleted_users;
truncate table modified_users;
truncate table sent_for_validation_users;
truncate table sent_for_transformation_users;
truncate table transformed_users;


/*Copy from source the user data from today*/
INSERT INTO today_users SELECT * FROM users;


/*Comparing the members from yesterday with the ones today and finding the NEW added members*/
insert into new_users select * from today_users where user_id
in
 (
   select user_id from today_users
   except
  select user_id from yesterday_users
 );
 
 
 
 /*Comparing the members from yesterday with the ones today and finding the DELETED members*/
 insert into deleted_users
 select * from yesterday_users where user_id 
 in
 (
 select user_id from yesterday_users
 except
 select user_id from today_users
 )
;



/*Comparing the users from yesterday with the ones today and finding the users that have some of their data modified*/
insert into modified_users
select * from 
(
 select * from today_users
 except
 select * from yesterday_users
 ) as modified
 where not user_id in
 ( select user_id from today_users
except
 select user_id from yesterday_users
 )
;




/*Sending the NEW, MODIFIED and DELETED users for validation */
insert into sent_for_validation_users select user_id,user_name,birthdate,'New' from new_users;
insert into sent_for_validation_users select user_id,user_name,birthdate,'Deleted' from deleted_users;
insert into sent_for_validation_users select user_id,user_name,birthdate,'Modified' from modified_users;


select * from sent_for_validation_users;

/*Validating Fixing and Rejecting data and inserting them into the coresponding tables*/
/* DEALLOCATE CURSOR curs;*/

CREATE OR REPLACE FUNCTION valitdate_user_test()
       RETURNS SETOF text AS $$
       DECLARE curs1
CURSOR  for select * from sent_for_validation_users;

 status          integer:=0;/*0 not changed send it for transformation, 1 send to rejected , 2 send to fix send it for transformation*/
 UserID      	 varchar(50):='';
 Birthdate        date:=current_date ;
 Username        varchar(50):='';
 ChangeType      varchar(50) :='';
 
 begin
 FOR r IN curs1 LOOP 
 
 status:=0;
 UserID     :=r.user_id;
 Username   :=r.user_name;
 Birthdate   :=r.birthdate;
 ChangeType :=r.change_type;
 
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
 
 
  if Birthdate > CURRENT_DATE then
     Birthdate:= CURRENT_DATE;
	 status:=2;
	 end if;
	 
	
	 
	 if status=2 then  
 INSERT INTO fixed_user_Data(user_id, user_name, birthdate, change_type)
 VALUES (UserID, Username, Birthdate, ChangeType);

  insert into sent_for_transformation_users(user_id, user_name, birthdate, change_type)
 VALUES (UserID, Username, Birthdate, ChangeType);
  end if; 
  
  
 	if status=0 then 
 insert into sent_for_transformation_users(user_id, user_name, birthdate, change_type)
 VALUES (UserID, Username, Birthdate, ChangeType);
 end if; 
 
    if status=1 then 
	insert into rejected_user_data (user_id, user_name, birthdate, change_type)
  VALUES (UserID, Username, Birthdate, ChangeType);
 end if; 

 END LOOP;
 
 END; $$ LANGUAGE plpgsql;

 SELECT valitdate_user_test();

select * from sent_for_transformation_users; 

INSERT
INTO transformed_users
SELECT
COALESCE(user_id,'unkwnown'),
COALESCE(user_name,'unkwnown'),
birthdate,
change_type
FROM sent_for_transformation_users;


/*Inserting the new users into the user dimension of the DWH*/
insert into D_User(user_id,name_d,birthdate)
         select nextval('sqDHW'),
		 user_name,
		 birthdate
		 from transformed_users
		 where change_type  in ('New', 'Modified');



delete from sent_for_transformation_users;  

delete from transformed_users; 

delete from sent_for_validation_users; 

commit; 