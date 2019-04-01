
local gLogModule = require( "log" );
local gBit       = require( "bit" );
local gUtils     = require( "utils" );

dofile( getScriptPath() .. "\\" .. "view.lua" );
dofile( getScriptPath() .. "\\" .. "config.lua" );


local gLog     = nil;   -- table
local gCandles = nil;
local gIsRun   = true;


-- состояния скрипта
local gStates =
{
    NEUTRAL = "NEUTRAL"   -- получает на старте
   ,BUY     = "BUY    "   -- длинная позиция
   ,SELL    = "SELL   "   -- короткая позиция
};


-- параметры скрипта, меняющиеся в процессе работы
local gParameters =
{
    STATE         = gStates.NEUTRAL -- текущее состояние
   ,TRADES_COUNT  = 0               -- количество сделок
   ,PL            = 0               -- PL
   ,CURRENT_PRICE = 0               -- текущая цена инструмента
   ,DEAL_PRICE    = 0               -- цена последней сделки
   ,UP_PRICE      = 0
   ,DOWN_PRICE    = 0
};


--
function log( _mode, _str )
    local prefix = "[STATE=" .. gParameters.STATE .. "] ";

    if     ( "DEBUG"  == _mode ) then
        gLog:Debug( prefix .. _str );
    elseif ( "INFO"   == _mode ) then
        gLog:Info( prefix .. _str );
    elseif ( "WARNING"== _mode )then
        gLog:Warning( prefix .. _str );
    elseif ( "ERROR"  == _mode )then
        gLog:Error( prefix .. _str );
    else
        gLog:Error( "Unknown log mode!" );
    end
end -- log


--
function log_info( _str )
    log( "INFO", _str );
end -- log_info


--
function log_warning( _str )
    log( "WARNING", _str );
end  -- log_warning


-- 
function log_error( _str )
    log( "ERROR", _str );
end -- log_error


-- 
function log_debug( _str )
    log( "DEBUG", _str );
end  -- log_debug


-- заказ свечей
function CreateCandlesDataSource()
    local errorDesk = nil;
    gCandles, errorDesk = CreateDataSource( gConfig.CLASS_CODE, gConfig.SEC_CODE, INTERVAL_M1 );
    
    if ( not gCandles ) then 
        log_error( "Can't get candles data source : " .. (nil == errorDesk and "Unknown Error!" or errorDesk) .. " Exiting..." );
        return false;
    end
    log_debug( "Get candles data" );
end -- CreateCandlesDataSource


-- обновление свечей
function UpdateCandles()
    if ( not gCandles ) then return; end
    
    gCandles:SetEmptyCallback();  
    gParameters.CURRENT_PRICE = gCandles:C( gCandles:Size() );  
end -- UpdateCandles


-- обновление коридора цен
function UpdatePricesRange()
    gParameters.DOWN_PRICE = gParameters.CURRENT_PRICE - gConfig.PRICE_STEP;
    gParameters.UP_PRICE   = gParameters.CURRENT_PRICE + gConfig.PRICE_STEP;
end -- UpdatePricesRange


-- закрыть источник по свечам
function CloseCandlesDataSource()
    if ( not gCandles ) then return; end
    
    gCandles:Close();
end -- CloseCandlesDataSource


-- обработка текущей цены
function ProcessDataChanges()
    if     ( gParameters.CURRENT_PRICE < gParameters.DOWN_PRICE ) then 
        return ChangeState( gStates.SELL );
    elseif ( gParameters.CURRENT_PRICE > gParameters.UP_PRICE )   then
        return ChangeState( gStates.BUY );
    end
    
    return true;
end  -- ProcessDataChanges


-- смена состояния
function ChangeState( _newState )
    local res       = false;
    local curPrice  = gParameters.CURRENT_PRICE;
    local curState  = gParameters.STATE;
    local priceStep = gConfig.PRICE_STEP;

    if     ( gStates.NEUTRAL == curState ) then
        if ( gStates.BUY  == _newState ) then
            -- купить
            gParameters.DEAL_PRICE = curPrice;
            UpdatePricesRange();
            res = true;
        elseif ( gStates.SELL == _newState ) then
            -- продать
            gParameters.DEAL_PRICE = curPrice;
            UpdatePricesRange();
            res = true;
        end

    elseif ( gStates.BUY == curState ) then
        if     ( gStates.BUY  == _newState ) then
            -- цена в сторону открытия позиции
            UpdatePricesRange();
            res = true;
        elseif ( gStates.SELL == _newState ) then
            -- перевернуть позицию
            -- закрыть длинную, открыть короткую
            localPL = curPrice - gParameters.DEAL_PRICE;
            gParameters.PL = gParameters.PL + localPL;
            
            gParameters.DEAL_PRICE = curPrice;
            gParameters.TRADES_COUNT = gParameters.TRADES_COUNT + 1;
            UpdatePricesRange();
            
            res = true;
        end
    elseif ( gStates.SELL    == curState ) then
        if ( gStates.BUY  == _newState ) then
            -- перевернуть позицию
            -- закрыть короткую, открыть длинную
            localPL = gParameters.DEAL_PRICE - curPrice;
            gParameters.PL = gParameters.PL + localPL;
            
            gParameters.DEAL_PRICE = curPrice;
            gParameters.TRADES_COUNT = gParameters.TRADES_COUNT + 1;
            UpdatePricesRange();
            
            res = true;

        elseif ( gStates.SELL == _newState ) then
            -- цена в сторону открытия позиции
            UpdatePricesRange();
            res = true;
        end
    end
    
    if ( not res ) then
        log_error( "Unexpected script state passed: " .. _newState );
    else
        gParameters.STATE = _newState;
        log_info( "Script state changed to: " .. gParameters.STATE );
        PrintTable( "gParameters", gParameters );
    end
    
    return res;
end  -- ChangeState


-- main
function main()
    log_info( "Start..." );

    while gIsRun do
        UpdateCandles();
        gIsRun = ProcessDataChanges();
        UpdateView( gParameters );
        sleep( 100 );
    end  -- while

    log_info( "Stop..." );
    gLog:Close();
end  -- main


-- 
function OnInit( _path )
    gLog = gLogModule:new();  

    local logFullFilePath = getScriptPath() .. "\\" .. "bender" .. "_" .. gConfig.SEC_CODE .. "_"..os.date("%Y").."_"..os.date("%m").."_"..os.date("%d")..".log";  
    gLog:Open( logFullFilePath );  	

    log_debug( "OnInit call" );
    log_info( "Log file name = " .. logFullFilePath );

    CreateCandlesDataSource();
    UpdateCandles();
    UpdatePricesRange()

    CreateView( "trend algo", gConfig );
    UpdateView( gParameters );
    PrintTable("gConfig",     gConfig)
    PrintTable("gParameters", gParameters)
end  -- OnInit


--
function OnStop( _signal )
    log_debug( "Got stop signal" );
    CloseCandlesDataSource();
    DestroyView();

    gIsRun = false;
    return 3000;
end  -- OnStop



