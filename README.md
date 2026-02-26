# SubtleSentinel: A Cybersecurity Monitor for Schools

SubtleSentinel is an open-source project developed by SubtleTea Research to provide
real-time analysis of how healthy the networks are, measured in terms
of user and employee cybersecurity perparedness and behaviors, beyond just 
successful cyberattacks.

Schools are vulnerable targets for cybersecurity attacks due to limited
resources for training and personnel to build and maintain cybersecurity systems
to keep up with modern threats including social engineering. But school
districts cannot just hand over sensitive student and employee behavioral data 
that beyond violating privacy might also reveal information about network
vulnerabilities in the system. 

To support this work, please contribute by testing and suggesting improvements
or fork and contribute patches.

If your school district or similar geographically-distributed network
organization would like assistance setting up the necessary data adaptors to
aggregate your data in guaranteed-anonymized format for sending to the
SubtleSentinel Realtime app.


## First code to break ground

The only code for this groundbreaking is in [`map-demo.R`](/map-demo.R), 
who get their high speed internet from the Merced County Office of Education.
Merced County districts are organized into five, "Trustee Areas", Area 1, Area
2, etc. This demo script simply fetches data on California school district
shapes for plotting in a map, matches districts to areas, and colors each
district's polygon by its Area membership.


