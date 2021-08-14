# MMO Games Database Design And Implementation
massive multiplayer online (MMO) games database design and implementation.\
<img src='Diagram files/diagram-main.jpg'></img>
## Overview of content
This project consists of three main parts:
* Building database tables and injecting data into them
* Functions and views
  * a function which gets an alliance ID and returns usernames of its members in a table (table-valued function)
  * a function which gets an location ID and returns its coordinates (scalar-valued function)
  * a function which gets a player ID and a unit ID and returns 1 if player can purchase the unit and 0 otherwise (scalar-valued function)
  * a function which orders alliances based on sum of its members' credits
  * a view containing id,name and number of members for each alliance
  * a view containing a list of all locations and name and number of units located in each location
  * a view containing  ids  and usernames of all players  and number of each two type of movements they have started
  * a view containing a list of all locations and name and number of structures located in each location

* Precursors and Triggers
  * a procedure to add a player to an alliance
  * a procedure to remove a player from an alliance
  * a procedure to add structures to a location
  * a procedure to destroy structures to a location
  * a procedure to buy units and locate them on a location
  * a procedure to sell units of a location
  * a trigger to record activities of alliances members
  * a trigger to record creation and deletion of alliances
  * a trigger to record trades on units

## Contact
Find me at [My Email](elitoulabin@gmail.com)

