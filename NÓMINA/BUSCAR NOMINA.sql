DECLARE @Idnomina AS integer = 3188;
DECLARE @Idrfcemisor AS integer = 3654;

SELECT *
FROM tfelcomprobantesD
WHERE idcomprobante IN (SELECT idcomprobante FROM tfelcomplementosnomina WHERE IdNomina = @Idnomina)

SELECT *
FROM tfelpercepcionesdeducciones
WHERE idcomprobante IN (SELECT idcomprobante FROM tfelcomplementosnomina WHERE IdNomina = @Idnomina)

SELECT *
FROM tfelcomprobantes
WHERE idcomprobante IN (SELECT idcomprobante FROM tfelcomplementosnomina WHERE IdNomina = @Idnomina)

SELECT *
FROM tfelcomplementosnomina
WHERE IdNomina = @Idnomina

SELECT *
FROM tFELnominas
WHERE IdRFCemisor = @Idrfcemisor AND IdNomina = @Idnomina

