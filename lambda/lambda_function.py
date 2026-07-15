import json
import os

import requests
from discord_webhook import DiscordEmbed, DiscordWebhook


def get_secret():
    secret_name = os.environ["SECRET_NAME"]
    session_token = os.environ["AWS_SESSION_TOKEN"]
    port = os.environ.get("PARAMETERS_SECRETS_EXTENSION_HTTP_PORT", "2773")

    response = requests.get(
        f"http://localhost:{port}/secretsmanager/get",
        params={"secretId": secret_name},
        headers={"X-Aws-Parameters-Secrets-Token": session_token},
        timeout=5,
    )
    response.raise_for_status()

    payload = response.json()
    return payload["SecretString"], {
        "name": payload.get("Name"),
        "versionId": payload.get("VersionId"),
    }


def get_webhook_url(secret_string):
    # Support either a raw webhook URL or a JSON secret.
    try:
        secret = json.loads(secret_string)
    except json.JSONDecodeError:
        return secret_string

    if isinstance(secret, str):
        return secret
    return secret["DISCORD_WEBHOOK"]


def lambda_handler(event, context):
    secret_string, secret_metadata = get_secret()
    print("Secret retrieved successfully")

    # A Lambda console test with {} verifies access without calling Discord.
    records = event.get("Records", [])
    if not records:
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Secret retrieved successfully",
                **secret_metadata,
            }),
        }

    webhook = DiscordWebhook(url=get_webhook_url(secret_string))
    sns_message = records[0]["Sns"]["Message"]

    embed = DiscordEmbed(
        title="Expense Tracker Alarm",
        description=sns_message,
        color="03b2f8",
    )
    webhook.add_embed(embed)

    response = webhook.execute()
    if response.status_code == 204:
        print("Message sent to Discord successfully")
    else:
        print(
            "Failed to send message to Discord, "
            f"status code: {response.status_code}"
        )

    return {
        "statusCode": 200,
        "body": json.dumps("Message processed successfully"),
    }
