if type(APP.model) ~= "table" then
    APP.model = {}
end

if type(APP.configuration) ~= 'table' then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION) 
end

local _charsetTable = {}
_charset="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
_charset:gsub(".",function(c) table.insert(_charsetTable,c) end)
local _rpcPass = eliUtil.random_string(20, _charsetTable)

local _isSystemnode = nil
if APP.configuration.NODE_TYPE == 'systemnode' then 
    _isSystemnode = true
end

APP.model = eliUtil.merge_tables(
    APP.model,
    {
        RPC_USER = APP.configuration.USER,
        RPC_PASS = APP.configuration.RPC_PASS or _rpcPass,
        RPC_PORT = APP.configuration.RPC_PORT or 5520,
        IS_SERVER = type(APP.configuration.NODE_PRIVKEY) == 'string' or APP.configuration.SERVER,
        DAEMON_NAME = "bin/crownd",
        CLI_NAME = "bin/crown-cli",
        CONF_NAME = "crown.conf",
        CONF_SOURCE = "__crw/assets/crown.conf",
        SERVICE_NAME = "crownd",
        DATA_DIR = "data",
        IS_SYSTEMNODE = _isSystemnode
    },true
)