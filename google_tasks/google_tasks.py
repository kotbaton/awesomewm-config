#!/usr/bin/python
import json
import pickle
import os
import sys
import argparse

from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/tasks.readonly',
          'https://www.googleapis.com/auth/tasks']

# v all taskslists
# v list of tasks from [tasklist]
# v mark [task] from [tasklist] as completed
# v insert new [task] into [tasklist]

#   update [task] from [tasklist]

def get_parser():
    parser = argparse.ArgumentParser(description='Google tasks API wrapper')
    group = parser.add_mutually_exclusive_group()

    group.add_argument('--all',
                       action='store_true',
                       help='Get JSON with all user\'s task lists')
    group.add_argument('--list',
                       nargs=1,
                       metavar=('TASKLIST_ID',),
                       type=str,
                       help='Get JSON with all tasks in the speceified task list')
    group.add_argument('--mark_as_completed',
                       nargs=2,
                       metavar=('TASK_ID', 'TASKLIST_ID'),
                       type=str,
                       help='Mark TASK from TASKLIST as comleted')
    group.add_argument('--insert',
                       nargs=3,
                       metavar=('TASKLIST_ID', 'TITLE', 'NOTES'),
                       type=str,
                       help='Insert new task with TITLE and NOTES into TASKLIST')
    group.add_argument('--edit',
                       nargs=4,
                       metavar=('TASKLIST_ID', 'TASK_ID', 'TITLE', 'NOTES'),
                       type=str,
                       help='Update task with TASK_ID by TITLE and NOTES in TASKLIST')


    return parser


def authorize():
    dir = os.path.dirname(os.path.realpath(__file__))
    token_filename = f'{dir}/token.pickle'
    credentials_filename = f'{dir}/credentials.json'

    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists(token_filename):
        with open(token_filename, 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                credentials_filename, SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open(token_filename, 'wb') as token:
            pickle.dump(creds, token)

    return build('tasks', 'v1', credentials=creds)


def main():
    service = authorize()

    parser = get_parser()
    args = parser.parse_args()

    if args.all:
        results = service.tasklists().list(maxResults=20).execute()
        print(json.dumps(results['items']))

    elif args.list:
        results = service\
                  .tasks()\
                  .list(tasklist=args.list[0],
                        maxResults=50,
                        showCompleted=False)\
                  .execute()
        print(json.dumps(results['items']))

    elif args.mark_as_completed:
        task = args.mark_as_completed[0]
        tasklist = args.mark_as_completed[1]

        task_body = service.tasks().get(tasklist=tasklist, task=task).execute()

        task_body['status'] = 'completed'

        result = service.tasks().update(tasklist=tasklist,
                                         task=task,
                                         body=task_body).execute()
    elif args.edit:
        tasklist_id = args.edit[0]
        task_id = args.edit[1]

        task_body = service.tasks().get(tasklist=tasklist_id, task=task_id).execute()

        if (new_title := args.edit[2]):
            task_body['title'] = new_title

        task_body['notes'] = args.edit[3]

        result = service.tasks().update(tasklist=tasklist_id,
                                         task=task_id,
                                         body=task_body).execute()
        print(json.dumps(result))
    elif args.insert:
        tasklist_id = args.insert[0]
        task_body = {
            'title': args.insert[1],
            'notes': args.insert[2]
        }

        result = service.tasks().insert(tasklist=tasklist_id, body=task_body).execute()
        print(json.dumps(result))

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
