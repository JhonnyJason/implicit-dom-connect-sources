naivsearchmodule = {name: "naivsearchmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["naivsearchmodule"]?  then console.log "[naivsearchmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
naivsearchmodule.initialize = () ->
    log "naivsearchmodule.initialize"
    return
    
module.exports = naivsearchmodule