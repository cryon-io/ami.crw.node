if type(APP.model) ~= "table" then
    APP.model = {}
end

if type(APP.configuration) ~= 'table' then
    log_warn("Configuration not found...")
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
        DAEMON_CONFIGURATION = {
            rpcuser = APP.configuration.RPC_USER or APP.user,
            rpcpassword = APP.configuration.RPC_PASS or _rpcPass,
            rpcport = APP.configuration.RPC_PORT or 5520,
            server = (type(APP.configuration.NODE_PRIVKEY) == 'string' or APP.configuration.SERVER) and 1 or nil,
            listen = (type(APP.configuration.NODE_PRIVKEY) == 'string' or APP.configuration.SERVER) and 1 or nil,
            masternodeprivkey = configuration.NODE_TYPE == "masternode" and configuration.NODE_PRIVKEY or nil,
            masternode = configuration.NODE_TYPE == "masternode" and 1 or nil,
            systemnodeprivkey = configuration.NODE_TYPE == "systemnode" and configuration.NODE_PRIVKEY or nil,
            systemnode = configuration.NODE_TYPE == "systemnode" and 1 or nil,
            logtimestamps = 1,
            maxconnections=256
        },
        DAEMON_NAME = "bin/crownd",
        CLI_NAME = "bin/crown-cli",
        CONF_NAME = "crown.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "crownd",
        DATA_DIR = "data",
        IS_SYSTEMNODE = _isSystemnode
    },true
)