from __future__ import absolute_import

from actions import acquire_single_freq_fft
from schedule.tests import TEST_SCHEDULE_ENTRY
from schedule.tests.utils import post_schedule

from .mocks import usrp as mock_usrp


def test_detector(user_client):
    # Put an entry in the schedule that we can refer to
    rjson = post_schedule(user_client, TEST_SCHEDULE_ENTRY)
    entry_name = rjson['name']
    task_id = rjson['next_task_id']

    # Retreive that actual instance
    action = acquire_single_freq_fft.SingleFrequencyFftAcquisition(
        frequency=400e6,
        sample_rate=10e6,
        fft_size=16,
        nffts=11  # [0.0] * 16 to [1.0] * 16
    )
    action.usrp = mock_usrp
    action(entry_name, task_id)