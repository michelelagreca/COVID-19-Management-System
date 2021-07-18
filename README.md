# COVID-19 Management System
This tutorial has been the final project of the course that I have taken in my Bachelor Degree of Computer Engineering with the Prof. Daniela Giordano: Database. <br><br>
In this project it will be analyzed a relational database useful for the management of the COVID-19 virus pandemic. The technology used is Mysql, working with XAMPP.<br><br>
# Approach
Various types of information can be entered into the database.<br><br>
Various COVID-19 test models are inserted and tracked, which will have different characteristics. It also possible to keeps track of various copies of the tests, which are useful for testing patients.<br><br>
Each test model is observed by development teams, who improve it using different techniques. Then it will keep track of the various improvements made, and the various improved indices.<br><br>
The test procedure through the COVID-19 test is performed by an operator on a patient compulsorily in a specialized hub, which can be a hospital or a private hub. So the test performed will have all these characteristics.<br><br>
The test will be evaluated by one or more analysis laboratories, which will provide the result. All the results received will then be saved.<br><br>
When a hub is converted into a COVID-19 hub, it chooses a check agency in order to monitor its internal situation, which can optionally be used by the hub. If the check agency adheres, it will only be able to control a single COVID-19 hub per company policy. This information is then tracked.<br><br>
Each city will have information relating to their lockdown condition, both currently and historically.<br><br><br>
# Tables Structure
The first step of the project is to define the structure of the tables used in the database.
#### Lockdown
- This entity will contain several types of lockdown used in the world due to the pandemic.
- Each entry of the entity has a primary key (``tipology``), a start time, an end time, and the total number of weekly days when the lockdown is effective.<br>
#### City
- This entity will contain several cities with informations regarding the current type of its lockdown.
- Each entry of the entity has a primary key (``ID``), the name, the country, and a current lockdown.
- ``current_lockdown`` is a foreign key connected to the primary key of the lockdown entity. This relationship is 1 to N: a city can only have a single type of current lockdown, but a single type of lockdow can be applied to many cities. <br>
#### History Lockdown
- This entity keeps track of all the lockdowns that the cities have been subjected to over time.
- Each entry of the entity has a primary key (``ID``), the city, the lockdown, the start date and the end date.
- ``lockdown`` and ``city`` are foreign keys connected respectively to the primary key of the lockdown entity and to the primary key of the specific city. This relationship is N to N: a city can be checked many times in the catalog with different lockdowns and in turn each lockdown can be associated with a different city. <br>
#### Person
- This entity will contain several people within the world.
- Each entry of the entity has a primary key (``CF``), and other information, such as information regarding the type of death (for COVID-19 or not) and the date of the death.
- ``city`` is a foreign key connected to the primary key of the city where the person is from. This relationship is 1 to N: a person can only have a city, but a single city can have more people.<br>
#### Staff
- This entity will contain several workers in the world health business.
- Each entry of the entity has a primary key (``CF``), and other information.
- ``CF`` is a foreign key connected to the primary key of the person information of the staff. It is also the primary key of the staff worker. This relationship is 1 to 1: a person can only be a worker, and a worker corresponds to only a person.<br>
#### Patient
- This entity will contain several patients.
- Each entry of the entity has a primary key (``CF``), and other information.
- ``CF`` is a foreign key connected to the primary key of the person information of the staff. It is also the primary key of the patient. This relationship is 1 to 1: a person can only be a patient, and a patient corresponds to only a person.<br>
#### Test
- This entity will contain several types of test created to check if a person has the COVID-19 virus.
- Each entry of the entity has a primary key (``ID``), and other information, such as the ``creation_date`` that has to be subsequent to a specific date.<br>
#### Test Info
- This entity will contain the information regarding a specific type of COVID-19 test.
- Each entry of the entity has a primary key (``ID``), and other information.
- ``ID`` is a foreign key connected to the primary key of the realtive type of COVID-19 test. This relationship is 1 to 1: a test has a specific set of information, and vice versa.<br>
#### Developing Team
- This entity will contain several teams that try to improve and make more correct and reliable the COVID-19 tests.
- Each entry of the entity has a primary key (``ID``), and a name.<br>
#### Technique
- This entity will contain several technique that teams can use to improve and make more correct and reliable the COVID-19 tests.
- Each entry of the entity has a primary key (``name``), and a creator.<br>
#### Technique Info
- This entity will contain the information regarding a specific type of technique for improving the COVID-19 tests.
- Each entry of the entity has a primary key (``name``), and other information.
- ``name`` is a foreign key connected to the primary key of the realtive technique. This relationship is 1 to 1: a technique has a specific set of information, and vice versa.<br>
#### Improvement
- This entity will contain several improvements used to improve COVID-19 tests by a team using a specific technique.
- Each entry of the entity has a multiple primary key (``ID``, ``test``, ``team``, ``technique``) and other information.
- ``ID``, ``test``, ``team`` and ``technique`` are foreign keys connected to primary keys of Test, Developing Team and Technique entities. These three relationships are 1 to N: an improvement can use multiple times the same team / technique / test as content of the improvement. There will not be problem of duplicated primary key because each entry of this entity will also contain and ID.<br>
#### Check Agency
- This entity will contain several agency that periodically check a specific hub where COVID-19 tests are made. These controlls are about the hygiene.
- Each entry of the entity has a primary key (``ID``), a name, an address, a place, and a checked hub.
- ``place`` is a foreign key connected to the primary key of the city where the agency is located. It is a 1 to N relationship. ``checked_hub`` is a value that contain the ID of the COVID-19 hub checked by the agency. It is set using a trigger.<br>
#### Hub
- This entity will contain several hubs where COVID-19 tests are made.
- Each entry of the entity has a primary key (``ID``), a name, an address, a place, and a check agency and a tipology (Hospital or Private Hub).
- ``place`` is a foreign key connected to the primary key of the city where the hub is located. It is a 1 to N relationship. ``check_agency`` is a foreign key connected to the primary key of a check agency. This relationship is 1 to 1 with minimum cardinality 0 because an entity may not be controlled but if it is, it can only be controlled by a controlling company following an agreement made with that company at the time of conversion of the entity to an entity. COVID-19. Each company can not control COVID19 entities, but if it does, it can only control one for corporate privacy, since the information obtained must not be disclosed to other entities.<br>
#### Hub Info
- This entity will contain the information regarding a specific COVID-19 hub.
- Each entry of the entity has a primary key (``ID``), and other information.
- ``ID`` is a foreign key connected to the primary key of the relative COVID-19 hub. This relationship is 1 to 1: a hub has a specific set of information, and vice versa.<br>
#### Real Test
- While the entity Test described before contains a several model of COVID-19 test, this entity contains the real instances of each model, the copies that are going to be used to test the patients.
- Each entry of the entity has a primary key (``ID``, ``tipology``), a staff worker that executes the test, a patient, a hub where the test is made, and a date.
- The relationship are 1 to N.<br>
#### Lab
- This entity will contain several laboratories that analyze the real tests and give a result.
- Each entry of the entity has a primary key (``ID``), a name, an address, a place.
- ``place`` is a foreign key connected to the primary key of the city where the lab is located. It is a 1 to N relationship.<br>
#### Result
- This entity will contain several result of the COVID-19 test made by staff to patients. 
- Each entry of the entity has a primary key (``test``, ``tipology``, ``lab``, ``date``), and a result.
- A real test can be sent multiple times to different labs to obtain different results. A lab can analysze several tests. The relationship is N to N.<br><br><br>
## Entity-Realtionship Schema
![](/ERSchema.png)<br><br><br>
## Views
#### Full Test
This view joins real tests with the informations regarding the original COVID-19 test and its information.
#### Full Test Plus
This view joins the previous view with the results of the real tests.<br><br><br>
# Triggers and business rules
In addition to the tables, the database respects some rules and constraints in the insertion and management of data within it.
#### No same lockdown
- In the History Lockdown relationship it is not possible to have lockdowns of the same city that start or end in the period of other lockdowns.
#### Update real efficacy
- In the Test Info entity there is an attribute, ``real_efficacy``, that is redundant and it depends to ``nominal_efficacy`` and ``structure``. Thus, once a test info is inserted, the system update ``real_efficacy`` subsequently. The real efficacy of a test is less than 1.5% of the nominal one if its structure is rigid, greater than 0.5% if it is flexible. Moreover, ``real_efficacy`` and ``nominal_efficacy`` are percentages and their value is between 0 and 99.99.
#### Improvement
- Each improvement made on a test influences its nominal efficacy, thus also the real efficacy. The value of the attribute ``improvement`` is added to the attribute ``nominal_efficacy`` of the test info of the improved test.
#### Improvement date
- It is not possible to insert a test improvement if the test does not exists yet according to the improvement date.
#### Update check agency
- Once an hib is inserted in the database, it has an attribute, ``check_agency``, that says if a check agency controlls the hub. This trigger will update the attribute ``checked_hub`` in the check agency entity to the value of the Hub ID.
#### No death
- A test cannot be entered if one of the operator and patient died on that date.
#### Date test
- A real test can not be inserted if the test date is earlier than the creation of the original test model.
#### No same staff and patient
- It is not possible to insert a test where staff and patient are the same person, even if ii is possible that a staff got a test, and a patient is a staff and executed some tests.
#### Result date
- It is not possible to insert a test result if the correspondent test was not made up to the result date. Morevover, the same test can be sent to several analysis laboratories but on different dates.
#### Result
- The value of a result has to be between 0 and 99.99. It is a float that goes from 0 to 100 and indicates: from 0 to 10 which is null, from 10 to 50 which is negative, greater than 50 which is positive. The condition of that particular patient will be updated accordingly.
#### Update patient condition
- After a test has received a result, the condition of the patient who got that test will be updated, regarding the result of the last test result chronologically.
#### Quarantine
- If the last result of a test is higher that 50, the patient will have to stay in quarantine.
