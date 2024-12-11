from firebase_functions import firestore_fn, https_fn
from firebase_admin import initialize_app, firestore
import csv
from io import StringIO
import datetime
import requests
from firebase_admin import initialize_app, auth, firestore, storage



# Initialize Firebase Admin SDK
app = initialize_app()
# Newsletter API Configuration
PI_URL = 'https://ifyouchange42862.api-us1.com/api/3'
API_KEY = 'a8bb1fd8ba76b2b1a0c2c58b1745ba2fc458e5f69da898048ccd790b14a5206db1bd9ef7'
HEADERS = {
    'Api-Token': API_KEY,
    'Content-Type': 'application/json'
}











# Helper Function to Write CSV to Cloud Storage
def write_csv_to_storage(bucket_name, filename, data):
    """Write CSV data to a file in Cloud Storage."""
    from google.cloud import storage_google
    storage_client = storage_google.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(filename)
    blob.upload_from_string(data, content_type='text/csv')
    return f"gs://{bucket_name}/{filename}"

# Helper Function to Clean Data
def clean_data(records, required_fields):
    """Clean the data by filtering out records missing required fields."""
    return [record for record in records if all(field in record for field in required_fields)]

# Firebase Function: Generate FinalCharacterDoc CSV with Sample Data
@https_fn.on_request()
def generate_final_character_csv(req: https_fn.Request) -> https_fn.Response:
    """
    Export FinalCharacterDoc data into a CSV file and save to Cloud Storage.
    Deletes the existing file before saving a new one.
    Adds sample data directly into the CSV for debugging purposes if the debug flag is enabled.
    """
    try:
        db = firestore.client()
        bucket = storage.bucket()

        # CSV filename
        csv_filename = "final_character_snapshot.csv"
        blob = bucket.blob(csv_filename)

        # Check and delete existing file
        if blob.exists():
            blob.delete()

        # CSV content
        csv_output = StringIO()
        csv_writer = csv.writer(csv_output)

        # Write CSV headers
        csv_writer.writerow(["User-UUID", "ResultsX", "CombinedTotalScore", "CompletionDate", "FinalCharacter", "FinalCharacterDescription"])

        # Fetch data from Firestore and add to CSV
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
                                    subcollection_name,
                                    data.get("combinedTotalScore", ""),
                                    data.get("completionDate", ""),
                                    data.get("finalCharacter", "")
                                ])
                            except Exception as e:
                                # Skip rows with issues
                                print(f"Error processing user {user_id} in {subcollection_name}: {e}")

        # Save new CSV file to Cloud Storage
        blob.upload_from_string(csv_output.getvalue(), content_type="text/csv")

        return https_fn.Response(
            f"CSV file {csv_filename} successfully created in Cloud Storage.",
            status=200
        )

    except Exception as e:
        return https_fn.Response(
            f"Error exporting FinalCharacterDoc to CSV: {e}",
            status=500
        )





# Firebase Function: Generate FrageID CSV
@https_fn.on_request()
def generate_frageid_csv(req: https_fn.Request) -> https_fn.Response:
    """
    Export FrageID data into a CSV file and save to Cloud Storage.
    Iterates over users and their results / results_x subcollections.
    For each document (except "finalCharacter"), reads the 'answers' array of maps,
    each containing 'answer' (number) and 'id' (number). Disregards collections
    with improperly structured answers fields.
    """
    try:
        firestore_client = firestore.client()
        bucket = storage.bucket()

        csv_filename = "frageid_snapshot.csv"
        blob = bucket.blob(csv_filename)

        # Check and delete existing file
        if blob.exists():
            blob.delete()
            
        # CSV content
        csv_output = StringIO()
        csv_writer = csv.writer(csv_output)

        # Write CSV headers
        csv_writer.writerow(["User-UUID", "ResultsX", "FrageID", "Answer"])

        # Iterate over users and their subcollections
        users_ref = firestore_client.collection("users")
        users = users_ref.stream()

        for user in users:
            user_id = user.id
            user_doc_ref = users_ref.document(user_id)
            subcollections = user_doc_ref.collections()

            for subcollection in subcollections:
                subcollection_name = subcollection.id

                # Consider only "results" or "results_x" subcollections
                if subcollection_name == "results" or subcollection_name.startswith("results_"):
                    results = subcollection.stream()
                    discard_collection = False  # Flag to discard invalid collections

                    for result in results:
                        # Skip the "finalCharacter" document if present
                        if result.id == "finalCharacter":
                            continue

                        data = result.to_dict()
                        answers = data.get("answers", [])

                        # Check if answers is a list of dictionaries
                        if not isinstance(answers, list) or not all(isinstance(ans, dict) for ans in answers):
                            discard_collection = True
                            break  # Exit loop for this collection

                        # Iterate through the answers array
                        for ans in answers:
                            frage_id = ans.get("id", "")
                            answer_val = ans.get("answer", "")

                            # Write to CSV if we have at least an id and an answer
                            if frage_id != "" and answer_val != "":
                                csv_writer.writerow([
                                    user_id,
                                    subcollection_name,
                                    frage_id,
                                    answer_val
                                ])

                    # If collection is invalid, skip further processing
                    if discard_collection:
                        print(f"Discarded invalid collection: {subcollection_name} for user {user_id}")
                        break  # Skip this collection entirely

        # Save CSV file to Cloud Storage
        blob.upload_from_string(csv_output.getvalue(), content_type="text/csv")

        return https_fn.Response(
            f"CSV file {csv_filename} successfully created in Cloud Storage.",
            status=200
        )

    except Exception as e:
        return https_fn.Response(
            f"Error exporting FrageID to CSV: {e}",
            status=500
        )

# Firebase Function: Generate Aggregated Scores CSV
@https_fn.on_request()
def generate_aggregated_scores_csv(req: https_fn.Request) -> https_fn.Response:
    """
    Export aggregated scores into a CSV file and save to Cloud Storage.
    Access the data in the same manner as generate_final_character_csv.
    """
    try:
        firestore_client = firestore.client()
        bucket = storage.bucket()

        # CSV content
        csv_output = StringIO()
        csv_writer = csv.writer(csv_output)

        # Write CSV headers
        csv_writer.writerow(["User-UUID", "ResultsX", "AVG-Score-Lebensbereich1", "AVG-Score-LebensbereichX", "AVG-Score-Ebene"])

        # Iterate over users and their subcollections
        users_ref = firestore_client.collection("users")
        users = users_ref.stream()

        for user in users:
            user_id = user.id
            user_doc_ref = users_ref.document(user_id)
            subcollections = user_doc_ref.collections()

            for subcollection in subcollections:
                subcollection_name = subcollection.id

                # Consider only "results" or "results_x" subcollections
                if subcollection_name == "results" or subcollection_name.startswith("results_"):
                    results = subcollection.stream()

                    for result in results:
                        data = result.to_dict()
                        avg_scores = data.get("avgScores", {})

                        if all(key in avg_scores for key in ["Lebensbereich1", "LebensbereichX", "Ebene"]):
                            csv_writer.writerow([
                                user_id,
                                subcollection_name,
                                avg_scores.get("Lebensbereich1", ""),
                                avg_scores.get("LebensbereichX", ""),
                                avg_scores.get("Ebene", "")
                            ])

        # Save CSV file to Cloud Storage
        csv_filename = "aggregated_scores_snapshot.csv"
        blob = bucket.blob(csv_filename)
        blob.upload_from_string(csv_output.getvalue(), content_type="text/csv")

        return https_fn.Response(
            f"CSV file {csv_filename} successfully created in Cloud Storage.",
            status=200
        )

    except Exception as e:
        return https_fn.Response(
            f"Error exporting aggregated scores to CSV: {e}",
            status=500
        )

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
from google.cloud import bigquery

@https_fn.on_request()
def export_to_bigquery(req: https_fn.Request) -> https_fn.Response:
    """
    Export FinalCharacterDoc data from Firestore directly to BigQuery.
    Inserts data into personality-score.result_data.aa table.
    """

    
    try:
        # Initialize Firestore client
        db = firestore.Client()
        bigquery_client = bigquery.Client()

        # BigQuery dataset and table
        dataset_id = "personality-score.result_data"
        table_id = "aa"

        # Define the rows to insert
        rows_to_insert = []

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
                            rows_to_insert.append({
                                "user_uuid": user_id,
                                "results_x": subcollection_name,
                                "combined_total_score": data.get("combinedTotalScore", ""),
                                "completion_date": data.get("completionDate", ""),
                                "final_character": data.get("finalCharacter", ""),
                                "final_character_description": data.get("finalCharacterDescription", "")  # Optional
                            })

        # Insert rows into BigQuery
        if rows_to_insert:
            table_ref = bigquery_client.dataset(dataset_id).table(table_id)
            errors = bigquery_client.insert_rows_json(table_ref, rows_to_insert)

            if errors:
                # Log and return error details if any rows failed
                return https_fn.Response(
                    f"Data insertion to BigQuery failed with errors: {errors}",
                    status=500
                )
            else:
                # Return success message with row count
                return https_fn.Response(
                    f"Data successfully exported to BigQuery. {len(rows_to_insert)} rows inserted.",
                    status=200
                )
        else:
            # Return a message if no data was available for insertion
            return https_fn.Response(
                "No data to insert into BigQuery. Ensure your Firestore data matches the required fields.",
                status=200
            )

    except Exception as e:
        # Catch and return any unexpected errors
        return https_fn.Response(
            f"Error exporting data to BigQuery: {e}",
            status=500
        )



# https://us-central1-personality-score.cloudfunctions.net/export_to_csv

# https://<region>-<project-id>.cloudfunctions.net/export_to_csv


# firebase deploy --only functions

# FinalCharacterDoc CSV
# response = requests.get("https://us-central1-personality-score.cloudfunctions.net/generate_final_character_csv")
# print(response.status_code, response.text)

# FrageID CSV
# response = requests.get("https://us-central1-personality-score.cloudfunctions.net/generate_frageid_csv")
# print(response.status_code, response.text)

# Aggregated Scores CSV
# response = requests.get("https://us-central1-personality-score.cloudfunctions.net/generate_aggregated_scores_csv")
# print(response.status_code, response.text)