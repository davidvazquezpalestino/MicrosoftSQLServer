declare @Fecha as date = '20190929'

IF OBJECT_ID(N'tempdb.dbo.#Cartera', N'U') IS NOT NULL
	DROP TABLE tempdb.dbo.#Cartera;
CREATE TABLE #Cartera ( [TipoOperacion] varchar(64), [NumeroParcialidad] INT, [FechaPago] date, [CapitalExigible] DECIMAL(18, 2), [CapitalAlDia] DECIMAL(18, 2), [InteresOrdinarioTotal] DECIMAL(18, 2), [InteresMoratorioTotal] DECIMAL(18, 2), [Total] DECIMAL(18, 2), [Capital] DECIMAL(18, 2), [SaldoTotal] DECIMAL(18, 2), [CargosTotal] DECIMAL(18, 2), [Dias] DECIMAL(18, 2), [DiasMora] DECIMAL(18, 2), [MoraMaxima] DECIMAL(18, 2), [TotalAtrasado] DECIMAL(18, 2), [IdCuenta] INT );


DECLARE @SqlCommand AS nvarchar (400);
DECLARE ForEach CURSOR FOR

	SELECT CONCAT('EXEC [dbo].[pAYCcalcularInteresDeudoresPROY] @IdCuenta = ',  cuenta.IdCuenta,', @FechaTrabajo = ''', @Fecha,'''')
	FROM PagoCreditos Pago WITH (NOLOCK)
	INNER JOIN  vAYCaperturaCuentas  cuenta on pago.Cuenta = cuenta.Cuenta

OPEN ForEach
FETCH NEXT FROM ForEach INTO @SqlCommand
WHILE @@fetch_status = 0
BEGIN
    
	INSERT INTO #Cartera
	EXECUTE (@SqlCommand)      

FETCH NEXT FROM ForEach INTO @SqlCommand
END
CLOSE ForEach
DEALLOCATE ForEach;


SELECT Socio, Nombre, Cuenta, CuentaDescripcion, CapitalAlDia
FROM #Cartera car with (nolock)
INNER JOIN vAYCcuentaBasica cuen with (nolock) on car.IdCuenta = cuen.IdCuenta
WHERE CapitalAlDia > 0