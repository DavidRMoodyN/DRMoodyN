--===============================================================================
--  Crear dispositivo de backups múltiples para la BD Adventureworks.
--===============================================================================
-- En la base de datos master
USE master
GO

-- Dispositivo, esto se creara en memoria
EXEC sp_addumpdevice 'disk','AdventureWorks2019Dispositivo',
'C:\Programacion\Net\SqlServer\Tareas\QueryTranza\MSSQL2019\Backup\AdventureWorks2019BackupDivice.bak' 
GO

-- Lista de los dispositivos creados
SELECT * FROM sys.backup_devices
GO

-- Crear el primer backup
BACKUP DATABASE AdventureWorks2019
	TO AdventureWorks2019Dispositivo
		WITH FORMAT,INIT, NAME = 'AdventureWorks2019FullBackupBase'
GO

-- Mirar todos los backup de AdventureWorks2019Dispositivo
RESTORE HEADERONLY FROM AdventureWorks2019Dispositivo
GO

-- Lista de archivos que contiene el back
RESTORE FILELISTONLY FROM AdventureWorks2019Dispositivo
GO

SELECT * FROM sys.backup_devices
GO

-- Borrar backup
--EXEC sp_dropdevice 'AdventureWorks2019Dispositivo','delfile'
--GO

--===============================================================================
--Ya puede crear nuevos backup diferenciales
-- Crear un nombre de backup de forma dinamica
--===============================================================================
-- Agregando datos a AdventureWorks2019
Use AdventureWorks2019
GO

CREATE SCHEMA Moody
GO

CREATE TABLE Moody.PersonMoody(
	MoodyID INT PRIMARY KEY IDENTITY,
	MoodyName NVARCHAR(40) NOT NULL,
	IsActivo BIT DEFAULT 1 NOT NULL,
	CreateDate DATETIME DEFAULT GETDATE()
)
GO

-- Nombre para el backup dinamico
CREATE PROC BackupDinamico(@Name NVARCHAR(100))
AS
SET @Name += FORMAT(GETDATE(),'yyyyMMdd_hhmmss')

BACKUP DATABASE AdventureWorks2019
	TO AdventureWorks2019Dispositivo
		WITH DIFFERENTIAL, NAME = @Name
GO

-- DROP PROC BackupDinamico

EXEC BackupDinamico 'Adventure'

-- Restuar el backup y verificar la nueva tabla
-- Con el nombre AdventureWorks2019Test
-- Agregando datos a AdventureWorks2019
Use AdventureWorks2019
GO

CREATE TABLE Moody.HijoMoody(
	HijoID INT PRIMARY KEY IDENTITY,
	Carrera NVARCHAR(50) NOT NULL,
	IsActivo BIT DEFAULT 1 NOT NULL,
	MoodyID INT NOT NULL,
	CONSTRAINT Fk_Hijo_Ref_Person 
		FOREIGN KEY(MoodyID) REFERENCES Moody.PersonMoody(MoodyID)
)
GO

EXEC BackupDinamico 'Adventure'

-- Restuar el backup y verificar la nueva tabla
-- Con el nombre AdventureWorks2019Test

RESTORE DATABASE AdventureWorks2019Test
FROM DISK = N'C:\Programacion\Net\SqlServer\Tareas\QueryTranza\MSSQL2019\Backup\AdventureWorks2019BackupDivice.bak'
WITH REPLACE

INSERT INTO Moody.PersonMoody(MoodyName)
VALUES
('DAVID 1'),
('DAVID 2'),
('DAVID 3'),
('DAVID 4'),
('DAVID 5')
GO

RESTORE DATABASE AdventureWorks2019Test
FROM DISK = N'C:\Programacion\Net\SqlServer\Tareas\QueryTranza\MSSQL2019\Backup\AdventureWorks2019BackupDivice.bak'
WITH REPLACE

INSERT INTO Moody.HijoMoody(Carrera,MoodyID)
VALUES
('Programador',1),
('Programador',2),
('Programador',3)
GO

