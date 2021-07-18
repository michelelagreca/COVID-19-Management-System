# COVID-19 Management System
This tutorial has been the final project of the course that I have taken in my Bachelor Degree of Computer Engineering with the Prof. Daniela Giordano: Database. <br><br>
In this project it will be analyzed a relational database useful for the management of the COVID-19 virus pandemic. The technology used is Mysql, working with XAMPP.<br><br>
## Tables Structure
The first step of the project is to define the structure of the tables used in the database.
#### Lockdown
- This entity will contain several types of lockdown used in the world due to the pandemic.
- Each entry of the entity has a primary key (tipology), a start time, an end time, and the total number of weekly days when the lockdown is effective.<br>
#### City
- This entity will contain several cities with informations regarding the current type of its lockdown.
- Each entry of the entity has a primary key (ID), the name, the country, and a current lockdown.
- ``current_lockdown`` is a foreign key connected to the primary key of the lockdown entity. This relationship is 1 to N: a city can only have a single type of current lockdown, but a single type of lockdow can be applied to many cities. <br>
