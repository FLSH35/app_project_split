const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const axios = require('axios');

const API_URL = 'https://ifyouchange42862.api-us1.com/api/3/contacts';
API_KEY = 'a8bb1fd8ba76b2b1a0c2c58b1745ba2fc458e5f69da898048ccd790b14a5206db1bd9ef7'

exports.proxyActiveCampaign = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== 'POST') {
      return res.status(405).send('Method Not Allowed');
    }

    try {
      const response = await axios.get(API_URL, {
        headers: {
          'Api-Token': API_TOKEN,
          'Content-Type': 'application/json',
        },
        params: req.body, // Use email or other query params here
      });
      res.status(response.status).json(response.data);
    } catch (error) {
      res.status(error.response?.status || 500).json({ error: error.message });
    }
  });
});
