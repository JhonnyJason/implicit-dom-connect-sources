pughandlermodule = {name: "pughandlermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pughandlermodule"]?  then console.log "[pughandlermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modules
fs = require "fs"
camelcase = require "camelcase"

############################################################
path = null
search = null

#endregion

############################################################
#region internalProperties
foundIds = []

foundIncludePaths = []
furtherFilePaths = []

#endregion

############################################################
pughandlermodule.initialize = () ->
    log "pughandlermodule.initialize"
    path = allModules.pathhandlermodule
    search = allModules.fastsearchtreemodule
    return

############################################################
#region internal functions
setUpSearchTree = ->
    search.reset()
    search.addExactMatchPattern("//-", onComment)
    search.addExactMatchPattern("include ", onInclude)

    search.addTokenMatchPattern("#", " ", onId)
    search.addTokenMatchPattern("#", "(", onId)
    search.addTokenMatchPattern("#", ".", onId)

    search.addIgnoreSequence("\"", "\"")
    search.addIgnoreSequence("'", "'")
    search.addIgnoreSequence("(", ")")
    return

############################################################
#region resultFunctions
onComment = (result, input, lastPosition) -> return

onInclude = (result, input, lastPosition) ->
    includePath = input.substr(lastPosition).replace(/\s/g, "")
    foundIncludePaths.push(includePath)
    return

onId = (result, input, lastPosition) ->
    foundIds.push(result)
    return

#endregion

############################################################
processFile = (filePath) ->
    log "processFile"
    log filePath
    foundIncludePaths = []
    pugString = String(fs.readFileSync(filePath))
    lines = pugString.split(/\r\n|\r|\n/)
    for line in lines
        line += " "
        search.scan(line)
    
    base = path.dirname(filePath)
    for includePath in foundIncludePaths
        furtherFilePaths.push(path.resolve(base, includePath))
    return        

#endregion

############################################################
pughandlermodule.readFiles = () ->
    log "pughandlermodule.readFiles"
    setUpSearchTree()
    processFile(path.pugHeadPath)
    while furtherFilePaths.length
        otherPath = furtherFilePaths.pop()
        processFile(otherPath)
    return

pughandlermodule.getAllIds = ->
    log "pughandlermodule.getAllIds"
    result = []
    for idString in foundIds
        camelCased = camelcase(idString).replace(/#/g, "")
        if camelCased then result.push(camelCased)
    return result

module.exports = pughandlermodule