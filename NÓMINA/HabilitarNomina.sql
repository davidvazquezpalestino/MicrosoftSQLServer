declare @IdUsduario as integer = 37;
declare @idrfcemisor as integer =0


set @idrfcemisor =(select idrfc
				   from tfelemisores 
				   where idrfc = (select idrfc 
								  from tFELRFCs 
								  where idcliente = (select IdCliente 
													 from tCTLusuarios  
													 where IdUsuario = @IdUsduario)))

select @idrfcemisor	as IdRFCemisor

select *
--UPDATE t set HabilitarNomina = 1
from tFELemisores t
where IdRFC = @idrfcemisor

