coffeehandlermodule = {name: "coffeehandlermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["coffeehandlermodule"]?  then console.log "[coffeehandlermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
pug = null
path = null
search = null

allIds = null
allFiles = null


############################################################
coffeehandlermodule.initialize = () ->
    log "coffeehandlermodule.initialize"
    pug = allModules.pughandlermodule
    path = allModules.pathhandlermodule
    search = allModules.fasttreesearchmodule
    return

setUpSearchTree = ->
    log "setUpSearchTree"
    search.reset()
    return

############################################################
coffeehandlermodule.scanForUsedIds = ->
    log "coffeehandlermodule.scanForUserIds"
    allIds = pug.getAllIds()
    allFiles = path.coffeeCodeFilePaths
    olog allIds
    olog allFiles
    
    return


module.exports = coffeehandlermodule