cliargumentsmodule = {name: "cliargumentsmodule"}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["cliargumentsmodule"]?  then console.log "[cliargumentsmodule]: " + arg
    return

############################################################
meow = require("meow")

############################################################
cliargumentsmodule.initialize = () ->
    log "cliargumentsmodule.initialize"
    return

############################################################
#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ implicit-dom-connect <arg1> <arg2> <arg3>
    
        Options
            required: 
                arg1, --pug-head <pugHead>, -p <pugHead>
                    path of where we may find the pug head for the document.
                    The path may be relative or absolute.
                    
                arg2, --coffee-code <coffeeCode>, -c <coffeeCode>
                    single path or glob expression of where we may find the
                    coffeescript files which are potentially using the
                    ids of the document.
                    The path may be relative or absolute.

                arg3, --output <output>, -o <output>
                    path of the output file. This will be a coffee script
                    module doing it's connection part on an initialize 
                    function.
                    The path may be relative or absolute.


        TO NOTE:
            The flags will overwrite the flagless argument.
     
        Examples
            $ implicit-dom-connect pug-heads/document-head.pug ./*/*.coffee ./domconnect/domconnect.coffee 
            ...
    """

getOptions = ->
    log "getOptions"
    return {
        flags:
            pugHead:
                type: "string"
                alias: "p"
            coffeeCode:
                type: "string"
                alias: "c"
            output:
                type: "string"
                alias: "o"
    }

extractMeowed = (meowed) ->
    log "extractMeowed"

    ############################################################
    pugHead = null
    coffeeCode = null
    output = null

    ############################################################
    if meowed.input[0]
        pugHead = meowed.input[0]
    if meowed.input[1]
        coffeeCode = meowed.input[1]
    if meowed.input[2]
        output = meowed.input[2]
    
    ############################################################
    if meowed.flags.pugHead then pugHead = meowed.flags.pugHead
    if meowed.flags.coffeeCode then coffeeCode = meowed.flags.coffeeCode
    if meowed.flags.output then output = meowed.flags.output

    ############################################################
    if !pugHead then throw "Usage failure!"
    if !coffeeCode then throw "Usage failure!"
    if !output then throw "Usage failure!"
    
    return {pugHead, coffeeCode, output}

#endregion

############################################################
cliargumentsmodule.extractArguments = ->
    log "cliargumentsmodule.extractArguments"
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    return extract

module.exports = cliargumentsmodule