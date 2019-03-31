
-- лог
local Log  =
{
    File = nil;
}

--
function Log:new( _l )
	local _l = _l or {};
	setmetatable( _l, self );
	self.__index = self;
	return _l;
end

--
function Log:Open( _fileName )
	if nil == self.File then
		self.File = assert(io.open( _fileName, 'a'));
	end
end

--
function Log:Info( _msgStr )
	if nil ~= self.File then
		self.File:write( os.date("%X") .. " [INFO   ] " .. _msgStr .. "\n" );
		self.File:flush();
	end
end

--
function Log:Warning( _msgStr )
	if nil ~= self.File then
		self.File:write( os.date("%X") .. " [WARNING] " .. _msgStr .. "\n" );
		self.File:flush();
	end
end

--
function Log:Error( _errStr )
	if nil ~= self.File then
		self.File:write( os.date("%X") .. " [ERROR  ] " .. _errStr .. "\n" );
		self.File:flush();
	end
end


--
function Log:Debug( _dbgStr )
	if nil ~= self.File then
		self.File:write( os.date("%X") .. " [DEBUG  ] " .. _dbgStr .. "\n" );
		self.File:flush();
	end
end


--
function Log:Close()
	if nil ~= self.File then
		self.File:close();
		self.File = nil;
	end
end

return Log
