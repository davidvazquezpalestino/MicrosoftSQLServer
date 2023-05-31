

declare @tabla as varchar(100)='vAYCasignacionesCargosComisionesDGUI',
		@alias as varchar(150)='',
		@Nom as varchar(50)='';

WITH se (tabla, campo,orden )
As ( SELECT SO.NAME, SC.NAME, COLUMN_ID FROM sys.objects SO INNER JOIN sys.columns SC ON SO.OBJECT_ID = SC.OBJECT_ID WHERE so.name like @tabla ),
campos(tabla,campos) 
AS (
	SELECT tabla, nuevo = LEFT(rtrim( + p.lista), LEN(rtrim(+ p.lista))-1) 
	FROM se 
	CROSS APPLY(SELECT  case when not @alias = '' then @alias + '.' + r.campo else r.campo end + ', ' AS [text()]  
	FROM se r INNER JOIN 
		(SELECT DISTINCT campo  FROM  se ) v ON v.campo = r.campo 
	ORDER BY r.orden 
	FOR XML PATH('') ) p (lista) 
	GROUP BY  Tabla,LEFT(rtrim(p.lista), LEN(rtrim(p.lista))-1))

SELECT   
'
IF EXISTS(SELECT * FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID(''pLST'+Replace((SELECT substring(@tabla,5,len(@tabla))),'GUI','')+'''))
DROP PROCEDURE dbo.pLST'+Replace((SELECT substring(@tabla,5,len(@tabla))),'GUI','')+'
GO


CREATE PROC [dbo].[pLST'+Replace((SELECT substring(@tabla,5,len(@tabla))),'GUI','')+']
@TipoOperacion varchar(25) = ''''    
AS 

SET NOCOUNT ON 
SET XACT_ABORT ON

IF @TipoOperacion=''LST''
BEGIN
	SELECT '+campos +'
	FROM '+Tabla+' 
	WHERE IdEstatus <>  0
END
GO'
FROM campos



