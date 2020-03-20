{{moduleName}} = {name: "{{moduleName}}"}

############################################################
{{moduleName}}.initialize = () ->
    {{#usedIds}}
    global.{{variable}} = document.getElementById("{{documentId}}")
    {{/usedIds}}
    return
    
module.exports = {{moduleName}}