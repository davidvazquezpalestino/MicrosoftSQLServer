CREATE OR ALTER PROCEDURE dbo.pCRUDprogramacionNomina
@TipoOperacion VARCHAR(5) = NULL, 
@IdProgramacion INT = 0 OUTPUT, 
@IdEmpresaNomina INT =  NULL, 
@Codigo VARCHAR(10) =  NULL, 
@IdTipoD INT = 0, 
@IdPeriodoNomina INT =  NULL, 
@IdEmpleado INT =  NULL, 
@IdBienServicio INT = 0, 
@FechaInicio DATE =  NULL, 
@FechaFin DATE =  NULL, 
@IdTipoDinfonavit INT =  NULL, 
@Infonavit VARCHAR(50) =  NULL, 
@Formula VARCHAR(MAX) =  NULL, 
@Limite NUMERIC(18, 4) =  NULL, 
@IdEstatus INT =  NULL, 
@IdSesion INT =  NULL
AS 
			
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	IF @TipoOperacion = 'C'
	BEGIN 
		INSERT INTO dbo.tNOMprogramacion (IdEmpresaNomina, IdTipoD, IdPeriodoNomina, IdEmpleado, IdBienServicio, FechaInicio, FechaFin, IdTipoDinfonavit, Infonavit, Formula, Limite, IdEstatus, IdSesion)
		VALUES(@IdEmpresaNomina, @IdTipoD, @IdPeriodoNomina, @IdEmpleado, @IdBienServicio, @FechaInicio, @FechaFin, @IdTipoDinfonavit, @Infonavit, @Formula, @Limite, @IdEstatus, @IdSesion)
		SET @IdProgramacion = SCOPE_IDENTITY()
	END

	IF @TipoOperacion = 'R'
	BEGIN
		SELECT  IdProgramacion, IdEmpresaNomina, Codigo, IdTipoD, IdPeriodoNomina, IdEmpleado, IdBienServicio, FechaInicio, FechaFin, IdTipoDinfonavit, Infonavit, Formula, Limite, IdEstatus, IdSesion
		FROM    dbo.tNOMprogramacion WITH (NOLOCK)
		WHERE   IdProgramacion = @IdProgramacion OR Codigo = @Codigo              
	END

	IF @TipoOperacion = 'U'
	BEGIN
		UPDATE dbo.tNOMprogramacion SET IdEmpresaNomina = @IdEmpresaNomina, Codigo = @Codigo, IdTipoD = @IdTipoD, IdPeriodoNomina = @IdPeriodoNomina, IdEmpleado = @IdEmpleado, IdBienServicio = @IdBienServicio, FechaInicio = @FechaInicio, FechaFin = @FechaFin, IdTipoDinfonavit = @IdTipoDinfonavit, Infonavit = @Infonavit, Formula = @Formula, Limite = @Limite, IdEstatus = @IdEstatus, IdSesion = @IdSesion
		FROM   dbo.tNOMprogramacion
		WHERE  IdProgramacion = @IdProgramacion 
	END

	IF @TipoOperacion = 'D'
	BEGIN
		UPDATE dbo.tNOMprogramacion SET IdEstatus = 2		
		FROM   dbo.tNOMprogramacion
		WHERE  IdProgramacion = @IdProgramacion
	END
END
GO
		
CREATE OR ALTER PROCEDURE dbo.pCRUDhorasExtras
@TipoOperacion VARCHAR(5) = NULL, 
@IdHoraExtra INT = 0 OUTPUT, 
@IdEmpresaNomina INT = 0, 
@IdPeriodoNomina INT =  NULL, 
@IdEmpleado INT =  NULL, 
@IdBienServicio INT =  NULL, 
@Semana INT =  NULL, 
@Dia INT =  NULL, 
@Turno INT =  NULL, 
@Horas NUMERIC(23, 8) =  NULL, 
@IdEstatus INT =  NULL, 
@IdSesion INT =  NULL
AS 
			
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	IF @TipoOperacion = 'C'
	BEGIN 
		INSERT INTO dbo.tNOMhorasExtras (IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Semana, Dia, Turno, Horas, IdEstatus, IdSesion)
		VALUES(@IdEmpresaNomina, @IdPeriodoNomina, @IdEmpleado, @IdBienServicio, @Semana, @Dia, @Turno, @Horas, @IdEstatus, @IdSesion)
		SET @IdHoraExtra = SCOPE_IDENTITY()
	END

	IF @TipoOperacion = 'R'
	BEGIN
		SELECT  IdHoraExtra, IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Semana, Dia, Turno, Horas, IdEstatus, IdSesion
		FROM    dbo.tNOMhorasExtras WITH (NOLOCK)
		WHERE   IdHoraExtra = @IdHoraExtra               
	END

	IF @TipoOperacion = 'U'
	BEGIN
		UPDATE dbo.tNOMhorasExtras SET IdEmpresaNomina = @IdEmpresaNomina, IdPeriodoNomina = @IdPeriodoNomina, IdEmpleado = @IdEmpleado, IdBienServicio = @IdBienServicio, Semana = @Semana, Dia = @Dia, Turno = @Turno, Horas = @Horas, IdEstatus = @IdEstatus, IdSesion = @IdSesion
		FROM   dbo.tNOMhorasExtras
		WHERE  IdHoraExtra = @IdHoraExtra 
	END

	IF @TipoOperacion = 'D'
	BEGIN
		UPDATE dbo.tNOMhorasExtras SET IdEstatus = 2		
		FROM   dbo.tNOMhorasExtras
		WHERE  IdHoraExtra = @IdHoraExtra
	END
END
GO


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
CREATE OR ALTER PROCEDURE dbo.pCRUDvacaciones
@TipoOperacion VARCHAR(5) = NULL, 
@IdVacacion INT = 0 OUTPUT, 
@IdEmpresaNomina INT = 0, 
@IdPeriodoNomina INT =  NULL, 
@IdEmpleado INT =  NULL, 
@IdBienServicio INT =  NULL, 
@Aniversario INT =  NULL, 
@PrimaVacacional NUMERIC(23, 8) =  NULL, 
@FechaInicio DATE =  NULL, 
@FechaFin DATE =  NULL, 
@Dias INT =  NULL, 
@IdEstatus INT =  NULL, 
@IdSesion INT =  NULL
AS 			
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	IF @TipoOperacion = 'C'
	BEGIN 
		INSERT INTO dbo.tNOMvacaciones (IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Aniversario, PrimaVacacional, FechaInicio, FechaFin, Dias, IdEstatus, IdSesion)
		VALUES(@IdEmpresaNomina, @IdPeriodoNomina, @IdEmpleado, @IdBienServicio, @Aniversario, @PrimaVacacional, @FechaInicio, @FechaFin, @Dias, @IdEstatus, @IdSesion)
		SET @IdVacacion = SCOPE_IDENTITY()
	END

	IF @TipoOperacion = 'R'
	BEGIN
		SELECT  IdVacacion, IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Aniversario, PrimaVacacional, FechaInicio, FechaFin, Dias, IdEstatus, IdSesion
		FROM    dbo.tNOMvacaciones WITH (NOLOCK)
		WHERE   IdVacacion = @IdVacacion               
	END

	IF @TipoOperacion = 'U'
	BEGIN
		UPDATE dbo.tNOMvacaciones SET IdEmpresaNomina = @IdEmpresaNomina, IdPeriodoNomina = @IdPeriodoNomina, IdEmpleado = @IdEmpleado, IdBienServicio = @IdBienServicio, Aniversario = @Aniversario, PrimaVacacional = @PrimaVacacional, FechaInicio = @FechaInicio, FechaFin = @FechaFin, Dias = @Dias, IdEstatus = @IdEstatus, IdSesion = @IdSesion
		FROM   dbo.tNOMvacaciones
		WHERE  IdVacacion = @IdVacacion 
	END

	IF @TipoOperacion = 'D'
	BEGIN
		UPDATE dbo.tNOMvacaciones SET IdEstatus = 2		
		FROM   dbo.tNOMvacaciones
		WHERE  IdVacacion = @IdVacacion
	END
END
GO

CREATE OR ALTER PROCEDURE dbo.pCRUDincidencias
@TipoOperacion VARCHAR(5) = NULL, 
@IdIncidencia INT = 0 OUTPUT, 
@IdEmpresaNomina INT = 0, 
@IdPeriodoNomina INT = 0, 
@IdEmpleado INT = 0, 
@IdBienServicio INT = 0, 
@Valor VARCHAR(1024) =  NULL, 
@Valor2 VARCHAR(1024) =  NULL, 
@IdSaldo INT =  NULL, 
@IdProyecto INT =  NULL, 
@IdEstatus INT =  NULL, 
@IdSesion INT =  NULL
AS 
			
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	IF @TipoOperacion = 'C'
	BEGIN 
		INSERT INTO dbo.tNOMincidencias (IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Valor, Valor2, IdSaldo, IdProyecto, IdEstatus, IdSesion)
		VALUES(@IdEmpresaNomina, @IdPeriodoNomina, @IdEmpleado, @IdBienServicio, @Valor, @Valor2, @IdSaldo, @IdProyecto, @IdEstatus, @IdSesion)
		SET @IdIncidencia = SCOPE_IDENTITY()
	END

	IF @TipoOperacion = 'R'
	BEGIN
		SELECT IdIncidencia, IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Valor, Valor2, IdSaldo, IdProyecto, IdEstatus, IdSesion
		FROM dbo.tNOMincidencias WITH (NOLOCK)
		WHERE   IdIncidencia = @IdIncidencia               
	END

	IF @TipoOperacion = 'U'
	BEGIN
		UPDATE dbo.tNOMincidencias SET IdEmpresaNomina = @IdEmpresaNomina, IdPeriodoNomina = @IdPeriodoNomina, IdEmpleado = @IdEmpleado, IdBienServicio = @IdBienServicio, Valor = @Valor, Valor2 = @Valor2, IdSaldo = @IdSaldo, IdProyecto = @IdProyecto, IdEstatus = @IdEstatus, IdSesion = @IdSesion
		FROM   dbo.tNOMincidencias
		WHERE  IdIncidencia = @IdIncidencia 
	END

	IF @TipoOperacion = 'D'
	BEGIN
		UPDATE dbo.tNOMincidencias SET IdEstatus = 2		
		FROM   dbo.tNOMincidencias
		WHERE  IdIncidencia = @IdIncidencia
	END
END
GO

CREATE OR ALTER PROCEDURE dbo.pCRUDfaltasIncapacidades
@TipoOperacion VARCHAR(5) = NULL, 
@IdFaltaIncapacida INT = 0 OUTPUT, 
@IdEmpresaNomina INT = 0, 
@IdPeriodoNomina INT =  NULL, 
@IdEmpleado INT =  NULL, 
@IdBienServicio INT =  NULL, 
@IdTipoDDia INT =  NULL, 
@IdTipoDFalta INT =  NULL, 
@NumeroFaltas INT =  NULL, 
@Porcentaje NUMERIC(23, 8) =  NULL, 
@PagarEmpresa BIT =  NULL, 
@PorcentajeEmpresa NUMERIC(23, 8) =  NULL, 
@CertificadoIMSS VARCHAR(30) =  NULL, 
@PorcentajeIMSS NUMERIC(23, 8) =  NULL, 
@IdTipoDIncapacidadSAT INT =  NULL, 
@Inicio DATE =  NULL, 
@Fin DATE =  NULL, 
@IdEstatus INT =  NULL, 
@IdSesion INT =  NULL
AS 
			
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	IF @TipoOperacion = 'C'
	BEGIN 			
		INSERT INTO dbo.tNOMfaltasIncapacidades (IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, IdTipoDDia, IdTipoDFalta, NumeroFaltas, Porcentaje, PagarEmpresa, PorcentajeEmpresa, CertificadoIMSS, PorcentajeIMSS, IdTipoDIncapacidadSAT, Inicio, Fin, IdEstatus, IdSesion)
		VALUES(@IdEmpresaNomina, @IdPeriodoNomina, @IdEmpleado, @IdBienServicio, @IdTipoDDia, @IdTipoDFalta, @NumeroFaltas, @Porcentaje, @PagarEmpresa, @PorcentajeEmpresa, @CertificadoIMSS, @PorcentajeIMSS, @IdTipoDIncapacidadSAT, @Inicio, @Fin, @IdEstatus, @IdSesion)
		SET @IdFaltaIncapacida = SCOPE_IDENTITY()
	END

	IF @TipoOperacion = 'R'
	BEGIN
		SELECT  IdFaltaIncapacida, IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, IdTipoDDia, IdTipoDFalta, NumeroFaltas, Porcentaje, PagarEmpresa, PorcentajeEmpresa, CertificadoIMSS, PorcentajeIMSS, IdTipoDIncapacidadSAT, Inicio, Fin, Referencia, PorcentajeReal, IdEstatus
		FROM    dbo.tNOMfaltasIncapacidades WITH (NOLOCK)
		WHERE   IdFaltaIncapacida = @IdFaltaIncapacida               
	END

	IF @TipoOperacion = 'U'
	BEGIN
		UPDATE dbo.tNOMfaltasIncapacidades SET IdEmpresaNomina = @IdEmpresaNomina, IdPeriodoNomina = @IdPeriodoNomina, IdEmpleado = @IdEmpleado, IdBienServicio = @IdBienServicio, IdTipoDDia = @IdTipoDDia, IdTipoDFalta = @IdTipoDFalta, NumeroFaltas = @NumeroFaltas, Porcentaje = @Porcentaje, PagarEmpresa = @PagarEmpresa, PorcentajeEmpresa = @PorcentajeEmpresa, CertificadoIMSS = @CertificadoIMSS, PorcentajeIMSS = @PorcentajeIMSS, IdTipoDIncapacidadSAT = @IdTipoDIncapacidadSAT, Inicio = @Inicio, Fin = @Fin, IdEstatus = @IdEstatus, IdSesion = @IdSesion
		FROM   dbo.tNOMfaltasIncapacidades
		WHERE  IdFaltaIncapacida = @IdFaltaIncapacida 
	END

	IF @TipoOperacion = 'D'
	BEGIN
		UPDATE dbo.tNOMfaltasIncapacidades SET IdEstatus = 2		
		FROM   dbo.tNOMfaltasIncapacidades
		WHERE  IdFaltaIncapacida = @IdFaltaIncapacida
	END
END
GO
						