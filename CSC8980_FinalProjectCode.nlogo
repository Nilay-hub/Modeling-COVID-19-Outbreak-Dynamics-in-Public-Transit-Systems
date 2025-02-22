;                          CSC8980  Modeling COVID-19 Outbreak Dynamics in Public Transit Systems.
;                                       Dattu Reddy Maddur & Nilay Patel
;                                  Department of Computer Science, Georgia State University





breed [passengers passenger] ; create agents i.e passengers


; declaring passenger specific variables
passengers-own[infection duration-inside-bus time-since-infection infected? ]



; declaring the global variables
globals [

  time
  susceptible-passengers
  infected-passengers

  ; Susceptible and infected passengers count at the start of simulation
  initial-susceptible-passengers
  initial-infected-passengers


  total-passengers-count ; total no. passengers that can be allowed in bus
  total-exposure
  virus-transmission-rate
  infectious-radius-local
  exposure-time-limit-local
  number
  passenger-boarding-rate
  count-exits
  total-passengers-with-destination
]




; below function to setup bus layout with passengers waiting outside
to setup
  clear-all  ; reset everything
  file-open "seatslayout.csv" ; load csv file to populate seats inside the bus
  set-default-shape passengers "person"
  ask patches[ set pcolor white ]
  create-bus
  while [not file-at-end?][
    create-seats
  ]
  add-passengers-in-bus-stop
  bus-entrance
  file-close-all ; close the csv file
  reset-ticks
  set count-exits 0
end



to start-simulation
  if ticks >= time-before-trip-ends * 1000 [ stop ] ; if trip time ends, stop simulation
  move-passengers  ; otherwise move passenger
  rate_of_passenger
  tick
end

 ; set the seat layout inside the bus using the csv file
to create-seats
  let csv file-read-line
  set csv word csv ","
  let mylist []
  while [not empty? csv]
  [
    let $sep position "," csv
    let $item substring csv 0 $sep
    carefully [set $item read-from-string $item][]
    set mylist lput $item mylist
    set csv substring csv ($sep + 1) length csv
  ]
  let x item 0 mylist * 1.75
  let y item 1 mylist * 1.75
    ask patch x ( y - 20 ) [
  let ent item 6 mylist
    (ifelse
    ent = "Entrance" [
      set pcolor green]
    ent = "SeatingArea" [
      set pcolor pink]
   ent = "Checkout" [
      set pcolor yellow]
   ent = "LowerLevelSeating" [
      set pcolor grey]
    [set pcolor red])
  ]
end




to create-bus
    ask patches[
    if pxcor = 32 and pycor = -25 [set pcolor yellow ]
    if  (pxcor >= -14 and pxcor <= 33 ) and pycor = -26 [set pcolor grey ]
      if  (pxcor >= 14 and pxcor <= 33 ) and pycor = -14 [set pcolor grey ]
    if  (pxcor >= -13 and pxcor <= 13 ) and pycor = -14 [set pcolor grey ]
    if  (pycor >= -26 and pycor <= -14) and pxcor = -14 [set pcolor grey ]
    if  (pycor >= -26 and pycor <= -6) and pxcor = 33 [set pcolor grey ]
   ; if  (pycor >= -14 and pycor <= -6) and pxcor = 14 [set pcolor grey ]
    if (pxcor >= -11 and pxcor <= -8) and (pycor >= 2 and pycor <= 4 )[set pcolor yellow ]
     if (pxcor >= 26 and pxcor <= 33) and (pycor >= -5 and pycor <= 8 )
    [set pcolor orange]
    if (pxcor >= -14 and pxcor <= 27) and (pycor >= -13 and pycor <= 8 )
    [set pcolor rgb 163 127 161 ]

    if (pxcor >= 14 and pxcor <= 25) and (pycor >= -4 and pycor <= 8 )
    [set pcolor rgb 163 127 161 ]
     if (pxcor >= -13  and pxcor <= 32 ) and (pycor >= -25 and pycor <= -15 )
     ;[set pcolor black ]
      [set pcolor black]
    ;if (pxcor >= 15  and pxcor <= 32 ) and (pycor >= -14 and pycor <= -6 )
     if (pxcor >= 15  and pxcor <= 32 ) and (pycor >= -25 and pycor <= -15 )
     [set pcolor black ]
     if (pxcor >= 28 and pxcor <= 31) and (pycor >= -13 and pycor <= -6 )
    [set pcolor red ]
  ]
end


to add-passengers-in-bus-stop
   create-passengers maximum-passengers
   [
      initialize-passengers
   ]
  set total-passengers-count count passengers

  set initial-susceptible-passengers count passengers with [color = white]
  set initial-infected-passengers count passengers with [color = orange]
  set time trip-duration * 10
  set number 0
  rate_of_passenger
end


to bus-entrance
  ask patches[
    if  (pxcor >= -9 and pxcor <= -5) and pycor = -14 [set pcolor green ] ; set the entrance patches
  ]
end



 ; Initial values for all the passengers.
to initialize-passengers
  let random_patch one-of patches with [pcolor = rgb 163 127 161]

  ; select any random patch from the bus stop area to place a passenger
  let x [ pxcor ] of random_patch
  let y [ pycor ] of random_patch

  ; set coordinates for passenger in a bus stop
  setxy  x  y
  set time-since-infection 0
  set color white
  set size 1
  set infected? false
  set duration-inside-bus random  500
  set infection random 100
  if infection > 100 - percentage_of_infected
  [
     set color orange
     set infected? true
  ]
end


to rate_of_passenger
  ifelse (number = 20 and time > 0) [
    set passenger-boarding-rate  random maximum-boarding-rate
    if change-arrival-rate? [
      set passenger-boarding-rate modified-arrival-rate
    ]
   create-passengers  passenger-boarding-rate [
      initialize-passengers
    ]
    set total-passengers-count total-passengers-count + passenger-boarding-rate
    set number 0
  ]
  [
    set number number + 1;
  ]
end


to move-passengers
  ask passengers [

    let s count passengers
    set duration-inside-bus duration-inside-bus - 1
    ifelse ( ( pcolor = rgb 163 127 161 or pcolor = green or pcolor = black or  pcolor = grey or pcolor = white or pcolor = yellow or pcolor = red or pcolor = orange) and duration-inside-bus > 0)  [
    if pcolor = rgb 163 127 161 [

        set heading towards one-of patches with [pcolor = green]  ; move passenger from bus stop to bus entrance
        fd 5
      ]
      if(pcolor = gray)
      [
        set heading 180
        fd 1
      ]
     if ( pcolor = green )[
        set heading 180
        fd 2
      ]
     if ( pcolor = black  )[
       set heading random 360
       fd 1
      ]
     if( pcolor = grey or pcolor = white or pcolor = yellow )
       [ bk 2 ]

    if pcolor = red [
        let x one-of [pxcor] of patches with [pcolor = orange]
        let y one-of [pycor] of patches with [pcolor = orange]
        facexy x y
        fd 1
    ]
    if pcolor = orange [
        if color = white [set susceptible-passengers susceptible-passengers + 1]
        if color = orange [set infected-passengers infected-passengers + 1]
        set total-passengers-with-destination total-passengers-with-destination + 1
        die

      ]

    ]
    [
      ifelse ( duration-inside-bus <= 0 and ( pcolor = black or pcolor  = 135 or pcolor = 105 or pcolor = red or pcolor = 45 or pcolor = 5 or pcolor = gray))
      [
         let x one-of [pxcor] of patches with [pcolor = red]
         let y one-of [pycor] of patches with [pcolor = red]
         facexy x y
         fd 1
        if (pcolor = red )
        [let x2 one-of [pxcor] of patches with [pcolor = orange]
         let y2 one-of [pycor] of patches with [pcolor = orange]
        facexy x2 y2
          fd 1
          ]
        if (pcolor = orange) [
;          fd random 10
;          stop
          if color = white [set susceptible-passengers susceptible-passengers + 1]
          if color = orange [set infected-passengers infected-passengers + 1]
          set total-passengers-with-destination total-passengers-with-destination + 1
          die
        ]
      ]
      [
        ifelse( duration-inside-bus <= 0 and ( pcolor = rgb 163 127 161 or pcolor  = green  ))
        [ set duration-inside-bus 10]
       [set heading 90 fd 1]
      ]
    ]
 ]
  spread-infection
  final-bus-stop
  exit-from-bus
end


to spread-infection
  ask passengers with [color = white ] [
    if (pcolor = black or pcolor  = 135 or pcolor = 105 or pcolor = red or pcolor = 45 or pcolor = 5 or pcolor = gray) [ ; this condition checks for if passenger in the bus
      check-mask
      check-if-vaccinated
      if any? other passengers in-radius infectious-radius-local with [color = orange] [
        ;exposure time
        set time-since-infection time-since-infection + 0.1

        set total-exposure total-exposure + time-since-infection
        if  time-since-infection > exposure-time-limit-local  [
            if random 100 < virus-transmission-rate [
            set infected? true
            set color orange
          ]
        ]
      ]
    ]
  ]
end


; change rate of transmission if passengers are vaccinated
to check-if-vaccinated
 ifelse vaccinated? [
    set virus-transmission-rate transmission-when-mask  ; update with the values from the interface selected
    set infectious-radius-local infectiousradius-when-mask
    set exposure-time-limit-local exposure-time-limit-when-mask
  ][
    set virus-transmission-rate transmission-rate
    set infectious-radius-local infectious-radius
    set exposure-time-limit-local exposure-time-limit
  ]
end


; function to change the transimssion rate if passengers are wearing masks
to check-mask
  ifelse mask? [
    set virus-transmission-rate transmission-when-mask
    set infectious-radius-local infectiousradius-when-mask
    set exposure-time-limit-local exposure-time-limit-when-mask
  ][
    set virus-transmission-rate transmission-rate
    set infectious-radius-local infectious-radius
    set exposure-time-limit-local exposure-time-limit
  ]
end


to exit-from-bus
  ask passengers with [pcolor = white] [
    die ; remove passengers from simulation
    set count-exits count-exits + 1
    print count-exits
  ]
  if (count passengers = 0) [stop]
end


to final-bus-stop
  set time time - 1
  if time < 0[
    ask passengers [
    if pcolor != rgb 163 127 161 and pcolor != green[ ; ask passengers to get down from bus
         let x one-of [pxcor] of patches with [pcolor = red]
         let y one-of [pycor] of patches with [pcolor = red]
         facexy x y
         fd 1
      ]
    ]
  ]
end



@#$#@#$#@
GRAPHICS-WINDOW
442
10
918
370
-1
-1
9.0
1
10
1
1
1
0
0
0
1
-16
35
-28
10
1
1
1
ticks
30.0

BUTTON
45
12
140
45
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
260
192
293
maximum-passengers
maximum-passengers
0
43
35.0
1
1
NIL
HORIZONTAL

BUTTON
40
60
163
93
Start Simulation
start-simulation
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
21
152
171
197
No of Passengers in Bus
count passengers with \n[pcolor != brown and pcolor != green]
17
1
11

SLIDER
17
311
189
344
time-before-trip-ends
time-before-trip-ends
0
24
17.0
1
1
NIL
HORIZONTAL

SLIDER
226
10
410
43
percentage_of_infected
percentage_of_infected
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
229
53
401
86
infectious-radius
infectious-radius
0
5
2.5
0.5
1
NIL
HORIZONTAL

PLOT
663
384
1040
646
Passengers in bus
time
Passengers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Infected Passengers" 1.0 0 -955883 true "" "plot count passengers with [color = orange]"
"Susceptible Passengers" 1.0 0 -5825686 true "" "plot count passengers with [color = white]"
"Total Passengers " 1.0 0 -7500403 true "" "plot count passengers"

SLIDER
227
147
397
180
exposure-time-limit
exposure-time-limit
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
227
96
399
129
transmission-rate
transmission-rate
0
5
1.0
1
1
NIL
HORIZONTAL

PLOT
1056
389
1382
627
Passengers after they exit the bus
time
No. of Passengers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Susceptible" 1.0 0 -13791810 true "" "plot susceptible-passengers"
"Total" 1.0 0 -1184463 true "" "plot infected-passengers + susceptible-passengers"
"Infected" 1.0 0 -2674135 true "" "plot infected-passengers"

SLIDER
933
119
1118
152
transmission-when-mask
transmission-when-mask
0
5
1.0
1
1
NIL
HORIZONTAL

SWITCH
940
19
1043
52
mask?
mask?
0
1
-1000

SLIDER
927
62
1135
95
infectiousradius-when-mask
infectiousradius-when-mask
0
5
1.0
0.5
1
NIL
HORIZONTAL

SLIDER
927
172
1142
205
exposure-time-limit-when-mask
exposure-time-limit-when-mask
0
10
7.0
1
1
NIL
HORIZONTAL

PLOT
15
362
300
585
Passenger Arrivial Rate
time
No. of passengers
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot passenger-boarding-rate"

PLOT
327
386
650
650
Infection Rate
time
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot infected-passengers / ( 1 + infected-passengers + susceptible-passengers)"

SLIDER
227
259
399
292
modified-arrival-rate
modified-arrival-rate
0
10
10.0
1
1
NIL
HORIZONTAL

SWITCH
227
196
396
229
change-arrival-rate?
change-arrival-rate?
1
1
-1000

SLIDER
7
105
187
138
maximum-boarding-rate
maximum-boarding-rate
0
10
3.0
1
1
NIL
HORIZONTAL

SWITCH
938
221
1059
254
vaccinated?
vaccinated?
0
1
-1000

SLIDER
14
209
186
242
trip-duration
trip-duration
0
24
16.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
             CSC8980  Modeling COVID-19 Outbreak Dynamics in Public Transit Systems.                                Dattu Reddy Maddur & Nilay Patel
                      Department of Computer Science, Georgia State University




Buses allow large numbers of people to travel in close proximity, making them a potential site for COVID-19 transmission. It is vital to find safe ways for passengers to travel and minimize virus spread. Models of passenger dynamics and transmission can estimate infection risk and assess interventions to reduce risk.

We propose an agent-based model with three components: a passenger mobility model, a virus transmission model, and a mask policy model. We use the model to estimate total passenger exposure time and number of potential infections.

ENTITY, STATE VARIABLES AND SCALES
Agents
Passengers enter and exit the bus at stops. Some are infected with COVID-19. Passengers move to open seats when boarding and may stand if seats are full.

Bus
The bus is represented as a grid of seats. The seats are patches colored blue. There are two doors for entry/exit.

Stops
Bus stops are patches colored red where passengers enter and exit the bus.

Environment
The environment is the bus and surroundings. key areas:

Doors: Entry and exit points colored green
Aisles: Walkways between seats
Seats: Patches for sitting colored blue
Stops: Bus stop patches colored red

PROCESS OVERVIEW AND SCHEDULING

Passenger Mobility: Passengers board at stops and move to open seats or stand. 
Transmission Model: Susceptible passengers become infected based on exposure time to infectious passengers.
Mask Policy: Models effect of mask use on virus transmission.
DESIGN CONCEPTS
Passenger Mobility
Boarding: New passengers spawn at stops and board bus through doors to open seats. If full, they stand.
Sitting and Standing: Passenger agents occupy seats or spaces.
Exit: Passengers exit at stops near destination through doors.
Transmission Model
Exposure: Susceptible passengers track time spent near infectious passengers
Infection: Susceptible passengers have infection chance based on exposure time
Mask Policy
Mask Use: Percentage of passengers wearing masks is set
Effect: Masks reduce transmission rate in mode
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
