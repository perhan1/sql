/*
1. Iz tabela discounts i stores baze pubs prikazati naziv popusta, 
ID i naziv prodavnice
*/
select * from discounts
select * from stores

select 
	discounttype as NazivPopusta, 
	stores.stor_id as ID, 
	stor_name as NazivProdavnice
from
	discounts left join stores 
	on stores.stor_id=discounts.stor_id

/*
2. Iz tabela employee i jobs baze pubs prikazati ID i ime uposlenika, ID posla i naziv posla koji obavlja*/
select emp_id,fname,employee.job_id,job_desc
from  employee inner join jobs on jobs.job_id=employee.job_id
/*
3. Iz tabela Employees, EmployeeTerritories, Territories i Region baze Northwind prikazati prezime i ime uposlenika kao polje ime i prezime, teritorije i regiju koju pokrivaju i stariji su od 30 godina.*/
use NORTHWND
select LastName + ' ' + FirstName as 'Prezime i ime', TerritoryDescription, RegionDescription
from Employees inner join EmployeeTerritories on Employees.EmployeeID=EmployeeTerritories.EmployeeID
inner join Territories on EmployeeTerritories.TerritoryID=Territories.TerritoryID 
inner join  Region on Region.RegionID=Territories.RegionID
--where GETDATE()-BirthDate>30
where datediff(yyyy, BirthDate, GetDate())>30
/*
4. Iz tabela Employees, Order Details i Orders baze Northwind prikazati ime i prezime uposlenika kao polje ime i prezime, jediničnu cijenu, količinu i izračunatu vrijednost pojedinačne narudžbe kao polje izracunato za sve narudžbe u 1997. godini, pri čemu će se rezultati sortirati prema novokreiranom polju izracunato.*/
select * from Employees
select * from [Order Details]
select * from Orders

select FirstName+' '+LastName as 'Ime i prezime', UnitPrice as JediničnaCijena, Quantity as Količina, UnitPrice*Quantity*(1-Discount) as Izračunato 
from Employees join Orders on Orders.EmployeeID=Employees.EmployeeID
	join [Order Details] on Orders.OrderID=[Order Details].OrderID
where year(OrderDate)=1997
order by 4

/*
5. Iz tabela Employees, Order Details i Orders baze Northwind prikazati ime uposlenika i ukupnu vrijednost svih narudžbi koje je taj uposlenik napravio u 1996. godini ako je ukupna vrijednost veća od 5000, pri čemu će se rezultati sortirati uzlaznim redoslijedom prema polju ime. Vrijednost sume zaokružiti na dvije decimale.*/
select FirstName+' '+LastName as 'Ime i prezime', round(sum(UnitPrice*Quantity*(1-Discount)),2) as UkupnaVrijednost 
from Employees join Orders on Orders.EmployeeID=Employees.EmployeeID
	join [Order Details] on Orders.OrderID=[Order Details].OrderID
where year(OrderDate)=1996
group by FirstName+' '+LastName
having round(sum(UnitPrice*Quantity*(1-Discount)),2)>5000
order by 1


/*Upotrebom tabela Orders i Order Details baze Northwind prikazati ID narudžbe i kupca koji je kupio više od 10 komada proizvoda čiji je ID 15.*/
use NORTHWND

select OrderID, CustomerID
from Orders
where (select Quantity from [Order Details] where Orders.OrderID = [Order Details].OrderID and CustomerID like '15')>10

--isti ovaj zadatak uraditi koristeći join
select Orders.OrderID, CustomerID
from Orders join [Order Details] on Orders.OrderID = [Order Details].OrderID
where Quantity>10 and CustomerID = '15'
/*-----------------------
19.4.2023. GRUPA B - JOIN
-------------------------*/
﻿/*
1. Iz tabela discounts i stores baze pubs prikazati naziv popusta, ID i naziv prodavnice
*/
use pubs
select * from discounts
select * from stores

select discounttype, stores.stor_id, stor_name
from discounts join stores on stores.stor_id=discounts.stor_id

select discounttype, stores.stor_id, stor_name
from discounts left join stores on stores.stor_id=discounts.stor_id

/*
2. Iz tabela employee i jobs baze pubs prikazati ID i ime uposlenika, ID posla i naziv posla koji obavlja*/

--prvi korak pronaći strani ključ preko kojeg ćemo spojiti tabele
select *
from employee join jobs on employee.job_id=jobs.job_id

--drugi korak odabrati kolone za prikaz
select employee.emp_id, employee.fname, jobs.job_id, jobs.job_desc
from employee join jobs on employee.job_id=jobs.job_id

/*
3. Iz tabela Employees, EmployeeTerritories, Territories i Region baze Northwind prikazati prezime i ime uposlenika kao polje ime i prezime, teritorije i regiju koju pokrivaju i stariji su od 30 godina.*/

--Sada imamo 4 tabele koje treba povezati. Koliko ćemo imati spojeva? Odgovor: 3 spoja
--Prvo pronađimo strane ključeve. Može nam pomoći dijagram
--Kako prikazati prezime i ime uposlenika kao jednu kolonu ime i prezime
use NORTHWND
select * from Employees
select 
	e.FirstName + ' ' + e.LastName as 'Ime i prezime',
	TerritoryDescription as Teritorija,
	RegionDescription as Regija
from Employees as e
join EmployeeTerritories as et on e.EmployeeID = et.EmployeeID
join Territories as t on t.TerritoryID = et.TerritoryID
join Region as r on r.RegionID = t.RegionID
where year(getdate())-year(BirthDate)>30

/*
4. Iz tabela Employees, Order Details i Orders baze Northwind prikazati ime i prezime uposlenika kao polje ime i prezime, jediničnu cijenu, količinu i izračunatu vrijednost pojedinačne narudžbe kao polje izracunato za sve narudžbe u 1997. godini, pri čemu će se rezultati sortirati prema novokreiranom polju izracunato.*/
select FirstName + ' ' + LastName as ImePrezime, UnitPrice, Quantity, UnitPrice*Quantity as izracun
from Employees
join [Order Details] on [Order Details].OrderID = OrderID
join Orders on Orders.OrderID = [Order Details].OrderID
where year(Orders.OrderDate) = 1997 
order by izracun

/*
5. Iz tabela Employees, Order Details i Orders baze Northwind prikazati ime uposlenika i ukupnu vrijednost svih narudžbi koje je taj uposlenik napravio u 1996. godini ako je ukupna vrijednost veća od 5000, pri čemu će se rezultati sortirati uzlaznim redoslijedom prema polju ime. Vrijednost sume zaokružiti na dvije decimale.*/
select FirstName + ' ' + LastName as 'Ime i Prezime', round(sum(UnitPrice*Quantity),2) as UkupnaVrijednost
from Employees join Orders on Orders.EmployeeID = Employees.EmployeeID join [Order Details] on Orders.OrderID=[Order Details].OrderID
where year(OrderDate) = 1996
group by FirstName+' '+LastName
having round(sum(UnitPrice*Quantity),2)>5000
order by 'Ime i Prezime'