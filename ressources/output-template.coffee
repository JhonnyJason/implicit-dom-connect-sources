{{moduleName}} = {name: "{{moduleName}}"}

############################################################
{{moduleName}}.initialize = () ->
    {{#usedIds}}
    global.{{variable}} = document.getElementById("{{documentId}}")
    {{/usedIds}}
    console.log("-> used Elements available in their global variable!")
    return
    
module.exports = {{moduleName}}