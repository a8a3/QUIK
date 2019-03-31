

-- вывод таблицы в лог
function PrintTable( _tableName, _table )
    log_info( "--------------------------");
    log_info( "Table '" .. _tableName .. "' : " );

	local paramValue = "";

    for k, v in pairs(_table) do
		paramValue = tostring( v );
		
		if ( #paramValue > 0 and paramValue ~= "0" ) then
			log_info( k .. " = " .. paramValue );
		end
    end
    log_info( "--------------------------");
end

