DECLARE @Idusduario AS integer = 2069;
DECLARE @Idrfcemisor AS integer = 0


SET @Idrfcemisor = (SELECT idrfc FROM tfelemisores WHERE idrfc = (SELECT idrfc 
																  FROM tFELRFCs WHERE IdEstatus = 1 AND idcliente = (SELECT IdCliente 
																								   FROM tCTLusuarios WHERE IdUsuario = @Idusduario)))

SELECT @Idrfcemisor AS IdRFCemisor

