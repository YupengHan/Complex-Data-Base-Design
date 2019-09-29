-- Yupeng Han
-- EE562 PRJ3 
-- My email is han434@purdue.edu
-- Please feel free to contact me, I am sure my code can run perfectly for all the queries and I finished all the triggers
create or replace function fun_to_date(weeknum number, daynum number)
    -- year is 2005
    return date 
    is 
    returndate date;
    startdate date:=to_date('01/01/2005','MM/DD/YY');
begin
   returndate:=startdate+7*(weeknum-1)+daynum+1;
   -- dbms_output.put_line('returndate is: '||returndate);
   return returndate;
end;
/


create or replace procedure pro_surgeon_schedule
    is
    weeknum number:=0;
    daynum number:=0;
    curdate date;
    countall number:=0;

begin
    daynum:=6;
    insert into surgeon_schedule values ('Dr. Richards',to_date('01/01/2005','MM/DD/YY'));
    insert into surgeon_schedule values ('Dr. Gower',to_date('01/01/2005','MM/DD/YY'));
    insert into surgeon_schedule values ('Dr. Rutherford',to_date('01/01/2005','MM/DD/YY'));
    loop 
    weeknum:=weeknum+1;
    exit when weeknum>52;
    daynum:=0;
        loop
        exit when daynum>6;
--        dbms_output.put_line('weeknum:'||weeknum||'   daynum:'||daynum);
        curdate:=fun_to_date(weeknum, daynum);
        -- if (daynum=0 or daynum=1 or daynum=4)
        -- then
        -- dbms_output.put_line('Drs. Smith'||curdate);
        -- dbms_output.put_line('Drs. Charles'||curdate);
        -- dbms_output.put_line('Drs. Taylor'||curdate);
        -- end if;


        if (daynum=0 or daynum=1 or daynum=4)
        then
        -- countall:=countall+1;
        insert into surgeon_schedule values ('Dr. Smith',curdate);
        insert into surgeon_schedule values ('Dr. Charles',curdate);
        insert into surgeon_schedule values ('Dr. Taylor',curdate);
--        dbms_output.put_line(countall);
--        dbms_output.put_line('S,M,T');
        
        end if;
        if (daynum=2 or daynum=3 or daynum=5 or daynum=6)
        then
        -- countall:=countall+1;
--        dbms_output.put_line(countall);
--        dbms_output.put_line('T,W,F,S');
        insert into surgeon_schedule values ('Dr. Richards',curdate);
        insert into surgeon_schedule values ('Dr. Gower',curdate);
        insert into surgeon_schedule values ('Dr. Rutherford',curdate);
        end if;
        daynum:=daynum+1;
        end loop;
    end loop;

end;
/

delete from surgeon_schedule;
begin
pro_surgeon_schedule;
end;
/

-- sat shangban!!!!
-- bushi 52 ge xunhuan!!!!


create or replace procedure pro_dr_schedule
    is 
    weeknum number:=0;
    daynum number;
    curdate date;
    countall number:=0;

begin
     daynum:=-1;
     weeknum:=1;
     curdate:=fun_to_date(weeknum,daynum);
     insert into dr_schedule values('James','GENERAL_WARD',curdate);
     insert into dr_schedule values('Robert','SCREENING_WARD',curdate);
     insert into dr_schedule values('Mike','PRE_SURGERY_WARD',curdate);
     insert into dr_schedule values('Adams','POST_SURGERY_WARD',curdate);
     insert into dr_schedule values('Tracey','Surgery',curdate);
     weeknum:=0;

    loop 
    weeknum:= weeknum +1;
    exit when weeknum>52;
    daynum:=0;
        loop
        exit when daynum>6;
        curdate:=fun_to_date(weeknum,daynum);
-- James 1
-- Robert 2 
-- Mike 3
-- Adams 4
-- Tracey 5
-- Rick 6

        if daynum=0
        then 
        -- dbms_output.put_line('sun');
        insert into dr_schedule values('James','GENERAL_WARD',curdate);
        insert into dr_schedule values('Robert','SCREENING_WARD',curdate);
        insert into dr_schedule values('Mike','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('Adams','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('Tracey','Surgery',curdate);
        insert into dr_schedule values('Rick','Surgery',curdate);
        end if;

        if daynum=1
        then 
        -- dbms_output.put_line('mon');
        insert into dr_schedule values('Robert','GENERAL_WARD',curdate);
        insert into dr_schedule values('Mike','SCREENING_WARD',curdate);
        insert into dr_schedule values('Adams','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('Tracey','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('Rick','Surgery',curdate);
        end if;

        if daynum=2
        then 
        -- dbms_output.put_line('tue');
        insert into dr_schedule values('Mike','GENERAL_WARD',curdate);
        insert into dr_schedule values('Adams','SCREENING_WARD',curdate);
        insert into dr_schedule values('Tracey','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('Rick','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('James','Surgery',curdate);
        end if;
        

        if daynum=3
        then 
        -- dbms_output.put_line('wed');
        insert into dr_schedule values('Adams','GENERAL_WARD',curdate);
        insert into dr_schedule values('Tracey','SCREENING_WARD',curdate);
        insert into dr_schedule values('Rick','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('James','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('Robert','Surgery',curdate);
        end if;
        

        if daynum=4
        then 
        -- dbms_output.put_line('thu');
        insert into dr_schedule values('Tracey','GENERAL_WARD',curdate);
        insert into dr_schedule values('Rick','SCREENING_WARD',curdate);
        insert into dr_schedule values('James','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('Robert','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('Mike','Surgery',curdate);
        end if;
        

        if daynum=5
        then 
        -- dbms_output.put_line('fri');
        insert into dr_schedule values('Rick','GENERAL_WARD',curdate);
        insert into dr_schedule values('James','SCREENING_WARD',curdate);
        insert into dr_schedule values('Robert','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('Mike','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('Adams','Surgery',curdate);
        end if;

        if daynum=6
        then
        -- dbms_output.put_line('sta');
        insert into dr_schedule values('James','GENERAL_WARD',curdate);
        insert into dr_schedule values('Robert','SCREENING_WARD',curdate);
        insert into dr_schedule values('Mike','PRE_SURGERY_WARD',curdate);
        insert into dr_schedule values('Adams','POST_SURGERY_WARD',curdate);
        insert into dr_schedule values('Tracey','Surgery',curdate);
        end if;

        daynum:=daynum+1;
        countall:=countall+1;
        -- dbms_output.put_line(daynum);

        end loop;
        
        -- dbms_output.put_line(countall);
    end loop;
end;
/

delete from dr_schedule;
begin
pro_dr_schedule;
end;
/


create or replace function validation
return number
is
-- >0 stands for not good, 0 stands for everything is fine
returnnum number:=0;
start_day date:=to_date('01/01/05','mm/dd/yy');
cur_day date;
i number;
j number;
gen number;
scr number;
pre number;
post number;
car number;
neu number;
con_3_ward number;
jawd number;
rowd number;
miwd number;
adwd number;
trwd number;
riwd number;
mv_num number;
begin
    for i in 1..365 loop
        cur_day:=start_day+i-1;

        select count(*) into gen
        from dr_schedule
        where duty_date=cur_day
        and ward='GENERAL_WARD';

        select count(*) into scr
        from dr_schedule
        where duty_date=cur_day
        and ward='SCREENING_WARD';

        select count(*) into pre
        from dr_schedule
        where duty_date=cur_day
        and ward='PRE_SURGERY_WARD';

        select count(*) into post
        from dr_schedule
        where duty_date=cur_day
        and ward='POST_SURGERY_WARD';

        if (post>0 and pre>0 and scr>0 and gen>0)
        then returnnum:=returnnum+0;
        else returnnum:=returnnum+1;
            dbms_output.put_line('not every ward has a doctor on '||cur_day);
        end if;

        select count(*) into car
        from surgeon_schedule
        where surgery_date=cur_day
        and (name='Dr. Charles' or name='Dr. Gower');

        select count(*) into neu
        from surgeon_schedule
        where surgery_date=cur_day
        and (name='Dr. Taylor' or name='Dr. Rutherford');

        if (car>0 and neu>0)
        then returnnum:=returnnum+0;
        else returnnum:=returnnum+1;
            dbms_output.put_line('cardiac or neuro may not have a surgeon on '||cur_day);
        end if;

    end loop;

    select count(distinct d0.name) into con_3_ward
    from dr_schedule d0,dr_schedule d1,dr_schedule d2,dr_schedule d3
    where d0.name=d1.name
    and d1.name=d2.name
    and d2.name=d3.name
    and d0.ward=d1.ward
    and d1.ward=d2.ward
    and d2.ward=d3.ward
    and d2.duty_date=d1.duty_date+1
    and d3.duty_date=d1.duty_date+2;



    if con_3_ward>0
    then 
    returnnum:=returnnum+1;
    end if;

    
    for i in 1..52 loop
        jawd:=0;
        rowd:=0;
        miwd:=0;
        adwd:=0;
        trwd:=0;
        riwd:=0;
        
        for j in 1..7 loop
            cur_day:=start_day+7*(i-1)+j;
            select count(*) into mv_num
            from dr_schedule
            where duty_date=cur_day
            and name='James';
            if mv_num>0
            then jawd:=jawd+1;
            end if;

            select count(*) into mv_num
            from dr_schedule
            where duty_date=cur_day
            and name='Robert';
            if mv_num>0
            then rowd:=rowd+1;
            end if;

            select count(*) into mv_num
            from dr_schedule
            where duty_date=cur_day
            and name='Mike';
            if mv_num>0
            then miwd:=miwd+1;
            end if;

            select count(*) into mv_num
            from dr_schedule
            where duty_date=cur_day
            and name='Adams';
            if mv_num>0
            then adwd:=adwd+1;
            end if;

            select count(*) into mv_num
            from dr_schedule
            where duty_date=cur_day
            and name='Tracey';
            if mv_num>0
            then trwd:=trwd+1;
            end if;

            select count(*) into mv_num
            from dr_schedule
            where duty_date=cur_day
            and name='Rick';
            if mv_num>0
            then riwd:=riwd+1;
            end if;

        end loop;
        if (riwd<>6 or trwd<>6 or adwd<>6 or miwd<>6 or rowd<>6 or jawd<>6)
        then returnnum:=returnnum+1;
        end if;
    end loop;

    if returnnum=0
    then dbms_output.put_line('dr_schedule and surgeon_schedule are both good!');
    end if;
    return returnnum;
end;
/

declare
c number;
begin
c:=validation;
end;
/

------------------------------------------------------------------------------------------------------------
-- displaying tables
------------------------------------------------------------------------------------------------------------

exec dbms_output.put_line('Schedule of each patient:');
select * from patient_input order by general_ward_admission_date;
select * from general_ward;
select * from SCREENING_WARD;
select * from PRE_SURGERY_WARD;
select * from POST_SURGERY_WARD;

exec dbms_output.put_line('Dr_schedule Table:');
select * from dr_schedule order by duty_date;

exec dbms_output.put_line('Surgeon_schedule Table:');
select * from surgeon_schedule order by surgery_date;

exec dbms_output.put_line('Dr_schedule Table:');
select * from dr_schedule order by duty_date;

exec dbms_output.put_line('Display Patient_Surgery_View');
create table view_table(
patient_name varchar2(30),
surgery_day date,
surgeon_name varchar2(30),
constraint vtpk primary key (patient_name,surgery_day));

create or replace procedure pro_view
is 
cursor con_list is 
select patient_name,patient_type,post_admission_date,scount 
from post_surgery_ward;
mv_name varchar2(30);
begin
    for pp in con_list loop
    if pp.patient_type='general'
                then
                    select name into mv_name
                    from surgeon_schedule
                    where surgery_date=pp.post_admission_date
                    and (name='Dr. Smith' or name='Dr. Richards');
    end if;

    if pp.patient_type='cardiac'
                then
                    select name into mv_name
                    from surgeon_schedule
                    where surgery_date=pp.post_admission_date
                    and (name='Dr. Charles' or name='Dr. Gower');
    end if;

    if pp.patient_type='neuro'
                then
                    select name into mv_name
                    from surgeon_schedule
                    where surgery_date=pp.post_admission_date
                    and (name='Dr. Taylor' or name='Dr. Rutherford');
    end if;
    insert into view_table values (pp.patient_name,pp.post_admission_date,mv_name);

    if pp.scount=2
    then
        if pp.patient_type='general'
                then
                    select name into mv_name
                    from surgeon_schedule
                    where surgery_date=pp.post_admission_date+2
                    and (name='Dr. Smith' or name='Dr. Richards');
        end if;

        if pp.patient_type='cardiac'
                then
                    select name into mv_name
                    from surgeon_schedule
                    where surgery_date=pp.post_admission_date+2
                    and (name='Dr. Charles' or name='Dr. Gower');
        end if;

        if pp.patient_type='neuro'
                then
                    select name into mv_name
                    from surgeon_schedule
                    where surgery_date=pp.post_admission_date+2
                    and (name='Dr. Taylor' or name='Dr. Rutherford');
        end if;
        insert into view_table values (pp.patient_name,pp.post_admission_date+2,mv_name);
    end if;

    end loop;
end;
/

begin
delete from view_table;
pro_view;
end;
/
-- select * from view_table;
create or replace view view_for_myexecute as
select * 
from view_table;

select * from view_for_myexecute;


