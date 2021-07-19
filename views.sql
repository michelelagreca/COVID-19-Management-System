create view full_test as
select t.ID, t.tipology as name_test, 
	t1.productor as prod, c.tipology, c.analysis, 
	c.mode, c.nominal_efficacy as e_nominal,
	c.structure, c.real_efficacy as e_real, 
	t1.creation_date as creation, t.date_test, 
	t.staff, t.patient, t.hub
from real_test t, test t1, test_info c 
where t.tipology=t1.ID 
	and t.tipology=c.ID;

create view full_test_plus as
	select t.ID, t.tipology as name_test, 
		t1.productor, c.tipology, c.analysis, 
		c.mode, c.nominal_efficacy as e_nominal,
		c.structure, c.real_efficacy as e_real, 
		t1.creation_date as creation, t.date_test, 	e.date_result, e.result_value as res, 
		t.staff, t.patient, t.hub
	from real_test t, test t1, test_info c, result e 
	where t.tipology=t1.ID
		and t.tipology=c.ID
		and t.tipology=e.tipology
		and t.ID=e.test;

-- N.B To display only the lines with the last received result of the tampone:
-- 	select * from full_test_plus 
--	where (ID, name_test, date_result) 
--	in(select ID, name_test, max(date_result) from full_test_plus group by ID, name_test) group by ID, name_test;