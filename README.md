# Prueba técnica Daniel-Gutirrez Torres Recall

### Fecha: 2/10/2025

Make a simple app in the latest version of Flutter that allows a user to login into a Firebase account, create notes and read saved notes. App specifications:

Firebase:
- Create a new Firebase project with firestore set in europe-central3
- Allow email authentication. Create a test user with credentials test@test.com and password Test123456
- Create a collection in Firestore called 'notes'. In firestore rules, allow only 'create' permission.
- Create a Firebase Function written in node.js called getUserNotes. If the user is authenticated, it will return in JSON all the notes that user's UID. If not, return an error.
- Create another Firebase Function in node.js called summarizeNote. If the user is authenticated, it will receive as a parameter the id of a note and it will call OpenAI API, summarize the text and return it in JSON format.

Flutter:
- A login screen where the user can enter the Firebase credentials.
- A screen showing first a text field and a send button to add new notes. Below that, all the user notes (if the note is too long, show only part of it).
- If the user adds a new note, the list will update. For creating a new note, use Firestore .add() method.
- A note object will have the following fields: text, createdAt and userId.
- To list all notes, call getUserNotes Firebase Function.
- If you click a note, a new screen will appear showing the full note. There will be a button in the top right corner to summarize the note by calling summarizeNote Firebase Function (show the summary on top of the note).

Delivery:
- Upload the code to Github
- Generate the web version of the app and deploy it to firebase hosting
