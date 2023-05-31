USE [ERP_MEDICO];


DECLARE @Tabla VARCHAR(100) = 'ProductoAlmacenes';
DECLARE @Entidad VARCHAR(100) = 'ProductoAlmacen';
DECLARE @Esquema VARCHAR(100) = 'Inventario';
DECLARE @ProcedimientoAlmacenado VARCHAR(100);

SELECT @ProcedimientoAlmacenado = CONCAT ('pCRUD', @Tabla);

EXECUTE Factory.pProcedimientoAlmacenado @Esquema = @Esquema,
    @Tabla = @Tabla,
    @Operacion = 'CRUD';

EXECUTE Factory.pProcedimientoAlmacenado @Esquema = @Esquema,
    @Tabla = @Tabla,
    @Operacion = 'LST';

EXECUTE Factory.pCapaDominio @Esquema = @Esquema, @NombreTabla = @Tabla,
    @Entidad = @Entidad;

EXECUTE Factory.pCapaDatos @ProcedimientoAlmacenado = @ProcedimientoAlmacenado,
    @Entidad = @Entidad;

EXECUTE Factory.pCapaNegocio @Entidad = @Entidad;

EXECUTE Factory.pCapaPresentacion @Tabla = @Tabla,
    @Entidad = @Entidad;

