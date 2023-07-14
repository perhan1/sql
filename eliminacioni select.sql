/*
6.Iz tabela Categories, Products i Suppliers baze Northwind prikazati naziv isporučitelja (dobavljača), mjesto i državu isporučitelja (dobavljača) i naziv(e) proizvoda iz kategorije napitaka (pića) kojih na stanju ima više od 30 jedinica. Rezultat upita sortirati po državi.
*/
select top 2 * from NORTHWND.dbo.Categories
select top 2 * from NORTHWND.dbo.Products
select top 2 * from NORTHWND.dbo.Suppliers

--Kolone? Suppliers.CompanyName, Suppliers.City, Suppliers.Country, Products.ProductName
--Tabele? Categories, Products, Suppliers
--Uslovi? CategoryID = 1 and UnitsInStock > 30
--Sortiranje? po Country
--Kako povezati tabele? Products.SupplierID = Suppliers.SupplierID
select 
	Suppliers.CompanyName as Dobavljac,
	Suppliers.City as Grad,
	Suppliers.Country as Drzava,
	Products.ProductName as Proizvod
from Categories inner join  Products on Categories.CategoryID=Products.CategoryID inner join  Suppliers on Suppliers.SupplierID=Products.SupplierID
where Products.UnitsInStock>30 and Products.CategoryID=1
order by Suppliers.Country

/*Unija, presjek i razlika
7. U tabeli Customers baze Northwind ID kupca je primarni ključ. U tabeli Orders baze Northwind ID kupca je vanjski ključ.
Dati izvještaj:
a) koliko je ukupno kupaca evidentirano u obje tabele (lista bez ponavljanja iz obje tabele)*/
select top 5 * from Customers
select top 5 * from Orders

select CustomerID from Customers
union
select CustomerID from Orders
--order by 1 desc

/*
b) da li su svi kupci obavili narudžbu(intersect) -- za vježbu
c) koji kupci nisu napravili narudžbu(except) -- za vježbu
*/


/*
8. 
a) Provjeriti u koliko zapisa (slogova) tabele Orders nije unijeta vrijednost u polje regija isporuke.*/

select top 5 ShipRegion, * from Orders

select count(*) as RegionIsNull
from Orders
where ShipRegion is null

/*
b) Upotrebom tabela Customers i Orders baze Northwind prikazati ID kupca pri čemu u polje regija kupovine (ShipRegion) nije unijeta vrijednost, uz uslov da je kupac obavio narudžbu (kupac iz tabele Customers postoji u tabeli Orders). Rezultat sortirati u rastućem redoslijedu.*/

select CustomerID from Customers
intersect
select CustomerID from Orders
where ShipRegion is null
order by 1

/*
c) Upotrebom tabela Customers i Orders baze Northwind prikazati ID kupca pri čemu u polje regija kupovine nije unijeta vrijednost i kupac nije obavio ni jednu narudžbu (kupac iz tabele Customers ne postoji u tabeli Orders).
Rezultat sortirati u rastućem redoslijedu.*/
select CustomerID from Customers
except
select CustomerID from Orders
where ShipRegion is null
order by 1

/*
9. Iz tabele HumanResources.Employee baze AdventureWorks2014 prikazati po 5 zaposlenika muškog, odnosno, ženskog pola uz navođenje sljedećih podataka: radno mjesto na kojem se nalazi, datum rođenja, korisnicko ime i godine starosti. Korisničko ime je dio podatka u LoginID. Rezultate sortirati prema polu uzlaznim, a zatim prema godinama starosti silaznim redoslijedom.*/

--kombinacija funkcija left, right i charindex

/* funkcija CHARINDEX(substring, string, start)
The CHARINDEX() function searches for a substring in a string, and returns the position.
If the substring is not found, this function returns 0.
Note: This function performs a case-insensitive search.
*/
select top 5 * from HumanResources.Employee
--Kolone? Gender, JobTitle, BirthDate, LoginID as KorisnickoIme, BirthDate za GodineStarosti  
--Sortiranje? gender asc, GodineStarosti desc

select top 5 
	Gender as Spol,
	JobTitle as RadnoMjesto,
	BirthDate as DatumRodjenja,
	SUBSTRING(LoginID,17,LEN(LoginID)-17) as KorisnickoIme,
	datediff(yyyy,BirthDate,GetDate()) as GodineStarosti
from HumanResources.Employee
where Gender='M'
union
select top 5 
	Gender as Spol,
	JobTitle as RadnoMjesto,
	BirthDate as DatumRodjenja,
	SUBSTRING(LoginID,17,LEN(LoginID)-17) as KorisnickoIme,
	datediff(yyyy,BirthDate,GetDate()) as GodineStarosti
from HumanResources.Employee
where Gender='F'
order by Gender, 5 desc

/*
10. Iz tabele HumanResources.Employee baze AdventureWorks2014 prikazati po 2 zaposlenika  bez obzira da li su u braku ili ne i obavljaju poslove inžinjera uz navođenje sljedećih podataka: radno mjesto na kojem se nalazi, datum zaposlenja i bračni status. Ako osoba nije u braku plaća dodatni porez, inače ne plaća. Rezultate sortirati prema bračnom statusu uzlaznim, a zatim prema stažu silaznim redoslijedom.
*/
select JobTitle, * from HumanResources.Employee
--Kolone? Radno mjesto (JobTitle), Datum zaposlenja (HireDate), Bračni status (MaritalStatus), Status poreza ('plaća porez' ili 'ne plaća porez')
--Uslovi? JobTitle like '%engineer%' and not like '%engineering%'
--Sortiranje? MaritalStatus, HireDate desc
select top 2 
	JobTitle as RadnoMjesto,
	HireDate as DatumZaposlenja,
	MaritalStatus as BracniStatus,
	'plaća porez' as StatusPoreza
from HumanResources.Employee
where JobTitle like '%engineer%' and JobTitle not like '%engineering%' and MaritalStatus = 'S'
union
select top 2 
	JobTitle as RadnoMjesto,
	HireDate as DatumZaposlenja,
	MaritalStatus as BracniStatus,
	'ne plaća porez' as StatusPoreza
from HumanResources.Employee
where JobTitle like '%engineer%' and JobTitle not like '%engineering%' and MaritalStatus = 'M'
order by MaritalStatus asc, HireDate desc

/*
11. Iz tabela HumanResources.Employee i Person.Person prikazati po 5 osoba prema tome da li žele primati email ponude od AdventureWorksa uz navođenje sljedećih polja: ime i prezime osobe kao jedinstveno polje, organizacijski nivo na kojem se nalazi i da li prima email promocije. Pored ovih uvesti i polje koje će, u ovisnosti od sadržaja polja EmailPromotion, davati poruke: Ne prima, Prima selektirane i Prima. Uslov je da uposlenici rade na 1. ili 4. organizacijskom nivou. Rezultat sortirati prema organizacijskom nivou i dodatno uvedenom polju.
*/
select	top 5 Person.Person.FirstName + ' ' + Person.Person.LastName,
		HumanResources.Employee.OrganizationLevel, 
		Person.Person.EmailPromotion,
		'ne prima' mail_status
from	HumanResources.Employee join Person.Person
on		HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
where	HumanResources.Employee.OrganizationLevel in (1,4) and
		Person.Person.EmailPromotion = 0 
union
select	top 5 Person.Person.FirstName + ' ' + Person.Person.LastName,
		HumanResources.Employee.OrganizationLevel, 
		Person.Person.EmailPromotion,
		'prima selektirane' mail_status
from	HumanResources.Employee join Person.Person
on		HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
where	HumanResources.Employee.OrganizationLevel in (1,4) and
		Person.Person.EmailPromotion = 1
union
select	top 5 Person.Person.FirstName + ' ' + Person.Person.LastName,
		HumanResources.Employee.OrganizationLevel, 
		Person.Person.EmailPromotion,
		'prima sve' mail_status
from	HumanResources.Employee join Person.Person
on		HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
where	HumanResources.Employee.OrganizationLevel in (1,4) and
		Person.Person.EmailPromotion = 2
order by 3, 4

/*
12. Iz tabela Sales.SalesOrderDetail i Production.Product prikazati 10 najskupljih stavki prodaje uz navođenje polja: naziv proizvoda, količina, cijena i iznos. Cijenu i iznos zaokružiti na dvije decimale. Iz naziva proizvoda odstraniti posljednji dio koji sadržava cifre i zarez. U rezultatu u polju količina na broj dodati 'kom.', a u polju cijena i iznos na broj dodati 'KM'.*/
select	top 10 left (P.Name, CHARINDEX (',', P.Name)-1) naziv, 
		cast (SOD.OrderQty as varchar) + ' kom.' broj,
		convert (varchar, ROUND (SOD.UnitPrice,2)) + ' KM' cijena, 
		cast (round ((SOD.OrderQty * SOD.UnitPrice),2) as varchar) + ' KM' ukupno
from	AdventureWorks2014.Sales.SalesOrderDetail as SOD join	
		AdventureWorks2014.Production.Product as P
on		SOD.ProductID = P.ProductID
where	CHARINDEX (',', P.Name)-1 > 0
order by SOD.OrderQty * SOD.UnitPrice desc

select CHARINDEX (',', Name)-1
from AdventureWorks2014.Production.Product

----------------------------------

--NORTHWND
/* 1 -- Zadatak riješiti pomoću podupita
Koristeći tabele Orders i Order Details kreirati upit koji će dati sumu količina po Order ID, pri čemu je uslov:
a) da je vrijednost Freighta veća od bilo koje vrijednosti Freighta narudžbi realiziranih u 12. mjesecu 1997. godine **/
select top 2 * from Orders
select top 2 * from [Order Details]
--Ako u uslovu imamo "bilo koje" onda koristimo u klauzuli where ključnu riječ "any"
--Uslov će biti .....where Freight > any (podupit sa uslovom da je month(OrderDate)=12 and year(OrderDate)=1997)

select 
	OrderID,
	(select sum(Quantity) 
		from [Order Details] 
		where Orders.OrderID=[Order Details].OrderID) as SumaKolicina --podupit koji sabire kolonu Quantity iz tabele OrderDetails
from Orders
where Freight > any (select Freight from Orders where OrderDate between '1997-12-01'and '1997-12-31') --podupit koji izdvaja sve vrijednosti Freight koje su iz decembra 1997.

/*
b) da je vrijednost Freighta veća od svih vrijednosti Freighta narudžbi realiziranih u 12. mjesecu 1997. godine
*/
select 
	OrderID,
	(select sum(Quantity) 
		from [Order Details] 
		where Orders.OrderID=[Order Details].OrderID) as SumaKolicina --podupit koji sabire kolonu Quantity iz tabele OrderDetails
from Orders
where Freight > all (select Freight from Orders where OrderDate between '1997-12-01'and '1997-12-31') --podupit koji izdvaja sve vrijednosti Freight koje su iz decembra 1997.

--AdventureWorks2014

/* 2 
Koristeći tabele Production.Product i Production.WorkOrder kreirati upit sa podupitom koji će dati sumu OrderQty po nazivu proizvoda pri čemu se izostavljaju zapisi u kojima je suma NULL vrijednost. Upit treba da sadrži naziv proizvoda i sumu po nazivu.
*/
select top 2 * from Production.Product
select top 2 * from Production.WorkOrder

select 
	Product.Name as nazivProizvoda,
	(select sum(OrderQty) from Production.WorkOrder 
		where Product.ProductID = WorkOrder.ProductID) as Suma
from Production.Product
where (select sum(OrderQty) from Production.WorkOrder 
		where Product.ProductID = WorkOrder.ProductID) is not null
/* 3
Koristeći tabele Sales.SalesOrderHeader i Sales.SalesOrderDetail kreirati upit sa podupitom koji će prebrojati CarrierTrackingNumber po SalesOrderID, 
pri čemu se izostavljaju zapisi čiji AccountNumber ne spada u klasu 10-4030. Upit treba da sadrži SalesOrderID i prebrojani broj.
*/
select top 2 * from Sales.SalesOrderHeader
select top 2 * from Sales.SalesOrderDetail

select 
	SalesOrderID,
	AccountNumber,
	(select count(CarrierTrackingNumber) from Sales.SalesOrderDetail
		where SalesOrderDetail.SalesOrderID=SalesOrderHeader.SalesOrderID) as PrebrojaniBroj --podupit koji će prebrojati CarrierTrackingNumber
from Sales.SalesOrderHeader
where left (AccountNumber,7) not like '10-4030'

/* 4
Koristeći tabele Sales.SpecialOfferProduct i Sales.SpecialOffer kreirati upit sa podupitom koji će prebrojati broj proizvoda po kategorijama koji su u 2014. godini 
bili na specijalnoj ponudi pri čemu se izostavljaju one kategorije kod kojih ne postoji ni jedan proizvod koji nije bio na specijalnoj ponudi.
*/
select top 2 * from Sales.SpecialOfferProduct
select top 2 * from Sales.SpecialOffer

select 
	Sales.SpecialOffer.Category as Kategorija,
	(select count(*) from Sales.SpecialOfferProduct where
		Sales.SpecialOffer.SpecialOfferID=Sales.SpecialOfferProduct.SpecialOfferID and
		year(Sales.SpecialOfferProduct.ModifiedDate) = 2014) as BrojProizvoda
from Sales.SpecialOffer
where (select count(*) from Sales.SpecialOfferProduct where
		Sales.SpecialOffer.SpecialOfferID=Sales.SpecialOfferProduct.SpecialOfferID and
		year(Sales.SpecialOfferProduct.ModifiedDate) = 2014) <> 0
		
--AdventureWorks2014
/* 5
Koristeći tabele SpecialOfferProduct i SpecialOffer prebrojati broj narudžbi po kategorijama popusta od 0 do 15%, pri čemu treba uvesti novu kolona kategorija u koju će biti unijeta vrijednost popusta, npr. 0, 1, 2... Rezultat sortirati prema koloni kategorija u rastućem redoslijedu. Upit treba da vrati kolone: SpecialOfferID, prebrojani broj i kategorija.
*/
select top 2 * from Sales.SpecialOfferProduct
select top 10 * from Sales.SpecialOffer

select
	SOP.SpecialOfferID,
	Count(*) as Ukupno,
	0 as Kategorija
from Sales.SpecialOffer as SO
	join Sales.SpecialOfferProduct as SOP
	on SO.SpecialOfferID = SOP.SpecialOfferID
where DiscountPct = 0
group by SOP.SpecialOfferID
union
select
	SOP.SpecialOfferID,
	Count(*) as Ukupno,
	2 as Kategorija
from Sales.SpecialOffer as SO
	join Sales.SpecialOfferProduct as SOP
	on SO.SpecialOfferID = SOP.SpecialOfferID
where DiscountPct = 0.02
group by SOP.SpecialOfferID
union
select
	SOP.SpecialOfferID,
	Count(*) as Ukupno,
	5 as Kategorija
from Sales.SpecialOffer as SO
	join Sales.SpecialOfferProduct as SOP
	on SO.SpecialOfferID = SOP.SpecialOfferID
where DiscountPct = 0.05
group by SOP.SpecialOfferID
union
select
	SOP.SpecialOfferID,
	Count(*) as Ukupno,
	10 as Kategorija
from Sales.SpecialOffer as SO
	join Sales.SpecialOfferProduct as SOP
	on SO.SpecialOfferID = SOP.SpecialOfferID
where DiscountPct = 0.1
group by SOP.SpecialOfferID
union
select
	SOP.SpecialOfferID,
	Count(*) as Ukupno,
	15 as Kategorija
from Sales.SpecialOffer as SO
	join Sales.SpecialOfferProduct as SOP
	on SO.SpecialOfferID = SOP.SpecialOfferID
where DiscountPct = 0.15
group by SOP.SpecialOfferID
order by 3

/* 6
Koristeći tabele Sales.Store i Sales.Customer kreirati upit kojim će se prebrojati koliko kupaca po teritorijama pokriva prodavac. Rezultat sortirati prema prodavcu i teritoriji.*/
select top 3 * from Sales.Store
select top 3 * from Sales.Customer

--Kolone: SalesPersonID, TerritoryID, count(*)
--Spojiti tabele t.d. BusinessEntityID = StoreID
select
	S.SalesPersonID,
	C.TerritoryID,
	Count(*) as Ukupno
from Sales.Store as S
	join Sales.Customer as C
	on S.BusinessEntityID = C.StoreID
group by S.SalesPersonID, C.TerritoryID
order by 1, 2
/* 7
Koristeći kolonu AccountNumber tabele Sales.Customer prebrojati broj zapisa prema broju cifara brojčanog dijela podatka iz ove kolone. Rezultat sortirati u rastućem redoslijedu.
*/
select * from Sales.Customer
--Poigrajte se sa funkcijama za rad sa stringovima: left i right, len
--funcija cast za prikazivanje stringa kao int
select 
	len(cast(Right(AccountNumber,8) as int)) as BrojCifara,
	count(len(cast(Right(AccountNumber,8) as int))) as Ukupno
from Sales.Customer
group by len(cast(Right(AccountNumber,8) as int))
order by 1
--JOIN
--AdventureWorks2014
/* 8
Koristeći tabele Person.Address, Sales.SalesOrderDetail i Sales.SalesOrderHeader kreirati upit koji će dati sumu naručenih količina po gradu i godini isporuke koje su izvršene poslije 2012. godine.
*/
select top 2 * from Person.Address
select top 2 * from Sales.SalesOrderDetail
select top 2 * from Sales.SalesOrderHeader

select
	PA.City, 
	Year(SOH.ShipDate),
	SUM(SOD.OrderQty)
from Person.Address as PA 
	join Sales.SalesOrderHeader as SOH
		on PA.AddressID = SOH.ShipToAddressID
	join Sales.SalesOrderDetail as SOD
		on SOH.SalesOrderID = SOD.SalesOrderID
where Year(SOH.ShipDate) > 2012
group by PA.City, Year(SOH.ShipDate)
/* 9
Koristeći tabele Sales.Store, Sales.SalesPerson i SalesPersonQuotaHistory kreirati upit koji će dati sumu prodajnih kvota po nazivima prodavnica i ID teritorija, ali samo onih čija je suma veća od 2 000 000. Sortirati po ID teritorije i sumi.
*/
select top 2 * from Sales.Store
select top 2 * from Sales.SalesPerson
select top 2 * from Sales.SalesPersonQuotaHistory

select
	--Kolone: Store.Name, SalesPerson.TerritoryID, sum(QuotaHistory.SalesQuota)
	SS.Name, 
	SP.TerritoryID, 
	SUM(SPQH.SalesQuota) as Suma
from Sales.Store as SS join Sales.SalesPerson as SP 
		on SS.SalesPersonID = SP.BusinessEntityID
	join Sales.SalesPersonQuotaHistory as SPQH
		on SPQH.BusinessEntityID = SP.BusinessEntityID
group by SS.Name, SP.TerritoryID
having sum(SPQH.SalesQuota)> 200000
order by 2,3

ALTER AUTHORIZATION ON DATABASE::AdventureWorks2014 TO sa;
GO

/* 10
Koristeći tabele Person.Person, Person.PersonPhone, Person.PhoneNumberType i Person.Password kreirati upit kojim će se dati informacija da li PasswordHash sadrži bar jedan +. Ako sadrži u koloni status_hash dati poruku "da", inače ostaviti prazn0. Upit treba da sadrži kolone Person.Person.PersonType, Person.PersonPhone.PhoneNumber, Person.PhoneNumberType.Name, Person.Password.PasswordHash.
*/
select top 5 * from Person.Password

select 
	P.PersonType,
		PP.PhoneNumber,
		PNT.Name,
		PW.PasswordHash,
		'Da' as Status_hesh
from 
	Person.Person as P join Person.PersonPhone as PP
		on P.BusinessEntityID = PP.BusinessEntityID
	join Person.PhoneNumberType as PNT
		on PP.PhoneNumberTypeID = PNT.PhoneNumberTypeID
	join Person.Password as PW
		on P.BusinessEntityID = PW.BusinessEntityID 
where charindex('+', PW.PasswordHash) > 0
union
select 
	P.PersonType,
		PP.PhoneNumber,
		PNT.Name,
		PW.PasswordHash,
		' ' as Status_hesh
from 
	Person.Person as P join Person.PersonPhone as PP
		on P.BusinessEntityID = PP.BusinessEntityID
	join Person.PhoneNumberType as PNT
		on PP.PhoneNumberTypeID = PNT.PhoneNumberTypeID
	join Person.Password as PW
		on P.BusinessEntityID = PW.BusinessEntityID 
where charindex('+', PW.PasswordHash) = 0

/* 11
Koristeći tabele HumanResources.Employee i HumanResources.EmployeeDepartmentHistory kreirati upit koji će dati pregled ukupno ostaverenih bolovanja (SickLeaveHours) po departmentu, pri čemu će se uzeti u obzir samo one osobe čiji nacionalni broj počinje ciframa 10, 20, 80 ili 90.
*/
select top 5 * from HumanResources.Employee
select top 5 * from HumanResources.EmployeeDepartmentHistory

select
	EDH.DepartmentID, 
	sum(E.SickLeaveHours) as Suma
from 
	HumanResources.Employee as E
	join HumanResources.EmployeeDepartmentHistory as EDH
		on E.BusinessEntityID = EDH.BusinessEntityID
where left(E.NationalIDNumber,2) in ('10', '20', '80', '90')
group by EDH.DepartmentID
 
/* 12
Koristeći tabele 
	Purchasing.PurchaseOrderHeader, 
	Purchasing.Vendor, 
	Purchasing.PurchaseOrderDetail i 
	Purchasing.ShipMethod 
kreirati upit koji će sadržavati kolone:
	VendorID, 
	Name vendora, 
	EmployeeID, 
	ShipDate, 
	ShipBase i 
	UnitPrice, 
uz uslov da je UnitPrice veća od ShipBase.
*/
select top 2 * from Purchasing.PurchaseOrderHeader
select top 2 * from Purchasing.Vendor
select top 2 * from Purchasing.PurchaseOrderDetail
select top 2 * from Purchasing.ShipMethod

select
	Purchasing.PurchaseOrderHeader.VendorID,
	Purchasing.Vendor.Name,
	Purchasing.PurchaseOrderHeader.EmployeeID, 
	Purchasing.PurchaseOrderHeader.ShipDate,
	Purchasing.PurchaseOrderDetail.UnitPrice,
	Purchasing.ShipMethod.ShipBase
from 
	Purchasing.PurchaseOrderHeader 
	inner join Purchasing.ShipMethod 
		on PurchaseOrderHeader.ShipMethodID=Purchasing.ShipMethod.ShipMethodID
	inner join Purchasing.PurchaseOrderDetail 
		on PurchaseOrderHeader.PurchaseOrderID= Purchasing.PurchaseOrderDetail.PurchaseOrderDetailID
	inner join Purchasing.Vendor 
		on Purchasing.Vendor.BusinessEntityID=Purchasing.PurchaseOrderHeader.VendorID
/* 13
Koristeći tabele 
	Person.Person, 
	Sales.PersonCreditCard i 
	Person.Password 
kreirati upit koji će da vrati polja 
	BusinessEntityID, 
	PersonType, 
	CreditCardID i 
	PasswordSalt.
*/
select top 2 * from Person.Person
select top 2 * from Sales.PersonCreditCard
select top 2 * from Person.Password
--Povezati sve preko BusinessEntityID
select
	PP.BusinessEntityID,
	PP.PersonType,
	PC.CreditCardID,
	PW.PasswordSalt
from
	Person.Password as PW 
	join Person.Person as PP 
		on PW.BusinessEntityID = PP.BusinessEntityID
	join Sales.PersonCreditCard as PC 
		on PP.BusinessEntityID = PC.BusinessEntityID

/* 14
Koristeći tabele  
	Production.ProductModelProductDescriptionCulture, 
	Production.ProductModel i 
	Production.Product 
kreirati upit koji će vratiti polja: 
	CultureID, Name iz tabele Production.ProductModel, 
	Name iz tabele Production.Product i 
	Color, te 
	prebrojani broj po koloni Color. 
Uslov je da se ne prikazuju upiti u kojima nije unijeta vrijednost za CatalogDescription iz tabele Production.ProductModel.
*/
--Probajte za vježbu
 
/* 15
Koristeći tabelu Production.Product kreirati upit koji će prebrojati broj zapisa iza tabele po bojama. Navesti i broj zapisa u kojima nije unijeta vrijednost za boju i dati poruku "nije unijeta vrijednost".
*/
select * from Production.Product
--Koristiti uniju