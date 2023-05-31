INSERT INTO dbo.tCATdomicilios (IdRel, IdTipoD, Descripcion, Calle, CodigoPostal, Asentamiento, Ciudad, Municipio, Estado, Pais, IdAsentamiento, IdCiudad, IdMunicipio, IdEstado, IdPais)
SELECT Relacion.IdRel,
       IdTipoD = 11,
       Descripcion = UPPER (Direccion),
       Calle = UPPER (Direccion),
       Asentamiento.CodigoPostal,
       Asentamiento = UPPER (Asentamiento.Asentamiento),
       Ciudad = UPPER (ISNULL (Asentamiento.Ciudad, '')),
       Municipio = UPPER (Domicilio.Municipio),
       Estado = UPPER (Domicilio.Estado),
       Pais = 'MÉXICO',
       Asentamiento.IdAsentamiento,
       IdCiudad = ISNULL (Asentamiento.IdCiudad, 0),
       Asentamiento.IdMunicipio,
       Asentamiento.IdEstado,
       IdPais = 142
FROM dbo.tPERempleados Empleado
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersonaFisica = Empleado.IdPersonaFisica
INNER JOIN dbo.tCTLrelaciones Relacion ON Relacion.IdDominio = Persona.IdPersona
INNER JOIN dbo.Domicilios Domicilio ON Domicilio.Codigo = Empleado.Codigo COLLATE DATABASE_DEFAULT
LEFT JOIN Sepomex.dbo.Asentamientos Asentamiento ON Asentamiento.CodigoPostal = RIGHT(CONCAT ('00000', Domicilio.CodigoPostal), 5)COLLATE DATABASE_DEFAULT AND
                                                     Domicilio.Colonia = Asentamiento.Asentamiento COLLATE DATABASE_DEFAULT
WHERE Asentamiento.IdAsentamiento IS NOT NULL;
