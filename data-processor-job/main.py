import os
import json
import base64


def main():
    """
    This is the main entry point for the Cloud Run Job.
    It reads the Pub/Sub message passed in as an environment variable,
    decodes it, and prints the file path.
    """
    print("Data processor job started...")

    try:
        # 1. Eventarc passes the CloudEvent as env vars.
        # We only care about the data payload.
        encoded_data = os.environ.get("CE_DATA")
        if not encoded_data:
            print("Error: CE_DATA environment variable not found.")
            print("This job must be triggered by Eventarc.")
            return

        # 2. The data is a JSON string. Parse it.
        # This payload is from Pub/Sub.
        event_data = json.loads(encoded_data)

        # 3. The Pub/Sub message itself is in the 'message.data' field,
        # and it is Base64 encoded.
        encoded_gcs_event = event_data.get("message", {}).get("data")
        if not encoded_gcs_event:
            print("Error: 'message.data' not found in Pub/Sub payload.")
            return

        # 4. Decode the Base64 string to get the GCS event JSON.
        decoded_gcs_event_str = base64.b64decode(encoded_gcs_event).decode("utf-8")

        # 5. Parse the final JSON from GCS.
        gcs_event = json.loads(decoded_gcs_event_str)

        bucket = gcs_event.get("bucket")
        file_name = gcs_event.get("name")

        if not bucket or not file_name:
            print("Error: GCS bucket or file name not found in event.")
            return

        # 6. This is the goal for Day 2!
        file_uri = f"gs://{bucket}/{file_name}"
        print(f"Successfully parsed file URI: {file_uri}")
        print("Data processor job finished.")

    except json.JSONDecodeError as e:
        print(f"Error: Failed to decode JSON. Data: {encoded_data}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    main()