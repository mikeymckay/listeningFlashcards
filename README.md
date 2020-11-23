# listeningFlashcards

Create flashcards that can be answered by typing or voice recognition. Uses cloud based voice recognition. 

Help me make it better!

Here's how I build the bundle:

npx browserify  -v -t coffeeify --debug --extension='.coffee' main.coffee | npx terser > bundle.js
