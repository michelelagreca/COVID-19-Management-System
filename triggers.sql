delimiter //
create trigger no_same_lockdown
	before insert on history_lockdown
	for each row
	begin
	declare msg char(255);
	set msg = concat('The lockdown entered appears to be in the period of some other lockdown that occurred in', new.city);
	if(exists(select * from history_lockdown where new.city=city and ((new.start_date>=start_date and new.start_date<end_date) or (new.start_date=start_date and new.end_date=end_date) or (new.start_date<start_date and new.end_date>start_date))))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end //

delimiter //
create trigger no_same_lockdown_update
	before update on history_lockdown
	for each row
	begin
	declare msg char(255);
	set msg = concat('The lockdown entered appears to be in the period of some other lockdown that occurred in', new.city);
	if(exists(select * from history_lockdown where new.city=city and ((new.start_date>=start_date and new.start_date<end_date) or (new.start_date=start_date and new.end_date=end_date) or (new.start_date<start_date and new.end_date>start_date))))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end //

delimiter //
create trigger update_real_efficacy_insert
	before insert on test_info
	for each row
	begin
		set new.real_efficacy = (case
			when new.structure='Rigid' then new.nominal_efficacy-1.5
			when new.structure='Flexible' then new.nominal_efficacy+0.5
		end);
	end //

-- N.B This trigger is before instead of after since the two attributes are in the same table.
-- If I had used after, it would have given me lock problems, as the table would have already been handled by the same trigger.

delimiter //
create trigger update_real_efficacy_update
	before update on test_info
	for each row
	begin
		set new.real_efficacy = (case
			when new.structure='Rigid' then new.nominal_efficacy-1.5
			when new.structure='Flexible' then new.nominal_efficacy+0.5
		end);
	end //

delimiter ;
create trigger improvement_insert
	after insert on improvement
	for each row
	update test_info
	set nominal_efficacy=nominal_efficacy+new.improvement
	where ID=new.test;

create trigger improvement_update
	after update on improvement
	for each row
	update test_info
	set nominal_efficacy=nominal_efficacy+new.improvement
	where ID=new.test;

delimiter //
create trigger improvement_date_insert
	before insert on improvement
	for each row
	begin
	declare msg char(255);
	set msg = concat('The test ', new.test, ' does not exists in the database regarding the date ', new.improvement_date);
	if(new.improvement_date<(select creation_date from test where new.test=ID))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger improvement_date_update
	before update on improvement
	for each row
	begin
	declare msg char(255);
	set msg = concat('The test ', new.test, ' does not exists in the database regarding the date ', new.improvement_date);
	if(new.improvement_date<(select creation_date from test where new.test=ID))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger update_check_agency_insert
	after insert on hub
	for each row
	begin
	if(new.check_agency is not null)
	then
	update check_agency
	set checked_hub = new.ID
	where ID=new.check_agency;
	end if;
	end //

delimiter //
create trigger update_check_agency_update
	after update on hub
	for each row
	begin
	if(new.check_agency is not null)
	then
	update check_agency
	set checked_hub = new.ID
	where ID=new.check_agency;
	end if;
	end //

delimiter //
create trigger no_death_insert
before insert on real_test
for each row
begin
declare msg char(255);
	set msg = concat('In date ', new.date_test, ' one among patient or staff is died');
	if(exists(select * from person where cf=new.staff and (die_date<=new.date_test)) or exists(select * from person where cf=new.patient and (die_date<=new.date_test)))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger no_death_update
before update on real_test
for each row
begin
declare msg char(255);
	set msg = concat('In date ', new.date_test, ' one among patient or staff is died');
	if(exists(select * from person where cf=new.staff and (die_date<=new.date_test)) or exists(select * from person where cf=new.patient and (die_date<=new.date_test)))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger date_test_insert
	before insert on real_test
	for each row
	begin
	declare msg char(255);
	set msg = concat('The test ', new.tipology, ' does not exists in the database regarding the date ', new.date_test);
	if(new.date_test<(select creation_date from test where new.tipology=ID))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger date_test_update
	before update on real_test
	for each row
	begin
	declare msg char(255);
	set msg = concat('The test ', new.tipology, ' does not exists in the database regarding the date ', new.date_test);
	if(new.date_test<(select creation_date from test where new.tipology=ID))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger no_same_staff_patient_insert
	before insert on real_test
	for each row
	begin
	declare msg char(255);
	set msg = 'The CF of both patient and staff are equals';
	if(new.staff=new.patient)
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger no_same_staff_patient_update
	before update on real_test
	for each row
	begin
	declare msg char(255);
	set msg = 'The CF of both patient and staff are equals';
	if(new.staff=new.patient)
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger result_date_insert
	before insert on result
	for each row
	begin
	declare msg char(255);
	set msg = concat('The test ', new.tipology, ' was not executed regarding the date ', new.date_result);
	if(new.date_result<(select date_test from real_test where new.test=ID and new.tipology=tipology))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger result_date_update
	before update on result
	for each row
	begin
	declare msg char(255);
	set msg = concat('The test ', new.tipology, ' was not executed regarding the date ', new.date_result);
	if(new.date_result<(select date_test from real_test where new.test=ID and new.tipology=tipology))
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger result_insert
	before insert on result
	for each row
	begin
	declare msg char(255);
	set msg = 'The result inserted is not between 0 and 99.99';
	if(new.result_value >=100 or new.result_value<0)
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger result_update
	before update on result
	for each row
	begin
	declare msg char(255);
	set msg = 'The result inserted is not between 0 and 99.99';
	if(new.result_value >=100 or new.result_value<0)
	then
	signal sqlstate '45000' set message_text = msg;
	end if;
	end//

delimiter //
create trigger update_patient_condition_insert
	before insert on result
	for each row
	begin
	update patient
	set condition_patient = (case
		when (new.result_value>50)
			then 'Positive'
		when (new.result_value between 10 and 50)
			then 'Negative'
		when (new.result_value <10)
			then 'Waiting for retesting'
		end)
	where CF = (select patient from real_test where (patient, date_test) in(select patient, max(date_test) from real_test group by patient) and ID=new.test and tipology=new.tipology)
	and(
	new.date_result>(select date_result from result where (test, tipology,date_result) in(select test, tipology, max(date_result) from result group by test, tipology) and test=new.test and tipology=new.tipology group by date_result) or not exists(select * from result where new.test=test and new.tipology=tipology))
	;
	end //

delimiter //
create trigger update_patient_condition_update
	before update on result
	for each row
	begin
	update patient
	set condition_patient = (case
		when (new.result_value>50)
			then 'Positive'
		when (new.result_value between 10 and 50)
			then 'Negative'
		when (new.result_value <10)
			then 'Waiting for retesting'
		end)
	where CF = (select patient from real_test where (patient, date_test) in(select patient, max(date_test) from real_test group by patient) and ID=new.test and tipology=new.tipology)
	and(
	new.date_result>(select date_result from result where (test, tipology,date_result) in(select test, tipology, max(date_result) from result group by test, tipology) and test=new.test and tipology=new.tipology group by date_result) or not exists(select * from result where new.test=test and new.tipology=tipology))
	;
	end //

-- N.B The only difference between insert and update is that in the latter the date can be equal to the maximum,
-- since it is the same as the one you are editing.

delimiter //
create trigger quarantine_insert
before insert on patient
for each row
begin
set new.quarantine = (case
	when new.condition_patient='Positive'
		then 'Yes'
	when new.condition_patient='Negative'
		then 'No'
	when new.condition_patient='Waiting for retesting'
		then 'No'
	when new.condition_patient='Waiting for results'
		then 'No'
	end);
end//

delimiter //
create trigger quarantine_update
before update on patient
for each row
begin
set new.quarantine = (case
	when new.condition_patient='Positive'
		then 'Yes'
	when new.condition_patient='Negative'
		then 'No'
	when new.condition_patient='Waiting for retesting'
		then 'No'
	when new.condition_patient='Waiting for results'
		then 'No'
	end);
end//

delimiter ;