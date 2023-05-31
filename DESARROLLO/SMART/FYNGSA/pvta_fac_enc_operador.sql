ALTER PROCEDURE pvta_fac_enc_operador
@id_fac INT,
@Operador VARCHAR(256) = NULL,
@Placas VARCHAR(256) = NULL,
@TarjetaCirculacion VARCHAR(256) = NULL,
@LicenciaOperador VARCHAR(256) = NULL
AS

IF @Operador IS NOT NULL OR @Placas IS NOT NULL OR @TarjetaCirculacion IS NOT NULL OR @LicenciaOperador IS NOT NULL
BEGIN
	INSERT INTO dbo.vta_fac_enc_operador(id_fac, Operador,Placas, TarjetaCirculacion, LicenciaOperador)
	VALUES (@id_fac, @Operador, @Placas, @TarjetaCirculacion, @LicenciaOperador)
END

