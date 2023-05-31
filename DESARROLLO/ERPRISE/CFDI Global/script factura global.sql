



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tFELfacturaGlobalIngresos')
BEGIN   
CREATE TABLE [dbo].[tFELfacturaGlobalIngresos] (
[IdOperacion] INT NULL,
[IdPeriodo] INT NULL,
[IdImpuesto] INT NULL,
[InteresOrdinario] DECIMAL(18, 2) NULL,
[IVAInteresOrdinario] DECIMAL(18, 2) NULL,
[InteresMoratorio] DECIMAL(18, 2) NULL,
[IVAInteresMoratorio] DECIMAL(18, 2) NULL,
[CargosPagados] DECIMAL(18, 2) NULL,
[IVACargosPagado] DECIMAL(18, 2) NULL,
[IdBienServicio] INT NULL,
[Subtotal] NUMERIC(18, 2) NULL,
[IVAVenta] NUMERIC(18, 2) NULL,
[IdOperacionFactura] INT NOT NULL DEFAULT 0 );
	
ALTER TABLE [dbo].[tFELfacturaGlobalIngresos] WITH CHECK ADD CONSTRAINT [FK_tFELfacturaGlobalIngresos_IdOperacionFactura] FOREIGN KEY([IdOperacionFactura])REFERENCES [dbo].[tGRLoperaciones]([IdOperacion]);
ALTER TABLE [dbo].[tFELfacturaGlobalIngresos] CHECK CONSTRAINT [FK_tFELfacturaGlobalIngresos_IdOperacionFactura]; 

END