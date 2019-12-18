SELECT c.Name,t.name AS DataType, C.precision, C.scale 
FROM tempdb.sys.columns c
inner join Sys.systypes t on t.xtype = c.system_type_id
WHERE [object_id] = OBJECT_ID(N'tempdb..##t_53_ILIDF_DATA_FEATURE');
	