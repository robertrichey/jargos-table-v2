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
