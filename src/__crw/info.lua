local _json = ...
local _hjson = require"hjson"

local _ok, _systemctl = safe_load_plugin("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin", EXIT_APP_START_ERROR)

local _info = {}
local _ok, _status = _systemctl.safe_get_service_status(APP.id .. "-" .. APP.model.SERVICE_NAME)
ami_assert(_ok, "Failed to start " .. APP.id .. "-" .. APP.model.SERVICE_NAME .. ".service " .. (_status or ""), EXIT_APP_START_ERROR)
_info.crownd = _status

_info.level = "ok"

local function _exec_crown_cli(...)
    local _cmd = exString.join_strings(" ", ...)
    local _rd, _proc_wr = eliFs.pipe()
    local _rderr, _proc_werr = eliFs.pipe()
    local _proc, _err = eliProc.spawn {"bin/bin/crown-cli", args = { ... }, stdout = _proc_wr, stderr = _proc_werr}
    _proc_wr:close()
    _proc_werr:close()

    if not _proc then
        _rd:close()
        _rderr:close()
        ami_error("Failed to execute crown-cli command: " .. _cmd, EXIT_APP_INTERNAL_ERROR)
    end
    local _exitcode = _proc:wait() 
    local _stdout = _rd:read("a")
    local _stderr = _rderr:read("a")
    --ami_assert(_exitcode == 0, "Failed to execute crown-cli command: " .. _cmd, EXIT_APP_INTERNAL_ERROR)
    return _exitcode, _stdout, _stderr
end

local function _get_crown_cli_result(exitcode, stdout, stderr)
    if exitcode ~= 0 then 
        local _errorInfo = stderr:match("error: (.*)")
        local _ok, _output = pcall(_hjson.parse, _errorInfo)
        if _ok then 
            return false, _output
        else 
            return false, { message = "unknown (internal error)" }
        end
    end
    
    local _ok, _output = pcall(_hjson.parse, stdout)
    if _ok then 
        return true, _output
    else 
        return false, { message = "unknown (internal error)" }
    end
end

if _info.crownd == "running" then 
    
    local _exitcode, _stdout, _stderr = _exec_crown_cli("-datadir=data", APP.configuration.NODE_TYPE, "status")
    local _success, _output = _get_crown_cli_result(_exitcode, _stdout, _stderr)

    _info.status = _output.message
    if _success and (_info.status == 'Systemnode successfully started' or _info.status == 'Masternode successfully started') then 
        _info.level = "ok"
    else
        _info.level = "error"
    end

    local _exitcode, _stdout, _stderr = _exec_crown_cli("-datadir=data", "getblockchaininfo")
    local _success, _output = _get_crown_cli_result(_exitcode, _stdout, _stderr)

    if _success then 
        _info.currentBlock = _output.blocks
        _info.currentBlockHash = _output.bestblockhash
    else 
        _info.currentBlock = "unknown"
        _info.currentBlockHash = "unknown"
    end

    local _exitcode, _stdout, _stderr = _exec_crown_cli("-datadir=data", "mnsync", "status")
    local _success, _output = _get_crown_cli_result(_exitcode, _stdout, _stderr)

    if _success then 
        _info.synced = _output.IsBlockchainSynced
    else 
        _info.synced = false
    end
else 
    _info.level = "error"
end

if not _info.synced and _info.level == 'ok' then 
    _info.level = 'warn'
end

if _json then
   print(_hjson.stringify_to_json(_info, { indent = false }))
else
   print(_hjson.stringify(_info))
end