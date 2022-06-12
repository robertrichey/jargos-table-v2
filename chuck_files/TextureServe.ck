//Texture Serve, chuck with Client.ck: your number 1 - 4
//
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


// TODO these are unused in the script. Remove?
Event finished; 
Event e; 
0.5::second => dur T; 
//---------------------------------------------

Hid inputDevice; 
HidMsg inputMessage;
int fadeValue;
0 => int keyboard;

// TODO arg should be 1? Could depend on machine
if (me.args()) { 
    Std.atoi(me.arg(0)) => keyboard;
}

if (!inputDevice.openKeyboard(keyboard)) {
    me.exit(); 
}

// NETWORK PARAMETERS
OscSend xmit;
xmit.setHost("224.0.0.1", 5501);

// key map
int key[256];

1 => key[29];//z
2 => key[27];//x
3 => key[6];//c
4 => key[25];//v
5 => key[5];//b
6 => key[17];//n
7 => key[16];//m
8 => key[54];//,
9 => key[55];//.
10 => key[56];// /
11 => key[4];//a
12 => key[22];//s
13 => key[7];//d
14 => key[9];//f
15 => key[10];//g
16 => key[11];//h
17 => key[13];//j
18 => key[14];//k
19 => key[15];//l
20 => key[51];//;
21 => key[52];//'
22 => key[20];//q
23 => key[26];//w
24 => key[8];//e
25 => key[21];//r
26 => key[23];//t
27 => key[28];//y
28 => key[24];//u
29 => key[12];//i
30 => key[18];//o
31 => key[19];//p
32 => key[47];//[
33 => key[48];//]
34 => key[49];//|
35 => key[53];//`
36 => key[30];//1
37 => key[31];//2
38 => key[32];//3
39 => key[33];//4
40 => key[34];//5
41 => key[35];//6
42 => key[36];//7
43 => key[37];//8
44 => key[38];//9
45 => key[39];//0
46 => key[45];//-
47 => key[46];//=
48 => key[44]; //space
//
spork ~ sendPulse(); // spork PULSE FOR SYNC TODO

//
while (true) {
    inputDevice => now;
    
    while (inputDevice.recv(inputMessage)) {
        if (inputMessage.which > 256) {
            continue;
        }
        if (inputMessage.isButtonDown()) {
            //<<< key[inputMessage.which] >>>;
            if (key[inputMessage.which] > 0 && key[inputMessage.which] < 27) {
                <<< key[inputMessage.which] >>>;
                sendControlSignal(key[inputMessage.which]);
            }
        }
    }
}

//
fun void sendControlSignal(int station) {   
    getfadeValue(station) => fadeValue;
    
    xmit.startMsg("/instrumentRhythm", "i i i");
    station => xmit.addInt;
    getReps() => xmit.addInt;
    fadeValue => xmit.addInt;
    //<<< fadeValue >>>;
}

// multicasts name of this machine to all on LAN
// TODO seems to send beat number 1-8.
fun void sendPulse() {
    0 => int beatNumber;
      
    while (true) {
        xmit.startMsg("/pulse", "i");
        (beatNumber % 8) + 1 => xmit.addInt;
        beatNumber++;
        250::ms => now;   
    }
} 

//
fun int getReps() {
    return Std.rand2(3, 23);
}

//
fun int getfadeValue(int station) {
    if (station >= 22 && station <= 26) { 
        return station - 22;
    }
    else {
        return fadeValue;
    }
}
   