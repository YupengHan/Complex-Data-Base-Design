
-- Yupeng Han
-- EE562 PRJ3 
-- My email is han434@purdue.edu
-- Please feel free to contact me, I am sure my code can run perfectly for all the queries and I finished all the triggers

create table general_ward(
patient_name varchar2(30),
g_admission_date date,
patient_type varchar2(10),
constraint gwpk PRIMARY KEY (patient_name,g_admission_date,patient_type));

create table screening_ward(
patient_name varchar2(30),
s_admission_date date,
bed_no number,
patient_type varchar2(10),
constraint swpk primary key (patient_name,s_admission_date,bed_no,patient_type));

create table pre_surgery_ward(
patient_name varchar2(30),
pre_admission_date date,
bed_no number,
patient_type varchar2(10),
constraint preswpk primary key (patient_name,pre_admission_date,bed_no));

create table post_surgery_ward(
patient_name varchar2(30),
post_admission_date date,
discharge_date date not null,
scount number,
patient_type varchar2(10),
constraint poswpk primary key (patient_name,post_admission_date,patient_type));

create table patient_chart(
patient_name varchar2(30),
pdate date,
temperature number,
BP number,
constraint pcpk primary key(patient_name,pdate));

create table dr_schedule(
name varchar2(30),
ward varchar2(20),
duty_date date,
constraint drspk primary key(name,ward,duty_date));

create table surgeon_schedule(
name varchar2(30),
surgery_date date,
constraint suspk primary key(name,surgery_date));

create table patient_input(
patient_name varchar2(30),
general_ward_admission_date date,
patient_type varchar2(10),
constraint paipk primary key(patient_name,general_ward_admission_date,patient_type));

