# scripting notes, memos, etc.,

> [!Important]
> Overall procedure follows that described in Gallivan & Chapman (2014)

> [!Todo]
>
> - [x] Rope in left-hand data
> - [x] Confirm whether opti is silently interpolating values
> - [x] Settle on filter properties
> - [x] Inspect data quality at trial-level
> - [x] Measure physical distance from start to objects
>   - About 40 cm
> - [x] Create participant-wise table mapping block to effector laterality/side

A concerning amount of RTs (klibs data) are straight-up implausible.
Using 1 sec as threshold, ~5% are overly delayed, and some go as high as several hundred...
Oh. Maybe there were issues with tech/props/etc that occurred mid-trial (i.e., markers falling off)?

###### Prop slopes (min - max z_pos) ~= 0

| pid | left-back | left-front | right-back | right-front | keep right? | keep left? |
| --- | --------- | ---------- | ---------- | ----------- | ----------- | ---------- |
| 51  | 1         | 0.97       | 0          | 0           | Yes         | No         |
| 52  | 0.68      | 0.20       | 0.42       | 0.63        | Yes         | Yes        |
| 53  | 0         | 0          | 0.80       | 0.03        | Iffy        | Yes        |
| 54  | 0         | 0          | 0          | 0.03        | Yes         | Yes        |
| 56  | 0.98      | 1          | 0.97       | 0.95        | No          | No         |
| 57  | 0.02      | 0.03       | 0          | 0           | Yes         | Yes        |
| 58  | 0         | 0.05       | 0          | 0.42        | Iffy        | Yes        |
| 59  | 0         | 0.02       | 0.35       | 0.42        | Yes         | Yes        |
| 60  | 0         | 0          | 0.08       | 0           | Yes         | Yes        |
| 61  | 0.40      | 0.47       | 0          | 0.02        | Yes         | Iffy       |
| 62  | 0         | 0          | 0.25       | 0.03        | Yes         | Iffy       |
| 63  | 0         | 0          | 0.98       | 0.83        | No          | Yes        |
| 64  | 0         | 0          | 0          | 0.10        | Yes         | Yes        |
| 65  | 1         | 0.97       | 0          | 0           | Yes         | No         |
| 66  | 0         | 0          | 0.05       | 0.48        | Iffy        | Yes        |
| 67  | 0.95      | 0.98       | 0.47       | 1           | No          | No         |
| 68  | 0.97      | 0.95       | 0.98       | 0.98        | No          | No         |
| 69  | 0.72      | 0.93       | 0.93       | 1           | No          | No         |
| 70  | 0.02      | 0          | 0          | 0.07        | Yes         | Yes        |
| 71  | 0         | 0.32       | 0          | 0.03        | Yes         | Iffy       |
| 72  | 0         | 0          | 0.12       | 0.05        | Yes         | Yes        |
| 73  | 0         | 0          |            |             | NA          | Yes        |
| 74  | 0         | 0          | 0.35       | 0.63        | Iffy        | Yes        |
| 75  | 0.88      | 0.28       | 0          | 0           | Yes         | No         |
| -   | -         | -          | -          | -           | 9           | 7          |

---

| pid | right | left |
| --- | ----- | ---- |
| 51  | Y     | N    |
| 52  | Y     | Y    |
| 53  | Y     | Y    |
| 54  | Y     | Y    |
| 56  | N     | N    |
| 57  | Y     | Y    |
| 58  | Y     | Y    |
| 59  | Y     | Y    |
| 60  | Y     | Y    |
| 61  | Y     | Y    |
| 62  | Y     | Y    |
| 63  | N     | Y    |
| 64  | Y     | Y    |
| 65  | Y     | N    |
| 66  | Y     | Y    |
| 67  | N     | N    |
| 68  | N     | N    |
| 69  | N     | N    |
| 70  | Y     | Y    |
| 71  | Y     | Y    |
| 72  | Y     | Y    |
| 73  | N     | Y    |
| 74  | Y     | Y    |
| 75  | Y     | N    |
| 76  | Y     | N    |

keep (all): 52, 53, 54, 57, 58, 59, 60, 61, 62, 64, 66, 70, 71, 72, 74
keep (right): 51, 52, 53, 54, 57, 58, 59, 60, 61, 62, 64, 65, 66, 70, 71, 72, 73, 74, 75, 76
keep (left): 52, 53, 54, 57, 58, 59, 60, 61, 62, 63, 64,66, 70, 71, 72, 73, 71
