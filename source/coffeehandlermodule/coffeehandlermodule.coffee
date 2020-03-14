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
fs = require "fs"
mustache = require "mustache"
decamelize = require "decamelize"

############################################################
pug = null
path = null

############################################################
allIds = null
allFiles = null

usedIds = []

############################################################
coffeehandlermodule.initialize = () ->
    log "coffeehandlermodule.initialize"
    pug = allModules.pughandlermodule
    path = allModules.pathhandlermodule
    return

############################################################
generateContentObject = ->
    log "generateContentObject"
    moduleName = path.basename(path.outputPath, ".coffee")
    content = {moduleName}
    content.usedIds = []
    for id in usedIds
        node =
            variable: id
            documentId: decamelize(id, "-")
        content.usedIds.push(node)
    return content

writeIfDifferent = (filePath, content)->
    log "writeIfDifferent"
    try oldContent = String(fs.readFileSync(filePath))
    catch err then oldContent = ""
    if oldContent != content then fs.writeFileSync(filePath, content)
    return

############################################################
coffeehandlermodule.scanForUsedIds = ->
    log "coffeehandlermodule.scanForUsedIds"
    allIds = pug.getAllIds()
    allFiles = path.coffeeCodeFilePaths
    usedIds.length = 0

    for id in allIds
        for file in allFiles
            coffeeString = String(fs.readFileSync(file))
            if coffeeString.indexOf(id + ".") != -1
                usedIds.push(id)
                break
    
    log "scanned usedIds"
    olog usedIds
    return

coffeehandlermodule.getUsedIds = -> usedIds

coffeehandlermodule.writeOutputFile = ->
    log "coffeehandlermodule.writeOutputFile"
    template = String(fs.readFileSync(path.templatePath))        
    contentObject = generateContentObject()
    fileContent = mustache.render(template, contentObject)
    writeIfDifferent(path.outputPath, fileContent)
    return

module.exports = coffeehandlermodule