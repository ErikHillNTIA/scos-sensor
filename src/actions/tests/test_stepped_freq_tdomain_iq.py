import json
import os
from os import path

from django.conf import settings
from sigmf.validate import validate as sigmf_validate

from tasks.models import Acquisition, TaskResult
from tasks.tests.utils import simulate_multirec_acquisition

SCHEMA_DIR = path.join(settings.REPO_ROOT, "schemas")
SCHEMA_FNAME = "scos_transfer_spec_schema.json"
SCHEMA_PATH = path.join(SCHEMA_DIR, SCHEMA_FNAME)

with open(SCHEMA_PATH, "r") as f:
    schema = json.load(f)


def test_metadata(user_client, test_scheduler):
    entry_name = simulate_multirec_acquisition(user_client)
    tr = TaskResult.objects.get(schedule_entry__name=entry_name, task_id=1)
    acquisitions = Acquisition.objects.filter(task_result=tr)
    for acquisition in acquisitions:
        assert sigmf_validate(acquisition.metadata)
        # FIXME: update schema so that this passes
        # schema_validate(sigmf_metadata, schema)


def test_data_file_created(user_client, test_scheduler):
    entry_name = simulate_multirec_acquisition(user_client)
    tr = TaskResult.objects.get(schedule_entry__name=entry_name, task_id=1)
    acquisitions = Acquisition.objects.filter(task_result=tr)
    for acquisition in acquisitions:
        assert acquisition.data
        assert path.exists(acquisition.data.path)
        os.remove(acquisition.data.path)
