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
//
0.9=>dac.gain; //adjust manually
int myMachine;
if( me.args() ) me.arg(0) => Std.atoi => myMachine;
if (myMachine <= 0 || myMachine > 4) <<< "Not a valid machine choice." >>>;
else <<< "My machine is number:", myMachine >>>;
//
[.5, 1., 1.5, .16666666667, .33333333] @=> float Tempo[]; int TempoIndex;
[50, 300, 1000, 2000, 5000] @=> int fadeValues[]; int fadeValueIndex;
Event finished; Event e; Event timeMe; Tempo[TempoIndex]::second => dur T; 1::second => dur tick;
int colorIndex; int durationIndex; int taleaIndex; int timbre; int DelayIndex;

//
//
OscRecv recv[4];
5501 => recv[0].port;//receives texture and pulse
5502 => recv[1].port;//receives timbre
5503 => recv[2].port;//receives rhythm/offset
5504 => recv[3].port;//receives pitch
//
for( int i; i < 4; i++ )
{recv[i].listen();}

recv[0].event( "/Pulse, i" ) @=> OscEvent msg1;
recv[0].event( "/instrumentRhythm, i i i" ) @=> OscEvent msg2;//station
//
recv[1].event( "/Timbre, i i" ) @=> OscEvent msg3;
//
recv[2].event( "/Rhythm, i i" ) @=> OscEvent msg4;
//
recv[3].event( "/Color, i" ) @=> OscEvent msg5;
//
Gain MainOut => dac;
float Main => MainOut.gain;
//
// Karp OrK tunings
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
//the array
[c1, csh1, d1, dsh1, e1, f1, fsh1, g1, gsh1, a1, ash1, b1,
c2, csh2, d2, dsh2, e2, f2, fsh2, g2, gsh2, a2, ash2, b2,
c3, csh3, d3, dsh3, e3, f3, fsh3, g3, gsh3, a3, ash3, b3,
c4, csh4, d4, dsh4, e4, f4, fsh4, g4, gsh4, a4, ash4, b4,
c5, csh5, d5, dsh5, e5, f5, fsh5, g5, gsh5, a5, ash5, b5,
c6, csh6, d6, dsh6, e6, f6, fsh6, g6, gsh6, a6, ash6, b6, c7] 
@=> float pitches[]; int pitchindex;
//
10 => int numKarpvoices;
int Karpvoices[numKarpvoices];// an array to keep up with voices used
StifKarp m[numKarpvoices];
BPF filter[numKarpvoices];
Envelope myenv[numKarpvoices];
JCRev rKarp; 0.05 => rKarp.mix; rKarp => MainOut;
//
for (0 => int i; i<numKarpvoices;i++){
    m[i] => filter[i] => myenv[i]; 1. => filter[i].gain;
    0.6  => m[i].pickupPosition;// these effect tuning; so, set once 
    1.0  => m[i].sustain => m[i].stretch => m[i].baseLoopGain;   
    (Std.rand2f(68., 80.), 1.) => filter[i].set;    
    0 => Karpvoices[i]; //all voices free
}
//
10 => int numSweepKarpvoices;
int SweepKarpvoices[numSweepKarpvoices];// an array to keep up with voices used
StifKarp swm[numSweepKarpvoices];
BPF filtersk[numSweepKarpvoices];
Envelope myenvsk[numSweepKarpvoices];

//
for (0 => int i; i<numSweepKarpvoices;i++){
    swm[i] => filtersk[i] => myenvsk[i]; 2. => filtersk[i].gain;
    0.6  => swm[i].pickupPosition;// these effect tuning; so, set once 
    1.0  => swm[i].sustain => swm[i].stretch => swm[i].baseLoopGain;   
    (Std.rand2f(68., 80.), 1.) => filtersk[i].set;    
    0 => SweepKarpvoices[i]; //all voices free
}
//
 
Gain gn[2];
Gain SweepkpOrk => gn[0];
gn[0] => DelayL del => HPF f => Dyno comp => MainOut;
del =>  gn[1]  => del;
// set parameters
10::ms => del.delay;
0.15 => gn[0].gain;
0.99 => gn[1].gain;
3 => f.Q;
comp.compress();
//
10 => int numBlo;
int Blovoices[numBlo];
BlowBotl bottle[numBlo]; 
ResonZ res[numBlo];
Envelope env[numBlo]; 
for (int i; i < numBlo; i++){ 
    bottle[i] => res[i] => env[i];
    res[i].set(Std.rand2f(315., 325.), Std.rand2f (0.35, 0.6));
    0 => Blovoices[i]; //reset voices to get
}
//
//
10 => int NumSineVoices;
SinOsc s[NumSineVoices];
int SineVoice[NumSineVoices];
Envelope sineEnv[NumSineVoices];
for (int i; i<NumSineVoices; i++)
{ 
    .03 => s[i].gain;
    s[i] => sineEnv[i];
}
JCRev rSine => MainOut;
.25 => rSine.mix;
//
JCRev rBlo => MainOut;
.15 => rBlo.mix;
//score parameters
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
] @=> int Color[][];
[[.125, .25, .5, 1., 2., 4.], [1., 2., 3., 4., 4.]] @=> float ringTime[][];
[[.25, .25, .5, .5], [.25, 1., 2.], [.5, .5, 1., 1., .25], [.125, .25, .125, .25, .25, 1., 2], [.125, .125, .5, 1.5, 4., 2.]] @=> float Talea[][];
[0., 0.25, 0.5, 1., 2.] @=> float DelayArray[];
//spork independent threads
spork ~ Pulse_listener();
spork ~ getRhythm();
spork ~ getTexture();
spork ~ getTimbre();
spork ~ getColor();
spork ~ sweep();
spork ~ timer(timeMe);
//Main loop

1::hour => now;



//
fun void waitForPoly( Event e, int reps )
{ Event off;
e => now;
//<<< "wait" >>>;

for (int i; i<reps; i++)
{  //<<< i >>>;
    // temp


    // not temp
    Tempo[TempoIndex]::second => dur T;
    Color[colorIndex] @=> int seq1[];
    ringTime[durationIndex] @=> float ringSeq[]; 
    Talea[taleaIndex] @=> float taleaSeq[];
    seq1[Std.rand2(0,seq1.cap()-1)] => int note;
    ringSeq[Std.rand2(0,ringSeq.cap()-1)]::T => dur len;
    if (timbre == 0) 
        spork ~ PlaySineNote(note, len, 8::ms, 10::ms);
    else if (timbre == 1) 
        spork ~ playBlo(note, len, 8::ms, 10::ms);
    else if (timbre == 2)
        spork ~ playKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.6, 0.99)); 
        else if (timbre == 3)
        spork ~ playSweepKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.7, 0.99));
 0.5::T => now; //a periodic groove
} off.signal();
//<<< "done" >>>;
off => now;
}
//
fun void waitForUnison( Event e, int reps )
{  Event off;
e => now;
DelayArray[DelayIndex]::T => now;
//<<< "wait" >>>;
for (int i; i<reps; i++)
{   //<<< i >>>;
    // temp


    // not temp
    Tempo[TempoIndex]::second => dur T;
    Color[colorIndex] @=> int seq1[];
    ringTime[durationIndex] @=> float ringSeq[]; 
    Talea[taleaIndex] @=> float taleaSeq[];
    seq1[i%seq1.cap()] => int note;
    ringSeq[i%ringSeq.cap()]::T => dur len;
    if (timbre == 0) 
    {
        <<< "Sine" >>>;
        spork ~ PlaySineNote(note, len, 8::ms, 10::ms);
    }
    else if (timbre == 1) 
    {
        <<< "Blo" >>>;
        spork ~ playBlo(note, len, 8::ms, 10::ms);
    }
    else if (timbre == 2)
    {
        <<< "Pluk" >>>;
        spork ~ playKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.7, 0.9));
    }
    else if (timbre == 3)
    {
        <<< "Sweep" >>>;
        spork ~ playSweepKarp(note, len, 8::ms, 10::ms, Std.rand2f(0.5, 0.7));
    }
    taleaSeq[i%taleaSeq.cap()]::T => now; 
} off.signal();
//<<< "done" >>>;
off => now;

}
//
// routes Texture data to machine
fun int selectTexture(int foo)
{
    
    
    [
    [1, 5, 7, 11, 15, 17],[1, 5],
    [2, 6, 7, 12, 16, 17],[2, 5],
    [3, 5, 7, 13, 14, 17],[3, 5], 
    [4, 6, 7, 14, 16, 17],[4, 5]
    ] @=> int machineArray[][];
    
    int jack;
    if ( myMachine == 1 ) 0 => jack;
    if ( myMachine == 2 ) 2 => jack;
    if ( myMachine == 3 ) 4 => jack;
    if ( myMachine == 4 ) 6 => jack;
    
    
    machineArray[jack] @=>  int TextureBang[];
    -1 => int check;
    for (int i; i < TextureBang.cap(); i++)
    {
        TextureBang[i] => int test;
        if (test == foo) 1 +=> check;
    }
    if (check > -1) return 1;
    else return 0;
    
}
//
fun int selectRhythm(int foo)
{
    
    
    [
    [1, 5, 7, 11, 15, 17],[1, 5],
    [2, 6, 7, 12, 16, 17],[2, 5],
    [3, 5, 7, 13, 14, 17],[3, 5], 
    [4, 6, 7, 14, 16, 17],[4, 5]
    ] @=> int machineArray[][];
    
    int jack;
    if ( myMachine == 1 ) 1 => jack;
    if ( myMachine == 2 ) 3 => jack;
    if ( myMachine == 3 ) 5 => jack;
    if ( myMachine == 4 ) 7 => jack;
    
    
    machineArray[jack] @=>  int RhythmRoute[];
    -1 => int check;
    for (int i; i < RhythmRoute.cap(); i++)
    {
        RhythmRoute[i] => int test;
        if (test == foo) 1 +=> check;
    }
    if (check > -1) return 1;
    else return 0;
    
}
//
fun int selectTimbre(int foo)
{
    
    
    [
    [1, 5, 7, 11, 15, 17],[1, 5, 6],
    [2, 6, 7, 12, 16, 17],[2, 5, 7],
    [3, 5, 7, 13, 14, 17],[3, 5, 6], 
    [4, 6, 7, 14, 16, 17],[4, 5, 7]
    ] @=> int machineArray[][];
    
    int jack;
    if ( myMachine == 1 ) 1 => jack;
    if ( myMachine == 2 ) 3 => jack;
    if ( myMachine == 3 ) 5 => jack;
    if ( myMachine == 4 ) 7 => jack;
    //<<< jack >>>;
    
    machineArray[jack] @=>  int TimbreRoute[];
    -1 => int check;
    for (int i; i < TimbreRoute.cap(); i++)
    {
        TimbreRoute[i] => int test;
        if (test == foo) 1 +=> check;
    }
    if (check > -1) return 1;
    else return 0;
    
}
////

fun void playKarp(int pitch, dur len, dur attktime, dur decaytime, float pluck){ 
    getKarpFreeVoice() => int newvoice; //<<< newvoice >>>;
    if(newvoice > -1) {        
        attktime => myenv[newvoice].duration;
        myenv[newvoice] => rKarp;
        pitches[pitch-24] => m[newvoice].freq;
        Std.rand2f (0.2, 0.8) => m[newvoice].pickupPosition;
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
fun int getKarpFreeVoice() {        
    for(0 => int i; i<numKarpvoices; i++){
        if(Karpvoices[i] == 0) { 
            1 => Karpvoices[i];
            return i; 
        }
    }
    return -1; //return only if no voices free
}
//
fun void playSweepKarp(int pitch, dur len, dur attktime, dur decaytime, float pluck){ 
    getSweepKarpFreeVoice() => int newvoice; //<<< newvoice >>>;
    if(newvoice > -1) {        
        attktime => myenvsk[newvoice].duration;
        myenvsk[newvoice] => SweepkpOrk;
        pitches[pitch-24] => swm[newvoice].freq;
        Std.rand2f (0.2, 0.8) => swm[newvoice].pickupPosition;
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
// 
fun int getSweepKarpFreeVoice() {        
    for(0 => int i; i<numSweepKarpvoices; i++){
        if(SweepKarpvoices[i] == 0) { 
            1 => SweepKarpvoices[i];
            return i; 
        }
    }
    return -1; //return only if no voices free
}
//
fun void PlaySineNote(int note, dur len, dur attktime, dur decaytime)
{ 
    getFreeSineVoice() => int newvoice; //<<< "sine" >>>;
    if (newvoice > -1)
    {
        attktime => sineEnv[newvoice].duration;
        sineEnv[newvoice] => rSine;
        note  => float freq;
        Std.mtof( freq + 12 ) => s[newvoice].freq;
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
    getBloFreeVoice() => int newvoice; //<<<"blo" >>>;
    if (newvoice > -1) { 
        attktime => env[newvoice].duration;
        env[newvoice] => rBlo;
        note  => float freq;
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
//
// 
fun int getBloFreeVoice() {        
    for(0 => int i; i<numBlo; i++){
        if(Blovoices[i] == 0) { 
            1 => Blovoices[i];
            return i; 
        }
    }
    return -1; //return only if no voices free
}
//
//
fun int getFreeSineVoice()
{
    for (int i; i<NumSineVoices; i++ )
    { 
        if (SineVoice[i] == 0)
        {
            1 => SineVoice[i];
            return i;
        }
    }
    return -1; //if no voice is free
}
//
fun void getRhythm()
{ //<<< "hi" >>>;
    while( true )
    {
        msg4 => now;
        
        while (msg4.nextMsg() != 0 )
        {
            msg4.getInt() => int station;
            msg4.getInt() => int control;
            
            if (selectRhythm(station) == 1 && control == 5)
            {
                0 => taleaIndex;//taleaIndex is reset to 0 if everyone is sent a parameter change
                rhythmControl(control);
            }
                
            else if (selectRhythm(station) == 1) 
            {
                rhythmControl(control);
                        
            }
               
           
        }
    }
}
//
//
fun void getTimbre()
{ //<<< "hi" >>>;
    while( true )
    {
        msg3 => now;
        
        while (msg3.nextMsg() != 0 )
        {
            msg3.getInt() => int station;
            msg3.getInt() => int control;
            //<<< station, control >>>;
           if (selectTimbre(station) == 1 && station == 6) 
           {
             timbreControl(station);
         }
         else if (selectTimbre(station) == 1 && station == 7) 
         {
             timbreControl(station);
         }
         else if (selectTimbre(station) == 1) 
            {
                timbreControl(control);
                //<<< "yes" >>>;
            }
            
            
        }
    }
}
//
//
fun void timbreControl(int x)
{  
if (x >= 6 && x <= 8) Std.rand2(0,3) => timbre;
else if (x >=10 && x <= 14) x - 11 => timbre;
<<< timbre >>>;
}


//
fun void rhythmControl(int x)
{
    if (x > 5 && x < 11)
    {
        x - 6 => DelayIndex;
        <<< "My delay is:", DelayArray[DelayIndex], "of pulse." >>>;
    }
    else if (x > 10 && x < 16)
    {
        x - 11 => taleaIndex;
        <<< "My talea index is:", taleaIndex >>>;
    }
    
    else if (x > 15 && x < 21)
    {
        x - 16 => TempoIndex;
    <<< "My tempo index is:", TempoIndex >>>;
}

}
    
    
          
//
fun void getTexture()
{ //<<< "listener is here" >>>;
    while( true )
    {
        msg2 => now; timeMe.signal();
        while (msg2.nextMsg() != 0 )
        {
            msg2.getInt() => int station; <<< station >>>;
            msg2.getInt() => int reps;
            msg2.getInt() => fadeValueIndex;
            //patch to stations
            if (selectTexture(station) == 1) 
            {
                <<< "My reps:", reps, "my Fade:", fadeValues[fadeValueIndex], "::ms" >>>;
                fadeUp(fadeValues[fadeValueIndex]::ms);
            }
            else if (selectTexture(station) == 0 && station <= 18) 
            {
                <<< "Not me this time, but reps =", reps >>>;
                fadeOut(fadeValues[fadeValueIndex]::ms);
            }
            //choose mode   
            if (station < 10 && selectTexture(station) == 1)
            {
                <<< "Unison" >>>;
                spork ~ waitForUnison(e, reps);
            }
            else if (station > 10 && selectTexture(station) == 1)
            {
                <<< "Poly" >>>;
                spork ~ waitForPoly(e,reps);
            }
        } 
    }
}
//
fun void Pulse_listener()
{
    while( true )
    {
        msg1 => now;
        while (msg1.nextMsg() != 0 )
        {
            msg1.getInt() => int Beat;
            e.broadcast();
            //<<< Beat >>>;
        }
    }
}


fun void getColor()
{ //<<< "color is here" >>>;
    while( true )
    {
        msg5 => now;
   
        while (msg5.nextMsg() != 0)
        {
            msg5.getInt() => colorIndex;
            <<< "My ColorIndex is:", colorIndex >>>;
        }
    }
}
//

fun void fadeUp(dur fadeTime)
{   
    fadeTime/2::ms => float n;
    0.9/n => float d;

    
    while (Main < 0.9)
{
    for (int i; i< 50; i++)
    {
        d +=> Main => Main;
        Main => MainOut.gain;
        2::ms => now;
       
    }
}
}
//
fun void fadeOut(dur fadeTime)
{   
    fadeTime/2::ms => float n;
    0.9/n => float d;
    while (Main > 0.)
    {
        for (int i; i< 50; i++)
            {
                Main - d => Main;
                Main => MainOut.gain;
                2::ms => now;
            }
     }
 }
//
//
fun void sweep(){ float t;
while( true )
{
    // sweep the cutoff
    Math.sin(t) * 110 => Std.fabs => Std.mtof => f.freq;
    // increment t
    .005 +=> t;
    // advance time
    5::ms => now;
}
}    
//
//
fun void timer(Event timeMe)
{  
    while( true)
    {   int count; int secondCount;
    -1 => int minuteCount;
    timeMe => now;
    while(true)
    {
        
        if (count%60 == 0) minuteCount++;
        if (count%12 == 0) <<<minuteCount, ":", secondCount>>>; 
        count++; secondCount++; if (secondCount == 60) 0 => secondCount;
        1::tick => now;
    }
}
}

