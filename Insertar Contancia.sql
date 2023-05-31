WITH Emisor --EMISOR	
AS (   SELECT IdEmpresa=Empresa.IdEmpresa, IdEmisorProveedor=Proveedor.IdEmisorProveedor, NombreEmisor=Persona.Nombre, RFCEmisor=Persona.RFC
       FROM dbo.tGRLpersonas Persona WITH ( NOLOCK )
       INNER JOIN dbo.tCTLempresas Empresa WITH ( NOLOCK ) ON Empresa.IdPersona=Persona.IdPersona
       INNER JOIN dbo.tSCSemisoresProveedores Proveedor WITH ( NOLOCK ) ON Proveedor.IdPersona=Empresa.IdPersona
       INNER JOIN dbo.tSATregimenFiscal RegimenFiscal WITH ( NOLOCK ) ON RegimenFiscal.IdSATregimenFiscal=Empresa.IdRegimenFiscal
       WHERE Empresa.IdEmpresa=1 ),
     constanciaRetenciones
AS ( SELECT IdEmpresa=1, Version='1.0', Folio=1, FechaExpedicion=CURRENT_TIMESTAMP, Clave='16', Descripcion='Intereses' )



SELECT Y.IdEmpresa, 
       Emisor.NombreEmisor,
	   Emisor.RFCEmisor,
	  
	   Nacionalidad='Nacional',
       ReceptorNombre = receptor.NombreCompleto,
	   ReceptorCURP = receptor.CURP,
	   ReceptorRFC = receptor.RFC,
       

       Y.Ejercicio,
       Y.PeriodoInicial,
       Y.PeriodoFinal,

       MontoTotalRetenido = Y.MontoRetenido,
	   Y.MontoExento,
       Y.MontoGravado,

	   MontoOperacion = Y.MontoInversion,

       Y.TasaRetencionISR,
       Y.BaseExenta,
       Y.SaldoCapital,
         
     
       Y.DiasInversion,
       Y.InteresNominal,
       Y.InteresReal,
       
	   Base = MontoGravado,
	   Y.Impuesto,
	   Y.MontoRetenido,
	   Y.TipoPago,

       Perdida=Y.InteresNominal-Y.InteresReal,
       OperacionesDerivadas='SI',
       Retiro='SI',
       SistemaFinanciero='SI',
       Version='1.0'

FROM ( SELECT IdEmpresa=1,
              x.IdPersona, 
              x.Nombre,
              x.InteresOrdinarioPagado,
              x.Ejercicio,
              x.PeriodoInicial,
              x.PeriodoFinal,
              Impuesto.TasaRetencionISR,
              x.BaseExenta,
              x.SaldoCapital,
              MontoExento=CASE WHEN x.MontoInversion>x.BaseExenta THEN x.BaseExenta
                               ELSE x.MontoInversion
                          END,
              MontoGravado=CASE WHEN x.MontoInversion>x.BaseExenta THEN x.MontoInversion-x.BaseExenta
                                ELSE 0
                           END,
              TipoPago='Pago Definitivo',
              MontoRetenido=x.RetencionISR,
              Impuesto='01',
              x.MontoInversion,
              x.DiasInversion,
              x.InteresNominal,
              x.InteresReal
       FROM ( SELECT s.IdPersona,
                     s.Nombre,
                     InteresOrdinarioPagado=SUM (tf.InteresOrdinarioPagado),
                     RetencionISR=SUM (tf.RetencionISR),
                     MontoInversion=SUM (InteresReal.MontoInvertido),
                     Ejercicio=YEAR (MAX (InteresReal.FechaInicial)),
                     PeriodoInicial=MONTH (MAX (InteresReal.FechaInicial)),
                     PeriodoFinal=MONTH (MAX (InteresReal.FechaFinal)),
                     BaseExenta=MAX (365 * 5 * salario.Salario),
                     InteresNominal=SUM (InteresReal.InteresNominal),
                     InteresReal=SUM (InteresReal.InteresReal),
                     DiasInversion=MAX (ISNULL (InteresReal.DiasInversion, 0)),
                     SaldoCapital=MAX (tf.SaldoCapital),
                     IdImpuesto=MAX (tf.IdImpuesto)
              FROM dbo.tSDOtransaccionesFinancieras tf
              INNER JOIN dbo.tAYCcuentas c WITH ( NOLOCK ) ON c.IdCuenta=tf.IdCuenta
              INNER JOIN dbo.vSCSsocios s WITH ( NOLOCK ) ON s.IdSocio=c.IdSocio
              INNER JOIN dbo.tSDOhistorialAcreedoras ha WITH ( NOLOCK ) ON ha.IdCuenta=c.IdCuenta AND ha.IdPeriodo=dbo.fObtenerIdPeriodo (tf.Fecha)
              INNER JOIN dbo.tCTLperiodos peri WITH ( NOLOCK ) ON peri.IdPeriodo=ha.IdPeriodo
              INNER JOIN dbo.tCTLejercicios eje WITH ( NOLOCK ) ON eje.IdEjercicio=peri.IdEjercicio
              INNER JOIN dbo.tTBLsalariosMinimos salario ON eje.Inicio BETWEEN salario.Inicio AND salario.Fin AND
                                                             eje.Fin BETWEEN salario.Inicio AND salario.Fin
              LEFT JOIN dbo.tAYCcalculoInteresesReales AS InteresReal ON InteresReal.IdCuenta=c.IdCuenta
              WHERE InteresOrdinarioPagado !=0 AND tf.IdEstatus=1 AND tf.RetencionISR>0 AND Fecha BETWEEN '20180101' AND '20181231' AND
                 NOT s.IdPersona IN ( 47681, 14, 47682, 47685 )
              GROUP BY s.IdPersona, s.Nombre ) AS x
	INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto=x.IdImpuesto ) AS Y
INNER JOIN constanciaRetenciones ON constanciaRetenciones.IdEmpresa=Y.IdEmpresa
INNER JOIN Emisor ON Emisor.IdEmpresa=Y.IdEmpresa
INNER JOIN dbo.vGRLpersonas receptor ON receptor.IdPersona = Y.IdPersona;
