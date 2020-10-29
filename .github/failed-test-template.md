---
title: FAILED test
assignees: {{ payload.sender.login }}
labels: bug
---

FAILED: test


[view workflow]({{ env.VIEW_URL }})


- who dunnit: {{ payload.sender.login }}
- when: {{ date | date('dddd, MMMM Do YYYY, HH:mm:ss') }}
- ref: {{ env.REF }}
- workflow: {{ env.WORKFLOW }}
- job: {{ env.JOB }}
- event_name: {{ env.EVENT_NAME }}


---
The End.
