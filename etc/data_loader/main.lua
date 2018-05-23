
--
gInstruments = 
{
    { class_code = "SPBFUT", sec_code = "SRU8", tf = INTERVAL_M1 },
    { class_code = "SPBFUT", sec_code = "SRU8", tf = INTERVAL_M5 },
    { class_code = "SPBFUT", sec_code = "SRU8", tf = INTERVAL_M10},
    { class_code = "SPBFUT", sec_code = "SRU8", tf = INTERVAL_M30},
    { class_code = "SPBFUT", sec_code = "SRU8", tf = INTERVAL_H1},	
};

-- конфигурация
gConfig =
{   
    OUT_FOLDER_NAME = "C:\\QUIK"    -- имя папки для выгрузки данных
   ,WAIT_TIME       = 5             -- сколько секунд ждать данные с сервера
   ,INSTRUMENTS     = gInstruments      
-- INTERVAL_TICK Тиковые данные  
-- INTERVAL_M1   1  минута  
-- ...
-- INTERVAL_M6   6  минут
-- INTERVAL_M10  10 минут
-- INTERVAL_M15  15 минут
-- INTERVAL_M20  20 минут
-- INTERVAL_M30  30 минут
-- INTERVAL_H1   1 час
-- INTERVAL_H2   2 часа
-- INTERVAL_H4   4 часа
-- INTERVAL_D1   1 день
-- INTERVAL_W1   1 неделя
-- INTERVAL_MN1  1 месяц
};

-- 
function getData( _class_code, _sec_code, _tf )
    local candles, errorDesk = CreateDataSource( _class_code, _sec_code, _tf );
    
    if ( not candles ) then 
        message( "Can't get data source : " .. (nil == errorDesk and "Unknown Error!" or errorDesk) .. " Skip data load", 3 );
		return;
    end
   
    if ( not candles:SetEmptyCallback() ) then
		candles:Close();
		message( "Can't get data from server. Skip data load", 3 );
		return;
	end 

	if ( 0 == candles:Size() ) then
		message( "Wait server response...", 2 );
	end

	local stopWaitTime = os.time() + gConfig.WAIT_TIME;

    while (errorDesk == "" or errorDesk == nil) and (0 == candles:Size()) and (stopWaitTime > os.time())
		do sleep( 1 );
	end
	
    if ( 0 == candles:Size() ) then 
		message( "Data source is empty: ".. (nil == errorDesk and "Unknown Error!" or errorDesk) .. " Skip data load" , 3 );
		return;
	end

	local fileName = gConfig.OUT_FOLDER_NAME .. "\\" .. _class_code .. "_" .. _sec_code .. "_" .. tostring(_tf) .. "_M" .. ".csv";
	local file = io.open( fileName, 'w' );	
	
	if ( not file ) then
		candles:Close();
		message( "Can't create file '" .. fileName .. "'" .. " Skip data load", 3 );
		return;
	end
		
	file:write( "<DATE>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE> \n" );
	
	for i = 1, candles:Size()-1, 1 do	
		file:write( candles:T(i).year .. string.format("%02d", candles:T(i).month) .. string.format("%02d", candles:T(i).day) .. "," .. string.format("%02d", candles:T(i).hour) .. string.format("%02d", candles:T(i).min).. string.format("%02d", candles:T(i).sec) .. "," .. 
					candles:O(i) .. "," .. 
					candles:H(i) .. "," .. 
					candles:L(i) .. "," .. 
					candles:C(i) .. "\n");
	end
				
	file:close();
    candles:Close();
	message( "Data saved to '" .. fileName .. "'", 1 );
end

--
function main()
	for _, _item in ipairs( gConfig.INSTRUMENTS ) do
		getData( _item.class_code, _item.sec_code, _item.tf );
	end
	message( "Done." );
end

