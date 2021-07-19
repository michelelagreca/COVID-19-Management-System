create table lockdown (
	tipology char(30) primary key,
	start_time time not null,
	end_time time not null,
	n_day_per_week integer not null,
	check(n_day_per_week between 1 and 7))
Engine = 'InnoDB';

create table city (
	ID char(5) primary key,
	name char(50) not null,
	country char(50) not null,
	current_lockdown char(30),
	index ind_lockdown(current_lockdown),
	foreign key (current_lockdown) references lockdown(tipology) on update cascade on delete set null)
Engine = 'InnoDB';

-- N.B I put on delete set null because if a lockdown is deleted from the database, I can also delete it
-- as an attribute from the city since I have a lockdown history.

create table history_lockdown (
	ID integer auto_increment,
	city char(5),
	lockdown char(30),
	start_date date,
	end_date date not null,
	index ind_city (city),
	index ind_lockdown (lockdown),
	foreign key (city) references city(ID) on update cascade,
	foreign key (lockdown) references lockdown(tipology) on update cascade,
	primary key(ID, city, lockdown, start_date),
	check(start_date<end_date))
Engine = 'InnoDB';

create table person (
	CF integer primary key auto_increment,
	name char(50) not null,
	surname char(50) not null,
	born_date date not null,
	email char(50) not null,
	address char(30) not null,
	die_date date,
	die_for_COVID19 enum('Yes', 'No'),
	city char(5) not null,
	index ind_city(city),
	foreign key (city) references city(ID) on update cascade,
	check(born_date<current_date()))
Engine = 'InnoDB';

create table staff (
	CF integer,
	code integer unique,
	specializzation char(50) not null,
	work_years integer not null,
	index ind_CF(CF),
	foreign key (CF) references person(CF) on update cascade,
	primary key(CF),
	check(work_years>0))
Engine = 'InnoDB';

create table patient(
	CF integer not null unique,
	condition_patient enum('Negative', 'Positive', 'Waiting for retesting', 'Waiting for results') not null default 'Waiting for results',
	quarantine enum('Yes', 'No') not null default 'No',
	index ind_CF(CF),
	foreign key (CF) references person(CF) on update cascade,
	primary key(CF))
Engine = 'InnoDB';

create table test (
	ID char(60) primary key,
	productor char(60) not null,
	creation_date date not null,
	check(creation_date between '2020-03-01' and current_date()))
Engine = 'InnoDB';

create table test_info (
	ID char(60),
	tipology char(50) not null,
	analysis char(50) not null,
	mode char(50) not null,
	nominal_efficacy numeric(4,2) not null,
	structure enum('Rigid', 'Flexible') not null,
	real_efficacy numeric(4,2) not null default 0,
	index ind_ID (ID),
	foreign key (ID) references test(ID) on update cascade on delete cascade,
	primary key(ID),
	check(nominal_efficacy between 0 and 99.99))
Engine = 'InnoDB';

-- N.B I put on delete cascade because if a tampone is deleted from the database, it is logical to delete its characteristics as well,
-- since it is a 1 to 1 association.

create table developing_team (
	ID char(5) primary key,
	name char(50) not null)
Engine = 'InnoDB';

create table technique (
	name char(50) primary key,
	creator char(50) not null)
Engine = 'InnoDB';

create table technique_info (
	name char(50),
	place char(50) not null,
	test char(50) not null,
	price integer not null,
	index ind_name(name),
	foreign key(name) references technique(name) on update cascade on delete cascade,
	primary key(name),
	check(price>0))
Engine = 'InnoDB';

-- N.B I put on delete cascade because if a technique is deleted from the database, it is logical to also delete its characteristics,
-- since it is a 1 to 1 association.

create table improvement (
	ID integer auto_increment,
	test char(60) not null,
	team char(5) not null,
	technique char(50) not null,
	improvement numeric(4,2) not null,
	improvement_date date not null,
	index ind_test(test),
	index ind_team(team),
	index ind_technique(technique),
	foreign key (test) references test(ID) on update cascade,
	foreign key (team) references developing_team(ID) on update cascade,
	foreign key (technique) references technique(name) on update cascade,
	primary key(ID, test, team, technique),
	check(improvement between -99.99 and 99.99))
Engine = 'InnoDB';

create table check_agency (
	ID integer auto_increment primary key,
	name char(50) not null,
	address char(50) not null,
	place char(8) not null,
	checked_hub integer unique,
	index ind_place (place),
	foreign key (place) references city(ID) on update cascade)
Engine = 'InnoDB';

create table hub (
	ID integer auto_increment primary key,
	name char(50) not null,
	place char(8) not null,
	address char(50) not null,
	tipology enum('Hospital', 'Private Hub') not null,
	check_agency integer unique,
	index ind_place(place),
	index ind_check_agency(check_agency),
	foreign key (place) references city(ID) on update cascade,
	foreign key (check_agency) references check_agency(ID) on update cascade)
Engine = 'InnoDB';

-- N.B Controllore is unique because the  ente - azienda di controllo relationship is 0-1, 0-1, therefore
-- it can be null, but it must be unique.

create table hub_info(
	ID integer primary key,
	p_iva integer unique,
	tax_no_hospital integer,
	n_divisions integer,
	efficacy_emergency integer,
	index ind_ID(ID),
	foreign key (ID) references hub(ID) on update cascade on delete cascade,
	check((tax_no_hospital between 0 and 100)and(n_divisions>0)and(efficacy_emergency between 0 and 100)))
Engine = 'InnoDB';

-- N.B I put on delete cascade because if an ente is deleted from the database, it is logical to also delete its structure,
-- since it is a 1 to 1 association.

create table real_test (
	ID integer,
	tipology char(60),
	staff integer not null,
	patient integer not null,
	hub integer not null,
	date_test date not null,
	index ind_tipology(tipology),
	index ind_staff(staff),
	index ind_patient(patient),
	index ind_hub(hub),
	foreign key(tipology) references test(ID) on update cascade,
	foreign key(staff) references staff(CF) on update cascade,
	foreign key(patient) references patient(CF) on update cascade,
	foreign key(hub) references hub(ID) on update cascade,
	primary key(ID, tipology),
	check(date_test<=current_date()))
Engine = 'InnoDB';

create table lab(
	ID integer auto_increment primary key,
	name char(50) not null,
	address char(50) not null,
	place char(50) not null,
	index ind_place(place),
	foreign key (place) references city(ID) on update cascade)
Engine = 'InnoDB';

create table result (
	test integer,
	tipology char(60),
	lab integer,
	date_result date,
	result_value numeric(4,2) not null,
	index ind_test(test, tipology),
	index ind_lab(lab),
	foreign key(test, tipology) references real_test(ID, tipology) on update cascade,
	foreign key(lab) references lab(ID) on update cascade,
	primary key(test,tipology,lab,date_result),
	check(result between 0 and 99.99))
Engine = 'InnoDB';