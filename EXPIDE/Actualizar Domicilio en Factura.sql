UPDATE cuenta
SET ReceptorCalle=domicilio.Calle,
    ReceptorCodigoPostal=domicilio.CodigoPostal,
    ReceptorColonia=domicilio.Colonia,
    ReceptorEntreCalles=domicilio.EntreCalles,
    ReceptorEstado=domicilio.Estado,
    ReceptorLocalidad=domicilio.Localidad,
    ReceptorMunicipio=domicilio.Municipio,
    ReceptorNumeroExterior=domicilio.NumeroExterior,
    ReceptorNumeroInterior=domicilio.NumeroInterior,
    ReceptorPais=domicilio.Pais
FROM dbo.tFELcomprobantes cuenta
INNER JOIN dbo.tFELdomicilios domicilio ON cuenta.IdRFCreceptor=domicilio.IdRFC
WHERE cuenta.IdComprobante = 271015;


UPDATE domicilio
SET domicilio.Calle = 'AVENIDA 5 BIS',
    domicilio.CodigoPostal = '94640',
    domicilio.Colonia ='MODERNA',
    domicilio.EntreCalles='',
    domicilio.Localidad = 'CORDOBA',
    domicilio.Municipio = 'CORDOBA',
    domicilio.NumeroExterior ='3700',
    domicilio.NumeroInterior = 'ESQUINA'
FROM dbo.tFELdomicilios domicilio
WHERE domicilio.IdRFC = 69189;
