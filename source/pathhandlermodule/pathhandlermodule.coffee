pathhandlermodule = {name: "pathhandlermodule"}
############################################################
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pathhandlermodule"]?  then console.log "[pathhandlermodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modulesFromEnvironment
############################################################
#region node_modules
fs = require("fs-extra")
glob = require("glob")
pathModule = require("path")
os = require("os")
exec = require("child_process").exec
#endregion

############################################################
cfg = null
#endregion

############################################################
#region properties
homedir = os.homedir()
watcherList = []

############################################################
#region exposedProperties
pathhandlermodule.homedir = homedir #directory
pathhandlermodule.pugHeadPath = "" #file
pathhandlermodule.coffeeCodePathExpression = "" #potential glob - file(s)
pathhandlermodule.coffeeCodeFilePaths = []
pathhandlermodule.outputPath = "" #file
pathhandlermodule.templatePath = "" #file
#endregion
#endregion

############################################################
pathhandlermodule.initialize = () ->
    log "pathhandlermodule.initialize"    
    cfg = allModules.configmodule
    pathhandlermodule.templatePath = pathModule.resolve(__dirname, cfg.outputTemplatePath)
    return

############################################################
#region internalFunctions
execGitCheckPromise = (path) ->
    options = 
        cwd: path
    
    return new Promise (resolve, reject) ->
        callback = (error, stdout, stderr) ->
            if error then reject(error)
            if stderr then reject(new Error(stderr))
            resolve(stdout)
        exec("git rev-parse --is-inside-work-tree", options, callback)

resolveHomeDir = (path) ->
    log "resolveHomeDir"
    if !path then return
    if path[0] == "~"
        path = path.replace("~", homedir)
    return path

onFileChange = (file, callback) ->
    log "onFileChange"

    directCallback = (eventType, filename) ->
        if filename and eventType == "change"
            log filename
            callback()
        return

    watcher = fs.watch(file, directCallback)
    watcherList.push(watcher)
    return

############################################################
checkSomethingExists = (something) ->
    try
        await fs.lstat(something)
        return true
    catch err then return false

checkDirectoryExists = (path) ->
    try
        stats = await fs.lstat(path)
        return stats.isDirectory()
    catch err then return false

checkFileExists = (path) ->
    try
        stats = await fs.lstat(path)
        return stats.isFile()
    catch err then return false

#endregion

############################################################
#region exposedFunctions
pathhandlermodule.onAnyFileChanges = (files, callback) ->
    log "pathhandlermodule.onAnyFileChanges"
    for file in files
        onFileChange(file, callback)
    return

pathhandlermodule.stopWatchingFiles =  ->
    log "pathhandlermodule.stopWatchingFiles"
    for watcher in watcherList
        watcher.close()
    watcherList.length = 0
    return

############################################################
#region preparationFunctions
pathhandlermodule.preparePugHeadPath = (providedPath) ->
    log "pathhandlermodule.preparePugHeadPath"    
    if !providedPath then throw "preparePugHeadPath - no providedPath"
    
    providedPath = resolveHomeDir(providedPath)
    if pathModule.isAbsolute(providedPath)
        pathhandlermodule.pugHeadPath = providedPath
    else
        pathhandlermodule.pugHeadPath = pathModule.resolve(process.cwd(), providedPath)
    
    log "our pugHead is: " + pathhandlermodule.pugHeadPath
    
    exists = await checkFileExists(pathhandlermodule.pugHeadPath)
    if !exists then throw "preparePugHead - no file existed at : " + providedPath
    return

pathhandlermodule.prepareCoffeeCodePath = (providedPath) ->
    log "pathhandlermodule.prepareCoffeeCodePath"
    pathhandlermodule.coffeeCodeFilePaths.length = 0

    if !providedPath then throw "prepareCoffeeCodePath - no providedPath"
    pathhandlermodule.coffeeCodePathExpression = providedPath
    providedPath = resolveHomeDir(providedPath)
    
    if !pathModule.isAbsolute(providedPath)
        providedPath = pathModule.resolve(process.cwd(), providedPath)
    
    files = glob.sync(providedPath)
    for filePath in files
        pathhandlermodule.coffeeCodeFilePaths.push(filePath)
    return

pathhandlermodule.prepareOutputPath = (providedPath) ->
    log "pathhandlermodule.prepareOutputPath"    
    
    if !providedPath then throw "prepareOutputPath - no providedPath"
    providedPath = resolveHomeDir(providedPath)
    if pathModule.isAbsolute(providedPath)
        pathhandlermodule.outputPath = providedPath
    else
        pathhandlermodule.outputPath = pathModule.resolve(process.cwd(), providedPath)

    # remove self from coffee paths - also if it was there then it surely existed ;-)
    for coffeePath,index in pathhandlermodule.coffeeCodeFilePaths
        if coffeePath ==  pathhandlermodule.outputPath
            pathhandlermodule.coffeeCodeFilePaths.splice(index, 1)
            return

    lastDir = pathModule.dirname(pathhandlermodule.outputPath)
    exists = await checkDirectoryExists(lastDir)
    if !exists then throw "Cannot write to output file - directory does not exist!"

    return

#endregion

############################################################
#region passingOtherFunctions
pathhandlermodule.resolve = pathModule.resolve
pathhandlermodule.relative = pathModule.relative
pathhandlermodule.dirname = pathModule.dirname
pathhandlermodule.basename = pathModule.basename

#endregion

#endregion

module.exports = pathhandlermodule