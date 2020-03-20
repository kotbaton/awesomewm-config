import json
import pickle
import os.path
import sys
import argparse

from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/tasks.readonly']

# all taskslists
# list of tasks from [tasklist]
# update [task] from [tasklist]
# mark [task] from [tasklist] as completed
# insert new [task] into [tasklist]

def get_parser():
    parser = argparse.ArgumentParser(description='Google tasks API wrapper')
    group = parser.add_mutually_exclusive_group()

    group.add_argument('--all',
                       action='store_true',
                       help='Get JSON with all user\'s task lists')
    parser.add_argument('--list',
                       nargs=1,
                       type=str,
                       help='Get JSON with all tasks in the speceified task list')
    return parser


def authorize():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    return build('tasks', 'v1', credentials=creds)


def main():
    service = authorize()

    parser = get_parser()
    args = parser.parse_args()

    if args.all:
        results = service.tasklists().list(maxResults=10).execute()
        print(json.dumps(results))

    elif args.list:
        results = service.tasks().list(tasklist=args.list[0]).execute()
        print(json.dumps(results))

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
