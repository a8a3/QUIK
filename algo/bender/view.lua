
-- отображение основных параметров скрипта

local gMainTableID = nil;
local gColumnID = 
{ 
     -- Parameters
     STATE          = 101 
    ,TRADES_COUNT   = 102 
    ,PL             = 103
    ,DEAL_PRICE     = 104
    ,DOWN_PRICE     = 105
    ,CURRENT_PRICE  = 106 
    ,UP_PRICE       = 107 
};

--
local gColours =
{
    RED         = RGB( 255,   0,   0 ),
    GREEN       = RGB(   0, 255,   0 ),
    YELLOW      = RGB( 255, 255,   0 ),
    BLACK       = RGB(   0,   0,   0 )
};

--
function CreateView( _wndCaption, _configTbl )
    log_info( "Create view table" );
    gMainTableID = AllocTable();

    -- Parameters
    AddColumn( gMainTableID, gColumnID.STATE,          "STATE"         , true, QTABLE_STRING_TYPE, 25 );
    AddColumn( gMainTableID, gColumnID.TRADES_COUNT,   "TRADES_COUNT"  , true, QTABLE_STRING_TYPE, 20 );
    AddColumn( gMainTableID, gColumnID.PL,             "P/L"           , true, QTABLE_STRING_TYPE, 20 );
    AddColumn( gMainTableID, gColumnID.DEAL_PRICE,     "DEAL_PRICE"    , true, QTABLE_STRING_TYPE, 20 );
    AddColumn( gMainTableID, gColumnID.DOWN_PRICE,     "DOWN_PRICE"    , true, QTABLE_STRING_TYPE, 25 );
    AddColumn( gMainTableID, gColumnID.CURRENT_PRICE,  "CURRENT_PRICE" , true, QTABLE_STRING_TYPE, 25 );
    AddColumn( gMainTableID, gColumnID.UP_PRICE,       "UP_PRICE"      , true, QTABLE_STRING_TYPE, 25 );

    if ( 1 == CreateWindow(gMainTableID) ) then
        log_info( "View table window created" );
    else
        log_error( "Can't create view table window" );
    end

    SetWindowCaption( gMainTableID, _wndCaption .. " -> ".. _configTbl.SEC_CODE .. ", price_step = " .. _configTbl.PRICE_STEP );
    InsertRow( gMainTableID, -1 );

    SetWindowPos( gMainTableID, 100, 100, 800, 90 );
end

--
function UpdateView( _parameters )

    SetCell ( gMainTableID, 1, gColumnID.STATE,        _parameters.STATE );
    SetCell ( gMainTableID, 1, gColumnID.TRADES_COUNT, tostring(_parameters.TRADES_COUNT) );

    -- PL значение
    local plVal = _parameters.PL >= 0 and "+" .. tostring(_parameters.PL) or "" .. tostring(_parameters.PL);
    SetCell ( gMainTableID, 1, gColumnID.PL, plVal );
    -- PL цвет
    local plFontColor = _parameters.PL >= 0 and gColours.GREEN or gColours.RED;
    SetColor( gMainTableID, 1, gColumnID.PL, plFontColor, gColours.BLACK, plFontColor, gColours.BLACK );
    
    SetCell ( gMainTableID, 1, gColumnID.DEAL_PRICE,    tostring(_parameters.DEAL_PRICE) );
    SetCell ( gMainTableID, 1, gColumnID.DOWN_PRICE,    tostring(_parameters.DOWN_PRICE) );
    SetCell ( gMainTableID, 1, gColumnID.CURRENT_PRICE, tostring(_parameters.CURRENT_PRICE) );
    SetCell ( gMainTableID, 1, gColumnID.UP_PRICE,      tostring(_parameters.UP_PRICE) );
end

-- 
function DestroyView()
    log_info( "Destroy view table" );
    DestroyTable( gMainTableID );
end