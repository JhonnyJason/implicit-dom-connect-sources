mainprocessmodule = {name: "mainprocessmodule"}
############################################################
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["mainprocessmodule"]?  then console.log "[mainprocessmodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region localModules
cfg = null
pug = null
path = null
coffee = null
#endregion

############################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    pug = allModules.pughandlermodule
    path = allModules.pathhandlermodule
    coffee = allModules.coffeehandlermodule
    return 

############################################################
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"    

    await path.preparePugHeadPath(e.pugHead)
    await path.prepareCoffeeCodePath(e.coffeeCode)
    # await path.prepareOutputPath(e.output)

    # await pug.readFiles()
    await coffee.scanForUsedIds()
    # await coffee.writeOutputFile()

    return

module.exports = mainprocessmodule
