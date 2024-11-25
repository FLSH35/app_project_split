const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getStorage } = require("firebase-admin/storage");

initializeApp();

exports.firestoreToStorage = onDocumentCreated(
  "users/{userId}/results/finalCharacter",
  async (event) => {
    try {
      const { data, params } = event; // Firestore document data and params
      const userId = params.userId;

      if (!data) {
        console.log(`No data in document for user ${userId}`);
        return;
      }

      const bucket = getStorage().bucket();
      const filePath = `users/${userId}/finalCharacter.json`;
      const fileContent = JSON.stringify(data);

      await bucket.file(filePath).save(fileContent, {
        contentType: "application/json",
      });

      console.log(`Data for user ${userId} saved to ${filePath}`);
    } catch (error) {
      console.error("Error saving data to Storage:", error);
    }
  }
);
