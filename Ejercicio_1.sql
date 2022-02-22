--========================================================================
-- BACKUP de segurity
-- Crear dispositivos multiples
--========================================================================

-- Tenemos que usar esta bd
USE master
GO

-- Creamos el dispositivo, esto se creara en memoria
EXEC sp_addumpdevice 'disk','AdventureWorks2019_Dispositivo',
'C:\Programacion\NET\SQLServer\Backup\AdventureWorks2019_FULL_Dispositivo.bak' 
GO

-- Listar los dispositivos creados
SELECT * FROM sys.backup_devices
GO

-- Borrar dispositivo que borrar tambien el backup
EXEC sp_dropdevice 'AdventureWorks2019_Dispositivo','delfile'
GO

-- Crear el primer backup full base
BACKUP DATABASE AdventureWorks2019
	TO AdventureWorks2019_Dispositivo
		WITH CHECKSUM, NAME = 'AdventureWorks2019_FULL',
		DESCRIPTION = 'AdventureWorks2019_FULL Completo'
GO

-- Verificar el contenido del BACKUP
RESTORE HEADERONLY FROM AdventureWorks2019_Dispositivo
GO

-- Tambien lo podemos hacer de esta manera
RESTORE HEADERONLY FROM DISK = 
'C:\Programacion\NET\SQLServer\Backup\AdventureWorks2019_FULL_Dispositivo.bak' 
GO

--========================================================================
--Ya puede crear nuevos backup diferenciales de forma dinamyca
--========================================================================
USE AdventureWorks2019
GO

-- Nombre para el backup differential dinamico
CREATE PROC BackupDifferentialAdventureWord(@Name NVARCHAR(100))
AS
BEGIN
SET @Name +='_Diff_'+FORMAT(GETDATE(),'yyyyMMdd_hhmmss')

BACKUP DATABASE AdventureWorks2019
	TO AdventureWorks2019_Dispositivo
		WITH CHECKSUM, DIFFERENTIAL, NAME = @Name
END
GO

EXEC BackupDifferentialAdventureWord 'AdventureWorks2019'
GO

EXEC BackupDifferentialAdventureWord 'AdventureWorks2019'
GO

EXEC BackupDifferentialAdventureWord 'AdventureWorks2019'
GO

EXEC BackupDifferentialAdventureWord 'AdventureWorks2019'
GO

--Borrar el proc
DROP PROC BackupDifferentialAdventureWord
GO

--========================================================================
-- Proceso de restauracion manual
--========================================================================

-- Listar los dispositivos creados
SELECT * FROM sys.backup_devices
GO

-- Verificar el contenido del BACKUP
RESTORE HEADERONLY FROM AdventureWorks2019_Dispositivo
GO

-- RESTORE 
-- NO RECOVERY: permite recuperar los demas backup
-- Esta en un estado de restaurando, no podes usarla
-- Podemos usar la ruta completa
RESTORE DATABASE AdventureWorks2019
FROM DISK =
'C:\Programacion\NET\SQLServer\Backup\AdventureWorks2019_FULL_Dispositivo.bak'
WITH FILE=1, NORECOVERY
GO

-- Podemos usar el dispositivo creado
RESTORE DATABASE AdventureWorks2019
FROM AdventureWorks2019_Dispositivo
WITH FILE=2, NORECOVERY
GO

RESTORE DATABASE AdventureWorks2019
WITH RECOVERY
GO

--========================================================================
-- Proceso de restauracion dinamica
--========================================================================