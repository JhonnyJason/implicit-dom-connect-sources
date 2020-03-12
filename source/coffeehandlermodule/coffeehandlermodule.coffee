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
    search = allModules.fastsearchtreemodule
    return

setUpSearchTree = ->
    log "setUpSearchTree"
    # search.reset({find: "all"})

    # search.addExactMatchPattern("/i", onTwoDifferentCharsMatch)
    search.addExactMatchPattern("///", onThreeSameCharsMatch)
    # search.addExactMatchPattern("//", onTwoSameCharsMatch)
    # search.addExactMatchPattern("/", onOneCharMatch)
    # search.addExactMatchPattern("/i", onSlashI)
    # search.addExactMatchPattern("/as", onSlashAS)
    # search.addExactMatchPattern("as", onAS)
    # search.addTokenMatchPattern("#", " ", onId)
    # search.addConsiderSequence("'''", "'''")
    # search.addIgnoreSequence("\"", "\"")
    return

onOneCharMatch = (result, input, cursorPosition) ->
    log "onOneChar"
    print "cursorPosition:" + cursorPosition
    print " - - - - - - - -  - - - - - -"
    return

onTwoDifferentCharsMatch = (result, input, cursorPosition) ->
    log "onTwoDifferentCharsMatch"
    print  "cursorPosition:" + cursorPosition
    print " - - - - - - - -  - - - - - -"
    return

onTwoSameCharsMatch = (result, input, cursorPosition) ->
    log "onTwoSameCharsMatch"
    print "cursorPosition:" + cursorPosition
    print " - - - - - - - -  - - - - - -"
    return

onThreeSameCharsMatch = (result, input, cursorPosition) ->
    log "onTwoSameCharsMatch"
    print "cursorPosition:" + cursorPosition
    print " - - - - - - - -  - - - - - -"
    return

############################################################
coffeehandlermodule.scanForUsedIds = ->
    log "coffeehandlermodule.scanForUserIds"
    # allIds = pug.getAllIds()
    # allFiles = path.coffeeCodeFilePaths
    # olog allIds
    # olog allFiles
    coffeeString = """
    ////
    """ 
    setUpSearchTree()
    search.scan(coffeeString)
    log "scan terminated!"
    return

module.exports = coffeehandlermodule