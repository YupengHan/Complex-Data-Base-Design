-- Yupeng Han
-- EE562 PRJ3 
-- My email is han434@purdue.edu
-- Please feel free to contact me, I am sure my code can run perfectly for all the queries and I finished all the triggers

-- ####################################################################################################
-- query
-- ####################################################################################################

exec dbms_output.put_line('Query 1');
create or replace procedure pro_q1
is 
cursor name_list is
select patient_name, count(g_admission_date) as cnt
from general_ward
group by patient_name;

mv_name varchar2(30);
mv_visits number;
mv_g_ad_date date;
mv_s_ad_date date;
mv_pre_ad_date date;
mv_dis_date date;
mv_post_ad_date date;
mv_during_once number;
mv_during_total number;
mv_type varchar2(10);
mv_cost_once number;
mv_cost_total number;
mv_var varchar2(30);
mv_num number;
pre_sur_signal number:=-1;


begin
    for name in name_list loop
    mv_name:=name.patient_name;
    mv_visits:=name.cnt;
--    dbms_output.put_line('777');
    mv_cost_total:=0;
    mv_during_total:=0;
    dbms_output.put_line(rpad('Patient Name',32,' ')||rpad('Number of visit',20,' ')||rpad('Average stay',20,' ')||rpad('Total insurance cost',20,' '));


        for i in 1..mv_visits loop

        mv_cost_once:=0;
        mv_during_once:=0;
        -- general_admission,name,type
        select * into mv_var,mv_g_ad_date,mv_type,mv_num
        from (select a.*, rownum rn
            from (select * from general_ward where patient_name=mv_name order by g_admission_date) a
            where rownum<=i)
        where rn>=i;
        -- dbms_output.put_line('stuname: '||mv_name||'.       g_admission_date: '||mv_g_ad_date||'.       type: '||mv_type);     

        -- screen admission date
        select * into mv_s_ad_date,mv_num
        from(select a.*,rownum rn
            from (select s_admission_date
                from screening_ward
                where patient_name=mv_name
                and s_admission_date>mv_g_ad_date
                order by s_admission_date) a
                where rownum<=1)
        where rn>=1;

        -- discharge date
        select * into mv_post_ad_date,mv_dis_date,mv_num
        from(select a.*,rownum rn
            from (select post_admission_date,discharge_date
                from post_surgery_ward
                where patient_name=mv_name
                and discharge_date>mv_g_ad_date
                order by discharge_date ) a
                where rownum<=1)
        where rn>=1;
        mv_during_once:=mv_dis_date-mv_g_ad_date;
        

        -- pre exists or not 
        select case 
            when exists(
                select pre_admission_date
                from pre_surgery_ward
                where patient_name=mv_name
                and pre_admission_date>mv_g_ad_date
                and pre_admission_date<mv_post_ad_date)
            then 1
            else 0
            end into pre_sur_signal
        from dual;

        if pre_sur_signal=1
        then 
            select pre_admission_date into mv_pre_ad_date
            from pre_surgery_ward
            where patient_name=mv_name
            and pre_admission_date>mv_g_ad_date
            and pre_admission_date<mv_post_ad_date;
        end if;

        -- calculate total cost reinbursed by insurance company
        -- general_ward
        mv_cost_once:=mv_cost_once+50*0.8*3+50*0.7*(mv_s_ad_date-mv_g_ad_date-3);
        -- screening & pre
        if pre_sur_signal=1
        then
            mv_cost_once:=mv_cost_once+70*0.85*2+70*0.75*(mv_pre_ad_date-mv_s_ad_date-2);
            mv_cost_once:=mv_cost_once+90*0.95*(mv_post_ad_date-mv_pre_ad_date);
        else
            mv_cost_once:=mv_cost_once+70*0.85*2+70*0.75*(mv_post_ad_date-mv_s_ad_date-2);
        end if;
--        dbms_output.put_line(mv_cost_once);
        -- surgery & post
        if (mv_dis_date-mv_post_ad_date=2)
        then
            if mv_type='general'
            then
            mv_cost_once:=mv_cost_once+2500*0.65+80*0.9*2;
            end if;

            if mv_type='neuro'
            then
            mv_cost_once:=mv_cost_once+5000*0.85+80*0.9*2;
            end if;

            if mv_type='cardiac'
            then
            mv_cost_once:=mv_cost_once+3500*0.75+80*0.9*2;
            end if;
        else
            if mv_type='general'
            then
            mv_cost_once:=mv_cost_once+2500*0.65+2500*0.6+80*0.9*4;
            end if;

            if mv_type='neuro'
            then
            mv_cost_once:=mv_cost_once+5000*0.85+5000*0.8+80*0.9*4;
            end if;

            if mv_type='cardiac'
            then
            mv_cost_once:=mv_cost_once+3500*0.75+3500*0.7+80*0.9*4;
            end if;
        end if;
        -- dbms_output.put_line('patient_name: '||mv_name);
        -- dbms_output.put_line(i||'time to vistit');
        -- dbms_output.put_line('cost: '||mv_cost_once);
        -- dbms_output.put_line('duration: '||mv_during_once);
        -- rpad('Borrower Name',35,' ')
--        dbms_output.put_line(666);

        mv_during_total:=mv_during_once+mv_during_total;
        mv_cost_total:=mv_cost_total+mv_cost_once;

        end loop;
    -- dbms_output.put_line('patient_name: '||mv_name);
    -- dbms_output.put_line('total cost: '||mv_cost_total);
    -- dbms_output.put_line('total duration: '||mv_during_total);
    dbms_output.put_line(rpad(mv_name,32,' ')||rpad(mv_visits,20,' ')||rpad(mv_during_total/mv_visits,20,' ')||rpad(mv_cost_total,20,' '));

    end loop;
end;
/

begin
pro_q1;
end;
/

exec dbms_output.put_line('Query 2');
create or replace procedure pro_q2
is 
cursor name_list is
select patient_name, count(g_admission_date) as cnt
from general_ward
group by patient_name;

mv_name varchar2(30);
mv_visits number;
mv_g_ad_date date;
mv_s_ad_date date;
mv_pre_ad_date date;
mv_dis_date date;
mv_post_ad_date date;
mv_during_once number;
mv_during_total number;
mv_type varchar2(10);
mv_cost_once number;
mv_cost_total number;
mv_var varchar2(30);
mv_num number;
pre_sur_signal number:=-1;
al_pt_visits number:=-1;
al_total_cost number:=0;
al_ins_cost number:=0;
al_pt_num number:=0;



begin
    al_pt_visits:=0;
    al_total_cost:=0;
    al_ins_cost:=0;

    for name in name_list loop
    al_pt_num:=al_pt_num+1;
    mv_name:=name.patient_name;
    mv_visits:=name.cnt;
    mv_cost_total:=0;
    mv_during_total:=0;
    al_pt_visits:=al_pt_visits+mv_visits;
    -- dbms_output.put_line(rpad('Patient Name',32,' ')||rpad('Number of visit',20,' ')||rpad('Average stay',20,' ')||rpad('Total insurance cost',20,' '));
        for i in 1..mv_visits loop
        -- dbms_output.put_line('666');
        mv_cost_once:=0;
        mv_during_once:=0;
        select * into mv_var,mv_g_ad_date,mv_type,mv_num
        from (select a.*, rownum rn
            from (select * from general_ward where patient_name=mv_name order by g_admission_date) a
            where rownum<=i)
        where rn>=i;
        select * into mv_s_ad_date,mv_num
        from(select a.*,rownum rn
            from (select s_admission_date
                from screening_ward
                where patient_name=mv_name
                and s_admission_date>mv_g_ad_date
                order by s_admission_date) a
                where rownum<=1)
        where rn>=1;
        select * into mv_post_ad_date,mv_dis_date,mv_num
        from(select a.*,rownum rn
            from (select post_admission_date,discharge_date
                from post_surgery_ward
                where patient_name=mv_name
                and discharge_date>mv_g_ad_date
                order by discharge_date ) a
                where rownum<=1)
        where rn>=1;
        mv_during_once:=mv_dis_date-mv_g_ad_date;
        -- pre exists or not 
        select case 
            when exists(
                select pre_admission_date
                from pre_surgery_ward
                where patient_name=mv_name
                and pre_admission_date>mv_g_ad_date
                and pre_admission_date<mv_post_ad_date)
            then 1
            else 0
            end into pre_sur_signal
        from dual;

        if pre_sur_signal=1
        then 
            select pre_admission_date into mv_pre_ad_date
            from pre_surgery_ward
            where patient_name=mv_name
            and pre_admission_date>mv_g_ad_date
            and pre_admission_date<mv_post_ad_date;
        end if;

        -- calculate total cost reinbursed by insurance company
        -- general_ward
        al_total_cost:=al_total_cost+50*(mv_s_ad_date-mv_g_ad_date);
        mv_cost_once:=mv_cost_once+50*0.8*3+50*0.7*(mv_s_ad_date-mv_g_ad_date-3);
        -- screening & pre
        if pre_sur_signal=1
        then
            mv_cost_once:=mv_cost_once+70*0.85*2+70*0.75*(mv_pre_ad_date-mv_s_ad_date-2);
            mv_cost_once:=mv_cost_once+90*0.95*(mv_post_ad_date-mv_pre_ad_date);
            al_total_cost:=al_total_cost+70*(mv_pre_ad_date-mv_s_ad_date)+90*(mv_post_ad_date-mv_pre_ad_date);
        else
            mv_cost_once:=mv_cost_once+70*0.85*2+70*0.75*(mv_post_ad_date-mv_s_ad_date-2);
            al_total_cost:=al_total_cost+70*(mv_post_ad_date-mv_s_ad_date);
        end if;
--        dbms_output.put_line(mv_cost_once);
        -- surgery & post
        if (mv_dis_date-mv_post_ad_date=2)
        then
            if mv_type='general'
            then
            mv_cost_once:=mv_cost_once+2500*0.65+80*0.9*2;
            al_total_cost:=al_total_cost+2500+160;
            end if;

            if mv_type='neuro'
            then
            mv_cost_once:=mv_cost_once+5000*0.85+80*0.9*2;
            al_total_cost:=al_total_cost+5000+160;
            end if;

            if mv_type='cardiac'
            then
            mv_cost_once:=mv_cost_once+3500*0.75+80*0.9*2;
            al_total_cost:=al_total_cost+3500+160;
            end if;
        else
            if mv_type='general'
            then
            mv_cost_once:=mv_cost_once+2500*0.65+2500*0.6+80*0.9*4;
            al_total_cost:=al_total_cost+5000+320;
            end if;

            if mv_type='neuro'
            then
            mv_cost_once:=mv_cost_once+5000*0.85+5000*0.8+80*0.9*4;
            al_total_cost:=al_total_cost+10000+320;
            end if;

            if mv_type='cardiac'
            then
            mv_cost_once:=mv_cost_once+3500*0.75+3500*0.7+80*0.9*4;
            al_total_cost:=al_total_cost+7000+320;
            end if;
        end if;

        mv_during_total:=mv_during_once+mv_during_total;
        mv_cost_total:=mv_cost_total+mv_cost_once;
        end loop;
    -- dbms_output.put_line(rpad(mv_name,32,' ')||rpad(mv_visits,20,' ')||rpad(mv_during_total/mv_visits,20,' ')||rpad(mv_cost_total,20,' '));
        al_ins_cost:=al_ins_cost+mv_cost_total;
    end loop;

    dbms_output.put_line(rpad('Total cost',12,' ')||rpad('Average cost per patient',26,' ')||rpad('Avg ins cost per visit',30,' '));
    -- dbms_output.put_line(rpad(al_total_cost,12,' ')||rpad(al_total_cost/al_pt_num,26,' ')||rpad(al_ins_cost/al_pt_visits,30,' '));
    dbms_output.put_line(rpad(al_ins_cost,12,' ')||rpad(al_ins_cost/al_pt_num,26,' ')||rpad(al_ins_cost/al_pt_visits,30,' '));
end;
/

begin
pro_q2;
end;
/




-- in test use name 8 instead of bob
exec dbms_output.put_line('Query 3');
create or replace procedure pro_q3
is
bob_2_ad date;
bob_2_dis date;
mv_num number;
name_dis date;
name_visit_num number;
name_each_g_ad date;
name_each_dis date;
name_total_during number;

cursor pt_bob_list is
select patient_name
from general_ward
where g_admission_date=bob_2_ad;



begin

    select * into bob_2_ad,mv_num
        from(select a.*,rownum rn
            from (select g_admission_date
                from general_ward
                where patient_name='Bob'
                -- where patient_name='name 8'
                order by g_admission_date) a
                where rownum<=2)
        where rn>=2;

    select * into bob_2_dis,mv_num
        from (select a.*,rownum rn
            from(
                select discharge_date
                from post_surgery_ward
                where patient_name='Bob'
                -- where patient_name='name 8'
                order by post_admission_date) a
            where rownum<=2)
        where rn>=2;

    for name in pt_bob_list loop

    select * into name_dis,mv_num
    from (select a.*,rownum rn
        from (select discharge_date
            from post_surgery_ward
            where patient_name=name.patient_name
            and discharge_date>bob_2_ad
            order by discharge_date) a
        where rownum<=1)
    where rn>=1;

    if name_dis<bob_2_dis
    then
        name_total_during:=0;

        select count(g_admission_date) into name_visit_num
        from general_ward
        where patient_name=name.patient_name
        group by general_ward.patient_name;
        dbms_output.put_line(rpad('Name',32,' ')||rpad('Avg of stay',20,' '));

        for i in 1..name_visit_num loop

        select * into name_each_g_ad,mv_num
        from (select a.*, rownum rn
            from (select g_admission_date from general_ward where patient_name=name.patient_name order by g_admission_date) a
            where rownum<=i)
        where rn>=i;

        select * into name_each_dis,mv_num
        from (select a.*, rownum rn
            from (select discharge_date from post_surgery_ward where patient_name=name.patient_name order by discharge_date) a
            where rownum<=i)
        where rn>=i;

        name_total_during:=name_total_during+name_each_dis-name_each_g_ad;

        end loop;
        dbms_output.put_line(rpad(name.patient_name,32,' ')||rpad(name_total_during/name_visit_num,20,' '));
    end if;
    dbms_output.put_line('666');
    end loop;
end;
/

begin
pro_q3;
end;
/
exec dbms_output.put_line('Query 4');
--drop table surgery_contin;
create table surgery_contin(
daynum date,
front_con number,
behind_con number,
surgery_num number,
-- general
smith_sur number,
richards_sur number,
-- cardiac
charles_sur number,
gower_sur number,
-- neuro
taylor_sur number,
rutherford_sur number,

constraint pro_4_s_c primary key(daynum));

create or replace procedure pro_q4_1
is 
inser_signal number;
start_date date:=to_date('01/01/05','mm/dd/yy');
cur_date date;
i number;
front_signal number;
behind_signal number;
sur_num number;
gen_sur number;
neu_sur number;
car_sur number;
gen_name varchar2(30);
car_name varchar2(30);
neu_name varchar2(30);
mid_var_num number;

begin
    delete from surgery_contin;
    for i in 0..364 loop
    cur_date:=start_date+i;

    select case 
    when exists (select * 
        from post_surgery_ward
        where (post_admission_date=cur_date or (post_admission_date+2=cur_date and scount=2))
        )
      then 1
      else 0
      end into inser_signal
    from dual;

    select case
    when exists(select * 
        from post_surgery_ward
        where post_admission_date=cur_date-1)
    then 1 
    else 0
    end into front_signal
    from dual;

    select case
    when exists(select * 
        from post_surgery_ward
        where post_admission_date=cur_date+1)
    then 1 
    else 0
    end into behind_signal
    from dual;

    if inser_signal=1
    then 
    select count(*) into sur_num
    from post_surgery_ward
    where (post_admission_date=cur_date or (post_admission_date+2=cur_date and scount=2));

    select count(*) into gen_sur
    from post_surgery_ward
    where (post_admission_date=cur_date or (post_admission_date+2=cur_date and scount=2))
    and patient_type='general';

    select count(*) into neu_sur
    from post_surgery_ward
    where (post_admission_date=cur_date or (post_admission_date+2=cur_date and scount=2))
    and patient_type='neuro';

    select count(*) into car_sur
    from post_surgery_ward
    where (post_admission_date=cur_date or (post_admission_date+2=cur_date and scount=2))
    and patient_type='cardiac';
    if (sur_num<>(gen_sur+car_sur+neu_sur))
    then dbms_output.put_line('This day is wrong!!!: '||'cur_date'||cur_date||'sur_num'||sur_num||'gen_sur'||gen_sur||'car_sur'||car_sur||'neu_sur'||neu_sur);
    end if;

    insert into surgery_contin values(cur_date,front_signal,behind_signal,sur_num,0,0,0,0,0,0);
    end if;

    if gen_sur>0
    then
        select name into gen_name
        from surgeon_schedule
        where (surgery_date=cur_date)
        and (name='Dr. Smith' or name='Dr. Richards');

        if gen_name='Dr. Smith'
        then 
        update surgery_contin set smith_sur=gen_sur where daynum=cur_date;
        else
        update surgery_contin set richards_sur=gen_sur where daynum=cur_date;
        end if;

    end if;

    if car_sur>0
    then
        select name into car_name
        from surgeon_schedule
        where (surgery_date=cur_date)
        and (name='Dr. Charles' or name='Dr. Gower');

        if gen_name='Dr. Charles'
        then 
        update surgery_contin set charles_sur=car_sur where daynum=cur_date;
        else
        update surgery_contin set gower_sur=car_sur where daynum=cur_date;
        end if;

    end if;

    if neu_sur>0
    then
        select name into gen_name
        from surgeon_schedule
        where (surgery_date=cur_date)
        and (name='Dr. Taylor' or name='Dr. Rutherford');

        if gen_name='Dr. Taylor'
        then 
        update surgery_contin set taylor_sur=neu_sur where daynum=cur_date;
        else
        update surgery_contin set rutherford_sur=neu_sur where daynum=cur_date;
        end if;

    end if;

   -- dbms_output.put_line('666');
    end loop;
end;
/

begin
pro_q4_1;
end;
/


--select * from surgery_contin;



set serveroutput on;
drop table pro_4_int_1;
create table pro_4_int_1(
start_date date,
end_date date,
total_surgery number,
most_surgeon varchar2(30),
constraint pro_4_i1 primary key (start_date,end_date));
















create or replace procedure pro_q4_2
is
int_count number;
-- general
smith_c number;
richards_c number;
-- cardiac
charles_c number;
gower_c number;
-- neuro
taylor_c number;
rutherford_c number;
i number;
cur_date date;
mv_num number;
int_start date;
int_end date;
day_last number;
int_surgery_count number;
most_surgeon varchar2(30);
int_surgery_oneday number;

begin
delete from pro_4_int_1;
    select count(*) into int_count
    from surgery_contin
    where front_con=0;

    for i in 1..int_count loop
        -- dbms_output.put_line('int_count'||int_count);
        select * into int_start, mv_num
        from (select a.*, rownum rn
            from (select daynum 
                from surgery_contin
                where front_con=0
                order by daynum) a
            where rownum<=i)
        where rn>=i;

        select * into int_end,mv_num
        from (select a.*, rownum rn
            from (select daynum
                from surgery_contin
                where behind_con=0
                order by daynum) a
            where rownum<=i)
        where rn>=i;

        day_last:=int_end-int_start;
        int_surgery_count:=0;
        smith_c:=0;
        richards_c:=0;
        charles_c:=0;
        gower_c:=0;
        taylor_c:=0;
        rutherford_c:=0;


        for j in 0..day_last loop
            cur_date:=int_start+j;
            -- dbms_output.put_line('cur_date'||cur_date);
            select surgery_num into int_surgery_oneday
            from surgery_contin
            where daynum=int_start+j;
            int_surgery_count:=int_surgery_count+int_surgery_oneday;

            select smith_sur into mv_num
            from surgery_contin
            where daynum=cur_date;
            smith_c:=smith_c+mv_num;

            select richards_sur into mv_num
            from surgery_contin
            where daynum=cur_date;
            richards_c:=richards_c+mv_num;

            select charles_sur into mv_num
            from surgery_contin
            where daynum=cur_date;
            charles_c:=charles_c+mv_num;

            select gower_sur into mv_num
            from surgery_contin
            where daynum=cur_date;
            gower_c:=gower_c+mv_num;

            select taylor_sur into mv_num
            from surgery_contin
            where daynum=cur_date;
            taylor_c:=taylor_c+mv_num;

            select rutherford_sur into mv_num
            from surgery_contin
            where daynum=cur_date;
            rutherford_c:=rutherford_c+mv_num;
            -- dbms_output.put_line('666');
            -- dbms_output.put_line('j'||j);
            -- dbms_output.put_line('smith_c'||smith_c);
            -- dbms_output.put_line('richards_c'||richards_c);
            -- dbms_output.put_line('charles_c'||charles_c);
        end loop;

        most_surgeon:='Dr. No one';
        if (smith_c>=richards_c and smith_c>=charles_c and smith_c>=gower_c and smith_c>=taylor_c and smith_c>=rutherford_c)
        then most_surgeon:='Dr. Smith';
        end if;

        if (richards_c>=smith_c and richards_c>=charles_c and richards_c>=gower_c and richards_c>=taylor_c and richards_c>=rutherford_c)
        then most_surgeon:='Dr. Richards';
        end if;

        if (charles_c>=smith_c and charles_c>=richards_c and charles_c>=gower_c and charles_c>=taylor_c and charles_c>=rutherford_c)
        then most_surgeon:='Dr. Charles';
        end if;

        if (gower_c>=smith_c and gower_c>=richards_c and gower_c>=charles_c and gower_c>=taylor_c and gower_c>=rutherford_c)
        then most_surgeon:='Dr. Gower';
        end if;

        if (taylor_c>=smith_c and taylor_c>=richards_c and taylor_c>=charles_c and taylor_c>=gower_c and taylor_c>=rutherford_c)
        then most_surgeon:='Dr. Taylor';
        end if;

        if (rutherford_c>=smith_c and rutherford_c>=richards_c and rutherford_c>=charles_c and rutherford_c>=gower_c and rutherford_c>=taylor_c)
        then most_surgeon:='Dr. Rutherford';
        end if;

        -- dbms_output.put_line('most_surgeon'||most_surgeon);
        -- dbms_output.put_line('666');
        insert into pro_4_int_1 values (int_start,int_end,int_surgery_count,most_surgeon);

        -- dbms_output.put_line('int_gen_all'||int_gen_all);
        -- dbms_output.put_line('int_neu_all'||int_neu_all);
        -- dbms_output.put_line('int_car_all'||int_car_all);
    end loop;

end;
/

begin
pro_q4_2;
end;
/

select * from pro_4_int_1;

create or replace procedure pro_q4_3
is 
cursor interval_list is 
select * 
from pro_4_int_1
order by total_surgery DESC;
begin
    dbms_output.put_line(rpad('Interval Start',20,' ')||rpad('Interval End',20,' ')||rpad('Busy Surgeon',30,' ')||rpad('Total Surgeries',20,' '));
    for pp in interval_list loop
    dbms_output.put_line(rpad(pp.start_date,20,' ')||rpad(pp.end_date,20,' ')||rpad(pp.most_surgeon,30,' ')||rpad(pp.total_surgery,20,' '));
    end loop;
end;
/
begin
pro_q4_3;
end;
/


exec dbms_output.put_line('Query 5');

create table april2005 (
daynum date,
constraint ap2005 primary key (daynum) );

create table april_conti(
daynum date,
front_con number,
behind_con number,
constraint ac2005 primary key(daynum) );


create or replace procedure pro_q5_1
is 
start_date date:=to_date('04/01/05','mm/dd/yy');
today_date date;
not_insert_signal number:=-1;
pt_ad date;
pt_type varchar2(10);
total_day number;
i number;
cur_day date;
mv_num number;
front_v number:=-1;
behind_v number:=-1;
interval_num number:=-1;
int_start_date date;
int_end_date date;

cursor today_namelist is 
select patient_name 
from post_surgery_ward
where discharge_date>today_date
and post_admission_date<=today_date;
begin
    delete from april2005;
    for i in 0..29 loop
    today_date:=start_date+i;
    -- dbms_output.put_line(today_date);
    not_insert_signal:=0;

        for today_pt in today_namelist loop

        -- dbms_output.put_line('666');

            select post_admission_date,patient_type into pt_ad,pt_type
            from post_surgery_ward
            where post_admission_date<=today_date
            and discharge_date>today_date
            and patient_name=today_pt.patient_name;

            if pt_type='cardiac'
            then
                select case
                    when exists (select * 
                                from surgeon_schedule
                                where surgery_date=pt_ad 
                                and name='Dr. Gower')
                    then 1
                    else 0
                    end into not_insert_signal
                from dual;
            end if;

            if pt_type='neuro'
            then
                select case
                    when exists (select * 
                                from surgeon_schedule
                                where surgery_date=pt_ad
                                and name='Dr. Taylor')
                    then 1 
                    else 0
                    end into not_insert_signal
                from dual;
            end if;
        end loop;

    if not_insert_signal=0
    then 
    insert into april2005 values(today_date);
    end if;
    end loop;

    

end;
/
begin 
pro_q5_1;
end;
/




create or replace procedure pro_q5_2
is 
start_date date:=to_date('04/01/05','mm/dd/yy');
today_date date;
not_insert_signal number:=-1;
pt_ad date;
pt_type varchar2(10);
total_day number;
i number;
cur_day date;
mv_num number;
front_v number:=-1;
behind_v number:=-1;
interval_num number:=-1;
int_start_date date;
int_end_date date;
begin
    select count(daynum) into total_day
    from april2005;
--    dbms_output.put_line(total_day);
    delete from april_conti;
    for i in 1..total_day loop
--    dbms_output.put_line(i);
    select * into cur_day,mv_num
    from (select a.*,rownum rn
        from (select daynum
            from april2005
            order by daynum) a
        where rownum<=i)
    where rn>=i;

    select case
        when exists(select * 
                    from april2005
                    where daynum=cur_day-1)
        then 1 
        else 0
        end into front_v
    from dual;

    select case 
        when exists(
                    select * 
                    from april2005
                    where daynum=cur_day+1)
        then 1
        else 0
        end into behind_v
    from dual;
    insert into april_conti values(cur_day,front_v,behind_v);
    end loop;
end;
/


begin 
pro_q5_2;
end;
/

create or replace procedure pro_q5_3
is
start_date date:=to_date('04/01/05','mm/dd/yy');
today_date date;
not_insert_signal number:=-1;
pt_ad date;
pt_type varchar2(10);
total_day number;
i number;
cur_day date;
mv_num number;
front_v number:=-1;
behind_v number:=-1;
interval_num number:=-1;
int_start_date date;
int_end_date date;
begin
select count(*) into interval_num
    from april_conti
    where front_con=0;
    -- dbms_output.put_line(interval_num);
    dbms_output.put_line(rpad('interval number',18,' ')||rpad('start date',18,' ')||rpad('end date',18,' '));
    for i in 1..interval_num loop
        select * into int_start_date,mv_num
        from (select a.*, rownum rn from(select daynum from april_conti where front_con=0 order by daynum) a where rownum<=i) 
        where rn>=i;

        select * into int_end_date,mv_num
        from (select a.*, rownum rn from (select daynum from april_conti where behind_con=0 order by daynum) a where rownum<=i)
        where rn>=i;

        dbms_output.put_line(rpad(i,18,' ')||rpad(int_start_date,18,' ')||rpad(int_end_date,18,' '));

    end loop;

end;
/

begin 
pro_q5_3;
end;
/

-- select * from april_conti;

-- select * from APRIL2005;

-- name 8 use Bob!!!!!!!!

exec dbms_output.put_line('Query 6');
create or replace procedure pro_q6
is 
bob_2_day date;
mv_num number;
patient_num number;
i number;
cur_name varchar2(30);
cur_g_ad date;
cur_s_ad date;
cur_pre_ad date;
cur_post_ad date;
cur_dis date;
cur_duration number;
pre_sur_signal number:=-1;
cur_cost number;
mv_type varchar2(10);

begin
    select * into bob_2_day,mv_num
    from (select a.*, rownum rn
        from (select post_admission_date+2 
            from post_surgery_ward
            where patient_name='Bob'
            -- where patient_name='name 8'
            order by post_admission_date) a
        where rownum<=3)
    where rn>=3;

    select count(*) into patient_num
    from post_surgery_ward
    where discharge_date<=bob_2_day+3
    and discharge_date>=bob_2_day-3;

    cur_cost:=0;
    dbms_output.put_line(rpad('Name',30,' ')||rpad('Cost',15,' ')||rpad('Discharge day',15,' '));
    for i in 1..patient_num loop
        select * into cur_name, cur_dis,mv_type, mv_num
        from (select a.*, rownum rn
            from (select patient_name, discharge_date,patient_type
                 from post_surgery_ward
                 where discharge_date<=bob_2_day+3
                 and discharge_date>=bob_2_day-3
                 order by patient_name) a
            where rownum<=i)
        where rn>=i;

        -- general admission date
        select * into cur_g_ad,mv_num
        from (select a.*, rownum rn
            from (select g_admission_date
                from general_ward
                where patient_name=cur_name
                and g_admission_date<cur_dis
                order by g_admission_date DESC) a
            where rownum<=1)
        where rn>=1;

        -- screen admission date
        select * into cur_s_ad,mv_num
        from(select a.*,rownum rn
            from (select s_admission_date
                from screening_ward
                where patient_name=cur_name
                and s_admission_date>cur_g_ad
                order by s_admission_date) a
                where rownum<=1)
        where rn>=1;

        -- post admission
        select * into cur_post_ad,mv_num
        from(select a.*,rownum rn
            from (select post_admission_date
                from post_surgery_ward
                where patient_name=cur_name
                and post_admission_date<cur_dis
                order by post_admission_date DESC) a
                where rownum<=1)
        where rn>=1;



        cur_duration:=cur_dis-cur_g_ad;

        select case 
            when exists(
                select pre_admission_date
                from pre_surgery_ward
                where patient_name=cur_name
                and pre_admission_date>cur_g_ad
                and pre_admission_date<cur_dis)
            then 1
            else 0
            end into pre_sur_signal
        from dual;

        if pre_sur_signal=1
        then 
            select pre_admission_date into cur_pre_ad
            from pre_surgery_ward
            where patient_name=cur_name
            and pre_admission_date>cur_g_ad
            and pre_admission_date<cur_post_ad;
        end if;

        cur_cost:=cur_cost++50*0.8*3+50*0.7*(cur_s_ad-cur_g_ad-3);

        if pre_sur_signal=1
        then
            cur_cost:=cur_cost+70*0.85*2+70*0.75*(cur_pre_ad-cur_s_ad-2);
            cur_cost:=cur_cost+90*0.95*(cur_post_ad-cur_pre_ad);
        else
            cur_cost:=cur_cost+70*0.85*2+70*0.75*(cur_post_ad-cur_s_ad-2);
        end if;

        if (cur_dis-cur_post_ad=2)
        then
            if mv_type='general'
            then
            cur_cost:=cur_cost+2500*0.65+80*0.9*2;
            end if;

            if mv_type='neuro'
            then
            cur_cost:=cur_cost+5000*0.85+80*0.9*2;
            end if;

            if mv_type='cardiac'
            then
            cur_cost:=cur_cost+3500*0.75+80*0.9*2;
            end if;
        else
            if mv_type='general'
            then
            cur_cost:=cur_cost+2500*0.65+2500*0.6+80*0.9*4;
            end if;

            if mv_type='neuro'
            then
            cur_cost:=cur_cost+5000*0.85+5000*0.8+80*0.9*4;
            end if;

            if mv_type='cardiac'
            then
            cur_cost:=cur_cost+3500*0.75+3500*0.7+80*0.9*4;
            end if;
        end if;

        dbms_output.put_line(rpad(cur_name,30,' ')||rpad(cur_cost,15,' ')||rpad(cur_dis,15,' '));
        cur_cost:=0;
    end loop;

end;
/

begin
pro_q6;
end;
/

exec dbms_output.put_line('Query 7');
create or replace procedure pro_q7
is 
pat_num number;
i number;
mv_num number;
mv_name varchar2(30);
mv_scount number;
mv_post_ad date;
mv_surgeon1 varchar2(30);
mv_surgeon2 varchar2(30);
mv_assit1 varchar2(30);
mv_assit2 varchar2(30);
assist_num number;
begin
    select count(*) into pat_num
    from post_surgery_ward
    where (post_admission_date>=to_date('04/09/05','mm/dd/yy')
        and post_admission_date<=to_date('04/15/05','mm/dd/yy')
        and patient_type='cardiac')
        or (scount=2 
            and post_admission_date>=to_date('04/07/05','mm/dd/yy')
            and post_admission_date<=to_date('04/13/05','mm/dd/yy')
            and patient_type='cardiac');
    dbms_output.put_line(rpad('patient name',32,' ')||rpad('surgery_num in visit',35,' ')||rpad('surgeon',30,' ')||rpad('assit doctor1',30,' ')||rpad('assit doctor2',30,' '));

    for i in 1..pat_num loop
        
        select * into mv_name,mv_scount,mv_post_ad,mv_num
        from (select a.*, rownum rn
            from (
                select patient_name,scount,post_admission_date
                from post_surgery_ward
                where (post_admission_date>=to_date('04/09/05','mm/dd/yy')
                and post_admission_date<=to_date('04/15/05','mm/dd/yy')
                and patient_type='cardiac')
                or (scount=2 
                and post_admission_date>=to_date('04/07/05','mm/dd/yy')
                and post_admission_date<=to_date('04/13/05','mm/dd/yy')
                and patient_type='cardiac')
                order by patient_name) a
            where rownum<=i)
        where rn>=i;

        if mv_scount=1
        then

            select name into mv_surgeon1
            from surgeon_schedule
            where surgery_date=mv_post_ad
            and (name='Dr. Charles' or name='Dr. Gower');
            mv_surgeon2:='only one surgeon';

            select count(*) into assist_num
            from dr_schedule
            where duty_date=mv_post_ad
            and ward='Surgery';

            if assist_num=2
            then
            select * into mv_assit1,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad
                    and ward='Surgery'
                    order by name) a
                where rownum<=1)
            where rn>=1;

            select * into mv_assit2,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad
                    and ward='Surgery'
                    order by name) a
                where rownum<=2)
            where rn>=2;

            else
            select * into mv_assit1,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad
                    and ward='Surgery'
                    order by name) a
                where rownum<=1)
            where rn>=1;

            mv_assit2:='only one assist';
            end if;
            dbms_output.put_line(rpad(mv_name,32,' ')||rpad(1,35,' ')||rpad(mv_surgeon1,30,' ')||rpad(mv_assit1,30,' ')||rpad(mv_assit2,30,' '));
            mv_assit1:='only have one surgery';
            mv_assit2:='only have one surgery';
            dbms_output.put_line(rpad(mv_name,32,' ')||rpad(2,35,' ')||rpad(mv_surgeon2,30,' ')||rpad(mv_assit1,30,' ')||rpad(mv_assit2,30,' '));

        end if;

        if mv_scount=2
        then
            -- select * into mv_surgeon1,mv_num
            -- from (a.*,rownum rn
            --  from (select name into mv_surgeon1
            --         from surgeon_schedule
            --         where surgery_date=mv_post_ad
            --         and name='Dr. Charles' or name='Dr. Gower';) a
            --  where rownum<=1)
            -- where rn>=1; 
            select name into mv_surgeon1
            from surgeon_schedule
            where surgery_date=mv_post_ad
            and (name='Dr. Charles' or name='Dr. Gower');
            
            

            select count(*) into assist_num
            from dr_schedule
            where duty_date=mv_post_ad
            and ward='Surgery';

            if assist_num=2
            then
            select * into mv_assit1,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad
                    and ward='Surgery'
                    order by name) a
                where rownum<=1)
            where rn>=1;

            select * into mv_assit2,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad
                    and ward='Surgery'
                    order by name) a
                where rownum<=2)
            where rn>=2;

            else
            select * into mv_assit1,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad
                    and ward='Surgery'
                    order by name) a
                where rownum<=1)
            where rn>=1;

            mv_assit2:='only one assist';
            end if;
            dbms_output.put_line(rpad(mv_name,32,' ')||rpad(1,35,' ')||rpad(mv_surgeon1,30,' ')||rpad(mv_assit1,30,' ')||rpad(mv_assit2,30,' '));

            select name into mv_surgeon2
            from surgeon_schedule
            where surgery_date=mv_post_ad+2
            and (name='Dr. Charles' or name='Dr. Gower');
            select count(*) into assist_num
            from dr_schedule
            where duty_date=mv_post_ad+2
            and ward='Surgery';

            if assist_num=2
            then
            select * into mv_assit1,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad+2
                    and ward='Surgery'
                    order by name) a
                where rownum<=1)
            where rn>=1;

            select * into mv_assit2,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad+2
                    and ward='Surgery'
                    order by name) a
                where rownum<=2)
            where rn>=2;

            else
            select * into mv_assit1,mv_num
            from (select a.*, rownum rn
                from (select name
                    from dr_schedule
                    where duty_date=mv_post_ad+2
                    and ward='Surgery'
                    order by name) a
                where rownum<=1)
            where rn>=1;

            mv_assit2:='only one assist';
            end if;
            dbms_output.put_line(rpad(mv_name,32,' ')||rpad(2,35,' ')||rpad(mv_surgeon2,30,' ')||rpad(mv_assit1,30,' ')||rpad(mv_assit2,30,' '));

        end if;


    end loop;
end;
/
set serveroutput on;

begin
pro_q7;
end;
/















exec dbms_output.put_line('Query 8');
drop table pro8_t1;
create table pro8_t1(
daynum date,
constraint pro8_1 primary key (daynum));

drop table pro8_t2;
create table pro8_t2(
daynum date,
front_con number,
behind_con number,
constraint pro8_2 primary key (daynum));


create or replace procedure pro_q8_1
is
i number;
-- first_day date:=to_date('01/01/05','mm/dd/yy');
bob_v3_g_ad_date date;
bob_v3_dis_date date;
curday date;
mv_num number;
v_length number;

begin
    select * into bob_v3_g_ad_date,mv_num
    from(select a.*,rownum rn
        from (select g_admission_date
            from general_Ward
            where patient_name='Bob'
            -- where patient_name='name 8'
            order by g_admission_date
            ) a
        where rownum<=3)
    where rn>=3;

    select * into bob_v3_dis_date
    from(select discharge_date
        from POST_SURGERY_WARD
        where patient_name='Bob'
        -- where patient_name='name 8'
        and post_admission_date>bob_v3_g_ad_date
        order by post_admission_date)
    where rownum=1;

    v_length:=bob_v3_dis_date- bob_v3_g_ad_date;

    for i in 0..v_length-1 loop
        curday:=bob_v3_g_ad_date+i;
--        dbms_output.put_line('curday'||curday);
        insert into pro8_t1 values(curday);
    end loop;


--     for i in 1..365 loop
--     curday:=first_day+i-1;
--     insert into pro8_t1 values(curday);
-- --    dbms_output.put_line(curday);
--     end loop;

end;
/


begin 
delete from pro8_t1;
pro_q8_1;
end;
/



create or replace procedure pro_q8_2
is
bob_3_g_ad date;
bob_3_s_ad date;
bob_3_pre_ad date;
bob_3_post_ad date;
bob_3_dis date;
bob_3_sur1_ad date;
bob_3_sur2_ad date;
mv_num number;
pre_signal number:=-1;
curday date;

gen_overlap_signal number:=-1;
gen_overlap_cnt number:=-1;
scr_overlap_cnt number:=-1; 
pre_overlap_cnt number:=-1; 
post_overlap_cnt number:=-1; 
surgery_overlap_cnt number:=-1;
begin

    select * into bob_3_g_ad,mv_num
    from(select a.*,rownum rn
        from (select g_admission_date
            from general_Ward
            where patient_name='Bob'
            -- where patient_name='name 8'
            order by g_admission_date
            ) a
        where rownum<=3)
    where rn>=3;
   -- dbms_output.put_line(bob_3_g_ad);

    select * into bob_3_s_ad,mv_num
    from(select a.*,rownum rn
        from (select s_admission_Date 
            from SCREENING_WARD
            where patient_name='Bob'
            -- where patient_name='name 8'
            and s_admission_date>bob_3_g_ad
            order by s_admission_date
            ) a
        where rownum<=1)
    where rn>=1;
    -- dbms_output.put_line(bob_3_s_ad);

    select * into bob_3_post_ad,bob_3_dis
    from(select post_admission_date, discharge_date
        from POST_SURGERY_WARD
        where patient_name='Bob'
        -- where patient_name='name 8'
        and post_admission_date>bob_3_g_ad
        order by post_admission_date)
    where rownum=1;

    -- dbms_output.put_line(bob_3_post_ad);

    select case 
    when exists(select *
        from PRE_SURGERY_WARD
        where pre_admission_date>=bob_3_g_ad
        and pre_admission_date<=bob_3_dis
        and patient_name='Bob'
        -- and patient_name='name 8'
        )
    then 1
    else 0
    end into pre_signal
    from dual;
    -- dbms_output.put_line(pre_signal);

    if pre_signal=1
    then 
    select * into bob_3_pre_ad,mv_num
    from(select a.*,rownum rn
        from (select pre_admission_date 
            from PRE_SURGERY_WARD
            where patient_name='Bob'
            -- where patient_name='name 8'
            and pre_admission_date>bob_3_g_ad
            order by pre_admission_date
            ) a
        where rownum<=1)
    where rn>=1;
    -- dbms_output.put_line(bob_3_pre_ad);
    end if;

    select case 
        when exists (select *
            from dr_schedule
            where name='Adams'
            and duty_date>=bob_3_g_ad
            and duty_date<bob_3_s_ad
            and ward='GENERAL_WARD')
        then 1
        else 0
        end into gen_overlap_signal
    from dual;
    -- dbms_output.put_line(gen_overlap_signal);

    if gen_overlap_signal=1
    then 
    
        select count(*) into gen_overlap_cnt
        from dr_schedule
        where name='Adams'
        and duty_date>=bob_3_g_ad
        and duty_date<bob_3_s_ad
        and ward='GENERAL_WARD';

        for i in 1..gen_overlap_cnt loop
            select * into curday,mv_num
            from (select a.*,rownum rn
                from (
                    select duty_date
                    from dr_schedule
                    where name='Adams'
                    and duty_date>=bob_3_g_ad
                    and duty_date<bob_3_s_ad
                    and ward='GENERAL_WARD') a
                where rownum<=i)
            where rn>=i;
            delete from pro8_t1 
            where daynum=curday;
--            dbms_output.put_line('666');
        end loop;
    end if;







    if pre_signal=1
    then
    select count(*) into scr_overlap_cnt
    from dr_schedule
    where name='Adams'
    and duty_date>=bob_3_s_ad
    and duty_date<bob_3_pre_ad
    and ward='SCREENING_WARD';
    -- dbms_output.put_line(bob_3_s_ad);
    -- dbms_output.put_line(bob_3_pre_ad);
    -- dbms_output.put_line('scr_overlap_cnt'||scr_overlap_cnt);


    if scr_overlap_cnt>0
    then 

        for i in 1..scr_overlap_cnt loop
            select * into curday,mv_num
            from (select a.*,rownum rn
                from (
                    select duty_date
                    from dr_schedule
                    where name='Adams'
                    and duty_date>=bob_3_s_ad
                    and duty_date<bob_3_pre_ad
                    and ward='SCREENING_WARD') a
                where rownum<=i)
            where rn>=i;
            delete from pro8_t1 
            where daynum=curday;
--            dbms_output.put_line('666');
        end loop;
    end if;

    select count(*) into pre_overlap_cnt
    from dr_schedule
    where name='Adams'
    and duty_date>=bob_3_pre_ad
    and duty_date<bob_3_post_ad
    and ward='PRE_SURGERY_WARD';

--    dbms_output.put_line('pre_overlap_cnt'||pre_overlap_cnt);


    if pre_overlap_cnt>0
    then 

        for i in 1..pre_overlap_cnt loop
            select * into curday,mv_num
            from (select a.*,rownum rn
                from (
                    select duty_date
                    from dr_schedule
                    where name='Adams'
                    and duty_date>=bob_3_pre_ad
                    and duty_date<bob_3_post_ad
                    and ward='PRE_SURGERY_WARD') a
                where rownum<=i)
            where rn>=i;
            delete from pro8_t1 
            where daynum=curday;
--            dbms_output.put_line('666');
        end loop;
    end if;

    select count(*) into post_overlap_cnt
    from dr_schedule
    where name='Adams'
    and duty_date>=bob_3_post_ad
    and duty_date<bob_3_dis
    and ward='POST_SURGERY_WARD';

--    dbms_output.put_line('post_overlap_cnt'||post_overlap_cnt);


    if post_overlap_cnt>0
    then 

        for i in 1..post_overlap_cnt loop
            select * into curday,mv_num
            from (select a.*,rownum rn
                from (
                    select duty_date
                    from dr_schedule
                    where name='Adams'
                    and duty_date>=bob_3_post_ad
                    and duty_date<bob_3_dis
                    and ward='POST_SURGERY_WARD') a
                where rownum<=i)
            where rn>=i;
            delete from pro8_t1 
            where daynum=curday;
            -- dbms_output.put_line('666');
        end loop;
    end if;

    select count(*) into surgery_overlap_cnt
    from dr_schedule
    where name='Adams'
    and (duty_date=bob_3_post_ad or duty_date=bob_3_post_ad+2)
    and ward='Surgery';

--    dbms_output.put_line('surgery_overlap_cnt: '||surgery_overlap_cnt);


    if surgery_overlap_cnt>0
    then 

        for i in 1..surgery_overlap_cnt loop
            select * into curday,mv_num
            from (select a.*,rownum rn
                from (
                    select duty_date
                    from dr_schedule
                    where name='Adams'
                    and (duty_date=bob_3_post_ad or duty_date=bob_3_post_ad+2)
                    and ward='Surgery') a
                where rownum<=i)
            where rn>=i;
            delete from pro8_t1 
            where daynum=curday;
--            dbms_output.put_line('666');
        end loop;
    end if;

    end if;

    if pre_signal=0
    then
        select count(*) into scr_overlap_cnt
        from dr_schedule
        where name='Adams'
        and duty_date>=bob_3_s_ad
        and duty_date<bob_3_post_ad
        and ward='SCREENING_WARD';


        if scr_overlap_cnt>0
        then 

            for i in 1..scr_overlap_cnt loop
                select * into curday,mv_num
                from (select a.*,rownum rn
                    from (
                        select duty_date
                        from dr_schedule
                        where name='Adams'
                        and duty_date>=bob_3_s_ad
                        and duty_date<bob_3_post_ad
                        and ward='SCREENING_WARD') a
                    where rownum<=i)
                where rn>=i;
                delete from pro8_t1 
                where daynum=curday;
--                dbms_output.put_line('666');
            end loop;
        end if;

        select count(*) into post_overlap_cnt
        from dr_schedule
        where name='Adams'
        and duty_date>=bob_3_post_ad
        and duty_date<bob_3_dis
        and ward='POST_SURGERY_WARD';


        if post_overlap_cnt>0
        then 

            for i in 1..post_overlap_cnt loop
                select * into curday,mv_num
                from (select a.*,rownum rn
                    from (
                        select duty_date
                        from dr_schedule
                        where name='Adams'
                        and duty_date>=bob_3_post_ad
                        and duty_date<bob_3_dis
                        and ward='POST_SURGERY_WARD') a
                    where rownum<=i)
                where rn>=i;
                delete from pro8_t1 
                where daynum=curday;
                -- dbms_output.put_line('666');
            end loop;
        end if;

        select count(*) into surgery_overlap_cnt
        from dr_schedule
        where name='Adams'
        and (duty_date=bob_3_post_ad or duty_date=bob_3_post_ad+2)
        and ward='Surgery';


        if surgery_overlap_cnt>0
        then 

          for i in 1..surgery_overlap_cnt loop
            select * into curday,mv_num
            from (select a.*,rownum rn
                from (
                    select duty_date
                    from dr_schedule
                    where name='Adams'
                    and (duty_date=bob_3_post_ad or duty_date=bob_3_post_ad+2)
                    and ward='Surgery') a
                where rownum<=i)
            where rn>=i;
            
            delete from pro8_t1 
            where daynum=curday;
            
--            dbms_output.put_line('666');
          end loop;
    end if;
    end if;

end;
/

begin
pro_q8_2;
end;
/


create or replace procedure pro_q8_3
is 
front_cnt number;
behind_cnt number;
i number;
front_day date;
behind_day date;
mv_num number;
begin
    select count(daynum) into front_cnt
    from pro8_t1 p1
    where not exists(select *
                from pro8_t1 p2
                where p2.daynum=p1.daynum-1);

    -- select count(daynum) into behind_cnt
    -- from pro8_t1 p1
    -- where not exists(select *
    --             from pro8_t1 p2
    --             where p2.daynum=p1.daynum+1);
    dbms_output.put_line(rpad('interval start',20,' ')||rpad('interval end',20,' '));
    for i in 1..front_cnt loop
        select * into front_day, mv_num
        from (select a.*,rownum rn
            from (
                select * from pro8_t1 t1
                where not exists(select * from pro8_t1 t2 where t2.daynum=t1.daynum-1)
                ) a
            where rownum<=i)
        where rn>=i;

        select * into behind_day, mv_num
        from (select a.*,rownum rn
            from (
                select * from pro8_t1 t1
                where not exists(select * from pro8_t1 t2 where t2.daynum=t1.daynum+1)
                ) a
            where rownum<=i)
        where rn>=i;

        dbms_output.put_line(rpad(front_day,20,' ')||rpad(behind_day,20,' '));
    end loop;
end;
/

begin
pro_q8_3;
end;
/

-- SELECT * 
-- FROM DR_SCHEDULE
-- WHERE NAME ='Adams'
-- and duty_date<=to_Date('03/16/05','mm/dd/yy')
-- and duty_date>=to_Date('03/04/05','mm/dd/yy');

-- select * from pro8_t1;



-- using name 1 to replace Bob in here
-- delete testing part
exec dbms_output.put_line('Query 9');
drop table pro_q9_t;
create table pro_q9_t(
daynum date,
constraint pro9_1 primary key (daynum));

create or replace procedure pro_q9_1
is
int_num number;
i number;
int_start date;
int_end date;
int_duration number;
j number;
cur_day date;
cur_BP number;
mv_num number;
begin
    select count(*) into int_num
    from general_ward
    where patient_name='Bob'
    -- where patient_name='name 1'
    and g_admission_date>=to_date('01/01/05','mm/dd/yy')
    and g_admission_date<=to_date('12/12/05','mm/dd/yy');

    for i in 1.. int_num loop
        -- dbms_output.put_line('333');
        select * into int_start, mv_num
        from (select a.*,rownum rn
            from (
                select g_admission_date
                from general_ward
                where patient_name='Bob'
                -- where patient_name='name 1'
                and g_admission_date>=to_date('01/01/05','mm/dd/yy')
                and g_admission_date<=to_date('12/12/05','mm/dd/yy')
                order by g_admission_date
                ) a
            where rownum<=i)
        where rn>=i;

        select * into int_end, mv_num
        from (select a.*,rownum rn
            from (
                select discharge_date
                from post_surgery_ward
                where patient_name='Bob'
                -- where patient_name='name 1'
                and post_admission_date>=to_date('01/01/05','mm/dd/yy')
                and post_admission_date<=to_date('12/12/05','mm/dd/yy')
                and post_admission_date>int_start
                order by post_admission_date
                ) a
            where rownum<=1)
        where rn>=1;

        int_duration:=int_end-int_start;
        
        for j in 1..int_duration loop
            -- dbms_output.put_line(int_duration);
            cur_day:=int_start+j-1;
            select BP into cur_BP 
            from patient_chart
            where patient_name='Bob'
            -- where patient_name='name 1'
            and pdate=cur_day;
            if (cur_BP<=140)
            then insert into pro_q9_t values(cur_day);
            end if;

        end loop;
    end loop;
end;
/
begin
pro_q9_1;
end;
/
-- select * from pro_q9_t;
-- delete from pro_q9_t where daynum=to_date('04/11/05','mm/dd/yy');
-- delete from pro_q9_t where daynum=to_date('04/12/05','mm/dd/yy');
-- delete from pro_q9_t where daynum=to_date('01/03/05','mm/dd/yy');
-- delete from pro_q9_t where daynum=to_date('04/19/05','mm/dd/yy');
-- delete from pro_q9_t where daynum=to_date('04/20/05','mm/dd/yy');
-- delete from pro_q9_t where daynum=to_date('04/21/05','mm/dd/yy');












create or replace procedure pro_q9_2
is
int_num number;
i number;
int_start date;
int_end date;
int_duration number;
scatter_num number;
mv_num number;
cur_day date;
start_signal number;
end_signal number;
mid_v number;
record_start date;
record_end date;
record_cnt number:=0;
begin
    select count(*) into int_num
    from general_ward
    where patient_name='Bob'
    -- where patient_name='name 1'
    and g_admission_date>=to_date('01/01/05','mm/dd/yy')
    and g_admission_date<=to_date('12/12/05','mm/dd/yy');
    dbms_output.put_line(rpad('Int Num',10,' ')||rpad('Start Date',20,' ')||rpad('End Date',20,' '));


    for i in 1.. int_num loop
        -- dbms_output.put_line('333');
        select * into int_start, mv_num
        from (select a.*,rownum rn
            from (
                select g_admission_date
                from general_ward
                where patient_name='Bob'
                -- where patient_name='name 1'
                and g_admission_date>=to_date('01/01/05','mm/dd/yy')
                and g_admission_date<=to_date('12/12/05','mm/dd/yy')
                order by g_admission_date
                ) a
            where rownum<=i)
        where rn>=i;

        select * into int_end, mv_num
        from (select a.*,rownum rn
            from (
                select discharge_date
                from post_surgery_ward
                where patient_name='Bob'
                -- where patient_name='name 1'
                and post_admission_date>=to_date('01/01/05','mm/dd/yy')
                and post_admission_date<=to_date('12/12/05','mm/dd/yy')
                and post_admission_date>int_start
                order by post_admission_date
                ) a
            where rownum<=1)
        where rn>=1;

        int_duration:=int_end-int_start;

        select count(*) into scatter_num
        from pro_q9_t
        where daynum>=int_start
        and daynum<int_end;
        -- dbms_output.put_line('scatter_num'||scatter_num);

        for j in 1..scatter_num loop
            start_signal:=0;
            end_signal:=0;

            select * into cur_day, mv_num
            from (select a.*,rownum rn
                from (
                    select *
                    from pro_q9_t
                    where daynum>=int_start
                    and daynum<int_end
                    ) a
                    where rownum<=j)
            where rn>=j;

            -- dbms_output.put_line('cur_day'||cur_day);

            for k in 1..3 loop


            select case
            when exists (select *
                from pro_q9_t 
                where daynum=cur_day-k)
            then 0
            else 1
            end into mid_v
            from dual;
            start_signal:=start_signal+mid_v;

            select case
            when exists(select *
                from pro_q9_t 
                where daynum=cur_day+k)
            then 0
            else 1
            end into mid_v
            from dual;
            end_signal:=end_signal+mid_v;

            end loop;

            if start_signal=3
            then
            -- dbms_output.put_line('************************.     start: '||cur_day);
            record_start:=cur_day;
            record_cnt:=record_cnt+1;
            end if;

            if end_signal=3
            then
            -- dbms_output.put_line('************************.      end : '||cur_day);
            record_end:=cur_day;
            dbms_output.put_line(rpad(record_cnt,10,' ')||rpad(record_start,20,' ')||rpad(record_end,20,' '));
            end if;

        end loop;
    end loop;

end;
/

begin
pro_q9_2;
end;
/








exec dbms_output.put_line('Query 10');
exec dbms_output.put_line('My assumption for this query is: ');
exec dbms_output.put_line('1 Patient come for more than 1 time in 2005.');
exec dbms_output.put_line('2 There was at least 1 time that the gap between next visit and this visit is more than 5 and less than 14.');
exec dbms_output.put_line('3 Also in this time the surgeon for fisrt surgeon next visit is different from the surgeon this visit.');

-- drop table pro_q9_t;
-- create table pro_q9_t(
-- daynum date,
-- constraint pro9_1 primary key (daynum));
drop table pro_q10_t1;
create table pro_q10_t1(
pt_name varchar2(30),
visit_num number,
start_day date,
end_day date,
surgeon1 varchar2(30),
surgeon2 varchar2(30),
constraint pro10_1 primary key (pt_name,visit_num)
);

create or replace procedure pro_q10_1
is
mul_v_name_cnt number;
cur_name varchar2(30);
mv_num number;
i number;
visit_num number;
j number;
cur_g_ad date;
cur_scount number;
cur_post_ad date;
cur_dis date;
cur_type varchar2(20);
surgeon1 varchar2(30);
surgeon2 varchar2(30);
begin
    select count(distinct g0.patient_name) into mul_v_name_cnt
    from general_ward g0
    where  ((select count(*)
        from general_ward g1
        where g1.patient_name=g0.patient_name)>1);

    -- cur_name 
    for i in 1..mul_v_name_cnt loop


        select * into cur_name,mv_num
        from (select a.*, rownum rn
            from (
                select distinct g0.patient_name
                from general_ward g0
                where  ((select count(*)
                from general_ward g1
                where g1.patient_name=g0.patient_name)>1)
                order by patient_name
                ) a
            where rownum<=i)
        where rn>=i;

        -- dbms_output.put_line('cur_name: '||cur_name);

        select count(patient_name) into visit_num
        from general_ward
        where patient_name=cur_name;

        -- cur_name j's visit
        for j in 1..visit_num loop
            -- dbms_output.put_line('cur_name: '||cur_name||'    visit_num: '||visit_num);

            select * into cur_g_ad,mv_num
            from (select a.*,rownum rn
                from (
                    select g_admission_date 
                    from general_ward
                    where patient_name=cur_name
                    order by g_admission_date
                    ) a
                where rownum<=j)
            where rn>=j;

            select * into cur_post_ad,cur_dis,cur_scount,cur_type,mv_num
            from (select a.*,rownum rn
                from (
                    select post_admission_date,discharge_date,scount,patient_type
                    from post_surgery_ward
                    where patient_name=cur_name
                    order by post_admission_date
                    ) a
                where rownum<=j)
            where rn>=j;

            if cur_scount=1
            then
                if cur_type='general'
                then
                    select name into surgeon1
                    from surgeon_schedule
                    where surgery_date=cur_post_ad
                    and (name='Dr. Smith' or name='Dr. Richards');
                end if;

                if cur_type='cardiac'
                then
                    select name into surgeon1
                    from surgeon_schedule
                    where surgery_date=cur_post_ad
                    and (name='Dr. Charles' or name='Dr. Gower');
                end if;

                if cur_type='neuro'
                then
                    select name into surgeon1
                    from surgeon_schedule
                    where surgery_date=cur_post_ad
                    and (name='Dr. Taylor' or name='Dr. Rutherford');
                end if;

                surgeon2:='No one';
                insert into pro_q10_t1 values (cur_name,j,cur_g_ad,cur_dis,surgeon1,surgeon2);
                -- dbms_output.put_line(cur_name||j||cur_g_ad||cur_dis||surgeon1||surgeon2);
            else
                if cur_type='general'
                then
                    select name into surgeon1
                    from surgeon_schedule
                    where surgery_date=cur_post_ad
                    and (name='Dr. Smith' or name='Dr. Richards');

                    select name into surgeon2
                    from surgeon_schedule
                    where surgery_date=cur_post_ad+2
                    and (name='Dr. Smith' or name='Dr. Richards');
                end if;

                if cur_type='cardiac'
                then
                    select name into surgeon1
                    from surgeon_schedule
                    where surgery_date=cur_post_ad
                    and (name='Dr. Charles' or name='Dr. Gower');

                    select name into surgeon2
                    from surgeon_schedule
                    where surgery_date=cur_post_ad+2
                    and (name='Dr. Charles' or name='Dr. Gower');
                end if;

                if cur_type='neuro'
                then
                    select name into surgeon1
                    from surgeon_schedule
                    where surgery_date=cur_post_ad
                    and (name='Dr. Taylor' or name='Dr. Rutherford');

                    select name into surgeon2
                    from surgeon_schedule
                    where surgery_date=cur_post_ad+2
                    and (name='Dr. Taylor' or name='Dr. Rutherford');
                end if;

                insert into pro_q10_t1 values (cur_name,j,cur_g_ad,cur_dis,surgeon1,surgeon2);
                -- dbms_output.put_line(cur_name||j||cur_g_ad||cur_dis||surgeon1||surgeon2);

            end if;


        end loop;
    end loop;

end;
/

begin
pro_q10_1;
end;
/
-- select * from pro_q10_t1;






drop table pro_q10_t2;
create table pro_q10_t2(
pt_name varchar2(30),
visit_num1 number,
end_day1 date,
surgeon1 varchar2(30),
surgeon2 varchar2(30),
visit_num2 number,
start_day2 date,
surgeon3 varchar2(30),
surgeon4 varchar2(30),
constraint pro10_2 primary key (pt_name,visit_num1)
);
create or replace procedure pro_q10_2
is
cursor namelist is 
select distinct(pt_name)
from pro_q10_t1;
i number;
e1 date;
s2 date;
surg1 varchar2(30);
surg2 varchar2(30);
surg3 varchar2(30);
surg4 varchar2(30);
cur_cnt number;
begin
    for name in namelist loop
        -- dbms_output.put_line(name.pt_name);
        select count(*) into cur_cnt
        from pro_q10_t1
        where pt_name=name.pt_name;

        for i in 1..cur_cnt-1 loop
            select end_day,surgeon1,surgeon2 into e1,surg1,surg2
            from pro_q10_t1
            where pt_name=name.pt_name
            and visit_num=i;
            -- dbms_output.put_line(i||'e1,surg1,surg2 '||e1||surg1||surg2);

            select start_day,surgeon1,surgeon2 into s2,surg3,surg4
            from pro_q10_t1
            where pt_name=name.pt_name
            and visit_num=i+1;
            -- dbms_output.put_line(i||'s2,surg3,surg4 '||s2||surg3||surg4);
            -- dbms_output.put_line('s2-e1: '||(s2-e1));

            if ((s2-e1)>5 and (s2-e1)<14 )
            then 
                -- dbms_output.put_line(i);
                if ((surg2='No one' or surg1=surg2) or (surg4='No one' or surg4=surg3))
                then 
                    if (surg3<>surg1 and surg3<>surg1)
                    then 
                    -- dbms_output.put_line('Find one!!!!');
                    insert into pro_q10_t2 values(name.pt_name,i,e1,surg1,surg2,i+1,s2,surg3,surg4);
                    end if;
                end if;
            end if;
        end loop;

    end loop;
end;
/
begin
pro_q10_2;
end;
/
select * from pro_q10_t2;

















create or replace procedure pro_q10_3
is
cursor name_list is 
select distinct pt_name
from pro_q10_t2;

-- cursor name_list is
-- select patient_name, count(g_admission_date) as cnt
-- from general_ward
-- group by patient_name;

mv_name varchar2(30);
mv_visits number;
mv_g_ad_date date;
mv_s_ad_date date;
mv_pre_ad_date date;
mv_dis_date date;
mv_post_ad_date date;
mv_during_once number;
mv_during_total number;
mv_type varchar2(10);
mv_cost_once number;
mv_cost_total number;
mv_var varchar2(30);
mv_num number;
pre_sur_signal number:=-1;

begin
    dbms_output.put_line(rpad('Name of Patient',32,' ')||rpad('Total cost reinbused by Insurance',70,' '));
    for name in name_list loop
        mv_name:=name.pt_name;
--        mv_name:='name 1';
        select count(g_admission_date) into mv_visits 
        from general_ward
        where patient_name=mv_name;
        
        mv_cost_total:=0;
        mv_during_total:=0;
        for i in 1..mv_visits loop

        mv_cost_once:=0;
        mv_during_once:=0;
        -- general_admission,name,type
        select * into mv_var,mv_g_ad_date,mv_type,mv_num
        from (select a.*, rownum rn
            from (select * from general_ward where patient_name=mv_name order by g_admission_date) a
            where rownum<=i)
        where rn>=i;
--         dbms_output.put_line('stuname: '||mv_name||'.       g_admission_date: '||mv_g_ad_date||'.       type: '||mv_type);     

        -- screen admission date
        select * into mv_s_ad_date,mv_num
        from(select a.*,rownum rn
            from (select s_admission_date
                from screening_ward
                where patient_name=mv_name
                and s_admission_date>mv_g_ad_date
                order by s_admission_date) a
                where rownum<=1)
        where rn>=1;

        -- discharge date
        select * into mv_post_ad_date,mv_dis_date,mv_num
        from(select a.*,rownum rn
            from (select post_admission_date,discharge_date
                from post_surgery_ward
                where patient_name=mv_name
                and discharge_date>mv_g_ad_date
                order by discharge_date ) a
                where rownum<=1)
        where rn>=1;
        mv_during_once:=mv_dis_date-mv_g_ad_date;
        

        -- pre exists or not 
        select case 
            when exists(
                select pre_admission_date
                from pre_surgery_ward
                where patient_name=mv_name
                and pre_admission_date>mv_g_ad_date
                and pre_admission_date<mv_post_ad_date)
            then 1
            else 0
            end into pre_sur_signal
        from dual;

        if pre_sur_signal=1
        then 
            select pre_admission_date into mv_pre_ad_date
            from pre_surgery_ward
            where patient_name=mv_name
            and pre_admission_date>mv_g_ad_date
            and pre_admission_date<mv_post_ad_date;
        end if;

        -- calculate total cost reinbursed by insurance company
        -- general_ward
        mv_cost_once:=mv_cost_once+50*0.8*3+50*0.7*(mv_s_ad_date-mv_g_ad_date-3);
        -- screening & pre
        if pre_sur_signal=1
        then
            mv_cost_once:=mv_cost_once+70*0.85*2+70*0.75*(mv_pre_ad_date-mv_s_ad_date-2);
            mv_cost_once:=mv_cost_once+90*0.95*(mv_post_ad_date-mv_pre_ad_date);
        else
            mv_cost_once:=mv_cost_once+70*0.85*2+70*0.75*(mv_post_ad_date-mv_s_ad_date-2);
        end if;
        -- dbms_output.put_line(mv_cost_once);
        -- surgery & post
        if (mv_dis_date-mv_post_ad_date=2)
        then
            if mv_type='general'
            then
            mv_cost_once:=mv_cost_once+2500*0.65+80*0.9*2;
            end if;

            if mv_type='neuro'
            then
            mv_cost_once:=mv_cost_once+5000*0.85+80*0.9*2;
            end if;

            if mv_type='cardiac'
            then
            mv_cost_once:=mv_cost_once+3500*0.75+80*0.9*2;
            end if;
        else
            if mv_type='general'
            then
            mv_cost_once:=mv_cost_once+2500*0.65+2500*0.6+80*0.9*4;
            end if;

            if mv_type='neuro'
            then
            mv_cost_once:=mv_cost_once+5000*0.85+5000*0.8+80*0.9*4;
            end if;

            if mv_type='cardiac'
            then
            mv_cost_once:=mv_cost_once+3500*0.75+3500*0.7+80*0.9*4;
            end if;
        end if;
--         dbms_output.put_line('patient_name: '||mv_name);
--         dbms_output.put_line(i||'time to vistit');
--         dbms_output.put_line('cost: '||mv_cost_once);
--         dbms_output.put_line('duration: '||mv_during_once);
--         rpad('Borrower Name',35,' ')
--        dbms_output.put_line(666);

        mv_during_total:=mv_during_once+mv_during_total;
        mv_cost_total:=mv_cost_total+mv_cost_once;

        end loop;
    -- dbms_output.put_line('patient_name: '||mv_name);
    -- dbms_output.put_line('total cost: '||mv_cost_total);
    -- dbms_output.put_line('total duration: '||mv_during_total);
    -- dbms_output.put_line(mv_cost_total);
    dbms_output.put_line(rpad(mv_name,32,' ')||rpad(mv_cost_total,20,' '));

    end loop;
end;
/
begin
pro_q10_3;
end;
/



