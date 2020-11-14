---
title: FAILED production run
assignees: ricardojosegomezulmke
labels: bug
---

FAILED: production run


[view workflow]({{ env.VIEW_URL }})


- who dunnit: {{ payload.sender.login }}
- when: {{ date | date('dddd, MMMM Do YYYY, HH:mm:ss') }}
- ref: {{ env.REF }}
- workflow: {{ env.WORKFLOW }}
- job: {{ env.JOB }}
- event_name: {{ env.EVENT_NAME }}


---
The End.
