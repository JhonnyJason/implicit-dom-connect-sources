debugmodule = {name: "debugmodule"}

##############################################################################
debugmodule.initialize = () ->
    # console.log "debugmodule.initialize - nothing to do"
    return     
##############################################################################
debugmodule.modulesToDebug = 
    unbreaker: true
    # cliargumentsmodule: true
    # configmodule: true
    coffeehandlermodule: true
    # fastsearchtreemodule: true
    # mainprocessmodule: true
    # startupmodule: true
    # pathhandlermodule: true
    # pughandlermodule: true
    
module.exports = debugmodule