-- Yupeng Han
-- EE562 PRJ3 
-- My email is han434@purdue.edu
-- Please feel free to contact me, I am sure my code can run perfectly for all the queries and I finished all the triggers

------------------------------------------------------------------------------------------------------------------
-- create patient chart with my own data
------------------------------------------------------------------------------------------------------------------
create or replace procedure pro_create_patient_chart
is 
cur_date date:=to_date('01/01/05','mm/dd/yy');
nor_temp number:=98;
nor_BP number:=120;
cur_name varchar2(20);
un_temp number:=70;
un_BP number:=200;
i number;
j number;
begin
-- normal patient
    for i in 1..365 loop
        for j in 1..6 loop
            cur_name:=CONCAT('name',to_char(j,'9'));
            -- dbms_output.put_line('cur_name: '||cur_name);
            insert into patient_chart values(cur_name,cur_date,nor_temp,nor_BP);
        end loop;
-- patient temperature un-normal
        -- dbms_output.put_line('cur_name: name 7');
        insert into patient_chart values('name 7',cur_date,un_temp,nor_BP);
-- patient BP & temperature unnormal
        -- dbms_output.put_line('cur_name: name 8');
        insert into patient_chart values('name 8',cur_date,un_temp,un_BP);

        cur_date:=cur_date+1;
        -- dbms_output.put_line('cur_date: '||cur_date);

    end loop;

end;
/


delete from patient_chart;
begin
pro_create_patient_chart;
end;
/

-- select * from patient_chart;


-- insert some basic data into patient input 
delete from patient_input;
insert into patient_input values ('name 1',to_date('01/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 2',to_date('01/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 3',to_date('01/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 4',to_date('01/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 5',to_date('01/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 6',to_date('01/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 7',to_date('01/01/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 8',to_date('01/01/05','mm/dd/yy'),'neuro');

insert into patient_input values ('name 1',to_date('02/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 7',to_date('02/01/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 2',to_date('02/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 8',to_date('02/01/05','mm/dd/yy'),'neuro');
insert into patient_input values ('name 3',to_date('02/01/05','mm/dd/yy'),'general');


insert into patient_input values ('name 8',to_date('03/04/05','mm/dd/yy'),'neuro');
insert into patient_input values ('name 1',to_date('03/01/05','mm/dd/yy'),'general');
insert into patient_input values ('name 2',to_date('03/05/05','mm/dd/yy'),'general');
insert into patient_input values ('name 3',to_date('03/06/05','mm/dd/yy'),'general');
insert into patient_input values ('name 7',to_date('03/02/05','mm/dd/yy'),'general');

insert into patient_input values ('name 1',to_date('04/04/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 8',to_date('04/02/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 7',to_date('04/05/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 1',to_date('04/17/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 2',to_date('04/02/05','mm/dd/yy'),'neuro');
insert into patient_input values ('name 3',to_date('04/15/05','mm/dd/yy'),'neuro');
insert into patient_input values ('name 1',to_date('05/2/05','mm/dd/yy'),'general');

insert into patient_input values ('name 8',to_date('06/01/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 8',to_date('06/21/05','mm/dd/yy'),'general');
insert into patient_input values ('name 8',to_date('07/10/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 8',to_date('07/30/05','mm/dd/yy'),'general');
insert into patient_input values ('name 8',to_date('08/21/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 8',to_date('09/15/05','mm/dd/yy'),'general');
insert into patient_input values ('name 8',to_date('10/01/05','mm/dd/yy'),'cardiac');
insert into patient_input values ('name 8',to_date('10/27/05','mm/dd/yy'),'general');





------------------------------------------------------------------------------------------------------------------
-- populate_db
------------------------------------------------------------------------------------------------------------------
create or replace procedure populate_db
is 
    cursor pp is 
    select patient_name, general_ward_admission_date, patient_type
    from patient_input
    order by general_ward_admission_date,patient_name;
begin
    for i in pp loop
    insert into general_ward values (i.patient_name,i.general_ward_admission_date,i.patient_type);
    -- dbms_output.put_line('incase of infinity loop.');
    end loop;
end;
/

begin
populate_db;
end;
/



-- delete from patient_input;
-- delete from general_ward;
-- delete from screening_ward;
-- delete from pre_surgery_ward;
-- delete from post_surgery_ward;
-- delete from temp_scr_ward;
-- delete from temp_pre_ward;





-- select * from general_ward;
-- select *  from screening_ward;
-- select *  from pre_surgery_ward;
-- select *  from post_surgery_ward;
-- select *  from temp_scr_ward;
-- select *  from temp_pre_ward;














