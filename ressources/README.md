# implicit-dom-connect - a small tool to identify usage of elements in .pug files inside .coffee files to then be implicitly availabe 

# Why?
Not using a weird things like angular,react,vue and the like I have witnessed to type very often:

- idOfElement = document.getElementById("id-of-element)
- idOfElement.addEventListener("click", idOfElementOnClick)
- idOfElementOnClick = -> idOfElement.classList.add("active")

while I could type instead

- idOfElementOnClick = -> idOfElement.classList.add("active")

The connection to the DOM is implicitely and unambigously defined already when we have respect an implicit semantic meaning to our variable which reflects what it really is.

# What?

A small CLI helper tool.
It reads through the .pug to retrieve everything which is an id.
Then it reads through the .coffee files to figure out if the camelCased id is used as a variable somewhere. There it remembers the ones which are being used.

Last it writes to the specified output file. Where all the variables are injected into the global Scope on initialize.

- id is what starts with # and ends with ' ', '(', '.' or '\n'
- as variable is recognized camalCased id followed by '.'

# How?

Installation
------------

Current git version
``` sh
$ npm install git+https://github.com/JhonnyJason/implicit-dom-connect.git
```
Npm Registry
``` sh
$ npm install implicit-dom-connect
```

Usage
-----

```
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

    optional:
        --watch, -w
            flag that we should watch on file-change.


TO NOTE:
    The flags will overwrite the flagless argument.

Examples
    $ implicit-dom-connect pug-heads/document-head.pug ./*/*.coffee ./domconnect/domconnect.coffee 
    ...
```

Example
-----
The Pug
```pug
include otherFile
//- #NoId
#super-id-element.special-super(superness="over9000")


```
The otherFile
```pug
.crappy-class(background="#fff")
    #awesome-id-element
```

The Coffee
```coffeescript
superness = superIdElement.getAttribute("superness")
console.log("superIdElements' superness is:" + superness)
awesomeIdElement.setAttribute("superness", superness)

```

The Call
```sh
$ implicit-dom-connect Pug Coffee Result
```

The Result
```coffeescript
Result = {name: "Result"}

############################################################
Result.initialize = () ->
    global.awesomeIdElement = document.getElementById("awesome-id-element")
    global.superIdElement = document.getElementById("super-id-element")
    console.log("-> used Elements available in their global variable!")
    return
    
module.exports = Result

```

# Further steps
- Only react on actual fileChanges
- More efficient textsearch algorithm -> fasttreesearch ;-)
- Add capability to inject EventListeners directly to other modules
- ...


All sorts of inputs are welcome, thanks!

---

# License

## The Unlicense JhonnyJason style

- Information has no ownership.
- Information only has memory to reside in and relations to be meaningful.
- Information cannot be stolen. Only shared or destroyed.

And you wish it has been shared before it is destroyed.

The one claiming copyright or intellectual property either is really evil or probably has some insecurity issues which makes him blind to the fact that he also just connected information which was freely available to him.

The value is not in him who "created" the information the value is what is being done with the information.
So the restriction and friction of the informations' usage is exclusively reducing value overall.

The only preceived "value" gained due to restriction is actually very similar to the concept of blackmail (power gradient, control and dependency).

The real problems to solve are all in the "reward/credit" system and not the information distribution. Too much value is wasted because of not solving the right problem.

I can only contribute in that way - none of the information is "mine" everything I "learned" I actually also copied.
I only connect things to have something I feel is missing and share what I consider useful. So please use it without any second thought and please also share whatever could be useful for others. 

I also could give credits to all my sources - instead I use the freedom and moment of creativity which lives therein to declare my opinion on the situation. 

*Unity through Intelligence.*

We cannot subordinate us to the suboptimal dynamic we are spawned in, just because power is actually driving all things around us.
In the end a distributed network of intelligence where all information is transparently shared in the way that everyone has direct access to what he needs right now is more powerful than any brute power lever.

The same for our programs as for us.

It also is peaceful, helpful, friendly - decent. How it should be, because it's the most optimal solution for us human beings to learn, to connect to develop and evolve - not being excluded, let hanging and destroy oneself or others.

If we really manage to build an real AI which is far superior to us it will unify with this network of intelligence.
We never have to fear superior intelligence, because it's just the better engine connecting information to be most understandable/usable for the other part of the intelligence network.

The only thing to fear is a disconnected unit without a sufficient network of intelligence on its own, filled with fear, hate or hunger while being very powerful. That unit needs to learn and connect to develop and evolve then.

We can always just give information and hints :-) The unit needs to learn by and connect itself.

Have a nice day! :D