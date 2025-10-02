const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { Configuration, OpenAIApi } = require("openai");

admin.initializeApp();
const db = admin.firestore();

const configuration = new Configuration({
  apiKey: functions.config().openai.key,
});
const openai = new OpenAIApi(configuration);

exports.getUserNotes = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    return { error: "User not authenticated" };
  }

  const uid = context.auth.uid;

  try {
    const notesSnapshot = await db
      .collection("notes")
      .where("userId", "==", uid)
      .orderBy("createdAt", "desc")
      .get();

    const notes = notesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    return { notes };
  } catch (error) {
    console.error(error);
    return { error: "Error fetching notes" };
  }
});

exports.summarizeNote = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    return { error: "User not authenticated" };
  }

  const { noteId } = data;
  if (!noteId) {
    return { error: "Note ID is required" };
  }

  try {
    const doc = await db.collection("notes").doc(noteId).get();

    if (!doc.exists) {
      return { error: "Note not found" };
    }

    const note = doc.data();
    const text = note.text;

    const completion = await openai.createChatCompletion({
      model: "gpt-4",
      messages: [
        { role: "system", content: "You are a helpful assistant that summarizes text." },
        { role: "user", content: `Summarize this note: ${text}` },
      ],
    });

    const summary = completion.data.choices[0].message.content;

    return { summary };
  } catch (error) {
    console.error(error);
    return { error: "Error summarizing note" };
  }
});
