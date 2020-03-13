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
args = null

############################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    pug = allModules.pughandlermodule
    path = allModules.pathhandlermodule
    coffee = allModules.coffeehandlermodule
    return 

onChangeProcess = ->
    log "onChangeProcess"
    path.stopWatchingFiles()
    await path.prepareCoffeeCodePath(args.coffeeCode)
    await path.prepareOutputPath(args.output)
    await process()
    watchFiles()
    return

watchFiles = ->
    log "watchFiles"
    pugFiles = pug.getProcessedFiles()
    path.onAnyFileChanges(pugFiles, onChangeProcess)
    coffeeFiles = path.coffeeCodeFilePaths
    path.onAnyFileChanges(coffeeFiles, onChangeProcess)
    return

eternalWatch = ->
    log "eternalWatch"
    watchFiles()
    eternalPromise = new Promise (resolve, reject) -> 
        resolveFunction = -> resolve("done")
        neverCalledResolve = resolveFunction
        return
    return eternalPromise

process = ->
    log "process"
    await pug.readFiles()
    await coffee.scanForUsedIds()
    await coffee.writeOutputFile()
    return

############################################################
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"    
    args = e

    await path.preparePugHeadPath(args.pugHead)
    await path.prepareCoffeeCodePath(args.coffeeCode)
    await path.prepareOutputPath(args.output)

    await process()

    if args.watch then answer = await eternalWatch()

    return

module.exports = mainprocessmodule
