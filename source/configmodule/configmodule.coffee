configmodule = {name: "configmodule"}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

############################################################
#region exposedProperties
configmodule.cli =
    name: "implicit-dom-connect"
configmodule.outputTemplatePath = "output-template.coffee"
#endregion


############################################################
configmodule.initialize = () ->
    log "configmodule.initialize"
    return


module.exports = configmodule