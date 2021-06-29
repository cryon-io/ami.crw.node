local _nodeType = am.app.get_configuration("NODE_TYPE", "plain")

am.app.set_model(
    {
        DAEMON_CONFIGURATION = {
            server = (type(am.app.get_configuration("NODE_PRIVKEY") == "string") or am.app.get_configuration("SERVER")) and 1 or nil,
            listen = (type(am.app.get_configuration("NODE_PRIVKEY") == "string") or am.app.get_configuration("SERVER")) and 1 or nil,
            masternodeprivkey = _nodeType == "masternode" and am.app.get_configuration("NODE_PRIVKEY") or nil,
            masternode = _nodeType == "masternode" and 1 or nil,
            systemnodeprivkey = _nodeType == "systemnode" and am.app.get_configuration("NODE_PRIVKEY") or nil,
            systemnode = _nodeType == "systemnode" and 1 or nil,
            logtimestamps = 1,
            maxconnections = 256
        },
        DAEMON_NAME = "bin/crownd",
        CLI_NAME = "bin/crown-cli",
        CONF_NAME = "crown.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "crownd",
        DATA_DIR = "data",
        IS_SYSTEMNODE = _nodeType == "systemnode"
    },
    { merge = true, overwrite = true }
)