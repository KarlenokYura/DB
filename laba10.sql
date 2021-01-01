--3.	Продемонстрируйте заимствование прав для любой процедуры в базе данных.
USE Services;

CREATE LOGIN Valentin with PASSWORD = 'Valentin';
CREATE LOGIN Egor with PASSWORD = 'Egor';
CREATE USER Valentin for LOGIN Valentin;
CREATE USER Egor for LOGIN Egor;

EXEC sp_addrolemember 'db_datareader', 'Valentin';
EXEC sp_addrolemember 'db_ddladmin', 'Valentin';
DENY SELECT on Services.dbo.Service TO Egor;
GO

CREATE PROCEDURE us_proc_GetService
WITH EXECUTE AS 'Valentin'
AS
SELECT * FROM Services.dbo.Service;

ALTER AUTHORIZATION ON  us_proc_GetService
TO Valentin;

GRANT EXECUTE ON us_proc_GetService to Egor;

SETUSER 'Egor';
SELECT * FROM Services.dbo.Service;
EXEC us_proc_GetService;

--(4-6).Создать для экземпляра SQL Server объект аудита.
--Задать для серверного аудита необходимые спецификации.
--Запустить серверный аудит, продемонстрировать журнал аудита.

USE MASTER;

CREATE SERVER AUDIT CustomerAudit
TO FILE
(
 FILEPATH = 'D:\Univer\sem6\database\labs\laba10',
 MAXSIZE = 100 MB
)
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);

alter server audit CustomerAudit with ( state = on );

select * from fn_get_audit_file( 'D:\Univer\sem6\database\labs\laba10\CustomerAudit_A71C3805-511C-4BCE-A6B6-7C39A9EBF2CA_0_132331615579840000.sqlaudit', null, null ) order by event_time desc,sequence_number

--(7-9) Создать необходимые объекты аудита.
-- Задать для аудита необходимые спецификации.
-- Запустить аудит БД, продемонстрировать журнал аудита
USE Services  
GO    
CREATE DATABASE AUDIT SPECIFICATION Specification_CustomerAudit
FOR SERVER AUDIT CustomerAudit
add ( select on object::[dbo].[Service] by [public]);

alter database AUDIT SPECIFICATION Specification_CustomerAudit with (state = on);
GO
--10.	Остановить аудит БД и сервера
alter server audit CustomerAudit with ( state = off );
alter database AUDIT SPECIFICATION Specification_CustomerAudit with (state = off);

--11.	Создать для экземпляра SQL Server ассиметричный ключ шифрования.
USE Services
GO
CREATE ASYMMETRIC KEY Lab10akey   
    WITH ALGORITHM = RSA_2048   
    ENCRYPTION BY PASSWORD = 'Lab10';   
GO  
--12.	Зашифровать и расшифровать данные при помощи этого ключа.
GO
USE Services
CREATE TABLE CreditCardInformation
(
	PersonID int PRIMARY KEY IDENTITY,
	CreditCardNumber varbinary(max)
)
GO

INSERT INTO CreditCardInformation(CreditCardNumber)
VALUES (ENCRYPTBYASYMKEY( AsymKey_ID('Lab10akey') , N'1111-2222-3333-4444'))
GO
SELECT * FROM CreditCardInformation
GO

SELECT PersonID, CONVERT(nvarchar(max),  DecryptByAsymKey( AsymKey_Id('Lab10akey'), CreditCardNumber, N'Lab10'))   
,DecryptByAsymKey( AsymKey_Id('Lab10akey'), CreditCardNumber, N'Lab10')
AS DecryptedData   
FROM CreditCardInformation
GO  

--13.	Создать для экземпляра SQL Server сертификат.
create certificate SampleCert
encryption by password = N'<Pa$$w0rd>'
with subject = N'Creation Target',
Expiry_DATE = N'28/10/2022';

--14.	Зашифровать и расшифровать данные при помощи этого сертификата.
INSERT INTO [dbo].[CreditCardInformation] values(EncryptByCert(Cert_ID('SampleCert'), N'Секретные данные'));
GO
SELECT * FROM [dbo].[CreditCardInformation]
GO
SELECT (Convert(Nvarchar(100), DecryptByCert(Cert_ID('SampleCert'), CreditCardInformation.CreditCardNumber, N'<Pa$$w0rd>'))) FROM [dbo].[CreditCardInformation];
GO

--15.	Создать для экземпляра SQL Server симметричный ключ шифрования данных.
--drop Symmetric key SKey
create Symmetric key SKey
WITH ALGORITHM = AES_256  
ENCRYPTION BY PASSWORD = '<Pa$$w0rd>';

Open symmetric key SKey
Decryption by password = '<Pa$$w0rd>'
create Symmetric key SData
with Algorithm =  AES_256
encryption by symmetric key SKey;

Open symmetric key SData 
Decryption by symmetric key SKey;

create Master key encryption by password = N'StRoNgPa$$w0Rd';

-- 16.	Зашифровать и расшифровать данные при помощи этого ключа.

INSERT INTO [dbo].[CreditCardInformation] VALUES (ENCRYPTBYKEY( Key_GUID('SData') , N'Secret Data'))
GO
SELECT * FROM [dbo].[CreditCardInformation]
GO
--Расшифрование с помощью симетричного ключа.
SELECT [PersonID], CONVERT(nvarchar(max),  DecryptByKey( [CreditCardNumber])) AS DecryptedData  FROM [dbo].[CreditCardInformation]
GO 

--17.	Продемонстрировать прозрачное шифрование базы данных.

USE master;  
GO  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<UseStrongPasswordHere>';  
go
CREATE CERTIFICATE MyServerCert WITH SUBJECT = 'My DEK Certificate';  
go
  
USE Services
GO  
CREATE DATABASE ENCRYPTION KEY  
WITH ALGORITHM = AES_128  
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;  
GO  
ALTER DATABASE Services  
SET ENCRYPTION ON;  
GO  

--18.	Продемонстрировать применение хэширования.
select HASHBYTES('SHA1', 'Hesh example');

--19.	Продемонстрировать применение Электронной подписи(ЭЦП) при помощи сертификата.
GO
select SignByCert(Cert_Id( 'SampleCert' ),'Secrect Info', N'<Pa$$w0rd>')

--20.	Сделать резервную копию необходимых ключей и сертификатов.
Backup certificate SampleCert
to File = N'D:\Univer\sem6\database\labs\laba10\BackupSampleCert.cer'
with private key (
File = N'D:\Univer\sem6\database\labs\laba10\BackupSampleCert.pvk',
Encryption by password = N'<Pa$$w0rd>',
Decryption by password = N'<Pa$$w0rd>');





