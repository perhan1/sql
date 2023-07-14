/*
Za zagrijavanje
 
    1. Kreirati proceduru nad tabelama
		- Production.Product, 
		- Production.ProductSubcategory,	
		- Production.ProductListPriceHistory, 
		- Purchasing.ProductVendor 
		kojom će se definirati parametri: 
		- p_name za naziv proizvoda, (Product)
		- Color, (Product)
		- ps_name za naziv potkategorije, (ProductSubcategory)
		- ListPrice sa zaokruživanjem na dvije decimale, (Product)
		- AverageLeadTime, (ProductVendor)
		- MinOrderQty, (ProductVendor)
		- MaxOrderQty i (ProductVendor)
		- Razlika kao razliku maksimalne i minimalne naručene količine. 
		
		Dati odgovarajuće nazive. Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koje parametar bez unijete vrijednosti), te da procedura daje rezultat ako je unijeta vrijednost bilo kojeg parametra. 
		Zapisi u proceduri trebaju biti sortirani po vrijednostima parametra ListPrice.
    Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
        1. MaxOrderQty = 1000
        2. Razlika = 350
        3. Color = Red i naziv potkategorije = Helmets
*/
use AdventureWorks2017
go
select top 2 * from Production.ProductSubcategory
select top 2 * from Production.Product
go 

create or alter procedure Zadatak1
	@p_name nvarchar(50) = NULL,
	@Color nvarchar(15) = NULL,
	@ps_name nvarchar(50) = NULL,
	@ListPrice money = NULL,
	@AverageLeadTime int = NULL,
	@MinOrderQty int = NULL,
	@MaxOrderQty int = NULL,
	@Razlika int = NULL
as
begin
select 
	PP.Name as p_name,
	PP.Color,
	PPS.Name as ps_name,
	ROUND(PLPH.ListPrice, 2) as Cijena,
	PPV.AverageLeadTime,
	PPV.MinOrderQty,
	PPV.MaxOrderQty,
	(PPV.MaxOrderQty - PPV.MinOrderQty) as Razlika
from Production.ProductSubcategory as PPS
join Production.Product as PP on PPS.ProductSubcategoryID=PP.ProductSubcategoryID
join Purchasing.ProductVendor as PPV on PP.ProductID = PPV.ProductID
join Production.ProductListPriceHistory as PLPH on PP.ProductID = PLPH.ProductID
WHERE 
PP.Name = @p_name 
	OR PP.Color = @Color 
	OR PPS.Name = @ps_name 
	OR PLPH.ListPrice = @ListPrice 
	OR PPV.AverageLeadTime = @AverageLeadTime 
	OR PPV.MinOrderQty = @MinOrderQty 
	OR PPV.MaxOrderQty = @MaxOrderQty 
	OR (PPV.MaxOrderQty-PPV.MinOrderQty) = @Razlika
ORDER BY PP.ListPrice
END
GO 

ALTER AUTHORIZATION ON DATABASE::AdventureWorks2017 TO sa; 

exec Zadatak1 @MaxOrderQty = 1000
/*
Za vježbu, izvršiti izmjenu procedure Zadatak1 tako da prosljeđuje samo one zapise u kojima je razlika veća od 500.
*/

/*
Šta je batch?
Niz sql naredbi i proceduralnih ekstenzija koje se šalju u DB Engine radi zajedničkog izvršavanja. Prednost je da se naredbe mogu izvršiti odjednom.
Batch nam se nalazi između dva GO-a.
Šta je blok naredbi?
BEGIN
	naredba1
	naredba2
	...
END

IF statement
if (izraz == true) 
	begin
		n1
		n2
	end
else
	begin
		n1
		n2
	end
*/

-- Prebrojati koliko ima 'Sales Representative'-a u tabeli HumanResources.Employee.
-- Ako ih ima više od 14, ispisati poruku "Broj uposlenika sa titulom Sales Representative je veći od 14."
-- Inače, ispisati sve uposlenike iz tabele.
set nocount on;
if(select count(*) from HumanResources.Employee where JobTitle = 'Sales Representative')>14
	begin
		PRINT 'Broj uposlenika sa titulom Sales Representative je veći od 14.'
	end
else
	begin
		PRINT 'Ovo su uposlenici sa titulom Sales Representative.'
		select * from HumanResources.Employee where JobTitle = 'Sales Representative'
	end

-- WHILE STATEMENT
use NORTHWND
go
--Prikazati sve iz tabele Order Details gdje  je ProductID = 12.

SELECT * FROM [Order Details] WHERE ProductID = 12

-- Izvršiti update tabele Order Details tako da povećavamo cijenu UnitPrice 10% tamo gdje je ProductID = 12.
update [Order Details]
set UnitPrice = UnitPrice * 1.1
where ProductID = 12

-- Ovo raditi sve dok je ukupna suma Unit Price-a za ProductID = 12 manja od 700.

while (select sum(UnitPrice) from [Order Details] where ProductID=12) < 700
begin
	update [Order Details]
	set UnitPrice = UnitPrice * 1.1
	where ProductID = 12
end

-- Ako Unit Price dostigne vrijednost veću od 45, zaustaviti povećavanje.

while (select sum(UnitPrice) from [Order Details] where ProductID=12) < 700
begin
	update [Order Details]
	set UnitPrice = UnitPrice * 1.1
	where ProductID = 12
	if (select max(UnitPrice) from [Order Details] where ProductID = 12) > 45
		begin
			break
		end
	else
		begin
			continue
		end
end

SELECT * FROM [Order Details] WHERE ProductID = 12

/*
Lokalne varijable

DECLARE @nazivVarijable INT 

Vrijednost lokalne varijable se može dodijeliti na 3 načina:

- Koristeći specijalnu verziju select-a
	declare @varijabla INT
	select @varijabla = count(*) from HR.Employee
	print @varijabla

- Koristeći set izraz
	declare @varijabla INT
	set @varijabla = 5
	select @varijabla

- Direktno u DECLARE izrazu
	declare @varijabla int = 5
	select @varijabla

ZADAĆA: 
1. Kako se kreiraju korisnički definisani tipovi podataka ili UDT (user-defined data types)
2. Primjer UDT-a
3. User-defined Table Types
4. User-defined Functions
	

*/

