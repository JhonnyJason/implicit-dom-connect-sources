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
isComment = (commentIndex, includeIndex, idHashIndex) ->
    log "isComment"
    if includeIndex == -1 then includeIndex = commentIndex + 1
    if idHashIndex == -1 then idHashIndex = commentIndex + 1
    if commentIndex < includeIndex and commentIndex < idHashIndex
        return true
    return false

isInclude = (commentIndex, includeIndex, idHashIndex) ->
    log "isInclude"
    if commentIndex == -1 then commentIndex = includeIndex + 1
    if idHashIndex == -1 then idHashIndex = includeIndex + 1
    if includeIndex < commentIndex and includeIndex < idHashIndex
        return true
    return false

rememberFile = (line) ->
    log "rememberFile"
    tokens =  line.split(" ")
    for token,i in tokens
        if token == "include"
            foundIncludePaths.push(tokens[i+1])
            return
    return

rememberId = (line, idHashIndex) ->
    log "rememberId"
    bestGuessEnd = line.length-1
    
    dotIndex = line.indexOf(".", idHashIndex)
    if dotIndex == -1 then dotIndex = line.length-1

    braceIndex = line.indexOf("(", idHashIndex)
    if braceIndex == -1 then braceIndex = line.length-1
    
    spaceIndex = line.indexOf(" ", idHashIndex)
    if spaceIndex == -1 then spaceIndex = line.length-1

    if dotIndex < bestGuessEnd then bestGuessEnd = dotIndex
    if braceIndex < bestGuessEnd then bestGuessEnd = braceIndex
    if spaceIndex < bestGuessEnd then bestGuessEnd = braceIndex

    id = line.slice(idHashIndex, bestGuessEnd)
    foundIds.push(id)
    return

scanLine = (line) ->
    log "scanLine"
    commentIndex = line.indexOf("//-")
    includeIndex = line.indexOf("include ")
    idHashIndex = line.indexOf("#")
    braceIndex = line.indexOf("(")

    if commentIndex >= 0
        if isComment(commentIndex, includeIndex, idHashIndex) then return
    if includeIndex >= 0
        if isInclude(commentIndex, includeIndex, idHashIndex)
            rememberFile(line)
            return
    
    if idHashIndex >= 0
        if braceIndex != -1 and braceIndex < idHashIndex then return
        rememberId(line, idHashIndex)
    return

processFile = (filePath) ->
    log "processFile"
    log filePath
    foundIncludePaths = []
    pugString = String(fs.readFileSync(filePath))
    lines = pugString.split(/\r\n|\r|\n/)
    for line in lines
        line += " "
        scanLine(line)
    
    log "after scanning... found stuff:"
    olog foundIncludePaths
    olog foundIds

    base = path.dirname(filePath)
    for includePath in foundIncludePaths
        furtherFilePaths.push(path.resolve(base, includePath))
    return        


############################################################
pughandlermodule.readFiles = () ->
    log "pughandlermodule.readFiles"
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