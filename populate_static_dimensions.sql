
CREATE INDEX d_date_date_actual_idx
ON D_DateTime(date_id);
 

/* populating dimensiion D_DateTime */ 
INSERT INTO D_DateTime 

SELECT nextval('sqDHW') AS date_id,
       datum AS date_d,
       EXTRACT(DAY FROM datum) AS day_d,
       EXTRACT(MONTH FROM datum ) AS month_d,
	   EXTRACT(YEAR FROM datum) AS year_d,
	   cast(timestamp '2014-04-03 00:00:00' as time) as time_d,
	   EXTRACT(HOUR FROM datum) As hour_d,
	   EXTRACT(MINUTE FROM datum) As hour_d,
	   EXTRACT(SECOND FROM datum) as second_d

FROM generate_series('2019-01-01 00:00:00'::timestamp, '2020-01-01 23:59:59'::timestamp, '1 second') datum
ORDER  BY datum;

/* populating D_Heart_Rate with values from 40 to 250*/ 
do $$
begin 
for i in 40..250 loop
  insert into public.d_heart_rate values(nextval('sqDHW'),i);
end loop;
end;
$$;

/* populating D_Age with values from 1 to 110*/ 

do $$
begin 
for i in 1..110 loop
  insert into public.d_heart_rate values(nextval('sqDHW'),i);
end loop;
end;
$$;


/* populating the D_State_Group*/
insert into D_State_Group values(nextval('sqDHW'));


/* populating the D_Layout_Group*/
insert into D_Layout_Group values(nextval('sqDHW'));


/*populating D_State_Group*/

insert into D_State_Group values (nextval('sqDHW')); 

/* populating D_Hear_Rate_Group*/

insert into D_Hear_Rate_Group(nextval('sqDHW')); 

