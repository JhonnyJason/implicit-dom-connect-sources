fastsearchtreemodule = {name: "fastsearchtreemodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["fastsearchtreemodule"]?  then console.log "[fastsearchtreemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region internalProperties
options  = {}

initialState = null

stateFlowTree = {}
initialNextStates = {}

allStateObjects = []
unpreparedStateObjects = []

superposedCount = 0

############################################################
#region globalState
input = ""
cursorPosition = 0
nextStates = null
enterDefaultNextState = null
currentBaseState = null
#endregion

############################################################
considerPatterns = []
ignorePatterns = []
exactPatterns = []
tokenPatterns = []

############################################################
tokenTerminationStates = {}
tokenStart = 0

#endregion

############################################################
fastsearchtreemodule.initialize = () ->
    log "fastsearchtreemodule.initialize"
    initialState = new BaseStateObject("initialState")
    setInitialState()
    return

############################################################
#region classes
class GeneralStateObject
    constructor: ->
        @name = "unnamed GeneralStateObject"
        @resultFunction = null
        @nextStates = null
        @followUpStates = {}
        @printed = false
        @prepared = false
        unpreparedStateObjects.push(this)
        allStateObjects.push(this)
        return

    print: (prefix, symbol)->
        r = "noResultFunction"
        if @resultFunction then r = "hasResultFunction"
        print "["+prefix+symbol+"] -> "+@type+"("+r+")"
        return

    prepare: ->
        if @prepared then return
        @nextStates = @followUpStates
        @prepared = true
        return
        
    addFollowUpState: (symbol, stateObject) ->
        mergeState(@followUpStates, symbol, stateObject)
        return

    superpose: (stateObject) ->
        if Object.is(stateObject, this)
            print " - warning! we tried to superpose the stateObject on itself"
            return this
        print "superposing onto " + @name + " <- "+stateObject.name
        result = new SuperposedStateObject()
        result = result.superpose(this)
        result = result.superpose(stateObject)
        return result

    enterState: ->
        nextStates = @nextStates
        if @resultFunction then @resultFunction()
        return

class SuperposedStateObject extends GeneralStateObject
    constructor: ->
        super()
        superposedCount++
        @name = "superposed "+superposedCount+" "
        @type = "SuperposedStateObject"
        @superposedStateObjects = []
        @assignedResultFunctions = []
        print "constructed "+@name
        return

    resultFunction: ->
        for stateObject in @superposedStateObjects
            if stateObject.resultFunction then stateObject.resultFunction()
        for resultFunction in @assignedResultFunctions
            resultFunction()
        return

    print: (prefix, symbol)->
        s = 0
        r = @assignedResultFunctions.length
        for stateObject in @superposedStateObjects
            s++
            if stateObject.resultFunction then r++
        states = " "+s+" states "
        results = " "+r+" resultFunctions "
        print "["+prefix+symbol+"] -> "+@name+"("+states+" | "+results+")"
        for stateObject in @superposedStateObjects
            stateObject.print("subState", "")

        if @nextStates
            print "nextStates:"
            for symbol,stateObject of @nextStates
                print "  "+symbol+" -> "+stateObject.name 
        print ""
        return

    prepare: ->
        print "... preparing "+@name+" isPrepared:"+@prepared
        @print("-", "")
        return if @prepared
        @followUpStates = {}
        for stateObject in @superposedStateObjects
            stateObject.prepare()
            @followUpStates = createMergedNextStates(@followUpStates, stateObject.nextStates)
        @nextStates = @followUpStates  
        @prepared = true
        print "... prepared "+@name
        @print("-", "")
        return

    superpose: (stateObject) ->
        if Object.is(stateObject, this)
            print " - warning! we tried to superpose the stateObject on itself"
            return this
        if @preparing
            result = new SuperposedStateObject()
            result = result.superpose(this)
            result = result.superpose(stateObject)
            result.preparing = true
            return result

        print "superposing onto " + @name + " <- "+stateObject.name
        if !@superposedStateObjects.includes(stateObject)
            @superposedStateObjects.push(stateObject)


        # if stateObject.type == "SuperposedStateObject"
        #     for subStateObject in stateObject.superposedStateObjects
        #         if !@superposedStateObjects.includes(subStateObject)
        #             @superposedStateObjects.push(subStateObject)        
        # else if !@superposedStateObjects.includes(stateObject)
        #     @superposedStateObjects.push(stateObject)
        return this

    # assignResultFunction: (resultFunction) ->
    #     @assignedResultFunctions.push(resultFunction)
    #     return

    #region oldCode
    # getFollowUpStateObject: (symbol) ->
    #     log "!! trying to get FollowUpObject pf SuperposedStateObject..."
    #     stateObject = @followUpStates[symbol]
    #     if !stateObject
    #         stateObject = new ExactMatchStateObject()
    #         @followUpStates[symbol] = stateObject
    #     return stateObject    

    # reflectOtherState: (stateObject) ->
    #     if Object.is(stateObject, this)
    #         log "!!! - we tried to reflect the state of the Superpositioned StateObject in itself!!"
    #         return
    #     return if @superposedStateObjects.includes(stateObject)
    #     if stateObject.type == "SuperposedStateObject"
    #         for subStateObject in stateObject.superposedStateObjects
    #             @superposedStateObjects.push(subStateObject)
    #         return        
    #     @superposedStateObjects.push(stateObject)
    #     return
    #endregion

class BaseStateObject extends GeneralStateObject
    constructor: (@name) ->
        super()
        @type = "BaseStateObject"
        print "constructed "+@name
        return
    
    print: (prefix, symbol)->
        f = Object.keys(@followUpStates)
        p = "unprepared"
        if @prepared then p = "is prepared"
        print "["+prefix+symbol+"] -> "+@name+" ["+f+"]"
        print "["+prefix+symbol+"] "+p

        if @nextStates
            print "nextStates:"
            for symbol,stateObject of @nextStates
                print "  "+symbol+" -> "+stateObject.name 

        if @prepared
            for symbol,nextStateObject of @nextStates
                print "["+prefix+symbol+"] next -> "+nextStateObject.name
        print ""
        return

    # prepare: ->
    #     print "... preparing "+@name+" isPrepared:"+@prepared
    #     if @prepared then return
    #     @nextStates = @followUpStates
    #     @prepared = true
    #     print "... prepared "+@name
    #     @print("-", "")
    #     return

    enterState: ->
        nextStates = @nextStates
        currentBaseState = this
        return

class ExactMatchStateObject extends GeneralStateObject
    constructor: (@pattern, @index) ->
        super()
        @type = "ExactMatchStateObject"
        @name = "exactMatch "+@pattern+"["+@index+"]"
        print "constructed "+@name
        return
    
    print: (prefix, symbol)->
        r = "noResultFunction"
        if @resultFunction then r = "hasResultFunction"
        f = Object.keys(@followUpStates)
        p = "unprepared"
        if @prepared then p = "is prepared"
        print "["+prefix+symbol+"] -> "+@name+" ("+r+") ["+f+"]"
        print "["+prefix+symbol+"] "+p

        if @nextStates
            print "nextStates:"
            for symbol,stateObject of @nextStates
                print "  "+symbol+" -> "+stateObject.name 

        if @prepared
            for symbol,nextStateObject of @nextStates
                print "["+prefix+symbol+"] next -> "+nextStateObject.name
        print ""
        return

    # prepare: ->
    #     print "... preparing "+@name+" isPrepared:"+@prepared
    #     if @prepared then return
    #     @nextStates = @followUpStates
    #     @prepared = true
    #     print "... prepared "+@name
    #     @print("-", "")
    #     return

    superpose: (stateObject) ->
        if Object.is(stateObject, this)
            print " - warning! we tried to superpose the stateObject on itself"
            return this
        print "superposing onto " + @name + " <- "+stateObject.name
        result = new SuperposedStateObject()
        result = result.superpose(this)
        result = result.superpose(stateObject)
        return result
    
    assignResultFunction: (resultFunction) ->
        @resultFunction = resultFunction
        return

    #region oldCode
    # getFollowUpStateObject: (symbol) ->
    #     stateObject = @followUpStates[symbol]
    #     if !stateObject
    #         stateObject = new ExactMatchStateObject()
    #         @followUpStates[symbol] = stateObject
    #     return stateObject    
    #endregion

#endregion

############################################################
#region internalFunctions
printAllStateObjects = ->
    print "=> print allStateObjects"
    for stateObject in allStateObjects
        stateObject.print("", "-")
    print ""
    return

printStateFlowTree = ->
    print "=> print the stateFlowTree"
    for stateObject in allStateObjects
        stateObject.printed = false
    initialSymbols = Object.keys(initialState.nextStates)
    print "> printing initialNextStates for " + initialSymbols
    for symbol in initialSymbols
        stateObject = initialState.nextStates[symbol]
        if stateObject.printed then continue
        stateObject.print("", symbol)
        stateObject.printed = true
        printNextLevel(symbol, stateObject)
    print ""
    return

printNextLevel = (prefix, stateObject) ->
    print "> printing nextStates"
    if !stateObject.nextStates
        print "there where no nextStates to print!"
        return
    nextLevelSymbols = Object.keys(stateObject.nextStates)
    print "["+prefix+"] -> nextLevelSymbols: " + nextLevelSymbols 
    for symbol in nextLevelSymbols
        nextStateObject = stateObject.nextStates[symbol]
        if nextStateObject.printed 
            print "> "+nextStateObject.name+" was marked as printed..."
            continue
        nextStateObject.print(prefix, symbol)
        nextStateObject.printed = true
        printNextLevel(prefix+symbol, nextStateObject)
    return

printThisLevelOnly = (prefix, level) ->
    nextLevelSymbols = Object.keys(level)
    for symbol in nextLevelSymbols
        nextStateObject = level[symbol]
        nextStateObject.print(prefix, symbol)
    return

############################################################
prepareStateFlowTree = ->
    print "=> prepare the stateFlowTree"

    for stateObject in allStateObjects
        stateObject.prepared = false
        stateObject.preparing = true
        if !unpreparedStateObjects.includes(stateObject)
            unpreparedStateObjects.push(stateObject)

    while unpreparedStateObjects.length
        stateObject = unpreparedStateObjects.pop()
        stateObject.prepare()
    print ""

    for stateObject in allStateObjects
        stateObject.preparing = false

    return

############################################################
createMergedNextStates = (states1, states2) ->
    log "createMergedNextStates"
    resultingStates = {}
    mergeNextStates(resultingStates, states1)
    mergeNextStates(resultingStates, states2)
    return resultingStates

    # for symbol,stateObject of states2
    #     if resultingStates[symbol] and !Object.is(stateObject, resultingStates[symbol])
    #         if stateObject.type == "SuperposedStateObject"
    #             stateObject.reflectOtherState(resultingStates[symbol])
    #             resultingStates[symbol] = stateObject
    #         else if resultingStates[symbol].type == "SuperposedStateObject"
    #             resultingStates[symbol].reflectOtherState(stateObject)
    #         else
    #             superposition = new SuperposedStateObject()
    #             superposition.reflectOtherState(resultingStates[symbol])
    #             superposition.reflectOtherState(stateObject)
    #             resultingStates[symbol] = superposition
    #     else resultingStates[symbol] = stateObject

mergeState = (states, symbol, stateObject) ->
    log "mergeState"
    if states[symbol] then states[symbol] = states[symbol].superpose(stateObject)
    else states[symbol] = stateObject
    return

mergeNextStates = (states1, states2) ->
    log "mergeNextStates"
    for symbol,stateObject of states2
        mergeState(states1, symbol, stateObject)
    return

############################################################
#region stateFlowFunctions
setInitialState = ->
    log "setInitialState"
    initialState.enterState()
    enterDefaultNextState = enterBaseState
    return

flowToNextState = (symbol) ->
    if nextStates[symbol] then nextStates[symbol].enterState()
    else enterDefaultNextState()
    return

enterBaseState = ->
    log "enterBaseState"
    currentBaseState.enterState()
    return

############################################################
terminateScan = -> 
    ## TODO implement
    return

#region oldCode
setIgnoreState = (escapeKey) ->
    log "setIgnoreState"
    nextStates = {}
    nextStates[escapeKey] = setInitialState
    enterDefaultNextState = -> return
    return

terminateTokenMatchingState = ->
    log "terminateTokenMatchingState"
    char = input[cursorPosition]
    log "cursorPosition: " + cursorPosition
    log "char: " + char
    result = input.substring(tokenStart, cursorPosition)
    log "result: " + result

    for pattern in tokenPatterns
        if pattern.terminationPattern[0] == char        
            if pattern.resultFunction
                pattern.resultFunction(result, input, cursorPosition) 

    nextStates = {}
    enterDefaultNextState = -> return
    return

setTokenMatchingState = ->
    log "setTokenMatchingState"
    tokenStart = cursorPosition
    startKey = input[cursorPosition]
    nextStates = tokenTerminationStates[startKey]
    enterDefaultNextState = -> return
    return

setExactMatchingState = (exactPattern, index) ->
    log "setExactMatchingState"
    # log "index: " + index
    # olog exactPattern
    # olog nextStates

    if exactPattern.pattern.length == index and exactPattern.resultFunction
        exactPattern.resultFunction(exactPattern.pattern, input, cursorPosition)
        nextStates = {}
        enterDefaultNextState = -> return
        return

    nextKey = exactPattern.pattern[index]
    nextIndex = index + 1
    nextStates = {}
    nextStates[nextKey] = -> setExactMatchingState(exactPattern, nextIndex)
    enterDefaultNextState = setInitialState
    # log "nextKey: " + nextKey
    # log "nextStates Keys: " + Object.keys(nextStates)
    # log "initialState Keys: " + Object.keys(initialNextStates)
    return

#endregion
#endregion

############################################################
#region patterrnsToStateFlow
addSelfSuperposingExactPattern = (pattern, resultFunction) ->
    log "addSelfSuperposingExactPattern"

    #region exactPathToExecution
    stateSequence = []
    for symbol,i in pattern
        state = new ExactMatchStateObject(pattern, i)
        # if i > 0 then stateSequence[i-1].addFollowUpState(symbol, state)
        stateSequence.push(state)

    stateSequence[stateSequence.length-1].assignResultFunction(resultFunction)
    #endregion

    #region superposeWithInitialState
    superposedSequence = []
    for state,i in stateSequence
        superposedSequence.push(state.superpose(initialState))
    
    #connect everything with the superposed states
    for symbol,i in pattern
        if i > 0 then stateSequence[i-1].addFollowUpState(symbol, superposedSequence[i])

    initialState.addFollowUpState(pattern[0], superposedSequence[0])
    #endregion

    print ""
    printAllStateObjects()
    prepareStateFlowTree()
    printStateFlowTree()
    return


exactPatternToStateFlow = (exactPattern) ->
    log "exactPatternToStateFlow"
    pattern = exactPattern.pattern
    resultFunction = exactPattern.resultFunction
    executableResultFunction = -> resultFunction("", input, cursorPosition)
    
    addSelfSuperposingExactPattern(pattern, executableResultFunction)
    return

    # startSymbol = pattern[0]

    # startState = new ExactMatchStateObject(pattern, 0)
    # initialState.addFollowUpState(startSymbol, startState)
    
    # stateObject = startState
    # index = 1
    # while index < pattern.length
    #     latestStateObject = stateObject
    #     symbol = pattern[index]
    #     stateObject = new ExactMatchStateObject(pattern, index)
    #     latestStateObject.addFollowUpState(symbol, stateObject)        
    #     ++index

    # stateObject.assignResultFunction(executableResultFunction)

    # print ""
    # printAllStateObjects()
    # prepareStateFlowTree()
    # printStateFlowTree()
    # return

#region oldCode
tokenPatternToStateFlow = (ambiguousPattern) ->
    throw "tokenPatternToStateFlow - not implemented yet"
    ##TODO implement
    # key = ambiguousPattern.startPattern[0]
    # if !initialNextStates[key]
    #     initialNextStates[key] = setTokenMatchingState
    #     tokenTerminationStates[key] = {}
    # terminationKey = ambiguousPattern.terminationPattern[0]
    # tokenTerminationStates[key][terminationKey] = terminateTokenMatchingState
    return

ignorePatternToStateFlow = (ignorePattern) ->
    throw "ignorePatternToStateFlow - not implemented yet"
    ##TODO implement
    # key = ignorePattern.startPattern[0]
    # escapeKey = ignorePattern.terminationPattern[0]
    # nextStateFunction = -> setIgnoreState(escapeKey)
    # initialNextStates[key] = nextStateFunction
    return    

considerPatternToStateFlow = (considerPattern) ->
    throw "considerPatternToStateFlow - not implemented yet"
    ##TODO implement
    return

#endregion
#endregion

#endregion

############################################################
#region exposedFunctions
fastsearchtreemodule.scan = (newInput) ->
    log "fastsearchtreemodule.scan"
    setInitialState()
    input = newInput
    for symbol,index in input
        cursorPosition = index
        flowToNextState(symbol)
    terminateScan()
    return

fastsearchtreemodule.reset = (newOptions) ->
    log "fastsearchtreemodule.reset"
    options = newOptions

    cursorPosition = 0
    input = ""

    initialState = null
    nextStates = null
    currentBaseState = null
    enterDefaultNextState = null

    allStateObjects = []
    superposedCount = 0
    unpreparedStateObjects = []

    #region unused variables    
    tokenTerminationStates = {}
    tokenStart = 0

    exactPatterns = []
    tokenPatterns = []
    ignorePatterns = []
    #endregion

    initialState = new BaseStateObject("initialState")
    setInitialState()
    return

############################################################
#region addingPatterns
fastsearchtreemodule.addExactMatchPattern = (pattern, resultFunction) ->
    log "fastsearchtreemodule.addExactMatchPattern"
    exactPattern = 
        pattern: pattern
        resultFunction: resultFunction
    exactPatternToStateFlow(exactPattern)
    return

#region unimplementedCode
fastsearchtreemodule.addTokenMatchPattern = (startPattern, terminationPattern, resultFunction) ->
    log "fastsearchtreemodule.addTokenMatchPattern"
    tokenPattern = 
        startPattern: startPattern
        terminationPattern: terminationPattern
        resultFunction: resultFunction
    tokenPatterns.push(ambiguousPattern)
    #TODO add that one pattern to the stateFlowTree
    return

fastsearchtreemodule.addIgnoreSequence = (startPattern, terminationPattern) ->
    log "fastsearchtreemodule.addIgnoreSequence"
    ignorePattern = 
        startPattern: startPattern
        terminationPattern: terminationPattern
    ignorePatterns.push(ignorePattern)
    #TODO add that one pattern to the stateFlowTree
    return

fastsearchtreemodule.addConsiderSequence = (startPattern, terminationPattern) ->
    log "fastsearchtreemodule.addConsiderSequence"
    considerPattern = 
        startPattern: startPattern
        terminationPattern: terminationPattern
    considerPatterns.push(ignorePattern)
    ##TODO add that one pattern to the stateFlowTree
    return

#endregion

#endregion

#endregion

module.exports = fastsearchtreemodule