CREATE TABLE dbo.tAUDIobjetos
(
[Nombre] VARCHAR(128)NULL,
[Tipo] CHAR(2)NULL,
[Descripcion] VARCHAR(60)NULL,
[Definicion] VARCHAR(MAX)NULL,
[Version] VARCHAR(5)NULL,
[Alta] DATETIME NULL
);


SET NOCOUNT ON;
INSERT INTO dbo.tAUDIobjetos (Nombre, Tipo, Descripcion, Definicion, Version, Alta)
SELECT Nombre = NAME,
       Tipo = TYPE,
       Descripcion = TYPE_DESC,
       Definicion = DEFINITION,
       Version = '1.2.1' ,
       Alta = CURRENT_TIMESTAMP
FROM dbo.vOBJECTS
ORDER BY TYPE;