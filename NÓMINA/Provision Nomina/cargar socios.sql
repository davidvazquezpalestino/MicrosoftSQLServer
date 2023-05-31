USE iERP_UPS

	-- delete from  dbo.tHSTsocios	where idperiodo = 385

	DECLARE @FIN AS DATE, @IdPeriodo INT;
	SELECT  @FIN = Fin, @IdPeriodo = IdPeriodo 
	FROM dbo.tCTLperiodos with (nolock) 
	WHERE Codigo = '2018-10';

	--certificados
	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion, TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento, EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor, Otros, Fallecido)
	
	SELECT DISTINCT idperiodo, tmp.IdSocio, tmp.IdPersona, 1, 0, 0, Total, 0, 
					tmp.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 1, 0, 0, 0, 0, 0, Fecha, 0, 0, tmp.EsPersonaMoral, 0, '', 0, 0
	FROM (	SELECT  tmp.IdSocio, tmp.IdPersona, Fecha = MAX(tmp.Fecha),          tmp.idperiodo,          tmp.EsPersonaMoral,          tmp.IdSucursal, Total = SUM(total)
			FROM (	SELECT  c.IdSocio, s.IdPersona, Total = SUM(tf.CapitalGenerado - tf.CapitalPagado), Fecha = MAX(tf.Fecha), 
							idperiodo = @IdPeriodo, pe.EsPersonaMoral, s.IdSucursal
					FROM dbo.tAYCcuentas c						WITH (NOLOCK)
					JOIN dbo.tAYCproductosFinancieros PF		WITH (NOLOCK) ON PF.IdProductoFinanciero = c.IdProductoFinanciero
					JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
					JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
					JOIN dbo.tSDOtransaccionesFinancieras tf	WITH (NOLOCK) ON tf.IdCuenta = c.IdCuenta
					WHERE tf.IdEstatus = 1 AND pf.IdProductoFinanciero =1 AND tf.Fecha <= @FIN
					GROUP BY c.IdSocio, s.IdPersona, pe.EsPersonaMoral, s.IdSucursal) AS tmp 
			WHERE total > 0 
			GROUP BY tmp.IdSocio, tmp.IdPersona, tmp.idperiodo, tmp.EsPersonaMoral, tmp.IdSucursal) AS tmp
	WHERE tmp.IdSocio > 0
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst
						WHERE hst.IdPeriodo = tmp.idperiodo AND hst.IdSocio = tmp.IdSocio);
	--parcial
	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion, TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento, EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor, Otros, Fallecido)
	
	SELECT DISTINCT idperiodo, tmp.IdSocio, tmp.IdPersona, 0, 0, 0, 0, 0, 
					tmp.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 0, 1, 0, 0, 0, 0, Fecha, 0, Total, tmp.EsPersonaMoral, 0, '', 0, 0
	FROM (	SELECT  tmp.IdSocio, tmp.IdPersona, Fecha = MAX(tmp.Fecha),          tmp.idperiodo,          tmp.EsPersonaMoral,          tmp.IdSucursal, Total = SUM(Total)
			FROM (	SELECT  c.IdSocio, s.IdPersona, Total = SUM(tf.CapitalGenerado - tf.CapitalPagado), Fecha = MAX(tf.Fecha), 
							idperiodo = @IdPeriodo, pe.EsPersonaMoral, s.IdSucursal
					FROM dbo.tAYCcuentas c						WITH (NOLOCK)
					JOIN dbo.tAYCproductosFinancieros PF		WITH (NOLOCK) ON PF.IdProductoFinanciero = c.IdProductoFinanciero
					JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
					JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
					JOIN dbo.tSDOtransaccionesFinancieras tf	WITH (NOLOCK) ON tf.IdCuenta = c.IdCuenta
					WHERE tf.IdEstatus = 1 AND pf.IdProductoFinanciero = 2 AND tf.Fecha <= @FIN
					GROUP BY c.IdSocio, s.IdPersona, pe.EsPersonaMoral, s.IdSucursal) AS tmp 
			WHERE total > 0 
			GROUP BY tmp.IdSocio, tmp.IdPersona, tmp.idperiodo, tmp.EsPersonaMoral, tmp.IdSucursal) AS tmp
	WHERE tmp.IdSocio > 0
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst
						WHERE hst.IdPeriodo = tmp.idperiodo AND hst.IdSocio = tmp.IdSocio);


	--MENORES AHORRADORES
	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion, TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento, EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor, Otros, Fallecido)
	
	SELECT DISTINCT idperiodo, tmp.IdSocio, tmp.IdPersona, 0, 0, 0, 0, 0, 
					tmp.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 0, 0, 1, 0, 0, 1, Fecha, 0, 0, tmp.EsPersonaMoral, 0, '', 0, 0
	FROM (	SELECT  tmp.IdSocio, tmp.IdPersona, Fecha = MAX(tmp.Fecha),          tmp.idperiodo,          tmp.EsPersonaMoral,          tmp.IdSucursal
			FROM (	SELECT  c.IdCuenta, c.IdSocio, s.IdPersona, Total = SUM(tf.CapitalGenerado - tf.CapitalPagado), Fecha = MAX(tf.Fecha), 
							idperiodo = @IdPeriodo, pe.EsPersonaMoral, s.IdSucursal
					FROM dbo.tAYCcuentas c						WITH (NOLOCK)
					JOIN dbo.tAYCproductosFinancieros PF		WITH (NOLOCK) ON PF.IdProductoFinanciero = c.IdProductoFinanciero
					JOIN dbo.tSITproductosFinancieros si		WITH (NOLOCK) ON si.AhorroMenores = 1 AND si.IdProductoFinanciero = c.IdProductoFinanciero
					JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
					JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
					JOIN dbo.tSDOtransaccionesFinancieras tf	WITH (NOLOCK) ON tf.IdCuenta = c.IdCuenta
					WHERE tf.IdEstatus = 1 AND tf.Fecha <= @FIN
					GROUP BY  c.IdCuenta, c.IdSocio, s.IdPersona, pe.EsPersonaMoral, s.IdSucursal) AS tmp 
			WHERE total > 0 
			GROUP BY tmp.IdSocio, tmp.IdPersona, tmp.idperiodo, tmp.EsPersonaMoral, tmp.IdSucursal) AS tmp
	WHERE tmp.IdSocio > 0
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst
						WHERE hst.IdPeriodo = tmp.idperiodo AND hst.IdSocio = tmp.IdSocio);

	-- CUENTAS SIN MOVIMIENTO
	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion,    TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento , EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor , Otros, Fallecido )

	SELECT DISTINCT idperiodo, tmp.IdSocio, tmp.IdPersona, 0, 0, 0, 0, 0, 
			tmp.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 0, 0, 0, 1, 0, 1, Fecha, 0, 0, tmp.EsPersonaMoral, 0, '', 0, 0
	FROM (	SELECT c.IdCuenta, c.IdProductoFinanciero, c.IdSocio, s.IdPersona, Total = SUM(tf.CapitalGenerado - tf.CapitalPagado), Fecha = MAX(tf.Fecha), 
					idperiodo = @IdPeriodo, pe.EsPersonaMoral, s.IdSucursal
			FROM dbo.tAYCcuentas c						WITH (NOLOCK)
			JOIN dbo.tAYCproductosFinancieros PF		WITH (NOLOCK) ON PF.IdProductoFinanciero = c.IdProductoFinanciero
			JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
			JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
			JOIN dbo.tSDOtransaccionesFinancieras tf	WITH (NOLOCK) ON tf.IdCuenta = c.IdCuenta
			WHERE tf.IdEstatus = 1 AND c.IdTipoDProducto IN (1570) AND tf.Fecha <= @FIN
			GROUP BY  c.IdCuenta, c.IdProductoFinanciero, c.IdSocio, s.IdPersona, pe.EsPersonaMoral, s.IdSucursal) AS tmp
	WHERE tmp.Total > 0 AND tmp.IdSocio > 0
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst WITH (NOLOCK) 
						WHERE hst.IdPeriodo = tmp.idperiodo AND hst.IdSocio = tmp.IdSocio);
	
	-- CAPITAL NO EXHIBIDO
	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion,    TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento , EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor , Otros, Fallecido )

	SELECT DISTINCT idperiodo, tmp.IdSocio, tmp.IdPersona, 0, 0, 0, 0, 0, 
			tmp.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 0, 0, 0, 1, 0, 1, Fecha, 0, 0, tmp.EsPersonaMoral, 0, '', 0, 0
	FROM (	SELECT c.IdProductoFinanciero, c.IdSocio, s.IdPersona, Total = SUM(tf.CapitalGenerado - tf.CapitalPagado), Fecha = MAX(tf.Fecha), 
					idperiodo = @IdPeriodo, pe.EsPersonaMoral, s.IdSucursal
			FROM dbo.tAYCcuentas c						WITH (NOLOCK)
			JOIN dbo.tAYCproductosFinancieros PF		WITH (NOLOCK) ON PF.IdProductoFinanciero = c.IdProductoFinanciero
			JOIN dbo.tSITproductosFinancieros pfs ON pfs.IdProductoFinanciero = c.IdProductoFinanciero AND pfs.EsCapitalSocialNoExhibido = 1
			JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
			JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
			JOIN dbo.tSDOtransaccionesFinancieras tf	WITH (NOLOCK) ON tf.IdCuenta = c.IdCuenta
			WHERE tf.IdEstatus = 1 AND tf.Fecha <= @FIN
			GROUP BY c.IdProductoFinanciero, c.IdSocio, s.IdPersona, pe.EsPersonaMoral, s.IdSucursal) AS tmp
	WHERE tmp.Total > 0 AND tmp.IdSocio > 0
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst WITH (NOLOCK) 
						WHERE hst.IdPeriodo = tmp.idperiodo AND hst.IdSocio = tmp.IdSocio);

	UPDATE dbo.tHSTsocios SET CertificadoAportacionExcedente = 0 WHERE IdPeriodo = @IdPeriodo;

	UPDATE hst SET CertificadoAportacionExcedente = total
	FROM (	SELECT c.IdProductoFinanciero, c.IdSocio, s.IdPersona, Total = SUM(tf.CapitalGenerado - tf.CapitalPagado), Fecha = MAX(tf.Fecha), 
					idperiodo = @IdPeriodo, pe.EsPersonaMoral, s.IdSucursal
			FROM dbo.tAYCcuentas c						WITH (NOLOCK)
			JOIN dbo.tAYCproductosFinancieros PF		WITH (NOLOCK) ON PF.IdProductoFinanciero = c.IdProductoFinanciero
			JOIN dbo.tSITproductosFinancieros pfs ON pfs.IdProductoFinanciero = c.IdProductoFinanciero AND pfs.EsCapitalSocialNoExhibido = 1
			JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
			JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
			JOIN dbo.tSDOtransaccionesFinancieras tf	WITH (NOLOCK) ON tf.IdCuenta = c.IdCuenta
			WHERE tf.IdEstatus = 1 AND tf.Fecha <= @FIN
			GROUP BY c.IdProductoFinanciero, c.IdSocio, s.IdPersona, pe.EsPersonaMoral, s.IdSucursal) AS tmp
	JOIN dbo.tHSTsocios hst ON hst.IdSocio = tmp.IdSocio AND hst.IdPeriodo = @IdPeriodo
	WHERE tmp.Total > 0 AND tmp.IdSocio > 0 AND hst.CertificadoAportacionExcedente = 0;
	

	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion,    TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento , EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor , Otros, Fallecido )

	SELECT DISTINCT d.idperiodo, s.IdSocio, s.IdPersona, 0, 0, 0, 0, 0, 
			s.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 0, 0, 0, 0, 0, 1, s.FechaAlta, 0, 0, EsPersonaMoral, 0, '', 1, 0
	FROM dbo.tAYCcuentas c						WITH (NOLOCK)
	JOIN dbo.tSDOhistorialDeudoras d			WITH (NOLOCK) ON d.IdCuenta = c.IdCuenta
	JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
			JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
	WHERE IdPeriodo = @IdPeriodo AND d.IdEstatus IN (1,7,53)
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst WITH (NOLOCK) 
						WHERE hst.IdPeriodo = d.idperiodo AND hst.IdSocio = s.IdSocio);


	INSERT INTO dbo.tHSTsocios	( IdPeriodo, IdSocio, IdPersona, TieneCertificadoAportacion,    TieneSeguro, TieneGastosFunerarios, CertificadoAportacion, Edad, 
								  IdSucursal, IdEstatusSeguro, AltaSeguro, BajaSeguro, Vigente, Pagado, Vencimiento , EsSocio, EsPreSocio, EsMenor, EsAdolescente, Alta, IdEstatus , 
								  FechaIngreso, CertificadoAportacionExcedente, PreSocios, EsPersonaMoral, IdPersonaPadreTutor, IdentificadorPadreTutor , Otros, Fallecido )

	SELECT DISTINCT d.idperiodo, s.IdSocio, s.IdPersona, 0, 0, 0, 0, 0, 
			s.IdSucursal, 0, 0, 0, 0, '19000101', '19000101', 0, 0, 0, 0, 0, 1, s.FechaAlta, 0, 0, EsPersonaMoral, 0, '', 1, 0
	FROM dbo.tAYCcuentas c						WITH (NOLOCK)
	JOIN dbo.tSDOhistorialAcreedoras d			WITH (NOLOCK) ON d.IdCuenta = c.IdCuenta
	JOIN dbo.tSCSsocios s						WITH (NOLOCK) ON s.IdSocio = c.IdSocio
			JOIN dbo.tGRLpersonas pe					WITH (NOLOCK) ON pe.IdPersona = s.IdPersona
	WHERE IdPeriodo = @IdPeriodo AND d.IdEstatus IN (1,7,53)
	AND NOT EXISTS (	SELECT *
						FROM dbo.tHSTsocios hst WITH (NOLOCK) 
						WHERE hst.IdPeriodo = d.idperiodo AND hst.IdSocio = s.IdSocio);
	UPDATE h SET Edad = dbo.fGRLcalcularEdad( pf.FechaNacimiento, @Fin)
	FROM dbo.tHSTsocios h
	JOIN dbo.tGRLpersonas p ON p.IdPersona = h.IdPersona
	JOIN dbo.tGRLpersonasFisicas pf ON pf.IdPersonaFisica = p.IdPersona
	WHERE IdPeriodo = @IdPeriodo AND h.Edad = 0;



