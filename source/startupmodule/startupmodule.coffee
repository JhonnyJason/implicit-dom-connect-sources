
startupmodule = {name: "startupmodule"}
############################################################
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
printSuccess = (arg) -> console.log(chalk.green(arg))
printError = (arg) -> console.log(chalk.red(arg))
print = (arg) -> console.log(arg)
#endregion

############################################################
chalk = require('chalk')

############################################################
#region localModules
mainProcess = null
cfg = null 
cliArguments = null
#endregion

############################################################
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    mainProcess = allModules.mainprocessmodule
    cfg = allModules.configmodule
    cliArguments = allModules.cliargumentsmodule
    return

############################################################
startupmodule.cliStartup = ->
    log "startupmodule.cliStartup"
    try
        e = cliArguments.extractArguments()
        await mainProcess.execute(e)
        printSuccess('All done!');
    catch err
        printError("Error!")
        printError(err)
        if err.stack then printError(err.stack)
        process.exit(-1)

module.exports = startupmodule

