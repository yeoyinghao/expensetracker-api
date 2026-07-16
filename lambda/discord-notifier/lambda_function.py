import os

from discord_webhook import DiscordEmbed, DiscordWebhook
from aws_lambda_powertools.utilities.parameters import get_secret

secret_name = os.environ["SECRET_NAME"]

def lambda_handler(event, context):
    secret_json : dict = get_secret(secret_name, transform="json")

    # A Lambda console test with {} verifies access without calling Discord.
    records = event.get("Records", [])
    if not records:
        return {
            "statusCode": 500,
            "message": "Failed to retrieve SNS Records."
        }

    webhook = DiscordWebhook(url=secret_json["discord-webhook-url"])
    sns_message = records[0]["Sns"]["Message"]

    embed = DiscordEmbed(
        title="Expense Tracker Alarm",
        description=sns_message,
        color="03b2f8",
    )
    webhook.add_embed(embed)

    response = webhook.execute()
    response.raise_for_status()

    return {
        "statusCode": 200,
        "message": "Message processed successfully"
    }
