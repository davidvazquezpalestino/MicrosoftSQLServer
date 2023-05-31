--DROP TABLE tFELconstanciaRetenciones

CREATE TABLE tFELconstanciaRetenciones
(
IdConstanciaRetencion INT IDENTITY(1, 1) PRIMARY KEY(IdConstanciaRetencion),
Version VARCHAR(8),
FechaExpedicion DATE,
Clave VARCHAR(25),
Descripcion VARCHAR(25),
EmisorRfc VARCHAR(13),
EmisorRazonSocial VARCHAR(250),
EmisorCurp VARCHAR(18),
ReceptorNacionalidad VARCHAR(25),
ReceptorNacionalRfc VARCHAR(13),
ReceptorNacionalRazonSocial VARCHAR(300),
ReceptorNacionalCurp VARCHAR(18),
ReceptorExtranjeroNumeroIdentificacionFiscal VARCHAR(18),
ReceptorExtranjeroRazonSocial VARCHAR(250),
PeriodoMesInicial INT,
PeriodoMesFinal INT,
PeriodoEjercicio INT,
MontoOperacion NUMERIC(18, 2),
MontoGravado NUMERIC(18, 2),
MontoExento NUMERIC(18, 2),
MontoRetenido NUMERIC(18, 2),
ImpuestoRetenidoBase NUMERIC(18, 2),
ImpuestoRetenidoImpuesto VARCHAR(2),
ImpuestoRetenidoMontoRetenido NUMERIC(18, 2),
ImpuestoRetenidoTipoPago VARCHAR(16)
) ;
--

DROP TABLE tFELcomplementoConstanciaRetencionesIntereses
CREATE TABLE tFELcomplementoConstanciaRetencionesIntereses
(
IdComplementoConstanciaRetencionesInteres INT IDENTITY(0, 1) PRIMARY KEY(IdComplementoConstanciaRetencionesInteres),
IdConstanciaRetencion INT,
Version VARCHAR(8),
SistemaFinanciero VARCHAR(4),
Retiro VARCHAR(4),
OperacionesDerivadas VARCHAR(4),
MontoNominal NUMERIC(18, 2),
MontoReal NUMERIC(18, 2),
Perdida NUMERIC(18, 2)
) ;

GO
DROP PROCEDURE pLSTconstanciaRetenciones
go
CREATE PROCEDURE pLSTconstanciaRetenciones
AS 
SELECT Constancia.IdConstanciaRetencion,
       Constancia.Version,
       Constancia.FechaExpedicion,
       Constancia.Clave,
       Constancia.Descripcion,
       Constancia.EmisorRfc,
       Constancia.EmisorRazonSocial,
       Constancia.EmisorCurp,
       Constancia.ReceptorNacionalidad,
       Constancia.ReceptorNacionalRfc,
       Constancia.ReceptorNacionalRazonSocial,
       Constancia.ReceptorNacionalCurp,
       Constancia.ReceptorExtranjeroNumeroIdentificacionFiscal,
       Constancia.ReceptorExtranjeroRazonSocial,
       Constancia.PeriodoMesInicial,
       Constancia.PeriodoMesFinal,
       Constancia.PeriodoEjercicio,
       Constancia.MontoOperacion,
       Constancia.MontoGravado,
       Constancia.MontoExento,
       Constancia.MontoRetenido,
       Constancia.ImpuestoRetenidoBase,
       Constancia.ImpuestoRetenidoImpuesto,
       Constancia.ImpuestoRetenidoMontoRetenido,
       Constancia.ImpuestoRetenidoTipoPago,
       complemento.IdComplementoConstanciaRetencionesInteres,
       complemento.IdConstanciaRetencion,

       complemento.SistemaFinanciero,
       complemento.Retiro,
       complemento.OperacionesDerivadas,
       complemento.MontoNominal,
       complemento.MontoReal,
       complemento.Perdida
FROM dbo.tFELconstanciaRetenciones Constancia 
INNER JOIN dbo.tFELcomplementoConstanciaRetencionesIntereses complemento ON complemento.IdConstanciaRetencion = Constancia.IdConstanciaRetencion


INSERT INTO dbo.tFELconstanciaRetenciones(Version, FechaExpedicion, Clave, Descripcion, EmisorRfc, EmisorRazonSocial, ReceptorNacionalidad, ReceptorNacionalRfc, 
										  ReceptorNacionalRazonSocial, ReceptorNacionalCurp, PeriodoMesInicial, PeriodoMesFinal, 
										  PeriodoEjercicio, MontoOperacion, MontoGravado, MontoExento, MontoRetenido, 										  
										  ImpuestoRetenidoBase, 
										  ImpuestoRetenidoImpuesto, 
										  ImpuestoRetenidoMontoRetenido, 
										  ImpuestoRetenidoTipoPago
										  
										  )
SELECT Version = '1.0',
       FechaExpedicion = CURRENT_TIMESTAMP,
       Clave = '16',
       Descripcion = '',
       temptable.RFC,
       Persona.Nombre,
       ReceptorNacionalidad = 'Mexicana',
       ReceptorNacionalRfc = temptable.RFC,
	   ReceptorNacionalRazonSocial = Socio,
	   ReceptorNacionalCurp = CURP,
	   PeriodoMesInicial = [Mes Inicial],
	   PeriodoMesFinal = [Mes Final],
	   PeriodoEjercicio = 2019, 
	   MontoOperacion = [Monto de la operacion o actividad exenta para efectos del ISR],
	   MontoGravado = [Monto de la operacion o actividad exenta para efectos del ISR],
	   MontoExento = 0,
	   MontoRetenido = [ISR retenido],
	  ImpuestoRetenidoBase =  ROUND(CAST([ISR retenido] AS NUMERIC(18, 2))/ CAST([Monto de la operacion o actividad exenta para efectos del ISR]AS NUMERIC(18, 2)), 2),
	  ImpuestoRetenidoImpuesto = '02',
	  ImpuestoRetenidoMontoRetenido = [ISR retenido],
	  ImpuestoRetenidoTipoPago = 'Pago Definitivo'
FROM temptable
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersona = 1
WHERE temptable.RFC IN ('RIRA5302247G7', 'HESJ5401042H8') ;


INSERT INTO dbo.tFELcomplementoConstanciaRetencionesIntereses( IdConstanciaRetencion, Version, SistemaFinanciero, Retiro, OperacionesDerivadas, MontoNominal, MontoReal, Perdida)

SELECT IdConstanciaRetencion, Version = '1.0', SistemaFinanciero = 'SI', Retiro = 'NO', OperacionesDerivadas = 'NO', [Monto de interés nominal], [Interes Real], [Interes Real]
FROM temptable
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersona = 1
INNER JOIN tFELconstanciaRetenciones xx ON temptable.RFC = xx.ReceptorNacionalRfc
WHERE temptable.RFC IN ('RIRA5302247G7', 'HESJ5401042H8') ;


