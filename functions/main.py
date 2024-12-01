# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import firestore_fn, https_fn
# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import https_fn, storage_fn
from firebase_admin import initialize_app, auth, firestore, storage
import google.cloud.firestore

# The Firebase Admin SDK to access Cloud Firestore.
from firebase_admin import initialize_app, firestore
import google.cloud.firestore
from firebase_functions import https_fn
from firebase_admin import initialize_app
import requests
from io import StringIO
import csv
import os


app = initialize_app()


@https_fn.on_request()
def addmessage(req: https_fn.Request) -> https_fn.Response:
    """Take the text parameter passed to this HTTP endpoint and insert it into
    a new document in the messages collection."""
    # Grab the text parameter.
    original = req.args.get("text")
    if original is None:
        return https_fn.Response("No text parameter provided", status=400)

    firestore_client: google.cloud.firestore.Client = firestore.client()

    # Push the new message into Cloud Firestore using the Firebase Admin SDK.
    _, doc_ref = firestore_client.collection("messages").add({"original": original})

    # Send back a message that we've successfully written the message
    return https_fn.Response(f"Message with ID {doc_ref.id} added.")

@https_fn.on_request()
def create_user(req: https_fn.Request) -> https_fn.Response:
    """Create a new user and save their details in Firestore."""
    # Parse required parameters
    email = req.args.get("email")
    password = req.args.get("password")
    display_name = req.args.get("display_name")

    if not email or not password or not display_name:
        return https_fn.Response("Missing required parameters: email, password, display_name", status=400)

    try:
        # Create the user using Firebase Auth
        user = auth.create_user(email=email, password=password, display_name=display_name)

        # Save the user details in Firestore
        firestore_client: google.cloud.firestore.Client = firestore.client()
        firestore_client.collection("users").document(user.uid).set({
            "email": email,
            "display_name": display_name,
            "created_at": firestore.SERVER_TIMESTAMP
        })

        return https_fn.Response(f"User with ID {user.uid} created successfully.", status=200)

    except Exception as e:
        return https_fn.Response(f"Error creating user: {e}", status=500)
    

# Newsletter API Configuration
API_URL = 'https://ifyouchange42862.api-us1.com/api/3'
API_KEY = 'a8bb1fd8ba76b2b1a0c2c58b1745ba2fc458e5f69da898048ccd790b14a5206db1bd9ef7'
HEADERS = {
    'Api-Token': API_KEY,
    'Content-Type': 'application/json'
}

# Helper Functions for Newsletter API
def get_contact_by_email(email):
    params = {'email': email}
    response = requests.get(f"{API_URL}/contacts", params=params, headers=HEADERS)
    data = response.json()
    
    # Überprüfe, ob 'contacts' existiert und nicht leer ist
    if 'contacts' in data and len(data['contacts']) > 0:
        return data['contacts'][0]
    else:
        return None  # Kein Kontakt gefunden

def create_or_get_contact(email):
    contact = get_contact_by_email(email)
    if contact:
        return contact
    data = {"contact": {"email": email}}
    response = requests.post(f"{API_URL}/contacts", json=data, headers=HEADERS)
    return response.json().get('contact')

def create_or_get_list(list_name):
    response = requests.get(f"{API_URL}/lists", headers=HEADERS)
    for lst in response.json().get('lists', []):
        if lst['name'] == list_name:
            return lst
    data = {
        "list": {
            "name": list_name,
            "stringid": list_name.lower().replace(' ', '_'),
            "sender_url": "https://ifyouchange42862.activehosted.com/",
            "sender_reminder": "You subscribed to this newsletter."
        }
    }
    response = requests.post(f"{API_URL}/lists", json=data, headers=HEADERS)
    return response.json().get('list')

def add_contact_to_list(contact_id, list_id):
    data = {"contactList": {"list": list_id, "contact": contact_id, "status": 1}}
    requests.post(f"{API_URL}/contactLists", json=data, headers=HEADERS)

def submit_form(email, first_name):
    form_url = 'https://ifyouchange42862.activehosted.com/proc.php'
    data = {
        'u': '25',
        'f': '25',
        's': '',
        'c': '0',
        'm': '0',
        'act': 'sub',
        'v': '2',
        'or': '1b8a5663599fc2cbe3a86b7a3d3f244c',  # Wert aus deinem Formular
        'firstname': first_name,
        'email': email
    }

    response = requests.post(form_url, data=data)
    if response.status_code == 200:
        print("Formular erfolgreich übermittelt. Double Opt-In E-Mail wurde gesendet.")
    else:
        raise Exception(f"Fehler beim Übermitteln des Formulars: {response.status_code} - {response.text}")


@https_fn.on_request()
def manage_newsletter(req: https_fn.Request) -> https_fn.Response:
    """
    Funktion zur Verwaltung von Newsletter-Operationen.
    Akzeptiert die folgenden Parameter:
    - email
    - first_name
    """
    # CORS: Erlaubt Anfragen von allen Ursprüngen (oder spezifischen Domains)
    response_headers = {
        "Access-Control-Allow-Origin": "*",  # Erlaubt alle Domains
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    # OPTIONS-Preflight-Anfrage behandeln
    if req.method == 'OPTIONS':
        return https_fn.Response("", status=204, headers=response_headers)

    # Anfrageparameter abrufen
    email = req.args.get('email')
    first_name = req.args.get('first_name')

    if not email:
        return https_fn.Response(
            "Fehlender Parameter: email",
            status=400,
            headers=response_headers,
        )

    if not first_name:
        return https_fn.Response(
            "Fehlender Parameter: first_name",
            status=400,
            headers=response_headers,
        )

    try:
        # Formular übermitteln, um Double Opt-In auszulösen
        submit_form(email, first_name)

        return https_fn.Response(
            "Kontakt erfolgreich zum Newsletter hinzugefügt! Double Opt-In-E-Mail wurde gesendet.",
            status=200,
            headers=response_headers,
        )
    except Exception as e:
        return https_fn.Response(
            f"Fehler: {e}",
            status=500,
            headers=response_headers,
        )



@https_fn.on_request()
def export_to_csv(req: https_fn.Request) -> https_fn.Response:
    """
    Export user data (simplified: userId, combinedTotalScore, completionDate, finalCharacter)
    into a CSV file and save to Cloud Storage.
    """
    try:
        # Firestore client
        db = firestore.client()

        # Cloud Storage bucket
        bucket = storage.bucket()

        # CSV content
        csv_output = StringIO()
        csv_writer = csv.writer(csv_output)

        # Write CSV headers
        csv_writer.writerow(["userId", "combinedTotalScore", "completionDate", "finalCharacter"])

        # Iterate through users
        users_ref = db.collection("users")
        users = users_ref.stream()

        for user in users:
            user_id = user.id
            user_doc_ref = users_ref.document(user_id)

            # Fetch all sub-collections of the user document
            subcollections = user_doc_ref.collections()

            for subcollection in subcollections:
                subcollection_name = subcollection.id

                # Filter collections by pattern (results_x or results)
                if subcollection_name == "results" or subcollection_name.startswith("results_"):
                    results = subcollection.stream()

                    for result in results:
                        # Check for the presence of required fields
                        data = result.to_dict()
                        if (
                            "combinedTotalScore" in data
                            and "completionDate" in data
                            and "finalCharacter" in data
                        ):
                            try:
                                csv_writer.writerow([
                                    user_id,
                                    data.get("combinedTotalScore", ""),
                                    data.get("completionDate", ""),
                                    data.get("finalCharacter", "")
                                ])
                            except Exception as e:
                                # Skip rows with issues
                                print(f"Error processing user {user_id} in {subcollection_name}: {e}")

        # Save CSV file to Cloud Storage
        csv_filename = "users_data_snapshot.csv"
        blob = bucket.blob(csv_filename)
        blob.upload_from_string(csv_output.getvalue(), content_type="text/csv")

        return https_fn.Response(
            f"CSV file {csv_filename} successfully created in Cloud Storage.",
            status=200
        )

    except Exception as e:
        return https_fn.Response(
            f"Error exporting to CSV: {e}",
            status=500
        )


# https://us-central1-personality-score.cloudfunctions.net

# https://<region>-<project-id>.cloudfunctions.net/export_to_csv


# firebase deploy --only functions