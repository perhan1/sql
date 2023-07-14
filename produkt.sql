----------------------------------------------------
--ISPIT IZ NAPREDNIH BAZA PODATAKA 13.7.2023. godine 
----------------------------------------------------

--1.a) Kreirati bazu pod vlastitim brojem indeksa.


CREATE DATABASE 305
GO

USE 305
GO

--1.b) Kreiranje tabela.

/*Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu produkt sljedeće strukture:
	- produktID, cjelobrojna varijabla, primarni ključ
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- mj_jedinica, 20 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_post_br, 10 unicode karaktera
	*/

CREATE TABLE Produkt(
	produktID INT PRIMARY KEY,
	jed_cijena MONEY,
	kateg_naziv NVARCHAR(15),
	mj_jedinica NVARCHAR(20),
	dobavljac_naziv NVARCHAR(40),
	dobavljac_post_br NVARCHAR(10)
)
GO
	
	/*
II. Kreirati tabelu narudzba sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, primarni ključ
	- dtm_narudzbe, datumska varijabla za unos samo datuma
	- dtm_isporuke, datumska varijabla za unos samo datuma
	- grad_isporuke, 15 unicode karaktera
	- klijentID, 5 unicode karaktera
	- klijent_naziv, 40 unicode karaktera
	- prevoznik_naziv, 40 unicode karaktera
	*/

CREATE TABLE Narudzba(
	narudzbaID INT PRIMARY KEY,
	dtm_narudzbe DATE,
	dtm_isporuke DATE,
	grad_isporuke NVARCHAR(15),
	klijentID NVARCHAR(5),
	klijent_naziv NVARCHAR(40),
	prevoznik_naziv NVARCHAR(40)
)
GO


	/*

III. Kreirati tabelu narudzba_produkt sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- produktID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla*/


CREATE TABLE Narudzba_produkt(
	narudzbaID INT CONSTRAINT FK_Narudzba FOREIGN KEY REFERENCES Narudzba(narudzbaID) NOT NULL,
	produktID INT CONSTRAINT FK_Produkt FOREIGN KEY REFERENCES Produkt(produktID) NOT NULL,
	uk_cijena MONEY
)
GO


/*2. Import podataka

a) Iz tabela Categories, Product i Suppliers baze Northwind u tabelu produkt importovati podatke prema pravilu:
	- ProductID -> produktID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- PostalCode -> dobavljac_post_br
	*/

INSERT INTO Produkt(produktID, mj_jedinica, jed_cijena, kateg_naziv, dobavljac_naziv, dobavljac_post_br)
SELECT P.ProductID, P.QuantityPerUnit, P.UnitPrice, C.CategoryName, S.ContactName, S.PostalCode
FROM NORTHWND.dbo.Categories AS C
JOIN
NORTHWND.dbo.Products AS P
ON C.CategoryID = P.CategoryID
JOIN
NORTHWND.dbo.Suppliers AS S
ON S.SupplierID = P.SupplierID
GO

SELECT * FROM Produkt
GO


/*
b) Iz tabela Customers, Orders i Shipers baze Northwind u tabelu narudzba importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- ShipCity -> grad_isporuke
	- CustomerID -> klijentID
	- (Customers)CompanyName -> klijent_naziv
	- (Shippers)CompanyName -> prevoznik_naziv
	*/

INSERT INTO Narudzba(narudzbaID, dtm_narudzbe, dtm_isporuke, grad_isporuke, klijentID, klijent_naziv, prevoznik_naziv)
SELECT O.OrderID, O.OrderDate, O.ShippedDate, O.ShipCity, O.CustomerID, C.CompanyName, S.CompanyName
FROM
NORTHWND.dbo.Customers AS C
JOIN
NORTHWND.dbo.Orders AS O
ON
C.CustomerID = O.CustomerID
JOIN
NORTHWND.dbo.Shippers AS S
ON
S.ShipperID = O.ShipVia
GO

SELECT * FROM Narudzba
GO

/*
c) Iz tabele Order Details baze Northwind u tabelu narudzba_produkt importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> produktID
	- uk_cijena <- proizvod jedinične cijene i količine
   uz uslov da je odobren popust 5% na produkt.
   */

INSERT INTO Narudzba_produkt(narudzbaID, produktID, uk_cijena)
SELECT OrderID, ProductID,(UnitPrice*Quantity*(1-Discount))
FROM NORTHWND.dbo.[Order Details]
WHERE Discount = 0.05
GO

SELECT * FROM Narudzba_produkt
GO

/*3. a) Koristeći tabele narudzba i narudzba_produkt kreirati pogled view-uk-cijena koji će imati strukturu:
	- narudzbaID
	- klijentID
	- uk_cijena_cijeli_dio
	- uk_cijena_feninzi - prikazati kao cijeli broj  
      Obavezno pregledati sadržaj pogleda.

b) Koristeći pogled view_uk_cijena kreirati tabelu nova_uk_cijena uz uslov da se preuzmu samo oni zapisi u kojima su feninzi veći od 49. 
   U tabeli trebaju biti sve kolone iz pogleda, te nakon njih kolona uk_cijena_nova u kojoj će ukupna cijena biti zaokružena na veću vrijednost. 
   Npr. uk_cijena = 10, feninzi = 90 -> uk_cijena_nova = 11
   */

CREATE OR ALTER VIEW [view-uk-cijena]
AS
SELECT N.narudzbaID, N.klijentID, LEFT(NP.uk_cijena, 2) AS uk_cijena_cijeli_dio, RIGHT(NP.uk_cijena, 2) AS uk_cijena_feninzi
FROM Narudzba AS N
JOIN
Narudzba_produkt AS NP
ON
N.narudzbaID = NP.narudzbaID
GO

SELECT * FROM [view-uk-cijena]
GO


SELECT narudzbaID, klijentID, uk_cijena_cijeli_dio, uk_cijena_feninzi, (uk_cijena_cijeli_dio+1) AS uk_cijena_nova
INTO nova_uk_cijena
FROM [view-uk-cijena]
WHERE uk_cijena_feninzi>49
GO

SELECT * FROM nova_uk_cijena
GO





   /*
4. Koristeći tabelu uk_cijena_nova kreiranu u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće vrijednosti varijabli:
	narudzbaID - 10730
	klijentID  - ERNSH
*/


CREATE OR ALTER PROCEDURE usp_uk_cijena_nova
@narudzbaID INT = NULL,
@klijentID NVARCHAR(5) = NULL
AS
BEGIN
	INSERT INTO nova_uk_cijena(narudzbaID, klijentID)
	VALUES (@narudzbaID, @klijentID)
END
GO

EXECUTE usp_uk_cijena_nova @narudzbaID = 10730, @klijentID = 'ERNSH'
GO

SELECT * FROM nova_uk_cijena
GO




/*
5. Koristeći tabelu produkt kreirati proceduru proc_post_br koja će prebrojati zapise u kojima poštanski broj dobavljača počinje cifrom. 
   Potrebno je dati prikaz poštanskog broja i ukupnog broja zapisa po poštanskom broju. Nakon kreiranja pokrenuti proceduru.

*/

CREATE OR ALTER PROCEDURE proc_post_br
AS
BEGIN
	SELECT dobavljac_post_br, COUNT(dobavljac_post_br) AS brojZapisa
	FROM Produkt
	WHERE dobavljac_post_br LIKE '[0-9]%'
	GROUP BY dobavljac_post_br
END
GO

EXECUTE proc_post_br
GO


/*
6. a) Iz tabele narudzba kreirati pogled view_prebrojano sljedeće strukture:
	- klijent_naziv
	- prebrojano - ukupan broj narudžbi po nazivu klijent
      Obavezno napisati naredbu za pregled sadržaja pogleda.
   b) Napisati naredbu kojom će se prikazati maksimalna vrijednost kolone prebrojano.
   c) Iz pogleda kreiranog pod a) dati pregled zapisa u kojem će osim kolona iz pogleda prikazati razlika maksimalne vrijednosti i kolone prebrojano 
      uz uslov da se ne prikazuje zapis u kojem se nalazi maksimlana vrijednost.
*/

CREATE OR ALTER VIEW view_prebrojano
AS
	SELECT klijent_naziv, COUNT(narudzbaID) AS prebrojano
	FROM Narudzba
	GROUP BY klijent_naziv
GO

SELECT * FROM view_prebrojano
GO

SELECT TOP 1 prebrojano
FROM view_prebrojano
ORDER BY prebrojano DESC
GO

SELECT klijent_naziv, prebrojano, ((
	SELECT TOP 1 prebrojano
	FROM view_prebrojano
	ORDER BY prebrojano DESC
)-prebrojano) AS Razlika
FROM view_prebrojano
WHERE prebrojano NOT IN (
	SELECT TOP 1 prebrojano
	FROM view_prebrojano
	ORDER BY prebrojano DESC
)
GROUP BY klijent_naziv, prebrojano
GO


/*

7. a) U tabeli produkt dodati kolonu lozinka, 20 unicode karaktera 
   b) Kreirati proceduru kojom će se izvršiti punjenje kolone lozinka na sljedeći način:
	- ako je u dobavljac_post_br podatak sačinjen samo od cifara, lozinka se kreira obrtanjem niza znakova koji se dobiju spajanjem zadnja četiri znaka kolone mj_jedinica i kolone dobavljac_post_br
	- ako podatak u dobavljac_post_br podatak sadrži jedno ili više slova na bilo kojem mjestu, lozinka se kreira obrtanjem slučajno generisanog niza znakova
      Nakon kreiranja pokrenuti proceduru.
      Obavezno provjeriti sadržaj tabele narudžba.
*/


ALTER TABLE Produkt
ADD lozinka NVARCHAR(20)
GO

SELECT * FROM Produkt
GO

CREATE OR ALTER PROCEDURE usp_popunjavanjeLozinke
AS
BEGIN
	UPDATE Produkt
	SET lozinka =
		CASE
			WHEN ISNUMERIC(dobavljac_post_br)=1 THEN REVERSE(RIGHT(mj_jedinica,4)+dobavljac_post_br)
		ELSE
			REVERSE(LEFT(NEWID(),20))
		END
END
GO

EXECUTE usp_popunjavanjeLozinke
GO

SELECT * FROM Produkt
GO


/*
8. a) Kreirati pogled kojim sljedeće strukture:
	- produktID,
	- dobavljac_naziv,
	- grad_isporuke
	- period_do_isporuke koji predstavlja vremenski period od datuma narudžbe do datuma isporuke
      Uslov je da se dohvate samo oni zapisi u kojima je narudzba realizirana u okviru 4 sedmice .
      Obavezno pregledati sadržaj pogleda.

   b) Koristeći pogled view_isporuka kreirati tabelu isporuka u koju će biti smještene sve kolone iz pogleda. 
*/

CREATE OR ALTER VIEW view_isporuka
AS
SELECT P.produktID, P.dobavljac_naziv, N.grad_isporuke, DATEDIFF(DAY, N.dtm_narudzbe, N.dtm_isporuke) AS period_do_isporuke
FROM Produkt AS P
JOIN
Narudzba_produkt AS NP
ON
P.produktID = NP.produktID
JOIN
Narudzba AS N
ON
N.narudzbaID = NP.narudzbaID
WHERE DATEDIFF(DAY, N.dtm_narudzbe, N.dtm_isporuke)<29
GO

SELECT * FROM view_isporuka
GO

SELECT * 
INTO isporuka
FROM view_isporuka
GO

SELECT * FROM isporuka
GO

/* 
9.  a) U tabeli isporuka dodati kolonu red_br_sedmice, 10 unicode karaktera.
    b) U tabeli isporuka izvršiti update kolone red_br_sedmice ( prva, druga, treca, cetvrta) u zavisnosti od vrijednosti u koloni period_do_isporuke. Pokrenuti proceduru
    c) Kreirati pregled kojim će se prebrojati broj zapisa po rednom broju sedmice. Pregled treba da sadrži redni broj sedmice i ukupan broj zapisa po rednom broju.
*/

ALTER TABLE isporuka
ADD red_br_sedmice NVARCHAR(10)
GO

SELECT * FROM isporuka
GO

CREATE OR ALTER PROCEDURE usp_update_red_br_sedmice
AS
BEGIN
	UPDATE isporuka
	SET red_br_sedmice =
		CASE
			WHEN period_do_isporuke BETWEEN 1 AND 7 THEN 'prva'
			WHEN period_do_isporuke BETWEEN 8 AND 14 THEN 'druga'
			WHEN period_do_isporuke BETWEEN 15 AND 21 THEN 'treća'
			ELSE 'četvrta'
		END
END
GO

EXECUTE usp_update_red_br_sedmice
GO

SELECT * FROM isporuka
GO


CREATE OR ALTER VIEW view_prebroji_sedmice
AS
SELECT red_br_sedmice, COUNT(red_br_sedmice) AS [Broj isporuka u sedmici]
FROM isporuka
GROUP BY red_br_sedmice
GO

SELECT * FROM view_prebroji_sedmice
GO

/*
10. a) Kreirati backup baze na default lokaciju.
    b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/
BACKUP DATABASE Mladjo
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\Mladjo.bak'
GO

CREATE OR ALTER PROCEDURE brisanje
AS
BEGIN
	DROP PROCEDURE usp_update_red_br_sedmice
	DROP PROCEDURE usp_popunjavanjeLozinke
	DROP PROCEDURE usp_uk_cijena_nova
	DROP PROCEDURE proc_post_br
	DROP VIEW view_isporuka
	DROP VIEW view_prebrojano
	DROP VIEW view_prebroji_sedmice
	DROP VIEW [view-uk-cijena]
	DROP PROCEDURE brisanje
END
GO

EXECUTE brisanje
GO