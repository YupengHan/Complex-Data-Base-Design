-- Yupeng Han
-- EE562 PRJ3 
-- My email is han434@purdue.edu
-- Please feel free to contact me, I am sure my code can run perfectly for all the queries and I finished all the triggers

create table temp_scr_ward(
patient_name varchar2(30),
s_admission_date date,
bed_no number,
patient_type varchar2(10),
stay_date date);

create table temp_pre_ward(
patient_name varchar2(30),
pre_admission_date date,
bed_no number,
patient_type varchar2(10),
stay_date date);


create or replace trigger trg_gen
	after insert on general_ward
	for each row
declare
cur_date date:=:new.g_admission_date+3;
finish_signal number:=0;
emp_sw_bedno number:=-1;
havebed number:=0;
bedno number:=-1;
loop_count number:=0;
state_exists number:=-1;
i number;

begin
    loop
    exit when finish_signal=1;
    exit when loop_count=30;

    -- serach for cur_date havebed ,whitch one
        for i in 1..5 loop
            exit when havebed=1;
            select case
                  when exists (select 1 
                  	          from temp_scr_ward
                  	          where stay_date=cur_date
                  	          and bed_no=i)
                  then 1
                  else 0
                end into state_exists
            from dual;
            -- dbms_output.put_line('state_exists is:');
            -- dbms_output.put_line(state_exists);
            if (state_exists=0)
            then
            havebed:=1;
            bedno:=i;
            end if;
        end loop;
        -- reset state_exists
        state_exists:=-1;

        if /*d3+1 sw have bed on cur_date,if have get bedno*/
        (havebed=1)
        then
        insert into screening_ward values(:new.patient_name,cur_date,bedno,:new.patient_type);
        finish_signal:=1;
        else  /*d3+1 sw donnot have bed*/
        cur_date:=cur_date+1;
        loop_count:=loop_count+1;
        dbms_output.put_line('Incase of keep inserting this is loop counter:');
        dbms_output.put_line(loop_count);
        end if;
    end loop;
    
end;
/ 



create or replace trigger trg_scr
	after insert on screening_ward
	for each row
declare 
cur_date date:=:new.s_admission_date;
state_exists number:=-1;
havebed number:=-1;  /*for pre_surgery_ward*/
stable_signal number:=-1;
finish_signal number:=-1;
conti_checker_date date;
conti_checker_number number;
mid_tem number;
mid_BP number;
bedno number;
i number;
j number;
loopcount number;
begin
    insert into temp_scr_ward values(:new.patient_name, :new.s_admission_date, :new.bed_no, :new.patient_type, :new.s_admission_date);
    insert into temp_scr_ward values(:new.patient_name, :new.s_admission_date, :new.bed_no, :new.patient_type, cur_date+1);
    insert into temp_scr_ward values(:new.patient_name, :new.s_admission_date, :new.bed_no, :new.patient_type, cur_date+2);
    cur_date:=cur_date+3;
    /*for forth day*/
    for i in 1..4 loop
        exit when havebed=1;
        select case 
            when exists(select 1
        	           from temp_pre_ward
        	           where stay_date=cur_date
        	           and bed_no=i
        	           )
            then 1
            else 0 
            end into state_exists
        from dual;

        if state_exists=0
        then 
        havebed:=1;
        bedno:=i;
        finish_signal:=1;
        end if;
    end loop;

    if havebed=1
    then
    insert into pre_surgery_ward values(:new.patient_name,cur_date,bedno,:new.patient_type);
    end if;

    if havebed<>1
    then
    insert into temp_scr_ward values(:new.patient_name, :new.s_admission_date, :new.bed_no, :new.patient_type, cur_date);
    cur_date:=cur_date+1;
    end if;

    /*for fifth and more than five days*/
    for loopcount in 1..30 loop
        exit when finish_signal=1;

        for i in 1..4 loop
            exit when havebed=1;
            select case 
                when exists(select 1
        	               from temp_pre_ward
        	               where stay_date=cur_date
        	               and bed_no=i
        	               )
                then 1
                else 0 
                end into state_exists
            from dual;

            if state_exists=0
            then 
            havebed:=1;
            bedno:=i;
            end if;
        end loop;

        if /*d3+1 sw have bed on cur_date,if have get bedno*/
        (havebed=1)
        then
        insert into pre_surgery_ward values(:new.patient_name,cur_date,bedno,:new.patient_type);
        finish_signal:=1;
        else
        /*continuous 4 days of loop*/
            conti_checker_number:=0;
            for j in 1..4 loop
                conti_checker_date:=cur_date-j;
            
                select temperature, BP into mid_tem, mid_BP
                from patient_chart
                where pdate=conti_checker_date
                and patient_name=:new.patient_name;

                if (mid_BP<=140 and mid_BP>=110 and mid_tem>=97 and mid_tem<=100)
                then
                conti_checker_number:=conti_checker_number+1;
                end if;

            end loop;

            if conti_checker_number=4
            then 
            insert into post_surgery_ward values(:new.patient_name,cur_date,cur_date+2,1,:new.patient_type);
            finish_signal:=1;
            else
            insert into temp_scr_ward values(:new.patient_name, :new.s_admission_date, :new.bed_no, :new.patient_type, cur_date);
            end if;

        end if;
        cur_date:=cur_date+1;
        dbms_output.put_line('Incase of keep inserting this is loop counter:');
        dbms_output.put_line(cur_date);

    end loop;

end;
/










create or replace trigger trg_pre
	after insert on pre_surgery_ward
	for each row
declare
begin
insert into temp_pre_ward values(:new.patient_name,:new.pre_admission_date,:new.bed_no,:new.patient_type,:new.pre_admission_date);
insert into temp_pre_ward values(:new.patient_name,:new.pre_admission_date,:new.bed_no,:new.patient_type,:new.pre_admission_date+1);
/*temperary discharge date for post surgery ward*/
insert into post_surgery_ward values(:new.patient_name,:new.pre_admission_date+2,:new.pre_admission_date+4,1,:new.patient_type);
end;
/


create or replace package post_mutating_pkg
	is
	type array is table of post_surgery_ward%rowtype
	index by binary_integer;

	post_values array;
	empty array;
end;
/


create or replace trigger post_mutating_trig_1
	before insert on post_surgery_ward
begin
    post_mutating_pkg.post_values:=post_mutating_pkg.empty;
end;
/


create or replace trigger trg_post
    before insert on post_surgery_ward
    for each row
declare
strange_signal number:=-1;
mid_tem number:=-1;
mid_BP number:=-1;
cur_date date:=:new.post_admission_date;
normal_checker_date date;
i number:=post_mutating_pkg.post_values.count+1;
begin
    for j in 1..2 loop
        exit when strange_signal=1;
        normal_checker_date:=cur_date+j-1;
        select temperature, BP into mid_tem, mid_BP
        from patient_chart
        where pdate=normal_checker_date
        and patient_name=:new.patient_name;

        if :new.patient_type='cardiac'
        then
            if (mid_BP>=140 or mid_BP<=110)
            then
            strange_signal:=1;
            end if;
        end if;

        if :new.patient_type='neuro'
        then
            if (mid_BP>=140 or mid_BP<=110 or mid_tem<=97 or mid_tem>=100)
            then
            strange_signal:=1;
            end if;
        end if;       

    end loop;

    if (strange_signal=1)
    then
    -- patient_name,post_admission_date,patient_type
    /*update*/
    post_mutating_pkg.post_values(i).patient_name:=:new.patient_name;
    post_mutating_pkg.post_values(i).post_admission_date:=:new.post_admission_date;
    post_mutating_pkg.post_values(i).patient_type:=:new.patient_type;
    dbms_output.put_line('666');
    end if;

end;
/
-- create or replace trigger trg_post
-- 	before insert on post_surgery_ward
-- 	for each row
-- declare
-- strange_signal number:=-1;
-- mid_tem number:=-1;
-- mid_BP number:=-1;
-- cur_date date:=:new.post_admission_date;
-- normal_checker_date date;
-- i number:=post_mutating_pkg.post_values.count+1;
-- begin
--     for j in 1..2 loop
--         exit when strange_signal=1;
--         normal_checker_date:=cur_date+j-1;
--         select temperature, BP into mid_tem, mid_BP
--         from patient_chart
--         where pdate=normal_checker_date
--         and patient_name=:new.patient_name;

--         if (mid_BP>=140 or mid_BP<=110 or mid_tem<=97 or mid_tem>=100)
--         then
--         strange_signal:=1;
--         end if;

--     end loop;

--     if (strange_signal=1)
--     then
--     -- patient_name,post_admission_date,patient_type
--     /*update*/
--     post_mutating_pkg.post_values(i).patient_name:=:new.patient_name;
--     post_mutating_pkg.post_values(i).post_admission_date:=:new.post_admission_date;
--     post_mutating_pkg.post_values(i).patient_type:=:new.patient_type;
--     dbms_output.put_line('666');
--     end if;

-- end;
-- /

create or replace trigger post_mutating_trig_2
	after insert on post_surgery_ward
declare
i number;
begin
    for i in 1..post_mutating_pkg.post_values.count
    loop 
        update post_surgery_ward
        	set scount=2
        	where patient_name=post_mutating_pkg.post_values(i).patient_name
        	and patient_type=post_mutating_pkg.post_values(i).patient_type
        	and post_admission_date=post_mutating_pkg.post_values(i).post_admission_date; 

        update post_surgery_ward
        	set discharge_date=post_mutating_pkg.post_values(i).post_admission_date+4
        	where patient_name=post_mutating_pkg.post_values(i).patient_name
        	and patient_type=post_mutating_pkg.post_values(i).patient_type
        	and post_admission_date=post_mutating_pkg.post_values(i).post_admission_date;
    end loop;
end;
/






/*procedure to populate db*/
create or replace procedure populate_db
is 
    cursor pp is 
    select patient_name, general_ward_admission_date, patient_type
    from patient_input
    order by general_ward_admission_date,patient_name;
begin
    for i in pp loop
    insert into general_ward values (i.patient_name,i.general_ward_admission_date,i.patient_type);
    dbms_output.put_line('incase of infinity loop.');
    end loop;
end;
/

-- execute the trigger
-- begin
-- populate_db;
-- end;
-- /

