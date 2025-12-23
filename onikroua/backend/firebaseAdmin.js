const admin = require('firebase-admin');
const logger = require('./logger');

// Initialisation Firebase Admin SDK
const initFirebase = () => {
  try {
    if (!process.env.FIREBASE_DATABASE_URL) {
      throw new Error('FIREBASE_DATABASE_URL manquant dans les variables d\'environnement');
    }

    let serviceAccount;
    
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      try {
        serviceAccount = require(process.env.GOOGLE_APPLICATION_CREDENTIALS);
      } catch (e) {
        logger.error(`Erreur chargement credentials: ${e.message}`);
        throw new Error('Erreur chargement fichier credentials');
      }
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      try {
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
      } catch (e) {
        logger.error('Erreur parsing FIREBASE_SERVICE_ACCOUNT_JSON');
        throw new Error('Format JSON invalide pour FIREBASE_SERVICE_ACCOUNT_JSON');
      }
    } else {
      throw new Error('Aucune configuration Firebase trouvée (GOOGLE_APPLICATION_CREDENTIALS ou FIREBASE_SERVICE_ACCOUNT_JSON requis)');
    }

    if (!admin.apps.length) {
      admin.initializeApp({
        credential: serviceAccount 
          ? admin.credential.cert(serviceAccount) 
          : admin.credential.applicationDefault(),
        databaseURL: process.env.FIREBASE_DATABASE_URL
      });
      logger.info('Firebase Admin initialisé avec succès');
    }
    
    return admin.database();
  } catch (error) {
    logger.error(`Erreur initialisation Firebase: ${error.message}`);
    throw error;
  }
};

const db = initFirebase();

module.exports = { admin, db };
