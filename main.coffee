Backbone = require 'backbone'
_ = require 'underscore'
global.$ = require 'jquery'
Backbone.$  = $

annyang = require 'annyang'

getRndInteger = (min, max) =>
    return Math.floor(Math.random() * (max - min + 1) ) + min

jokes = """
What do you call a dinosaur that is sleeping? A dino-snore!
What is fast, loud and crunchy? A rocket chip!
Why did the teddy bear say no to dessert? Because she was stuffed.
What has ears but cannot hear? A cornfield.
What did the left eye say to the right eye? Between us, something smells!
What do you get when you cross a vampire and a snowman? Frost bite!
What did one plate say to the other plate? Dinner is on me!
Why did the student eat his homework? Because the teacher told him it was a piece of cake!
When you look for something, why is it always in the last place you look? Because when you find it, you stop looking.
What is brown, hairy and wears sunglasses? A coconut on vacation.
Two pickles fell out of a jar onto the floor. What did one say to the other? Dill with it.
What did the Dalmatian say after lunch? That hit the spot!
Why did the kid cross the playground? To get to the other slide.
How does a vampire start a letter? Tomb it may concern...
What do you call a droid that takes the long way around? R2 detour.
How do you stop an astronaut's baby from crying? You rocket!
Why was 6 afraid of 7? Because 7, 8, 9
What is a witch's favorite subject in school? Spelling!
When does a joke become a 'dad' joke? When the punchline is a parent.
How do you make a lemon drop? Just let it fall.
What did the limestone say to the geologist? Don't take me for granite!
What do you call a duck that gets all A's? A wise quacker.
Why does a seagull fly over the sea? Because if it flew over the bay, it would be a baygull.
What kind of water cannot freeze? Hot water.
What kind of tree fits in your hand? A palm tree!
Why did the cookie go to the hospital? Because he felt crummy.
Why was the baby strawberry crying? Because her parents were in a jam.
What did the little corn say to the mama corn? Where is pop corn?
What is worse than raining cats and dogs? Hailing taxis!
How much does it cost a pirate to get his ears pierced? About a buck an ear.
Where would you find an elephant? The same place you lost her!
How do you talk to a giant? Use big words!
What animal is always at a baseball game? A bat.
What falls in winter but never gets hurt? Snow!
What do you call a ghost's true love? His ghoul-friend.
What did the drummer call his twin daughters? Anna one, Anna two!
How did Darth Vader know what Luke got him for Christmas? He felt his presents!
I wanted to go on a diet, but I feel like I have way too much on my plate right now.
Want to hear a joke about construction? I'm still working on it.
What's Forrest Gump's password? 1forrest1
What sound does a witches car make? Broom Broom
To whoever stole my copy of Microsoft Office, I will find you. You have my Word!
What does a zombie vegetarian eat? 'GRRRAAAIINS!'
This graveyard looks overcrowded. People must be dying to get in there.
What does a nosey pepper do? It gets jalapeno business!
I tell dad jokes, but I don't have any kids. I'm a faux pa.
Whenever the cashier at the grocery store asks my dad if he would like the milk in a bag he replies, 'No, just leave it in the carton!'
Two goldfish are in a tank. One says to the other, 'do you know how to drive this thing?'
What's that Nevada city where all the dentists visit? Floss Vegas.
You're American when you go into the bathroom, and you're American when you come out, but do you know what you are while you're in there? European.
Why did the picture go to jail? Because it was framed.
What do you call a bear without any teeth? A gummy bear!
What do you call a hippie's wife? Mississippi.
The shovel was a ground-breaking invention.
Dad, can you put the cat out? I didn't know it was on fire.
Does anyone need an ark? I Noah guy!
5/4 of people admit that they're bad with fractions.
What do you call a man with a rubber toe? Roberto.
I would avoid the sushi if I was you. It's a little fishy.
What do you call a fish with two knees? A two-knee fish!
The rotation of earth really makes my day.
I thought about going on an all-almond diet. But that's just nuts.
Did you know the first French fries weren't actually cooked in France? They were cooked in Greece.
I've never gone to a gun range before. I decided to give it a shot!
What's black and white and goes around and around? A penguin in a revolving door.
How does a tree sign into the internet? It logs in!
Why did the scientist take out the bell? He wanted to the win the no-bell peace prize!
""".split(/\n/)

class Question
  constructor: (options) ->
    @a = options?.a or getRndInteger(2,9)
    @b = options?.b or getRndInteger(9,19)
    @operator = options?.operator or _(['+','-']).sample()
    if @operator is '-'
      if @b > @a
        [@b,@a] = [@a,@b] # Always want a to be the bigger number

    evalString = "#{@a}#{if @operator is "x" then "*" else @operator}#{@b}"
    console.log evalString
    @answer = eval(evalString)

class Attempt
  constructor: (@question, @answer) ->
    @correct = @question.answer is @answer

class Quiz
  constructor: (@questions) ->
    @startTime = Date.now()
    @questionIndex = 0
    @attempts = []
    @complete = false
    @activeQuestion = @questions[@questionIndex]

  processAttempt: (number) =>
    attempt = new Attempt(@activeQuestion,number)
    @attempts.push attempt
    if attempt.correct
      if @questions.length > 0
        @activeQuestion = @questions[@questionIndex+=1]
      else
        @complete = true

  analysis: =>
    numberIncorrect = 0
    for attempt in @attempts
      numberIncorrect +=1 unless attempt.correct
    @endTime = Date.now()
    @totalSeconds = Math.floor((@endTime - @startTime)/1000)
    @averageSecondsPerQuestion = Math.floor(@totalSeconds/@questions.length)
    "#{numberIncorrect} mistake#{if numberIncorrect is 1 then "" else "s"} for #{@questions.length} questions. Total time was #{@totalSeconds} seconds, with each question taking on average #{@averageSecondsPerQuestion} seconds."

class QuizView extends Backbone.View
  events:
    "keypress #manual": "process"
    "keypress #resolveJoke": "hideJoke"

  hideJoke: =>
    @$("#manual").show().focus()
    @resolveJoke()

  process: (e) ->
    if not e
      e = window.event
    keyCode = e.keyCode or e.which
    if keyCode is 13
      @quiz.processAttempt(parseInt(e.target.value))
      @renderActiveQuestion()
      @renderProgress()
      @$("#manual").val("")


  createQuiz: =>
    questions = for questionNumber in [1..25]
      #questions = for questionNumber in [1..2]
      new Question()
    @quiz = new Quiz(questions)

  render: =>
    @$el.html "
      <div id='activeQuestion'></div>
      <div style='display:inline'>
        <input id='manual'></input>
      </div>
      <div id='progress'></div>
    "
    document.querySelector("#manual").focus()

    functionFactory = (number) => =>
      console.log number
      @quiz.processAttempt(number)
      @renderActiveQuestion()
      @renderProgress()
      @$("#manual").html ""

    commands = {}

    for numberInWords, number in [
      "zero"
      "one"
      "two"
      "three"
      "four"
      "five"
      "six"
      "seven"
      "eight"
      "nine"
      "ten"
      "eleven"
      "twelve"
      "thirteen"
      "fourteen"
      "fifteen"
      "sixteen"
      "seventeen"
      "eighteen"
      "nineteen"
      "twenty"
      "twenty-one"
      "twenty-two"
      "twenty-three"
      "twenty-four"
      "twenty-five"
      "twenty-six"
      "twenty-seven"
      "twenty-eight"
      "twenty-nine"
      "thirty"
      "thirty-one"
      "thirty-two"
      "thirty-three"
      "thirty-four"
      "thirty-five"
      "thirty-six"
      "thirty-seven"
      "thirty-eight"
      "thirty-nine"
      "forty"
      "forty-one"
      "forty-two"
      "forty-three"
      "forty-four"
      "forty-five"
      "forty-six"
      "forty-seven"
      "forty-eight"
      "forty-nine"
      "fifty"
      "fifty-one"
      "fifty-two"
      "fifty-three"
      "fifty-four"
      "fifty-five"
      "fifty-six"
      "fifty-seven"
      "fifty-eight"
      "fifty-nine"
      "sixty"
      "sixty-one"
      "sixty-two"
      "sixty-three"
      "sixty-four"
      "sixty-five"
      "sixty-six"
      "sixty-seven"
      "sixty-eight"
      "sixty-nine"
      "seventy"
      "seventy-one"
      "seventy-two"
      "seventy-three"
      "seventy-four"
      "seventy-five"
      "seventy-six"
      "seventy-seven"
      "seventy-eight"
      "seventy-nine"
      "eighty"
      "eighty-one"
      "eighty-two"
      "eighty-three"
      "eighty-four"
      "eighty-five"
      "eighty-six"
      "eighty-seven"
      "eighty-eight"
      "eighty-nine"
      "ninety"
      "ninety-one"
      "ninety-two"
      "ninety-three"
      "ninety-four"
      "ninety-five"
      "ninety-six"
      "ninety-seven"
      "ninety-eight"
      "ninety-nine"
      "one hundred"


    ]

      commands[numberInWords] = functionFactory(number)

    annyang.addCommands(commands)
    annyang.start()

    @renderActiveQuestion()

  renderActiveQuestion: =>
    if (@quiz.questionIndex+1) % 5 is 0
      @$("#activeQuestion").html "
        <span style='font-size:.5em'>
          #{ _(jokes).sample()}
          <input id='resolveJoke' style='background:transparent; border:none;outline:none; width:0px;' type='text'></input>
        </span>
      "
      @$("#manual").hide()
      @$("#resolveJoke").focus()
      await (new Promise (@resolveJoke) =>
        _.delay =>
          @hideJoke()
        , 9000
      )

    if @quiz.activeQuestion
      @$("#activeQuestion").html "#{@quiz.activeQuestion.a} #{@quiz.activeQuestion.operator} #{@quiz.activeQuestion.b} = "
    else
      @$("#manual").hide()
      @$("#activeQuestion").html "
        <span style='font-size:.5em'>
          #{@quiz.analysis()}
          <a href=''>Reset</a>
        </span>
      "

  renderProgress: =>
    @$("#progress").html "
    #{
      (for attempt in @quiz.attempts.reverse()
        "
        <div class='#{if attempt.correct then "correct" else "incorrect"}'>
          #{attempt.question.a} #{attempt.question.operator} #{attempt.question.b} = #{attempt.answer}
        </div>
        "
      ).join("<br/>")
    }
    "

class WelcomeView extends Backbone.View
  events:
    "click #customAdd": "customAdd"
    "click #customMultiply": "customMultiply"

  customAdd: =>
    numbers = @$("#customAdditionNumbers").val().replace(/[ ,]/g,"")
    router.navigate "addition/#{numbers}", trigger:true

  customMultiply: =>
    numbers = @$("#customMultiplyNumbers").val().replace(/[ ,]/g,"")
    router.navigate "multiply/#{numbers}", trigger:true

  render: =>
    @$el.html "
      <h1>Listening flashcards</h1>
      You can speak or type your answers.<br/>
      Email mikeymckay@gmail.com for suggestions on ways to improve this!<br/>
      <br/>
      <br/>
      #{
        (for route, text of {
          "addition/123456789": "Addition 1-9"
          "borrowingSubtraction": "Borrowing Subtraction"
          "multiply/25": "Multiply 2 and 5"
          "multiply/35": "Multiply 3 and 5"
          "multiply/6": "Multiply 6"
        }
          "
            <a style='font-size:4em;' href='##{route}'>#{text}</a>
            <br/>
          "
        ).join("")
      }
      <br/>
      <br/>
      <div style='font-size:4em'>
        Multiply my own numbers: 
        <input style='width:4em;font-size:1em;' type='text' id='customMultiplyNumbers'></input>
        <button style='height:4em' id='customMultiply'>Multiply!</button>
      </div>
      <div style='font-size:4em'>
        Add my own numbers: 
        <input style='width:4em;font-size:1em;' type='text' id='customAdditionNumbers'></input>
        <button style='height:4em' id='customAdd'>Add!</button>
      </div>
      <br/>
    "

class Router extends Backbone.Router
  routes:
    "": "welcome"
    "borrowingSubtraction": "borrowingSubtraction"
    "addition/:digits": "addition"
    "multiply/:digits": "multiply"

  welcome: =>
    @welcomeView = new WelcomeView()
    @welcomeView.setElement "body"
    @welcomeView.render()

  borrowingSubtraction: =>
    @quizView = new QuizView()
    @quizView.setElement "body"
    @quizView.createQuiz()

    questions = for questionNumber in [1..25]
      new Question
        a: getRndInteger(2,9)
        b: getRndInteger(9,19)
        operator: "-"
    @quizView.quiz = new Quiz(questions)

    @quizView.render()

  addition: (digits) =>
    @quizView = new QuizView()
    @quizView.setElement "body"

    questions = for questionNumber in [1..25]
      new Question
        a: _(digits.split("")).sample()
        b: _(digits.split("")).sample()
        operator: "+"

    @quizView.quiz = new Quiz(questions)

    @quizView.render()

  multiply: (digits) =>
    @quizView = new QuizView()
    @quizView.setElement "body"

    questions = for questionNumber in [1..25]
      new Question
        a: getRndInteger(1,9)
        b: _(digits.split("")).sample()
        operator: "x"

    @quizView.quiz = new Quiz(questions)

    @quizView.render()

global.router = new Router()

Backbone.history.start()

