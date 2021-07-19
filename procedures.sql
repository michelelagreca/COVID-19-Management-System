delimiter //
create procedure monitor_emergency_efficiency(in efficiency integer)
	begin
	drop table if exists temp1;
	create temporary table temp1(hub char(50), n_wrong_test integer);
	insert into temp1 select t.hub, count(*) from real_test t right join result e on (e.test=t.ID and e.tipology=t.tipology) where result_value<10 group by hub;
	select e.ID, e.name, s.efficacy_emergency, t1.n_wrong_test from hub e, hub_info s, temp1 t1 where e.ID=s.ID and t1.hub=e.ID and s.efficacy_emergency<efficiency;
	end //
delimiter ;
call monitor_emergency_efficiency(70);


delimiter //
create procedure average_test_per_person(in start date, in end date, out average numeric(6,2))
	begin
	drop table if exists temp1;
	drop table if exists temp2;
	create temporary table temp1 (patient integer, n_test_period integer);
	insert into temp1 select patient, count(*) from full_test where date_test between start and end group by patient;
	create temporary table temp2(patient integer, n_test_p integer);
	insert into temp2 select t.patient, coalesce(n.n_test_period, '0') as n_test_in_period from real_test t left join temp1 n on t.patient=n.patient group by t.patient;
	select avg(n_test_p) as average_number_tests_made_by_patient_in_period into average from temp2;
	end//
delimiter ;
call average_test_per_person('2020-07-01','2020-10-01',@average);
select @average;


delimiter //
create procedure positives_in_a_period(in start date, in end date, out total integer, out positives integer)
	begin
	drop table if exists temp1;
	create temporary table temp1 (ID integer, test char(50), res numeric(5,2));
	insert into temp1 select ID, name_test, res from full_test_plus where (ID, name_test, date_result) in(select ID, name_test, max(date_result) from full_test_plus group by ID, name_test) and date_test between start and end group by ID, name_test;
	select count(*) into total from temp1;
	select count(*) into positives from temp1 where res>50;
	end//
delimiter ;
call positives_in_a_period('2020-04-01', '2020-10-01', @tot_test, @pos_test);
select @tot_test, @pos_test;


delimiter //
create procedure deaths_and_positives_in_lockdown(in type_lockdown char(50))
	begin
	drop table if exists temp1;
	drop table if exists temp2;
	create temporary table temp1(CF integer, city char(10), death_date date);
	insert into temp1 select CF, city, die_date from person where city in (select distinct city from history_lockdown where lockdown=type_lockdown) and die_for_COVID19='Yes';
	select * from person where CF in (select t.CF from temp1 t left join history_lockdown s on t.city=s.city where t.death_date between s.start_date and s.end_date);
	create temporary table temp2(city char(10));
	insert into temp2 select city from person where CF in (select t.CF from temp1 t left join history_lockdown s on t.city=s.city where t.death_date between s.start_date and s.end_date) group by city;
	select CF, name, surname, city from person where CF in(select CF from patient where condition_patient='Positive') and city in (select * from temp2 where city in(select ID from city where current_lockdown=type_lockdown));
	end//
delimiter ;
call deaths_and_positives_in_lockdown('Daily');


delimiter //
create procedure city_highest_n_in_quarantine(in type_lockdown char(50))
	begin
	drop table if exists temp1;
	create temporary table temp1(city char(50), n_in_quarantine integer);
	insert into temp1 select city, count(*) from person where city in (select ID from city where current_lockdown=type_lockdown) and CF in (select CF from patient where quarantine='Yes') group by city;
	select c.ID, c.name, c.country, c.current_lockdown, t.n_in_quarantine from city c join temp1 t on c.ID=t.city where ID in (select city from temp1 where n_in_quarantine =(select max(n_in_quarantine) from temp1));
	end//
delimiter ;
call city_highest_n_in_quarantine('Total');


delimiter //
create procedure efficacy_comparing(in improvement_ID integer)
	begin
	SET AUTOCOMMIT=false;
	start transaction;
	drop table if exists temp1;
	drop table if exists temp2;
	drop table if exists temp3;
	create temporary table temp1 (ID integer, test char(50), improvement numeric(4,2), date_i date);
	insert into temp1 select ID, test, improvement, improvement_date from improvement where test = (select test from improvement where ID=improvement_ID) order by improvement_date;
	create temporary table temp2(pre_improvement numeric(4,2));
	insert into temp2 (select nominal_efficacy from test_info where ID in(select distinct test from temp1));
	update temp2 set pre_improvement = pre_improvement -(select sum(improvement) from temp1 where date_i>=(select date_i from temp1 where ID=improvement_ID));
	create temporary table temp3(later_improvement numeric(4,2) default 0);
	insert into temp3 select pre_improvement from temp2;
	update temp3 set later_improvement=later_improvement+(select improvement from improvement where ID=improvement_ID);
	update test_info set nominal_efficacy=(select pre_improvement from temp2) where ID = (select distinct test from temp1);
	select * from test_info where ID = (select distinct test from temp1);
	update test_info set nominal_efficacy=(select later_improvement from temp3) where ID = (select distinct test from temp1);
	select * from test_info where ID = (select distinct test from temp1);
	rollback;
	SET AUTOCOMMIT=true;
	end//
	
delimiter ;
call efficacy_comparing(63203);


delimiter //
create procedure best_lab()
	begin
	drop table if exists temp1;
	create temporary table temp1(lab integer, max_res integer);
	insert into temp1 select lab, max(result_value) from result group by lab;
	select * from lab l join temp1 t on l.ID=t.lab where t.max_res in(select max(max_res) from temp1);
	end//
delimiter ;
call best_lab();