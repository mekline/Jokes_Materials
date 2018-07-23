# Cloudy parametrization writeup!

I am now getting ready to analyze Joke>Non Joke activations in regions from the Cloudy alternate localizer for Theory of Mind, as an exploratory analysis.  This has been challenging to set up because the localizer was coming from another lab, and our old pipeline did not support the different-length blocks needed to properly create contrasts from that localizer. 

There are a variety of small analytical choices a person could make here; Hilary Richardson (local Saxelab expert on the localizer) assures us that they don't make dramatic differences in the outcome, so I'm choosing to go with the versions used in the Jacoby paper where possible. 

Steps: I start with the saxelab m file used to generate timings for THIER version of the movie presentation, which differs from Evlab, because we cut off the credits at the beginning. Also, because the localizer was coming from another lab + miscommunication between lab members here, the actual fMRI sessions were set up to run for different numbers of TRs; this just means the data ends at different points for different participants (e.g. participant saw a few seconds of blank, or scanner stopped during final closing shot of (inanimate) clouds).

Here are the necessary steps:

- Using the original *makePixarBehavs.m script* from Saxelab, extract THEIR timings to a csv I'm using to apply the adjustments.

- Apply the 4-tr adjustment: From Hilary: "Evlab cropped the opener from the movie, and used a diff amount of rest in the beginning of the experiment than saxelab. These changes result in a 4 TR difference b/w the two experiments such that Saxelab TR 12 is Evlab TR 8. ".  This is *Cloudy_PL2017.para*

- Create alternate versions for each of the lengths of Cloudy that were actually presented.  Wait! I don't need to do this because fixation is modeled implicitly. The last non-filler TR is several before the end of the shortest scan. So, there is just 1 output, *Cloudy_PL2017.para*

- These will be called:


And then I'll transfer those to mindhive and run the models! Phew!

- Side note: *olessia_sample.para* is one of the versions in use from a newer coding of the videos, I won't use because it has the old style of marking blocks (TR by TR) + I'm not sure which timing start-point it reflects. 