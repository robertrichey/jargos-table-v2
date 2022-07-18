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


// STATION AND OSC SETUP -------------------------------------------------------------

if (!me.args()) {
    <<< "Missing argument" >>>;
    me.exit();
}

Std.atoi(me.arg(0)) => int myStation;

if (myStation < 0 || myStation > 3) {
    <<< "Invalid argument" >>>;
    me.exit();
}  

<<< "My station is number:", myStation >>>;

OscRecv recv[4];
5501 => recv[0].port; //receives texture and pulse
5502 => recv[1].port; //receives timbre
5503 => recv[2].port; //receives rhythm/offset
5504 => recv[3].port; //receives pitch

for (0 => int i; i < 4; i++) {
    recv[i].listen();
}

recv[0].event("/pulse, i") @=> OscEvent pulseEvent;
recv[0].event("/instrumentRhythm, i i i") @=> OscEvent instrumentRhythmEvent;
recv[1].event("/timbre, i i") @=> OscEvent timbreEvent;
recv[2].event("/rhythm, i i") @=> OscEvent rhythmEvent;
recv[3].event("/color, i") @=> OscEvent colorEvent;

Event globalEvent; // TODO needs purpose clarified and a more descriptive name



// SCORE PARAMETERS ---------------------------------------------------------------------------

[[58, 60, 62], //0
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
int colorIndex;

[[0.125, 0.25, 0.5, 1.0, 2.0, 4.0], 
[1.0, 2.0, 3.0, 4.0, 4.0]
] @=> float ringTime[][];
int ringIndex;

[[0.25, 0.25, 0.5, 0.5], 
[0.25, 1.0, 2.0], 
[0.5, 0.5, 1.0, 1.0, 0.25], 
[0.125, 0.25, 0.125, 0.25, 0.25, 1.0, 2.0], 
[0.125, 0.125, 0.5, 1.5, 4.0, 2.0]
] @=> float taleaArray[][];
int taleaIndex;

1.0 / 3.0 => float oneThird;
1.0 / 6.0 => float oneSixth;
[0.5, 1.0, 1.5, oneSixth, oneThird] @=> float tempo[];
int tempoIndex;

dur timeUnit;
tempo[tempoIndex]::second => timeUnit;

[0.0, 0.25, 0.5, 1.0, 2.0] @=> float delayArray[];
int delayIndex;

// used for selecting instrument TODO place in getter/setter? (see timbreControl, waitForUnison, waitForPoly)
int timbre;

0.9 => dac.gain; // TODO why set dac gain?
Gain mainOut => dac;
float mainOutGain => mainOut.gain; // TODO initialization of mainOutGain? Only used for fadeUp() and fadedDown() - might be able to ditch it



// INSTRUMENT SETUP ---------------------------------------------------------------------------

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

// Named frequencies is used for pitch collections
[c1, csh1, d1, dsh1, e1, f1, fsh1, g1, gsh1, a1, ash1, b1,
c2, csh2, d2, dsh2, e2, f2, fsh2, g2, gsh2, a2, ash2, b2,
c3, csh3, d3, dsh3, e3, f3, fsh3, g3, gsh3, a3, ash3, b3,
c4, csh4, d4, dsh4, e4, f4, fsh4, g4, gsh4, a4, ash4, b4,
c5, csh5, d5, dsh5, e5, f5, fsh5, g5, gsh5, a5, ash5, b5,
c6, csh6, d6, dsh6, e6, f6, fsh6, g6, gsh6, a6, ash6, b6, c7] @=> float pitches[]; 


// Plucked string sound
10 => int pluckedCount;
int pluckedVoices[pluckedCount]; // an array to keep up with voices used
StifKarp pluckedString[pluckedCount];
BPF pluckedFilter[pluckedCount];
Envelope pluckedEnvelope[pluckedCount];
JCRev pluckedReverb; 
0.05 => pluckedReverb.mix; 
pluckedReverb => mainOut;

for (0 => int i; i < pluckedCount; i++) {
    pluckedString[i] => pluckedFilter[i] => pluckedEnvelope[i]; 
    1.0 => pluckedFilter[i].gain;
    0.6  => pluckedString[i].pickupPosition; // these effect tuning; so, set once
    1.0  => pluckedString[i].sustain => pluckedString[i].stretch => pluckedString[i].baseLoopGain;   
    pluckedFilter[i].set(Std.rand2f(68.0, 80.0), 1.0);
    0 => pluckedVoices[i];  // set voices to free
}

// Swept string sound
10 => int sweepCount;
int sweepVoices[sweepCount];
StifKarp sweepString[sweepCount];
BPF sweepFilter[sweepCount];
Envelope sweepEnvelope[sweepCount];

Gain dry;
Gain wet;
Gain sweepGain;
DelayL linearDelay;
HPF highPass;
Dyno compression;

sweepGain => dry => linearDelay => highPass => compression => mainOut;
linearDelay => wet => linearDelay;

0.15 => dry.gain;
0.99 => wet.gain;
10::ms => linearDelay.delay;
3 => highPass.Q;
compression.compress();

for (0 => int i; i < sweepCount; i++) {
    sweepString[i] => sweepFilter[i] => sweepEnvelope[i]; 
    2.0 => sweepFilter[i].gain;
    0.6  => sweepString[i].pickupPosition; // these effect tuning; so, set once 
    1.0  => sweepString[i].sustain => sweepString[i].stretch => sweepString[i].baseLoopGain;   
    sweepFilter[i].set(Std.rand2f(68.0, 80.0), 1.0);    
    0 => sweepVoices[i];
}

// Blown instrument sound
10 => int blowCount;
int blowVoices[blowCount];
BlowBotl blowBottle[blowCount]; 
ResonZ blowFilter[blowCount];
Envelope blowEnvelope[blowCount];
JCRev blowReverb => mainOut;
0.15 => blowReverb.mix;

for (0 => int i; i < blowCount; i++) { 
    blowBottle[i] => blowFilter[i] => blowEnvelope[i];
    blowFilter[i].set(Std.rand2f(315.0, 325.0), Std.rand2f(0.35, 0.6));
    0 => blowVoices[i];
}

// Sine waves
10 => int sineCount;
int sineVoices[sineCount];
SinOsc sine[sineCount];
Envelope sineEnvelope[sineCount];
JCRev sineReverb => mainOut;
0.25 => sineReverb.mix;

for (0 => int i; i < sineCount; i++) { 
    0.03 => sine[i].gain;
    sine[i] => sineEnvelope[i];
    0 => sineVoices[i];
}



// LISTEN AND MAKE MUSIC --------------------------------------------------------------------

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



// MAIN AND HELPER FUNCTIONS ------------------------------------------------------------------------

// Repeatedly receives counts 1-8 from TextureServe.ck 
// TODO intention vs timer()? Is it functional?
//      See sendPulse() in TextureServe.ck (currently printing is off, event broadcast logic unclear)
fun void pulseListener() {
    while (true) {
        pulseEvent => now;
        
        while (pulseEvent.nextMsg() != 0) {
            pulseEvent.getInt() => int beatCount;
            globalEvent.broadcast();
            // <<< beatCount >>>;
        }
    }
}

// possibleRoutes refers to the values assigned in ColorServe, RhythmServe, TimbreServe, and TextureServe
fun int selectMachines(int station) {
    [[1, 5, 7, 11, 15, 17],
    [2, 6, 7, 12, 16, 17],
    [3, 5, 7, 13, 14, 17],
    [4, 6, 7, 14, 16, 17]
    ] @=> int possibleRoutes[][];
    
    possibleRoutes[myStation] @=> int route[];
    0 => int isSelected;
    
    for (0 => int i; i < route.cap(); i++) {      
        if (route[i] == station) {
            1 +=> isSelected;
        }
    }
    return isSelected;
}

//
fun void getRhythm() {
    while (true) {
        rhythmEvent => now;
        
        while (rhythmEvent.nextMsg() != 0) {
            rhythmEvent.getInt() => int station;
            rhythmEvent.getInt() => int control;
            
            selectMachines(station) => int isSelected;
            
            if (isSelected) {
                if (control == 5) { // TODO why control == 5? should this be station == 5?
                    0 => taleaIndex; // taleaIndex is reset to 0 if everyone is sent a parameter change
                }
                rhythmControl(control);
            }
        }
    }
}

// Changes different parameters based on control value (delay vs talea vs tempo)
// TODO refactor to eliminate magic numbers
fun void rhythmControl(int control) {
    if (control < 21) {
        if (control > 15) {
            control - 16 => tempoIndex;
            <<< "My tempo index is:", tempoIndex >>>;
        }
        else if (control > 10) {
            control - 11 => taleaIndex;
            <<< "My talea index is:", taleaIndex >>>;
        }
        else {
            control - 6 => delayIndex;
            <<< "My delay is:", delayArray[delayIndex], "of pulse." >>>;
        }
    }
}

// 
fun void getTimbre() {
    while (true) {
        timbreEvent => now;
        
        while (timbreEvent.nextMsg() != 0) {
            timbreEvent.getInt() => int station;
            timbreEvent.getInt() => int control;
            
            selectMachines(station) => int isSelected;
            
            if (isSelected) {
                timbreControl(control);
            }
        }
    }
}

// TODO reduce use of magic numbers, compare error handling between here and RhythmsServe
fun void timbreControl(int control) {
    if (control > 5 && control < 8) {
        Std.rand2(0, 3) => timbre;
    }
    else if (control > 10 && control < 15) {
        control - 11 => timbre;
    }
    <<< timbre >>>;
}


// TODO improve invalid station handling (station < 18 indicates < 'K' key on TextureServe) - possibly moved this to TextureServe.ck
fun void getTexture() {
    [50, 300, 1000, 2000, 5000] @=> int fadeValues[];
    
    while (true) {
        instrumentRhythmEvent => now; 
        
        while (instrumentRhythmEvent.nextMsg() != 0) {
            instrumentRhythmEvent.getInt() => int station;             
            instrumentRhythmEvent.getInt() => int reps;
            instrumentRhythmEvent.getInt() => int index;
                        
            selectMachines(station) => int isSelected;
            
            // patch to stations
            // TODO should fadeUp/fadeOut be sporked?
            if (isSelected) {
                <<< "My reps:", reps, "my Fade:", fadeValues[index], "::ms" >>>;
                fadeUp(fadeValues[index]::ms);
                
                // choose mode
                if (station < 10 && isSelected) {
                    <<< "Unison" >>>;
                    spork ~ waitForUnison(globalEvent, reps);
                }
                else {
                    <<< "Poly" >>>;
                    spork ~ waitForPoly(globalEvent, reps);
                }
            }
            if (!isSelected && station < 18) { // TODO is the intention to fade out whenever a new machine is fading in?
                <<< "Not me this time, but reps =", reps >>>;
                fadeOut(fadeValues[index]::ms);
            }
        } 
    }
}

// TODO role of events? Currently prevent functions from exiting, not sure how 'e' gets signaled
// TODO talea vs ringTime when performing a 'unison'
fun void waitForUnison(Event e, int reps) {
    Event off;
    e => now;
    delayArray[delayIndex]::timeUnit => now; // TODO is this deliberately set to previously selected value of 'T'?
    
    tempo[tempoIndex]::second => timeUnit;
    color[colorIndex] @=> int colorSequence[];
    ringTime[ringIndex] @=> float ringSequence[];
    taleaArray[taleaIndex] @=> float taleaSequence[];
    
    for (0 => int i; i < reps; i++) {
        colorSequence[i % colorSequence.cap()] => int note;
        ringSequence[i % ringSequence.cap()]::timeUnit => dur length;
            
        if (timbre == 0) {
            <<< "Sine" >>>;
            spork ~ playSine(note, length, 8::ms, 10::ms);
        }
        else if (timbre == 1) {
            <<< "Blow" >>>;
            spork ~ playBlow(note, length, 8::ms, 10::ms);
        }
        else if (timbre == 2) {
            <<< "Pluck" >>>;
            spork ~ playPlucked(note, length, 8::ms, 10::ms, Std.rand2f(0.7, 0.9));
        }
        else if (timbre == 3) {
            <<< "Sweep" >>>;
            spork ~ playSweep(note, length, 8::ms, 10::ms, Std.rand2f(0.5, 0.7));
        }
        taleaSequence[i % taleaSequence.cap()]::timeUnit => now; 
    } 
    off.signal();
    off => now;
    <<< "DONE!" >>>;
}

// TODO role of events? Currently prevent functions from exiting, not sure how 'e' gets signaled
// TODO doesn't select a delay? (See line 497)
fun void waitForPoly(Event e, int reps) { 
    Event off;
    e => now;
    
    tempo[tempoIndex]::second => timeUnit;
    color[colorIndex] @=> int colorSequence[];
    ringTime[ringIndex] @=> float ringSequence[]; 
    taleaArray[taleaIndex] @=> float taleaSequence[];
    
    for (0 => int i; i < reps; i++) {
        colorSequence[Std.rand2(0, colorSequence.cap()-1)] => int note;
        ringSequence[Std.rand2(0, ringSequence.cap()-1)]::timeUnit => dur length;
        
        if (timbre == 0) {
            <<< "Sine" >>>;
            spork ~ playSine(note, length, 8::ms, 10::ms);
        }
        else if (timbre == 1) {
            <<< "Blow" >>>;
            spork ~ playBlow(note, length, 8::ms, 10::ms);
        }
        else if (timbre == 2) {
            <<< "Pluck" >>>;
            spork ~ playPlucked(note, length, 8::ms, 10::ms, Std.rand2f(0.6, 0.99)); 
        }
        else if (timbre == 3) {
            <<< "Sweep" >>>;
            spork ~ playSweep(note, length, 8::ms, 10::ms, Std.rand2f(0.7, 0.99));
        }
        0.5::timeUnit => now; // a periodic groove
    } 
    off.signal();
    off => now;
}

//
fun void playPlucked(int pitch, dur length, dur attackTime, dur delayTime, float pluck) {
    getFreeVoice(pluckedVoices) => int newvoice; //<<< newvoice >>>;
    
    if (newvoice > -1) {        
        attackTime => pluckedEnvelope[newvoice].duration;
        pluckedEnvelope[newvoice] => pluckedReverb;
        pitches[pitch - 24] => pluckedString[newvoice].freq;
        Std.rand2f(0.2, 0.8) => pluckedString[newvoice].pickupPosition;
        1 => pluckedEnvelope[newvoice].keyOn;
        pluck => pluckedString[newvoice].pluck;
        length - delayTime => now;
        delayTime => pluckedEnvelope[newvoice].duration;
        1 => pluckedEnvelope[newvoice].keyOff;
        delayTime => now;
        pluckedEnvelope[newvoice] =< pluckedReverb;
        0 => pluckedVoices[newvoice];
    }
}

//
fun void playSweep(int pitch, dur length, dur attackTime, dur delayTime, float pluck) { 
    getFreeVoice(sweepVoices) => int newvoice; //<<< newvoice >>>;
    
    if (newvoice > -1) {        
        attackTime => sweepEnvelope[newvoice].duration;
        sweepEnvelope[newvoice] => sweepGain;
        pitches[pitch - 24] => sweepString[newvoice].freq;
        Std.rand2f(0.2, 0.8) => sweepString[newvoice].pickupPosition;
        1 => sweepEnvelope[newvoice].keyOn;
        pluck => sweepString[newvoice].pluck;
        length - delayTime => now;       
        delayTime => sweepEnvelope[newvoice].duration;
        1 => sweepEnvelope[newvoice].keyOff;
        delayTime => now;        
        sweepEnvelope[newvoice] =< sweepGain;
        0 => sweepVoices[newvoice];
    }
}

//
fun void playBlow(int note, dur length, dur attackTime, dur delayTime) {
    getFreeVoice(blowVoices) => int newvoice; //<<<"blo" >>>;
    
    if (newvoice > -1) { 
        attackTime => blowEnvelope[newvoice].duration;
        blowEnvelope[newvoice] => blowReverb;
        note => float freq;
        Std.mtof(freq)=> blowBottle[newvoice].freq;
        0.019653 => blowBottle[newvoice].noiseGain;
        Std.rand2f(3.2, 4.4) => blowBottle[newvoice].vibratoFreq;
        Std.rand2f (0.5, 0.9) => blowBottle[newvoice].vibratoGain;
        0.65 => blowBottle[newvoice].volume; 
        1 => blowEnvelope[newvoice].keyOn;
        Std.rand2f(0.2, 0.4) => blowBottle[newvoice].noteOn;
        length - delayTime => now;
        1 => blowEnvelope[newvoice].keyOff;
        delayTime => now;
        1 => blowBottle[newvoice].noteOff;
        blowEnvelope[newvoice] =< blowReverb;
        0 => blowVoices[newvoice];
    }
}

//
fun void playSine(int note, dur length, dur attackTime, dur delayTime) { 
    getFreeVoice(sineVoices) => int newvoice;
    
    if (newvoice > -1) {
        attackTime => sineEnvelope[newvoice].duration;
        sineEnvelope[newvoice] => sineReverb;
        note => float freq;
        Std.mtof(freq + 12) => sine[newvoice].freq;
        0 => sine[newvoice].phase;
        1 => sineEnvelope[newvoice].keyOn;
        length - delayTime => now;
        delayTime => sineEnvelope[newvoice].duration;
        1 => sineEnvelope[newvoice].keyOff;
        delayTime => now;
        sineEnvelope[newvoice] =< sineReverb;
        0 => sineVoices[newvoice];
    }
}

// Find the index of a free voice in a ugen array using an auxiliary 'voices' array
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
//      Can this logic be replaced by the use of a 'master' Envelope on mainOut?
//      Consider removing if using MIDI instruments

fun void fadeUp (dur fadeTime) {
    <<< "fading up" >>>; // TODO remove   
    fadeTime / 2::ms => float n;
    0.9 / n => float d;
    
    while (mainOutGain < 0.9) {
        for (int i; i < 50; i++) {
            d +=> mainOutGain => mainOutGain;
            mainOutGain => mainOut.gain;
            2::ms => now;
        }
    }
}

fun void fadeOut(dur fadeTime) {
    <<< "fading down" >>>; // TODO remove
    fadeTime / 2::ms => float n;
    0.9 / n => float d;
    
    while (mainOutGain > 0.0) {
        for (0 => int i; i < 50; i++) {
            mainOutGain - d => mainOutGain;
            mainOutGain => mainOut.gain;
            2::ms => now;
        }
    }
}
//----------------------------------------------------------------------

// Sets the pitch collection currently in use
fun void getColor() {
    while (true) {
        colorEvent => now;
        
        while (colorEvent.nextMsg() != 0) {
            colorEvent.getInt() => colorIndex;
            <<< "My ColorIndex is:", colorIndex >>>;
        }
    }
}

// TODO what is 't'? logic behind calculation of highPass.freq?
// Used for sweepGain's filter
fun void sweep() {
    float t;
    
    while (true) {
        // sweep the cutoff
        Std.mtof(Std.fabs(Math.sin(t) * 110)) => highPass.freq;
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