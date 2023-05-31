
DECLARE @Idpersona AS INT = 15128;

BEGIN TRANSACTION
BEGIN TRY

	DELETE FROM tmpPersonas WHERE Idpersona = @Idpersona
	DELETE from tmpReferencias where IdpersonaReferencia = @Idpersona

	DELETE 
	FROM tAYCreferenciasAsignadas 
	WHERE IdReferenciaPersonal IN (SELECT IdReferenciaPersonal FROM tSCSpersonasFisicasReferencias WHERE IdPersona = @Idpersona )


	DELETE FROM tSCSpersonasFisicasReferencias WHERE IdPersona = @Idpersona 
	UPDATE tGRLpersonas SET IdPersonaFisica = 0, RFC ='' FROM tGRLpersonas WHERE IdPersona = @Idpersona 
	DELETE FROM tGRLpersonasFisicas WHERE IdPersona = @Idpersona 
	DELETE FROM tGRLpersonas WHERE IdPersona = @Idpersona  

	COMMIT TRANSACTION

END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 SELECT ERROR_MESSAGE ()
END CATCH