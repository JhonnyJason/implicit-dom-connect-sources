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
initialNextStates = {}

############################################################
unambiguousPatterns = []
ambiguousPatterns = []
ignorePatterns = []

############################################################
nextStates = null
cursorPosition = 0
input = ""
breakState = null

############################################################
ambiguousTerminationStates = {}
ambiguousStart = 0

#endregion

############################################################
fastsearchtreemodule.initialize = () ->
    log "fastsearchtreemodule.initialize"
    setInitialState()
    return

############################################################
#region internalFunctions
checkNextState = (char) ->
    if nextStates[char] then nextStates[char]()
    else breakState()
    return

############################################################
#region stateFunctions
setInitialState = ->
    log "setInitialState"
    nextStates = initialNextStates
    breakState = -> return
    return

setIgnoreState = (escapeKey) ->
    log "setIgnoreState"
    nextStates = {}
    nextStates[escapeKey] = setInitialState
    breakState = -> return
    return

terminateAmbiguousState = ->
    log "terminateAmbiguousState"
    char = input[cursorPosition]
    log "cursorPosition: " + cursorPosition
    log "char: " + char
    result = input.substring(ambiguousStart, cursorPosition)
    log "result: " + result

    for pattern in ambiguousPatterns
        if pattern.terminationPattern[0] == char        
            if pattern.resultFunction
                pattern.resultFunction(result, input, cursorPosition) 

    nextStates = {}
    breakState = -> return
    return

setAmbiguousMatchingState = ->
    log "setAmbiguousMatchingState"
    ambiguousStart = cursorPosition
    startKey = input[cursorPosition]
    nextStates = ambiguousTerminationStates[startKey]
    breakState = -> return
    return

setUnambiguousMatchingState = (unambiguousPattern, index) ->
    log "setUnambiguousMatchingState"
    # log "index: " + index
    # olog unambiguousPattern
    # olog nextStates

    if unambiguousPattern.pattern.length == index and unambiguousPattern.resultFunction
        unambiguousPattern.resultFunction(unambiguousPattern.pattern, input, cursorPosition)
        nextStates = {}
        breakState = -> return
        return

    nextKey = unambiguousPattern.pattern[index]
    nextIndex = index + 1
    nextStates = {}
    nextStates[nextKey] = -> setUnambiguousMatchingState(unambiguousPattern, nextIndex)
    breakState = setInitialState
    # log "nextKey: " + nextKey
    # log "nextStates Keys: " + Object.keys(nextStates)
    # log "initialState Keys: " + Object.keys(initialNextStates)
    return

#endregion

############################################################
#region patterrnsToStateFlow
flushPatternsToStateFlow = ->
    log "flushPatternsToStateFlow"
    ignorePatterns.forEach(ignorePatternToStateFlow)
    unambiguousPatterns.forEach(unambiguousPatternToStateFlow)
    ambiguousPatterns.forEach(ambiguousPatternToStateFlow)    
    return

############################################################
ignorePatternToStateFlow = (ignorePattern) ->
    key = ignorePattern.startPattern[0]
    escapeKey = ignorePattern.terminationPattern[0]
    nextStateFunction = -> setIgnoreState(escapeKey)
    initialNextStates[key] = nextStateFunction
    return    

unambiguousPatternToStateFlow = (unambiguousPattern) ->
    key = unambiguousPattern.pattern[0]
    nextStateFunction = -> setUnambiguousMatchingState(unambiguousPattern, 1)
    initialNextStates[key] = nextStateFunction
    return

ambiguousPatternToStateFlow = (ambiguousPattern) ->
    key = ambiguousPattern.startPattern[0]
    if !initialNextStates[key]
        initialNextStates[key] = setAmbiguousMatchingState
        ambiguousTerminationStates[key] = {}
    terminationKey = ambiguousPattern.terminationPattern[0]
    ambiguousTerminationStates[key][terminationKey] = terminateAmbiguousState
    return

#endregion

#endregion

############################################################
#region exposedFunctions
fastsearchtreemodule.scan = (newInput) ->
    log "fastsearchtreemodule.scan"
    setInitialState()
    input = newInput
    for char,index in input
        cursorPosition = index
        checkNextState(char)
    return

fastsearchtreemodule.reset = ->
    log "fastsearchtreemodule.reset"
    initialNextStates = {}
    
    cursorPosition = 0
    input = ""
    
    ambiguousTerminationStates = {}
    ambiguousStart = 0

    unambiguousPatterns = []
    ambiguousPatterns = []
    ignorePatterns = []
    
    setInitialState()
    return

############################################################
#region addingPatterns
fastsearchtreemodule.addUnambiguousFindPattern = (pattern, resultFunction) ->
    log "fastsearchtreemodule.addUnambigousFindPattern"
    unambiguousPattern = 
        pattern: pattern
        resultFunction: resultFunction
    unambiguousPatterns.push(unambiguousPattern)    
    flushPatternsToStateFlow()
    return

fastsearchtreemodule.addAmbiguousFindPattern = (startPattern, terminationPattern, resultFunction) ->
    log "fastsearchtreemodule.addAmbiguousFindPattern"
    ambiguousPattern = 
        startPattern: startPattern
        terminationPattern: terminationPattern
        resultFunction: resultFunction
    ambiguousPatterns.push(ambiguousPattern)
    flushPatternsToStateFlow()
    return

fastsearchtreemodule.addIgnoreSequence = (startPattern, terminationPattern) ->
    log "fastsearchtreemodule.addIgnoreSequence"
    ignorePattern = 
        startPattern: startPattern
        terminationPattern: terminationPattern
    ignorePatterns.push(ignorePattern)
    flushPatternsToStateFlow()
    return
#endregion

#endregion

module.exports = fastsearchtreemodule