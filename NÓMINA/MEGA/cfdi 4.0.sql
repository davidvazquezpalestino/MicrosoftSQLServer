SET QUOTED_IDENTIFIER ON;

SET ANSI_NULLS ON;
GO


ALTER PROCEDURE dbo.pNOMcomprobantesFiscalesNomina
    @Operacion VARCHAR(5),
    @IdCalculoE INT = 0,
    @IdNomina INT = 0,
    @IdSerie INT = 0
AS
BEGIN
    IF @Operacion = 'C'
    BEGIN
        DECLARE @NumeroFolio INT = 0;
        DECLARE @Serie VARCHAR(12);

        SELECT @NumeroFolio = MAX (Folio)
        FROM dbo.tIMPcomprobantesFiscales
        WHERE IdTipoDComprobante = 902;

        SELECT @Serie = Serie
        FROM dbo.tCTLseries
        WHERE IdSerie = @IdSerie;

        DECLARE @IdTipoDclasificacionNomina INT = 0;

        SELECT @IdTipoDclasificacionNomina = TipoNomina.IdTipoDclasificacionNomina
        FROM dbo.tNOMcalculosE Calculo WITH (NOLOCK)
        INNER JOIN dbo.tNOMtiposNominas TipoNomina ON TipoNomina.IdTipoNomina = Calculo.IdTipoNomina
        WHERE IdCalculoE = @IdCalculoE;

        /*====================================================================================
				1.- SE REGISTRAN LOS COMPROBANTES FISCALES.
		 =====================================================================================*/
        INSERT INTO dbo.tIMPcomprobantesFiscales (IdEmpresa, Folio, IdPersona, IdNomina, Importe, Descuento, Subtotal, Impuestos, ImpuestosRetenidos, Total, NombreEmisor, RFCEmisor, NombreReceptor, RFCReceptor, ReceptorCURP, RegimenFiscal, Serie, Email, IdSATregimenFiscal, EmisorCodigoPostal)
        SELECT IdEmpresa = MAX (Empresa.IdEmpresaNomina),
               Folio = ISNULL (@NumeroFolio, 0) + ROW_NUMBER () OVER (ORDER BY Empleado.IdEmpleado),
               IdPersona = MAX (Empleado.IdPersonaFisica),
               IdNomina = @IdNomina,
               Importe = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago IN (2687, 2689) THEN -- PERCEPCIÓNES / OTROS PAGOS
                                        Calculo.ImporteGravado + Calculo.ImporteExento
                                   ELSE 0
                              END),
               Descuento = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688 THEN -- DEDUCCIONES
                                          ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                                     ELSE 0
                                END),
               Subtotal = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago IN (2687, 2689) THEN -- PERCEPCIÓNES / OTROS PAGOS
                                         Calculo.ImporteGravado + Calculo.ImporteExento
                                    ELSE 0
                               END),
               Impuestos = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688
                                          AND BienServicio.IdBienServicio = -38 THEN -- DEDUCCIÓN
                                          Calculo.ImporteGravado + Calculo.ImporteExento
                                     ELSE 0
                                END),
               ImpuestosRetenidos = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688
                                                   AND BienServicio.IdBienServicio = -38 THEN -- DEDUCCIÓN
                                                   Calculo.ImporteGravado + Calculo.ImporteExento
                                              ELSE 0
                                         END),
               Total = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago IN (2687, 2689) THEN -- PERCEPCIÓNES / OTROS PAGOS
                                      Calculo.ImporteGravado + Calculo.ImporteExento
                                 ELSE 0
                            END) - SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688 THEN -- DEDUCCIONES
                                                  ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                                             ELSE 0
                                        END),
               NombreEmisor = MAX (Empresa.RazonSocial),
               RFCemisor = MAX (Empresa.RFC),
               NombreReceptor = MAX (Persona.Nombre),
               RFCreceptor = MAX (Persona.RFC),
               ReceptorCurp = MAX (PersonaFisica.CURP),
               RegimenFiscal = MAX (RegimenFiscal.RegimenFiscal),
               Serie = @Serie,
               Mail = MAX (ISNULL (Mail.Emails, '')),
               IdSATregimenFiscal = MAX (Empresa.IdRegimenFiscal),
               EmisorCodigoPostal = MAX (Empresa.CodigoPostal)
        FROM dbo.tNOMcalculos Calculo WITH (NOLOCK)
        INNER JOIN dbo.tPERempleados Empleado WITH (NOLOCK) ON Empleado.IdEmpleado = Calculo.IdEmpleado
        INNER JOIN dbo.tGRLpersonasFisicas PersonaFisica WITH (NOLOCK) ON PersonaFisica.IdPersonaFisica = Empleado.IdPersonaFisica
        INNER JOIN dbo.tGRLpersonas Persona WITH (NOLOCK) ON Persona.IdPersona = PersonaFisica.IdPersona
        INNER JOIN dbo.tNOMcalculosE CalculoE WITH (NOLOCK) ON CalculoE.IdCalculoE = Calculo.IdCalculoE
        INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = Calculo.IdBienServicio
        INNER JOIN dbo.tNOMempresas Empresa WITH (NOLOCK) ON Empresa.IdEmpresaNomina = CalculoE.IdEmpresaNomina
        INNER JOIN dbo.tSATregimenFiscal RegimenFiscal WITH (NOLOCK) ON Empresa.IdRegimenFiscal = RegimenFiscal.IdSATregimenFiscal
        LEFT JOIN dbo.vCATEmailsAgrupados Mail WITH (NOLOCK) ON Persona.IdRelEmails = Mail.IdRel
        LEFT JOIN dbo.tNOMnominas Nomina WITH (NOLOCK) ON Nomina.IdCalculoE = CalculoE.IdCalculoE
        LEFT JOIN dbo.tIMPcomprobantesFiscales Comprobante WITH (NOLOCK) ON Comprobante.IdNomina = Nomina.IdNomina
                                                                            AND Comprobante.IdPersona = Persona.IdPersona
        WHERE BienServicio.IdTipoD = 1452
              AND Calculo.IdCalculoE = @IdCalculoE
              AND Comprobante.IdComprobante IS NULL
        GROUP BY Empleado.IdEmpleado
        ORDER BY Empleado.IdEmpleado;

        UPDATE Comprobante
        SET TipoComprobante = 'N',
            Version = '4.0',
            IdSATformaPago = 20,
            FormaPago = '99',
            IdUsoCfdi = 25,
            IdSATmetodoPago = 1,
            MetodoPago = 'PUE',
            IdTipoDComprobante = 902,
            Fecha = CURRENT_TIMESTAMP,
            FechaHora = CURRENT_TIMESTAMP,
            IdComplemento = 13,
            Exportacion = '01',
            RegimenFiscalReceptor = '605',
            CodigoDivisa = 'MXN',
            IdDivisa = 1,
            TipoCambio = 1,
            Comprobante.ReceptorCodigoPostal = ISNULL (Domicilio.CodigoPostal, '05120'),
            IdEstatus = 1
        FROM dbo.tIMPcomprobantesFiscales Comprobante WITH (NOLOCK)
        INNER JOIN dbo.tGRLpersonas Persona WITH (NOLOCK) ON Persona.IdPersona = Comprobante.IdPersona
        LEFT JOIN dbo.tCATdomicilios Domicilio WITH (NOLOCK) ON Persona.IdRelDomicilios = Domicilio.IdRel
        WHERE IdNomina = @IdNomina;

        /*====================================================================================
			2.- SE REGISTRAN LOS DETALLES DEL COMPROBANTE.
		  ===================================================================================== */
        INSERT INTO dbo.tIMPcomprobantesFiscalesD (IdComprobante, Partida, Cantidad, UDM, Descripcion, PrecioUnitario, Importe, ISRretencion, MontoDescuento, IdProductoServicio, IdUnidadMedida, ObjetoImpuesto)
        SELECT Comprobante.IdComprobante,
               Partida = 1,
               Cantidad = 1,
               UDM = 'ACT',
               Descripcion = 'Pago de nómina',
               PrecioUnitario = Comprobante.Importe, ----total percepciones +total otros pagos
               Importe = Comprobante.Importe, ---total percepciones + total otros pagos
               ISRretencion = Comprobante.ImpuestosRetenidos,
               MontoDescuento = Comprobante.Descuento, ---total deducciones =total otras deducciones+totalImpuestos retenidos
               IdProductoServicio = 51541, --Servicios de contabilidad de sueldos y salarios
               IdUnidadMedida = 1358, --Unidad de recuento para definir el número de actividades (actividad: una unidad de trabajo o acción).
               ObjetoImpuesto = '01' --Atributo requerido para expresar si la operación comercial es objeto o no de impuesto
        FROM dbo.tIMPcomprobantesFiscales Comprobante (NOLOCK)
        LEFT JOIN dbo.tIMPcomprobantesFiscalesD ComprobanteD WITH (NOLOCK) ON ComprobanteD.IdComprobante = Comprobante.IdComprobante
        WHERE Comprobante.IdNomina = @IdNomina
              AND Comprobante.IdComprobante <> 0
              AND ComprobanteD.IdComprobanteD IS NULL
        ORDER BY Comprobante.IdComprobante;

        /*====================================================================================
		3.- SE REGISTRA LA RELACION DE PERCEPCIONES DEDUCCIONES A LAS NÓMINA Y EL COMPROBANTE FISCAL.
		  ===================================================================================== */
        INSERT INTO dbo.tNOMnominasPercepcionesDeducciones (IdNomina, IdEmpleado, IdEmpresaNomina, IdBienServicio, EsPercepcion, PercepcionDeduccion, Concepto, IdTipoDpercepcionDeduccion, ImporteGravado, ImporteExento, Importe, Otros, IdCuentaABCD, IdAuxiliar, IdDivision, Orden, IdComprobante)
        SELECT Nomina.IdNomina,
               Calculo.IdEmpleado,
               CalculoE.IdEmpresaNomina,
               Calculo.IdBienServicio,
               BienServicio.EsPercepcion,
               BienServicio.Codigo,
               BienServicio.Descripcion,
               BienServicio.IdTipoDpercepcionDeduccion,
               Calculo.ImporteGravado,
               Calculo.ImporteExento,
               Importe = CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688 THEN -- DEDUCCIÓN
                                   ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                              ELSE 0
                         END,
               --APLICA PARA SUBSIDIO, PRESTAMOS Y VIATICOS
               Otros = CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2689 THEN -- OTROS PAGOS
                                 ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                            ELSE 0
                       END,
               BienServicio.IdCuentaABCD,
               BienServicio.IdAuxiliar,
               BienServicio.IdDivision,
               Orden = ROW_NUMBER () OVER (ORDER BY Calculo.IdEmpleado,
                                                    CASE BienServicio.IdTipoDpercepcionDeduccionPago WHEN 2687 THEN -- PERCEPCIÓN
                                                                                                          1
                                                                                                     WHEN 2688 THEN -- DEDUCCIÓN
                                                                                                          2
                                                                                                     WHEN 2689 THEN -- OTRO PAGO
                                                                                                          3
                                                                                                     ELSE 4 -- OTRO
                                                    END,
                                                    Calculo.IdBienServicio),
               ComprobanteFiscal.IdComprobante
        FROM dbo.tNOMcalculos Calculo WITH (NOLOCK)
        INNER JOIN dbo.tNOMcalculosE CalculoE WITH (NOLOCK) ON CalculoE.IdCalculoE = Calculo.IdCalculoE
        INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = Calculo.IdBienServicio
        INNER JOIN dbo.tNOMnominas Nomina WITH (NOLOCK) ON Nomina.IdCalculoE = Calculo.IdCalculoE
        INNER JOIN dbo.tIMPcomprobantesFiscales ComprobanteFiscal WITH (NOLOCK) ON ComprobanteFiscal.IdNomina = Nomina.IdNomina
        INNER JOIN dbo.tPERempleados Empleado ON Empleado.IdEmpleado = Calculo.IdEmpleado
                                                 AND ComprobanteFiscal.IdPersona = Empleado.IdPersonaFisica
        WHERE BienServicio.IdTipoD = 1452
              AND Calculo.IdCalculoE = @IdCalculoE
        ORDER BY ComprobanteFiscal.IdComprobante;

        /*COMPLEMENTO NOMINA*/
        INSERT INTO dbo.tFELcomplementosNomina (IdComprobante, IdNomina, Version, RegistroPatronal, NumEmpleado, CURP, TipoRegimen, NumSeguridadSocial, FechaPago, FechaInicialPago, FechaFinalPago, NumDiasPagados, Departamento, CLABE, Banco, FechaInicioRelLaboral, Puesto, TipoContrato, TipoJornada, PeriodicidadPago, SalarioBaseCotApor, RiesgoPuesto, SalarioDiario, SalarioDiarioIntegrado, PercepcionesGravadas, PercepcionesExentas, DeduccionesGravadas, DeduccionesExentas, ISRretenido, TipoNomina, TotalDeducciones, TotalOtroPago, TotalPercepciones, ClaveEntidadFederativa, Sindicalizado, IdEmpleado)
        SELECT ComplementoNomina.IdComprobante,
               ComplementoNomina.IdNomina,
               Version = '1.2',
               ComplementoNomina.RegistroPatronal,
               ComplementoNomina.NumEmpleado,
               ComplementoNomina.CURP,
               ComplementoNomina.TipoRegimen,
               ComplementoNomina.NumeroSeguridadSocial,
               ComplementoNomina.FechaPago,
               ComplementoNomina.FechaInicialPago,
               ComplementoNomina.FechaFinalPago,
               ComplementoNomina.NumDiasPagados,
               ComplementoNomina.Departamento,
               ComplementoNomina.CLABE,
               ComplementoNomina.Banco,
               ComplementoNomina.FechaInicioRelLaboral,
               ComplementoNomina.Puesto,
               ComplementoNomina.TipoContrato,
               ComplementoNomina.TipoJornada,
               ComplementoNomina.PeriodicidadPago,
               ComplementoNomina.SalarioBaseCotApor,
               ComplementoNomina.RiesgoPuesto,
               ComplementoNomina.SalarioDiario,
               ComplementoNomina.SDI,
               OtroPago.PercepcionesGravadas,
               OtroPago.PercepcionesExentas,
               OtroPago.DeduccionesGravadas,
               OtroPago.DeduccionesExentas,
               ComplementoNomina.ISRretenido,
               ComplementoNomina.TipoNomina,
               OtroPago.TotalDeducciones,
               OtroPago.TotalOtroPago,
               OtroPago.TotalPercepciones,
               ComplementoNomina.ClaveEntidadFederativa,
               ComplementoNomina.Sindicalizado,
               ComplementoNomina.IdEmpleado
        FROM dbo.vCOMempleadosNomina ComplementoNomina
        INNER JOIN (SELECT IdEmpleado,
                           IdNomina,
                           PercepcionesGravadas,
                           PercepcionesExentas,
                           DeduccionesGravadas,
                           DeduccionesExentas,
                           TotalDeducciones,
                           TotalPercepciones,
                           TotalOtroPago
                    FROM dbo.vCOMdeduccionesPercepcionesOtrosPagos) AS OtroPago ON OtroPago.IdNomina = ComplementoNomina.IdNomina
                                                                                   AND OtroPago.IdEmpleado = ComplementoNomina.IdEmpleado
        WHERE ComplementoNomina.IdNomina = @IdNomina
              AND NOT EXISTS (SELECT 1
                              FROM dbo.tFELcomplementosNomina cn WITH (NOLOCK)
                              WHERE cn.IdComprobante = ComplementoNomina.IdComprobante)
        ORDER BY ComplementoNomina.IdComprobante;

        /*PERCEPCIONES*/
        INSERT INTO dbo.tFELpercepciones (IdComplementoNomina, TotalSueldos, TotalGravado, TotalExento)
        SELECT IdComplementoNomina,
               TotalPercepciones,
               PercepcionesGravadas,
               PercepcionesExentas
        FROM dbo.tFELcomplementosNomina ComplementoNomina WITH (NOLOCK)
        WHERE IdNomina = @IdNomina
              AND NOT EXISTS (SELECT 1
                              FROM dbo.tFELpercepciones Percepciones WITH (NOLOCK)
                              WHERE Percepciones.IdComplementoNomina = ComplementoNomina.IdComplementoNomina)
        ORDER BY ComplementoNomina.IdComplementoNomina;

        --DEDUCCIONES
        INSERT INTO dbo.tFELdeducciones (IdComplementoNomina, TotalOtrasDeducciones, TotalImpuestosRetenidos)
        SELECT Complemento.IdComplementoNomina,
               TotalOtrasDeducciones = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688
                                                      AND BienServicio.IdBienServicio <> -38 THEN -- OTRAS DEDUCCIONES
                                                      PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                                 ELSE 0
                                            END),
               TotalImpuestosRetenidos = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688
                                                        AND BienServicio.IdBienServicio = -38 THEN -- IMPUESTOS RETENIDOS
                                                        PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                                   ELSE 0
                                              END)
        FROM dbo.tNOMnominas Nomina
        INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH (NOLOCK) ON PercepcionDeduccion.IdNomina = Nomina.IdNomina
        INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = PercepcionDeduccion.IdBienServicio
        INNER JOIN dbo.tFELcomplementosNomina Complemento WITH (NOLOCK) ON Complemento.IdNomina = Nomina.IdNomina
                                                                           AND Complemento.IdComprobante = PercepcionDeduccion.IdComprobante
        WHERE Nomina.IdNomina = @IdNomina
              AND NOT EXISTS (SELECT 1
                              FROM dbo.tFELdeducciones Deduccion WITH (NOLOCK)
                              WHERE Deduccion.IdComplementoNomina = Complemento.IdComplementoNomina)
        GROUP BY Complemento.IdComplementoNomina
        ORDER BY Complemento.IdComplementoNomina;

        /*OTROS PAGOS*/
        INSERT INTO dbo.tFELotrosPagos (IdComplementoNomina, Concepto, TipoOtroPago, Importe, Clave)
        SELECT Complemento.IdComplementoNomina,
               BienServicio.Descripcion,
               TipoOtroPago = TipoPercepcionDeduccion.Codigo,
               Importe = ISNULL (PercepcionDeduccion.Otros, 0),
               Clave = TipoPercepcionDeduccion.Codigo
        FROM dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion
        INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = PercepcionDeduccion.IdBienServicio
        INNER JOIN dbo.tCTLtiposD TipoPercepcionDeduccion WITH (NOLOCK) ON TipoPercepcionDeduccion.IdTipoD = BienServicio.IdTipoDpercepcionDeduccion
        INNER JOIN dbo.tIMPcomprobantesFiscales Comprobante WITH (NOLOCK) ON PercepcionDeduccion.IdComprobante = Comprobante.IdComprobante
        INNER JOIN dbo.tFELcomplementosNomina Complemento WITH (NOLOCK) ON Complemento.IdComprobante = Comprobante.IdComprobante
        WHERE PercepcionDeduccion.IdNomina = @IdNomina
              AND BienServicio.IdTipoDpercepcionDeduccionPago = 2689
              AND NOT EXISTS (SELECT 1
                              FROM dbo.tFELotrosPagos Pagos WITH (NOLOCK)
                              WHERE Pagos.IdComplementoNomina = Complemento.IdComplementoNomina)
        ORDER BY Complemento.IdComplementoNomina;

        -- NÓMINAS DE AGUINALDO, PTU, ASIMILADOS SE QUITA EL SUBSIDIO CAUSADO
        INSERT INTO dbo.tFELotrosPagos (IdComplementoNomina, Concepto, TipoOtroPago, Importe, Clave)
        SELECT Complemento.IdComplementoNomina,
               Concepto = 'SUBSIDIO PARA EL EMPLEO',
               TipoOtroPago = '002',
               Importe = CASE WHEN @IdTipoDclasificacionNomina IN (2774, 2775, 2776) THEN 0
                              ELSE Calculo.SUBE
                         END,
               Clave = '002'
        FROM dbo.tNOMnominas Nomina
        INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdNomina = Nomina.IdNomina
        INNER JOIN dbo.tNOMcalculosEmpleados Calculo ON Calculo.IdCalculoE = Nomina.IdCalculoE
                                                        AND Calculo.IdEmpleado = Complemento.IdEmpleado
        WHERE Nomina.IdNomina = @IdNomina
              AND NOT EXISTS (SELECT 1
                              FROM dbo.tFELotrosPagos Pago WITH (NOLOCK)
                              WHERE Pago.IdComplementoNomina = Complemento.IdComplementoNomina)
        ORDER BY Complemento.IdComplementoNomina;

        -- SUBSIDIO CAUSADO
        -- NÓMINAS DE AGUINALDO, PTU, ASIMILADOS SE QUITA EL SUBSIDIO CAUSADO
        INSERT INTO dbo.tFELsubsidioAlEmpleo (IdOtroPago, SubsidioCausado)
        SELECT Pago.IdOtroPago,
               SubsidioCausado = CASE WHEN @IdTipoDclasificacionNomina IN (2774, 2775, 2776) THEN 0
                                      ELSE Calculo.SubsidioCausado
                                 END
        FROM dbo.tNOMnominas Nomina
        INNER JOIN dbo.tNOMcalculosEmpleados Calculo WITH (NOLOCK) ON Calculo.IdCalculoE = Nomina.IdCalculoE
        INNER JOIN dbo.tFELcomplementosNomina Complemento WITH (NOLOCK) ON Complemento.IdNomina = Nomina.IdNomina
                                                                           AND Complemento.IdEmpleado = Calculo.IdEmpleado
        INNER JOIN dbo.tFELotrosPagos Pago WITH (NOLOCK) ON Pago.IdComplementoNomina = Complemento.IdComplementoNomina
        WHERE Nomina.IdNomina = @IdNomina
              AND Pago.Clave = '002'
              AND NOT EXISTS (SELECT 1
                              FROM dbo.tFELsubsidioAlEmpleo s
                              WHERE s.IdOtroPago = Pago.IdOtroPago)
        ORDER BY Pago.IdOtroPago;
    END;

    IF @Operacion = 'R'
    BEGIN
        CREATE TABLE #Nomina
        (
            [IdEmpleado] INT PRIMARY KEY,
            [IdNomina] INT NULL,
            [Percepciones] DECIMAL(18, 8) NULL,
            [Deducciones] DECIMAL(18, 2) NULL,
            [Total] DECIMAL(18, 2) NULL
        );

        INSERT INTO #Nomina (IdNomina, IdEmpleado, Percepciones, Deducciones, Total)
        SELECT PercepcionDeduccion.IdNomina,
               PercepcionDeduccion.IdEmpleado,
               Percepciones = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago IN (2687, 2689) THEN -- PERCEPCIONES
                                             PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                        ELSE 0
                                   END),
               Deducciones = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688 THEN -- DEDUCCIONES
                                            PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                       ELSE 0
                                  END),
               Total = SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago IN (2687, 2689) THEN -- PERCEPCIONES
                                      PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                 ELSE 0
                            END) - SUM (CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688 THEN -- DEDUCCIONES
                                                  PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                             ELSE 0
                                        END)
        FROM dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion
        INNER JOIN dbo.tIMPcomprobantesFiscales Comprobante ON Comprobante.IdComprobante = PercepcionDeduccion.IdComprobante
        INNER JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = PercepcionDeduccion.IdBienServicio
        WHERE Comprobante.IdEstatus = 1
              AND PercepcionDeduccion.IdNomina = @IdNomina
        GROUP BY PercepcionDeduccion.IdNomina,
                 PercepcionDeduccion.IdEmpleado;

        SELECT Nomina.IdCalculoE,
               tempNomina.IdEmpleado,
               Sucursal = Sucursal.Descripcion,
               [Código] = Empleado.Codigo,
               Persona.RFC,
               Persona.Nombre,
               Empleado.FechaIngreso,
               Puesto = Puesto.Descripcion,
               Departamento = Departamento.Descripcion,
               tempNomina.Percepciones,
               tempNomina.Deducciones,
               tempNomina.Total
        FROM #Nomina tempNomina
        INNER JOIN dbo.tPERempleados Empleado ON Empleado.IdEmpleado = tempNomina.IdEmpleado
        INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersonaFisica = Empleado.IdPersonaFisica
        INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = Empleado.IdSucursal
        INNER JOIN dbo.tPERpuestos Puesto ON Puesto.IdPuesto = Empleado.IdPuesto
        INNER JOIN dbo.tPERdepartamentos Departamento ON Departamento.IdDepartamento = Puesto.IdDepartamento
        INNER JOIN dbo.tNOMnominas Nomina ON Nomina.IdNomina = tempNomina.IdNomina
        ORDER BY TRY_CAST(Empleado.Codigo AS INT);
    END;
END;
GO


SET QUOTED_IDENTIFIER ON;

SET ANSI_NULLS ON;
GO


--[pLSTdatosEncabezado]------------------------------------------------------------------------------------------------------------------------
ALTER PROC [dbo].[pLSTdatosEncabezado]
    @IdFactura AS INT = 0,
    @Serie AS VARCHAR(10) = '',
    @Folio INT = 0
AS
IF @IdFactura <> 0
BEGIN
    SELECT IdComprobante,
           id_cli = IdEmisor,
           IdRFCreceptor = IdReceptor,
           Version,
           Folio,
           Serie,
           Fecha,
           TipoDeComprobante = TipoComprobante,
           IdComplemento,
           Subtotal,
           Total,
           Moneda = CodigoDivisa,
           EmisorCodigoPostal,
           MetodoPago,
           FormaPago,
           TipoCambio,
           Descuento,
           condicionesDePago = CondicionesPago,
           Exportacion
    FROM dbo.tIMPcomprobantesFiscales
    WHERE IdComprobante = @IdFactura;
END;

IF @Serie <> ''
   AND @Folio <> 0
BEGIN
    SELECT e.id_fact,
           e.Version,
           e.Serie,
           e.Folio,
           e.Fecha,
           e.FechaHora,
           e.FormaPago,
           e.CondicionesDePago,
           e.SubTotal,
           e.Descuento,
           e.MotivoDescuento,
           e.TipoCambio,
           e.IdMoneda,
           e.Moneda,
           e.Total,
           e.tipoDeComprobante,
           e.tipoMetodoPago,
           e.metodoPago,
           e.LugarExpedicion,
           e.NumCtaPago,
           e.FolioFiscalOrig,
           e.SerieFolioFiscalOrig,
           e.FechaFolioFiscalOrig,
           e.MontoFolioFiscalOrig,
           e.DomicilioExpedicion,
           e.RFCEmisor,
           e.NombreEmisor,
           e.calleEmisor,
           e.noExteriorEmisor,
           e.noInteriorEmisor,
           e.coloniaEmisor,
           e.localidadEmisor,
           e.referenciaEmisor,
           e.municipioEmisor,
           e.estadoEmisor,
           e.paisEmisor,
           e.codigoPostalEmisor,
           e.RegimenFiscal,
           e.EmisorTelefonos,
           e.EmisorLogo,
           e.EmisorCURP,
           e.EmisorIdFormatoNomina,
           e.EmisorIdFormatoComprobante,
           e.EmisorGenerarPDF,
           e.calleEmision,
           e.noExteriorEmision,
           e.noInteriorEmision,
           e.coloniaEmision,
           e.localidadEmision,
           e.referenciaEmision,
           e.municipioEmision,
           e.estadoEmision,
           e.paisEmision,
           e.codigoPostalEmision,
           e.IdRFCreceptor,
           e.RFCreceptor,
           e.nombreReceptor,
           e.calleReceptor,
           e.noExteriorReceptor,
           e.noInteriorReceptor,
           e.coloniaReceptor,
           e.localidadReceptor,
           e.referenciaReceptor,
           e.municipioReceptor,
           e.estadoReceptor,
           e.paisReceptor,
           e.codigoPostalReceptor,
           e.ReceptorTelefonos,
           e.ReceptorCURP,
           e.ReceptorDomicilio,
           e.cantidad,
           e.unidad,
           e.noIdentificacion,
           e.descripcion,
           e.valorUnitario,
           e.Importe,
           e.numeroInfoAduanera,
           e.fechaInfoAduanera,
           e.aduanaInfoAduanera,
           e.totalImpuestosRetenidos,
           e.totalImpuestosTrasladados,
           e.impuestoRetenido,
           e.importeRetenido,
           e.impuestoTrasladado,
           e.tasaTrasladado,
           e.importeTrasladado,
           e.TipoDocumento,
           e.numero,
           e.id_status,
           e.id_cli,
           e.CorreoElectronico,
           e.IdRFCemisor,
           e.TipoComprobanteInterno,
           e.FormatoFactura,
           e.DecimalesPrecio,
           e.DecimalesCantidad,
           EmisorNombreComercial,
           ReceptorNombreComercial,
           e.Leyenda1,
           e.Leyenda2,
           CodigoPostalLugarExpedicion,
           IdOperacion
    FROM vInformacionCFDI e WITH (NOLOCK)
    WHERE e.Serie = @Serie
          AND e.Folio = @Folio;
END;
GO


ALTER PROC [dbo].[pLSTdatosReceptor]
    @IdCliente AS INT = 0,
    @IdComprobante AS INT = 0
AS
BEGIN
    SELECT RFCReceptor,
           NombreReceptor,
           ReceptorCodigoPostal,
           RegimenFiscalReceptor,
           Uso.UsoCFDI,
           ResidenciaFiscal = '',
           NumeroRegistroIdTributario = ''
    FROM dbo.tIMPcomprobantesFiscales Comprobante WITH (NOLOCK)
    INNER JOIN dbo.tSATusoCFDI Uso WITH (NOLOCK) ON Comprobante.IdUsoCfdi = Uso.IdSATusoCFDI
    WHERE IdComprobante = @IdComprobante;
END;
GO


SET QUOTED_IDENTIFIER ON;

SET ANSI_NULLS ON;
GO


ALTER VIEW [dbo].[vInformacionCFDiConceptos]
AS
SELECT Concepto.IdComprobanteD,
       Concepto.IdComplemento,
       Concepto.Cantidad,
       Concepto.UDM AS unidad,
       Concepto.Codigo AS noIdentificacion,
       Concepto.Descripcion,
       Concepto.PrecioUnitario AS valorUnitario,
       Concepto.Importe,
       Concepto.Subtotal,
       Concepto.IdComprobante AS id_fac,
       Concepto.IVA AS monto_iva,
       0 AS monto_iva_bse,
       0 AS tasa,
       0 AS Propina,
       Concepto.IdComprobanteDOrigen AS id_part_pad,
       Concepto.IdComprobanteD AS IdPartida,
       Concepto.Notas,
       Concepto.NumeroIdentificacion,
       Concepto.MontoDescuento,
       ProductoServicio.ClaveProductoServicio,
       unidadMedida.ClaveUnidad,
       ProductoServicioDescripcion = CONCAT (ProductoServicio.ClaveProductoServicio, ' - ', ProductoServicio.Descripcion),
       ClaveUnidadDescripcion = CONCAT (unidadMedida.ClaveUnidad, ' - ', unidadMedida.Nombre),
       Concepto.ObjetoImpuesto
FROM tIMPcomprobantesFiscalesD Concepto WITH (NOLOCK)
INNER JOIN dbo.tIMPcomprobantesFiscales Comprobante WITH (NOLOCK) ON Comprobante.IdComprobante = Concepto.IdComprobante
LEFT JOIN dbo.tSATproductosServicios ProductoServicio ON ProductoServicio.IdSATproductoServicio = Concepto.IdProductoServicio
LEFT JOIN dbo.tSATunidadesMedida unidadMedida ON Concepto.IdUnidadMedida = unidadMedida.IdSATunidadMedida;
GO


--[pLSTdatosConceptos]------------------------------------------------------------------------------------------------------------------------
ALTER PROC [dbo].[pLSTdatosConceptos]
    @TipoOperacion AS VARCHAR(10) = 'LST',
    @IdFactura AS INT = 0,
    @IdPartida AS INT = 0
AS
IF @TipoOperacion = 'LST'
BEGIN
    SELECT IdComprobanteD,
           IdComplemento,
           Cantidad,
           unidad,
           noIdentificacion,
           Descripcion,
           valorUnitario,
           Importe,
           id_fac,
           monto_iva,
           monto_iva_bse,
           tasa,
           Propina,
           [IdPartida],
           Notas,
           NumeroIdentificacion,
           MontoDescuento,
           ClaveProductoServicio,
           ClaveUnidad,
           ObjetoImpuesto
    FROM vInformacionCFDiConceptos
    WHERE id_fac = @IdFactura;
END;

IF @TipoOperacion = 'LSTPART'
BEGIN
    SELECT IdComprobanteD,
           IdComplemento,
           Cantidad,
           unidad,
           noIdentificacion,
           Descripcion,
           valorUnitario,
           Importe,
           id_fac,
           monto_iva,
           monto_iva_bse,
           tasa,
           Propina,
           [id_part_pad],
           [IdPartida],
           Notas,
           MontoDescuento,
           ClaveProductoServicio,
           ClaveUnidad,
           ObjetoImpuesto
    FROM vInformacionCFDiConceptos
    WHERE [id_part_pad] = @IdPartida
          AND id_part_pad != 0;
END;
GO