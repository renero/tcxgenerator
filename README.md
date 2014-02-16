tcxgenerator
============

Bash script that generates a TCX file for a treadmill indoor session. That file can be imported for logging purposes.

When training indoor without any devide tracking your session it is difficult (or impossible) to manually log that session in most programs. For that purpose, I wrote this simple bash script that creates a dummy training session with no GPS, nor altitude data for you in a TCX file. In my case, I use the TCX to import the session into TrailRunner.

Next steps / Limitations
------------------------

  * We can easily make most of the parameters of the script dependent on the arguments to it.
  * For the moment, the script only works in Mac. Some adjustments should be done in Linux with the ``date`` commands.
  * The script generates a 5km session at 10km/h (6 min/km). This can be easily parametrized.
 
Any comments or ideas are welcome!
