# ReMindME

## What

Yet Another Reminder App

## Why

# Because there are **_\*NO\*_** **_\*REMINDER\*_** apps on the market!

## The Hell you say!

### My Perspective

I have ADHD, and I am extremely busy.  A single "ding" and a 5 second popup that says "Eat Lunch", does me absolutely no good.

While there are many apps out there that call themselves "reminder apps" or "calendar/todo list managers" with "reminder" lists....

#### NONE of the more than 30 apps I tried ACTUALLY REMINDS you!!!

Two apps came close.  `BZ Reminder` and `Todoist` both have something that is a **_little_** bit better than all the others.  They try to notify you more than once, but use such polite, quiet tones, without even a popup window, that I never even noticed them when I was testing them (meaning I was waiting for said notification...)  They also have unchangeable "snooze" times.

**_\*\*Every time I get a popup reminder, I, being an adult, want to choose whether I snooze the reminder for 1 minute (I'm brushing my teeth), or 35 minutes (that's when my meeting will be over).  I found NO tool with "on the fly/this time only" changeable snooze times.

## Then what do you want??

### MVP Features

MVP is "Minimum Viable Product".

This is a set of features that when they all  are present, the tool/system/app is a useful tool.

And, the inverse is also true.  If \*any\* of the MVP features are missing, then the tool/system/app is likely Not useful or even usable at all.


* Runs on linux and macOS
* Reminders can be set to repeat
  * daily
  * weekly
  * on certain days of the week
  * every two hours
  * 4 specific times a day
  * on the 3rd and 4th of the month (You're rent is overdue!)
  * and any combination of the above
  * (currently, the same settings that are used by cron...)
* Popup reminder window
  * Gives you these 5 options:
    * Done.
      * Means "After the reminder popped up, I immediately did it")
    * Already Done.
      * Means that I had completed the item before the reminder)
    * Skip.
      * Means that have not done it and I'm not going too (it's 4:00 and the Eat Lunch reminder is still hoping I'll actually eat lunch)
    * Snooze
      * Will prompt you for how long to snooze for!
      * **_\*\* NONE of the UNCHANGEABLE SNOOZE TIME" NONSENSE \*\*_**)
    * Pause Notifications
      * Will prompt you for how long to Not notify you for ANYTHING
        * Like you are eating, driving, in a meeting....
* All NotificationAttempts data are stored in the database for future use when reporting is added.
  * so, when reports are added, they can show all the data from day one.

### ASAP Features

These features will get done very soon after the MVP features (i.e., these are planned, and will appear as soon as possible):

* Cascading reminders (rather than words, here's an example:
  * 'Eat Lunch - 12:00 daily'
    * 'Brush your teeth'
      * reminder fires 30 minutes after 'Eat Lunch' is marked Done.
    * 'Handle the Dishes' 
      * fires 5 minutes after 'Brush your teeth' is marked Done.
* Popup reminder window
  * doesn't steal your keyboard focus
  * waits until you've been inactive (mouse and keyboard) for 5 seconds
  * realizes when you aren't actively typing or mousing for a long while, and assumes that you aren't at that computer
* Run on a phone
* Run on Windows

### Later on features
* Reports based on how many times for any given item, you:
  * snoozed it, and for how long
  * whether you did it when reminded
  * or did it before you were reminded!! :-)
  * or you skipped it. :-(
