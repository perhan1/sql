/*

1. 

Rezultat prvih 10:

Broj narudzbi Ime                                                Srednje ime                                        Prezime

------------- -------------------------------------------------- -------------------------------------------------- --------------------------------------------------

28            Dalton                                             NULL                                               Perez

28            Mason                                              D                                                  Roberts

27            Nancy                                              E                                                  Chapman

27            Ryan                                               M                                                  Thompson

27            Samantha                                           NULL                                               Jenkins

27            Daniel                                             NULL                                               Davis

27            Charles                                            P                                                  Jackson

27            Ashley                                             NULL                                               Henderson

27            Fernando                                           NULL                                               Barnes

27            Hailey                                             I                                                  Patterson

...
Koriste�i tabele Person.Person, Sales.Customer i Sales.SalesOrderHeader,
 prikazati izvje�taj o broju kupovina svakog kupca.

Potrebno je prikazati:

                - Broj narudzbi (ukupan broj narud�bi odre�enog kupca)

                - Ime (FirstName)

                - Srednje ime (MiddleName)

                - Prezime (LastName)
*/

use AdventureWorks2014
select COUNT(SSOH.SalesOrderNumber) as 'Ukupan broj narudzbi jednog kupca',PP.FirstName 'Ime',PP.MiddleName 'Srednje ime',PP.LastName 'Prezime'
from Person.Person as PP inner join Sales.Customer SC on PP.BusinessEntityID = SC.PersonID 
inner join Sales.SalesOrderHeader as SSOH on SC.CustomerID = SSOH.CustomerID
group by PP.FirstName,PP.MiddleName,PP.LastName
order by COUNT(SSOH.SalesOrderNumber) desc

/*average, sum, count, min, max
su agregatne fje*/



/*

2.
Koriste�i tabele Person.Address, Sales.SalesOrderDetail i Sales.SalesOrderHeader kreirati upit koji �e dati
 sumu naru�enih koli�ina po gradu i godini isporuke koje su izvr�ene poslije 2012. godine, a gdje je suma 
 ve�a od 2000. 
 Rezultat poredati po sumi naru�enih koli�ina na silazni na�in.

 Izlaz:
-------- ----------------- -----------------------
Grad	 Godina isporuke   Suma naru�enih koli�ina
-------- ----------------- -----------------------
Toronto	 2013			   5719
London	 2013			   3572
Paris	 2013			   2788
Toronto	 2014	           2319

 */


 select PA.City 'grad',  year(SSOH.ShipDate) 'godina', SUM(SSOD.OrderQty) 'kolicina'
 from Person.Address PA inner join Sales.SalesOrderHeader SSOH on PA.AddressID = SSOH.ShipToAddressID 
 inner join Sales.SalesOrderDetail SSOD on SSOH.SalesOrderID = SSOD.SalesOrderID
 where year(SSOH.ShipDate) > 2012
 group by PA.City,  year(SSOH.ShipDate)
 having SUM(SSOD.OrderQty) > 2000 
 order by  SUM(SSOD.OrderQty) desc



 /* 
 3.
Koriste�i tabele Employee, Order Details i Orders baze Northwind kreirati upit
koji �e sadr�avati ime uposlenika i ukupnu vrijednost svih narud�bi koje je taj uposlenik 
napravio u 1997. godini ako je ukupna vrijednost ve�a od 50000, pri �emu �e se rezultati 
grupisati prema polju ime.

Rezultat:
----------- ---------------
FirstName   Ukupno
----------- ---------------
Margaret	128809,79
Nancy		93148,09
Janet		108026,15
Laura		56032,63
Robert		60471,19
Andrew		70444,14

*/
use NORTHWND

select E.FirstName, SUM(OD.UnitPrice * OD.Quantity) 'ukupno'
from Employees E inner join Orders O on E.EmployeeID = O.EmployeeID
inner join [Order Details] OD on O.OrderID = OD.OrderID
where YEAR(O.OrderDate) = 1997
group by E.FirstName
having SUM(OD.UnitPrice * OD.Quantity) > 50000



having = where za agregatnu funkciju
where- ne agregatna funkcija ili neki drugi uslovi
group by-agregatne funkcije,koristi se za kolone koje nisu pod agregatnom funkcijom
order by-sortiranje podataka


/*
4. Iz tabela Employees, EmployeeTerritories, Territories i Region baze Northwind prikazati 
prezime i ime uposlenika kao polje ime i prezime, teritorije i regiju koju pokrivaju i stariji su od 30 godina.*/


select E.FirstName 'ime'+ ' ' +E.LastName 'Ime i prezime', t.TerritoryDescription 'teritorija',
r.RegionDescription 'regija'
from Employees E inner join EmployeeTerritories ET on E.EmployeeID = ET.EmployeeID
inner join Territories T on ET.TerritoryID = T.TerritoryID inner join Region R on
T.RegionID = R.RegionID
where (2023-YEAR(E.BirthDate)) > 30





/*
5. Iz tabela Employees, Order Details i Orders baze Northwind prikazati ime i prezime uposlenika 
kao polje ime i prezime, jedini�nu cijenu, koli�inu i izra�unatu vrijednost 
pojedina�ne narud�be kao polje izracunato za sve narud�be u 1997. godini, 
pri �emu �e se rezultati sortirati prema novokreiranom polju izracunato.*/

select E.FirstName + ' ' + E.LastName 'ime i prezime', 
OD.UnitPrice 'jedinicna cijena', OD.Quantity 'kolicina', 
(OD.UnitPrice * OD.Quantity) * (1-OD.Discount) 'Ukupno'
from Employees E inner join Orders O on E.EmployeeID = O.EmployeeID 
inner join [Order Details] OD on O.OrderID = OD.OrderID
where YEAR(O.OrderDate) = 1997
order by (OD.UnitPrice * OD.Quantity) * (1-OD.Discount)



/*
6. Iz tabela Employee, Order Details i Orders baze Northwind prikazati ime uposlenika i ukupnu vrijednost
 svih narud�bi koje je taj uposlenik napravio u 1996. godini ako je ukupna vrijednost
 ve�a od 50000, pri �emu �e se rezultati sortirati uzlaznim redoslijedom prema polju ime.
  Vrijednost sume zaokru�iti na dvije decimale.*/

  select E.FirstName 'ime', round(SUM( OD.UnitPrice*OD.Quantity),2) 'ukupna vrijenost'
  from Employees E inner join Orders O on E.EmployeeID = O.EmployeeID inner join
  [Order Details] OD on O.OrderID = OD.OrderID
  where year(O.OrderDate) = 1996
  group by E.FirstName
  having SUM( OD.UnitPrice*OD.Quantity) > 50000
  order by E.FirstName

/*
7.Iz tabela Categories, Products i Suppliers baze Northwind prikazati naziv isporu�itelja (dobavlja�a), 
mjesto i dr�avu isporu�itelja (dobavlja�a) i naziv(e) proizvoda iz kategorije 
napitaka (pi�a) kojih na stanju ima vi�e od 30 jedinica. Rezultat upita sortirati po dr�avi.
*/


select S.ContactName 'dobavljac', S.City 'mjesto', S.Country 'drzava', P.ProductName 'naziv'
from Categories C inner join Products P on C.CategoryID = P.CategoryID
inner join Suppliers S on P.SupplierID = S.SupplierID
where C.CategoryName like 'Beverages' and P.UnitsInStock > 30
order by S.Country


select CategoryName from Categories

