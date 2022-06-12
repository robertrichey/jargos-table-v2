/*----------------------------------------------------------------------------
Jargo's Table (for four Laptops on a local network)

Copyright (c) 2010 Van Stiefel.  All rights reserved.
http://vanstiefel.com      
vstiefel@wcupa.edu

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
U.S.A.
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// name: Jargo's Table
// desc: networked laptop quartet (author uses an Airport Extreme)
//       (also see keyboard mappings for each part: 
//
//                         TextureServe.pdf
//                         ColorServe.pdf
//                         RhythmServe.pdf
//                         TimbreServe.pdf
//
// Each (laptop) player is responsible for controlling a singular compositional 
// parameter for all four machines. Interesting (or uninteresting) music arises
// out of the interdependent compositional/improvisational dialog.
//
// author: Van Stiefel using ChucK by Ge Wang and Perry Cook
//                            http://chuck.cs.princeton.edu/
//
// Run (command line chuck is preferred) each station chucks a Client.ck and one of the four "parts."
//
//                         TextureServe.ck
//                         ColorServe.ck
//                         RhythmServe.ck
//                         TimbreServe.ck
//
// Players are numbered 1 - 4. Their number is an argument chucked with Client.ck
// For Example:
// Machine One types:
//    %> chuck Client.ck:1 TextureServe.ck
// Machine Two types:
//    %> chuck Client.ck:2 ColorServe.ck
// Machine Three types:
//    %> chuck Client.ck:3 RhythmServe.ck
// Machine Four types:
//    %> chuck Client.ck:4 TimbreServe.ck
//
// It does not matter which machine number goes with which part. 
//
// Players are updated during play with messages indicating what timbre or color (pitchtable)
// or talea index (duration series) their station is sounding--or, if they are not playing.
// Every 12 seconds a time appears minute:second to time the length of fun you are having. 
// The duration of the composition is up to the group, or the TextureServe.ck player. 
// She is the player that ends the piece by simply quitting play.
// 
// TextureServe.ck also initiates play. This machine chooses the number of note events
// her machine (or another's) may play. It is best to wait for those iterations to end
// before initiating a new sequence, but it *should* not break if one keeps pressing keys.
// The other machines may change the variables of their parameters "mid-stream," or
// in the middle of a sounding sequence of note events.
//
// Note: TimbreServe.ck and RhythmServe.ck require two strokes to send a message. 
// See keyboard mapping pdf's for more direction.
//
// The author is perfectly satisfied listening to unamplified laptops playing
// this piece in a room. (Who Cares If They Listen). It may also be acceptable to route
// audio to a PA or to multiple speakers. This "chamber laptop group" model does
// not depend on the PLOrk paradigm, i.e. laptop-amp-stations firmly located in space.
// 
//-----------------------------------------------------------------------------


// TODO comments and casing for below globals --------------------------------------------------
//
0.9 => dac.gain; //adjust manually - TODO why?

int myMachine;

// TODO confirm logic
if (me.args()) {
    me.arg(0) => Std.atoi => myMachine;
}

if (myMachine <= 0 || myMachine > 4) {
    <<< "Not a valid machine choice." >>>;
} 
else {
    <<< "My machine is number:", myMachine >>>;
}


// TODO refactor floats as fractions?
[0.5, 1.0, 1.5, 0.16666666667, 0.33333333] @=> float tempo[];
int tempoIndex;
tempo[tempoIndex]::second => dur T;


Event finished; // TODO not used anywhere. Remove?
Event globalEvent; // TODO needs a better name


int colorIndex;
int durationIndex;
int taleaIndex;
int timbre;
int DelayIndex;

//
OscRecv recv[4];
5501 => recv[0].port;//receives texture and pulse
5502 => recv[1].port;//receives timbre
5503 => recv[2].port;//receives rhythm/offset
5504 => recv[3].port;//receives pitch

//
for (0 => int i; i < 4; i++) {
    recv[i].listen();
}

// TODO why does recv[0] have two .event operations?
recv[0].event("/pulse, i") @=> OscEvent pulseEvent;
recv[0].event("/instrumentRhythm, i i i") @=> OscEvent instrumentRhythmEvent;//station
recv[1].event("/Timbre, i i") @=> OscEvent timbreEvent;
recv[2].event("/Rhythm, i i") @=> OscEvent rhythmEvent;
recv[3].event("/Color, i") @=> OscEvent colorEvent;

Gain MainOut => dac;
float Main => MainOut.gain; // TODO initialization of Main? Only used for fadeUp() and fadedDown() - might be able to ditch it
<<< Main >>>;
//-----------------------------------------------------------------------------------------------

// Karp OrK tunings
// TODO what is the point of these? just intonation?
32.7 => float c1; //24
34.64 => float csh1; //25
36.7 => float d1; //26
38.89 => float dsh1; // 27
41.203 => float e1;//28
43.653 => float f1;//29
46.149 => float fsh1;//30
48.999  => float g1;//31
51.99 => float gsh1; //32
55.  => float a1; //33
58.27 => float ash1; //34
61.73 => float b1; //35
65.4 => float c2; //36
69.715658  => float csh2; //37       
73.686192  => float d2; // 38         
78.031746 => float dsh2; // 39
82.556889 => float e2; // 40         
87.587058 => float f2; // 41         
92.998606 => float fsh2; //42
98.1 => float g2; //43        
104.076174 => float gsh2; //44      
110.272  => float a2; //45
116.840940 => float ash2; //46      
123.950825 => float b2; //47  
131.71279 => float c3; //48      
140.141315 => float csh3; //49
148.192384 => float d3; //50      
156.363492 => float dsh3; // 51      
166.783778 => float e3;//52 
175.61412 => float f3;//53
185.897211 => float fsh3;//54
196.597711 => float g3;//55       
208.952349 => float gsh3;//56     
219.40 => float a3;//57
234.971881 => float ash3;//58       
249.341651 => float b3;//59         
263.72558 => float c4; //60
279.982631 => float csh4; //61      
297.914768 => float d4; // 62        
313.926984 => float dsh4;//63
332.477557 => float e4; //64        
353.628231 => float f4; //65         
374.644423 => float fsh4;//66
395.995436 => float g4; //67        
420.854698 => float gsh4; //68      
444.85 => float a4; //69
471.663762 => float ash4; // 70     
500.383301 => float b4; //71         
531.251131 => float c5;//72
562.365262 => float csh5;//73       
598.329536 => float d5;//74     
633.253967 => float dsh5;//75
671.255114 => float e5; //76       
714.156463 => float f5; //77        
751.988845 => float fsh5;//78
800.990872 => float g5; //79       
849.609395 => float gsh5; //80      
899.7 => float a5; //81
952.327523 => float ash5; //82      
1011.766603 => float b5; //83      
1072.502261 => float c6;//84
1138.730524 => float csh6;//85      
1210.659072 => float d6;//86        
1287.507935 => float dsh6;//87
1359.510228 => float e6; //88 
1451.91296 => float f6; //89       
1537.977691 => float fsh6; //90     
1625.98 => float g6;// 91
1739.218790 => float gsh6;//92
1829. => float a6; //93
1934.65 => float ash6; //94
2020.63 => float b6; //95
2190.65 => float c7;//96

// the array TODO describe
[c1, csh1, d1, dsh1, e1, f1, fsh1, g1, gsh1, a1, ash1, b1,
c2, csh2, d2, dsh2, e2, f2, fsh2, g2, gsh2, a2, ash2, b2,
c3, csh3, d3, dsh3, e3, f3, fsh3, g3, gsh3, a3, ash3, b3,
c4, csh4, d4, dsh4, e4, f4, fsh4, g4, gsh4, a4, ash4, b4,
c5, csh5, d5, dsh5, e5, f5, fsh5, g5, gsh5, a5, ash5, b5,
c6, csh6, d6, dsh6, e6, f6, fsh6, g6, gsh6, a6, ash6, b6, c7] 
@=> float pitches[]; 


//
10 => int numKarpvoices;
int Karpvoices[numKarpvoices]; // an array to keep up with voices used
StifKarp m[numKarpvoices]; // TODO variable name
BPF pluckFilter[numKarpvoices];
Envelope myenv[numKarpvoices];
JCRev rKarp; 
0.05 => rKarp.mix; 
rKarp => MainOut;

//
for (0 => int i; i < numKarpvoices; i++) {
    m[i] => pluckFilter[i] => myenv[i]; 
    1.0 => pluckFilter[i].gain;
    0.6  => m[i].pickupPosition;// these effect tuning; so, set once 
    1.0  => m[i].sustain => m[i].stretch => m[i].baseLoopGain;   
    (Std.rand2f(68.0, 80.0), 1.0) => pluckFilter[i].set; // TODO check parentheses - is this broken?
    0 => Karpvoices[i]; // all voices free
}


//
10 => int numSweepKarpvoices;
int SweepKarpvoices[numSweepKarpvoices]; // an array to keep up with voices used
StifKarp swm[numSweepKarpvoices];
BPF sweepFilter[numSweepKarpvoices];
Envelope myenvsk[numSweepKarpvoices];

// TODO what is the purpose of Gain dry?
Gain dry;
Gain wet;
Gain SweepkpOrk => dry;
dry => DelayL del => HPF highPass => Dyno comp => MainOut;
del => wet => del;

// set parameters
10::ms => del.delay;
0.15 => dry.gain;
0.99 => wet.gain;
3 => highPass.Q;
comp.compress();

//
for (0 => int i; i < numSweepKarpvoices; i++) {
    swm[i] => sweepFilter[i] => myenvsk[i]; 
    2.0 => sweepFilter[i].gain;
    0.6  => swm[i].pickupPosition; // these effect tuning; so, set once 
    1.0  => swm[i].sustain => swm[i].stretch => swm[i].baseLoopGain;   
    (Std.rand2f(68.0, 80.0), 1.0) => sweepFilter[i].set;    
    0 => SweepKarpvoices[i]; //all voices free
}


//
10 => int numBlo;
int Blovoices[numBlo];
BlowBotl bottle[numBlo]; 
ResonZ resonator[numBlo];
Envelope env[numBlo];
JCRev rBlo => MainOut;
0.15 => rBlo.mix;

for (0 => int i; i < numBlo; i++) { 
    bottle[i] => resonator[i] => env[i];
    resonator[i].set(Std.rand2f(315.0, 325.0), Std.rand2f(0.35, 0.6));
    0 => Blovoices[i]; //reset voices to get
}


//
10 => int NumSineVoices;
SinOsc s[NumSineVoices];
int SineVoice[NumSineVoices];
Envelope sineEnv[NumSineVoices];
JCRev rSine => MainOut;
0.25 => rSine.mix;

for (0 => int i; i < NumSineVoices; i++) { 
    0.03 => s[i].gain;
    s[i] => sineEnv[i];
}


// score parameters
[[ 58, 60, 62 ], //0
[57,64, 65, 67], //1
[50, 60, 64, 65], //2
[49, 56, 59, 61, 63],//3
[48, 56, 59, 61, 63],//4
[48, 58, 60, 62],//5
[57, 58, 62, 64],//6
[55, 57, 64, 65, 67],//7
[50, 57, 59, 64],//8
[52, 62, 64, 65],//9
[68, 70, 76, 77],//10
[61, 70, 72, 79],//11
[65, 69, 74, 76],//12
[63, 65, 71, 73, 75],//13
[67, 70, 75, 74],//14
[69, 74, 75, 78],//15
[69, 72, 74, 76, 82],//16
[69, 71, 73, 79, 81, 76],//17
[53, 64, 65, 71, 72, 44],//18
[68, 71, 72, 74, 79],//19
[45, 52, 53, 55, 64, 69, 72, 74]//20
] @=> int color[][];

[[0.125, 0.25, 0.5, 1.0, 2.0, 4.0], 
[1.0, 2.0, 3.0, 4.0, 4.0]
] @=> float ringTime[][];

[[0.25, 0.25, 0.5, 0.5], 
[0.25, 1.0, 2.0], 
[0.5, 0.5, 1.0, 1.0, 0.25], 
[0.125, 0.25, 0.125, 0.25, 0.25, 1.0, 2.0], 
[0.125, 0.125, 0.5, 1.5, 4.0, 2.0]
] @=> float Talea[][];

[0.0, 0.25, 0.5, 1.0, 2.0] @=> float DelayArray[];

// spork independent threads
spork ~ pulseListener();
spork ~ getRhythm();
spork ~ getTexture();
spork ~ getTimbre();
spork ~ getColor();
spork ~ sweep();
spork ~ timer();

// Let time pass
1::hour => now;

//------------------------------------------------------------------------

// Repeatedly receives counts 1-8 from TextureServe.ck 
// TODO intention vs timer? Is it functional? See sendPulse() in TextureServe.ck
fun void pulseListener() {
    while (true) {
        pulseEvent => now;
        
        while (pulseEvent.nextMsg() != 0) {
            pulseEvent.getInt() => int beatCount;
            globalEvent.broadcast();
            //<<< Beat >>>;
        }
    }
}

//
fun void getRhythm() { //<<< "hi" >>>;
    while (true) {
        rhythmEvent => now;
        
        while (rhythmEvent.nextMsg() != 0) {
            rhythmEvent.getInt() => int station;
            rhythmEvent.getInt() => int control;
            
            if (selectRhythm(station) == 1 && control == 5) {
                0 => taleaIndex;//taleaIndex is reset to 0 if everyone is sent a parameter change
                rhythmControl(control);
            }
            else if (selectRhythm(station) == 1) {
                rhythmControl(control);
            }
        }
    }
}

//
fun int selectRhythm(int foo) {
    [[1, 5, 7, 11, 15, 17],
    [1, 5],
    [2, 6, 7, 12, 16, 17],
    [2, 5],
    [3, 5, 7, 13, 14, 17],
    [3, 5], 
    [4, 6, 7, 14, 16, 17],
    [4, 5]
    ] @=> int machineArray[][];
    
    int jack;
    
    if (myMachine == 1) {
        1 => jack;
    }
    if (myMachine == 2) {
        3 => jack;
    }
    if (myMachine == 3) {
        5 => jack;
    }
    if (myMachine == 4) {
        7 => jack;
    }
    
    machineArray[jack] @=> int RhythmRoute[];
    -1 => int check;
    
    for (0 => int i; i < RhythmRoute.cap(); i++) {
        RhythmRoute[i] => int test;
        
        if (test == foo) {
            1 +=> check;
        }
    }
    
    if (check > -1) {
        return 1;
    }
    else {
        return 0;
    }
}

//
fun void rhythmControl(int x) {
    if (x > 5 && x < 11) {
        x - 6 => DelayIndex;
        <<< "My delay is:", DelayArray[DelayIndex], "of pulse." >>>;
    }
    else if (x > 10 && x < 16) {
        x - 11 => taleaIndex;
        <<< "My talea index is:", taleaIndex >>>;
    }
    else if (x > 15 && x < 21) {
        x - 16 => tempoIndex;
        <<< "My tempo index is:", tempoIndex >>>;
    }
}

//
fun void getTimbre() { //<<< "hi" >>>;
    while (true) {
        timbreEvent => now;
        
        while (timbreEvent.nextMsg() != 0) {
            timbreEvent.getInt() => int station;
            timbreEvent.getInt() => int control;
            //<<< station, control >>>;
            
            if (selectTimbre(station) == 1 && station == 6) {
                timbreControl(station);
            }
            else if (selectTimbre(station) == 1 && station == 7) {
                timbreControl(station);
            }
            else if (selectTimbre(station) == 1) {
                timbreControl(control);
                //<<< "yes" >>>;
            }
        }
    }
}

//
fun int selectTimbre(int foo) {
    [[1, 5, 7, 11, 15, 17],
    [1, 5, 6],
    [2, 6, 7, 12, 16, 17],
    [2, 5, 7],
    [3, 5, 7, 13, 14, 17],
    [3, 5, 6], 
    [4, 6, 7, 14, 16, 17],
    [4, 5, 7]
    ] @=> int machineArray[][];
    
    int jack;
    
    if (myMachine == 1) {
        1 => jack;
    }
    if (myMachine == 2) {
        3 => jack;
    }
    if (myMachine == 3) {
        5 => jack;
    }
    if (myMachine == 4) {
        7 => jack;
    }
    //<<< jack >>>;
    
    machineArray[jack] @=>  int TimbreRoute[];
    -1 => int check;
    
    for (0 => int i; i < TimbreRoute.cap(); i++) {
        TimbreRoute[i] => int test;
        
        if (test == foo) {
            1 +=> check;
        }
    }
    
    if (check > -1) {
        return 1;
    }
    else {
        return 0;
    }
}

//
fun void timbreControl(int x) {
    if (x >= 6 && x <= 8) {
        Std.rand2(0,3) => timbre;
    }
    else if (x >=10 && x <= 14) {
        x - 11 => timbre;
    }
    <<< timbre >>>;
}

//
fun void getTexture() {
    [50, 300, 1000, 2000, 5000] @=> int fadeValues[];
    int index;
    //<<< "listener is here" >>>;
    
    while (true) {
        instrumentRhythmEvent => now; 
        
        while (instrumentRhythmEvent.nextMsg() != 0) {
            instrumentRhythmEvent.getInt() => int station; 
            <<< station >>>;
            
            instrumentRhythmEvent.getInt() => int reps;
            instrumentRhythmEvent.getInt() => index;
            
            // patch to stations
            // TODO should fadeUp/fadeOut be sporked?
            if (selectTexture(station) == 1) {
                <<< "My reps:", reps, "my Fade:", fadeValues[index], "::ms" >>>;
                fadeUp(fadeValues[index]::ms);
            }
            else if (selectTexture(station) == 0 && station <= 18) { // TODO why station <= 18?
                <<< "Not me this time, but reps =", reps >>>;
                fadeOut(fadeValues[index]::ms);
            }
            
            // choose mode
            if (station < 10 && selectTexture(station) == 1) {
                <<< "Unison" >>>;
                spork ~ waitForUnison(globalEvent, reps);
            }
            else if (station > 10 && selectTexture(station) == 1) {
                <<< "Poly" >>>;
                spork ~ waitForPoly(globalEvent, reps);
            }
        } 
    }
}

// routes Texture data to machine
fun int selectTexture(int station) {
    [[1, 5, 7, 11, 15, 17],
    [1, 5],
    [2, 6, 7, 12, 16, 17],
    [2, 5],
    [3, 5, 7, 13, 14, 17],
    [3, 5], 
    [4, 6, 7, 14, 16, 17],
    [4, 5]
    ] @=> int machineArray[][]; // TODO use of indexes 1, 3, 5, 7?
    
    int jack;
    
    if (myMachine == 1) {
        0 => jack;
    }
    if (myMachine == 2) {
        2 => jack;
    }
    if (myMachine == 3) {
        4 => jack;
    }
    if (myMachine == 4) {
        6 => jack;
    }
    
    machineArray[jack] @=> int textureBang[];
    -1 => int check;
    
    for (0 => int i; i < TextureBang.cap(); i++) {
        if (textureBang[i] == station) {
            1 +=> check;
        }
    }
    
    if (check > -1) {
        return 1;
    }
    else {
        return 0;
    }
}

//
fun void waitForUnison(Event e, int reps) {
    Event off;
    e => now;
    DelayArray[DelayIndex]::T => now;
    //<<< "wait" >>>;
    
    for (int i; i < reps; i++) {
        tempo[tempoIndex]::second => dur T;
        color[colorIndex] @=> int seq1[];
        ringTime[durationIndex] @=> float ringSeq[]; 
        Talea[taleaIndex] @=> float taleaSeq[];
        seq1[i%seq1.cap()] => int note;
        ringSeq[i % ringSeq.cap()]::T => dur len;
        
        if (timbre == 0) {
            <<< "Sine" >>>;
            spork ~ PlaySineNote(note, len, 8::ms, 10::ms);
        }
        else if (timbre == 1) {
            <<< "Blo" >>>;
            spork ~ playBlo(note, len, 8::ms, 10::ms);
        }
        else if (timbre == 2) {
            <<< "Pluk" >>>;
            spork ~ playKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.7, 0.9));
        }
        else if (timbre == 3) {
            <<< "Sweep" >>>;
            spork ~ playSweepKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.5, 0.7));
        }
        taleaSeq[i % taleaSeq.cap()]::T => now; 
    } 
    off.signal();
    // <<< "done" >>>;
    off => now;
}

//
fun void waitForPoly(Event e, int reps) { 
    Event off;
    e => now;
    //<<< "wait" >>>;
    
    for (0 => int i; i < reps; i++) {
        tempo[tempoIndex]::second => dur T;
        color[colorIndex] @=> int seq1[];
        ringTime[durationIndex] @=> float ringSeq[]; 
        Talea[taleaIndex] @=> float taleaSeq[];
        seq1[Std.rand2(0,seq1.cap()-1)] => int note;
        ringSeq[Std.rand2(0,ringSeq.cap()-1)]::T => dur len;
        
        if (timbre == 0) {
            spork ~ PlaySineNote(note, len, 8::ms, 10::ms);
        }
        else if (timbre == 1) {
            spork ~ playBlo(note, len, 8::ms, 10::ms);
        }
        else if (timbre == 2) {
            spork ~ playKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.6, 0.99)); 
        }
        else if (timbre == 3) {
            spork ~ playSweepKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.7, 0.99));
        }
        0.5::T => now; // a periodic groove
    } 
    off.signal();
    // <<< "done" >>>;
    off => now;
}

//
fun void playKarp(int pitch, dur len, dur attktime, dur decaytime, float pluck) {
    getFreeVoice(Karpvoices) => int newvoice; //<<< newvoice >>>;
    
    if (newvoice > -1) {        
        attktime => myenv[newvoice].duration;
        myenv[newvoice] => rKarp;
        pitches[pitch-24] => m[newvoice].freq;
        Std.rand2f(0.2, 0.8) => m[newvoice].pickupPosition;
        1 => myenv[newvoice].keyOn;
        pluck => m[newvoice].pluck; //<<< "att" >>>;
        len - decaytime => now;       
        decaytime => myenv[newvoice].duration;
        1 => myenv[newvoice].keyOff; //<<< "decay" >>>;
        decaytime => now;        
        myenv[newvoice] =< rKarp;
        0 => Karpvoices[newvoice];
    }
}

//
fun void playSweepKarp(int pitch, dur len, dur attktime, dur decaytime, float pluck) { 
    getFreeVoice(SweepKarpvoices) => int newvoice; //<<< newvoice >>>;
    
    if (newvoice > -1) {        
        attktime => myenvsk[newvoice].duration;
        myenvsk[newvoice] => SweepkpOrk;
        pitches[pitch-24] => swm[newvoice].freq;
        Std.rand2f(0.2, 0.8) => swm[newvoice].pickupPosition;
        1 => myenvsk[newvoice].keyOn;
        pluck => swm[newvoice].pluck; //<<< "att" >>>;
        len - decaytime => now;       
        decaytime => myenvsk[newvoice].duration;
        1 => myenvsk[newvoice].keyOff; //<<< "decay" >>>;
        decaytime => now;        
        myenvsk[newvoice] =< SweepkpOrk;
        0 => SweepKarpvoices[newvoice];
    }
}

//
fun void PlaySineNote(int note, dur len, dur attktime, dur decaytime) { 
    getFreeVoice(SineVoice) => int newvoice; // <<< "sine" >>>;
    
    if (newvoice > -1) {
        attktime => sineEnv[newvoice].duration;
        sineEnv[newvoice] => rSine;
        note => float freq;
        Std.mtof(freq + 12) => s[newvoice].freq;
        0 => s[newvoice].phase;
        1 => sineEnv[newvoice].keyOn;
        len - decaytime => now;
        decaytime => sineEnv[newvoice].duration;
        1 => sineEnv[newvoice].keyOff;
        decaytime => now;
        sineEnv[newvoice] =< rSine;
        0 => SineVoice[newvoice];
    }
}

//
fun void playBlo(int note, dur len, dur attktime, dur decaytime) {
    getFreeVoice(Blovoices) => int newvoice; //<<<"blo" >>>;
    
    if (newvoice > -1) { 
        attktime => env[newvoice].duration;
        env[newvoice] => rBlo;
        note => float freq;
        Std.mtof( freq )=> bottle[newvoice].freq;
        0.019653 => bottle[newvoice].noiseGain;
        Std.rand2f(3.2, 4.4) => bottle[newvoice].vibratoFreq;
        Std.rand2f (0.5, 0.9) => bottle[newvoice].vibratoGain;
        0.65 => bottle[newvoice].volume; 
        1 => env[newvoice].keyOn;
        Std.rand2f(0.2, 0.4) => bottle[newvoice].noteOn;
        len - decaytime => now;
        1 => env[newvoice].keyOff;
        decaytime => now;
        1. => bottle[newvoice].noteOff;
        env[newvoice] =< rBlo;
        0 => Blovoices[newvoice];
    }
}

// Find the index of a free voice in a ugen array using in auxiliary 'voices' array
fun int getFreeVoice(int voices[]) { 
    for (0 => int i; i < voices.cap(); i++) {
        if (voices[i] == 0) { 
            1 => voices[i];
            return i; 
        }
    }
    return -1;
}

//----------------------------------------------------------------------
// TODO what do these do?
//      Result of dividing two durations and chucking to float?
//      Can this logic be replaced by the use of a 'master' Envelope on MainOut?

fun void fadeUp (dur fadeTime) {   
    fadeTime / 2::ms => float n;
    0.9 / n => float d;
    
    while (Main < 0.9) {
        for (int i; i < 50; i++) {
            d +=> Main => Main;
            Main => MainOut.gain;
            2::ms => now;
        }
    }
}

fun void fadeOut(dur fadeTime) {   
    fadeTime / 2::ms => float n;
    0.9 / n => float d;
    
    while (Main > 0.0) {
        for (0 => int i; i < 50; i++) {
            Main - d => Main;
            Main => MainOut.gain;
            2::ms => now;
        }
    }
}
//----------------------------------------------------------------------

//
fun void getColor() { //<<< "color is here" >>>;
    while (true) {
        colorEvent => now;
        
        while (colorEvent.nextMsg() != 0) {
            colorEvent.getInt() => colorIndex;
            <<< "My ColorIndex is:", colorIndex >>>;
        }
    }
}

// TODO what is 't'? logic behind calculation of f.freq?
// Used for SweepkpOrk's filter
fun void sweep() {
    float t;
    
    while (true) {
        // sweep the cutoff
        Math.sin(t) * 110 => Std.fabs => Std.mtof => highPass.freq; // no parentheses on functions - broken?
        // increment t
        0.005 +=> t;
        // advance time
        5::ms => now;
    }
}    

// prints the elapsed time of the piece every 12 seconds
fun void timer() {  
    while (true) {
        0 => int count;
        0 => int seconds;
        0 => int minutes;
        
        while (true) {
            if (count != 0 && count % 60 == 0) {
                minutes++;
            }
            if (count % 12 == 0) {
                <<< minutes, ":", seconds >>>;
            }
            count++; 
            seconds++; 
            
            if (seconds == 60) {
                0 => seconds;
            }
            second => now;
        }
    }
}