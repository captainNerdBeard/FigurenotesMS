//====================================================================================
//  Figurenotes Colours QML Plugin for Drake Music Scotland
//  (C)2020-23 Bas Gentenaar (figurenotes@drakemusicscotland.org)
//
//  Drake Music Scotland Figurenotes Project Figurenotes (C) Kaarlo Uusitalo, 1996 
//  Figurenotes applications (C) Markku Kaikkonen and Kaarlo Uusitalo, 1998 
//  
//  MuseScore
//  Music Composition & Notation
//
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013-2017 Nicolas Froment, Joachim Schmitz
//  Copyright (C) 2014 Jörn Eichler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//===================================================================================

import QtQuick 2.9
import MuseScore 3.0

MuseScore {
      version:  "4.0"
      description: qsTr("This plugin colours notes in the selection depending on their pitch as per the Figurenotes System")
      menuPath: "Plugins.Figurenotes.Colours"
      id: figurenotesColours
      thumbnailName: "FNMS_thumb.png"
      Component.onCompleted: {
            if (mscoreMajorVersion >= 4){
                  figurenotesColours.title = "Figurenotes Colours";
                  figurenotesColours.categoryCode = "color-notes";
                  figurenotesColours.thumbnailName = "FNMS_thumb.png";
                  figurenotesColours.menuPath = "Plugins.Figurenotes.Colours" //Show it in Plugin Menu
                  }
      }
      property string noteC : "#FF0000";
      property string noteD : "#946133";
      property string noteE : "#C6C4C1";
      property string noteF : "#0090D8";
      property string noteG : "#1A1919";
      property string noteA : "#F7E200";
      property string noteB : "#35A221";
      
      property string black : "#000000";

property variant colors : [ noteF, noteC, noteG, noteD, noteA, noteE, noteB, noteF, noteC, noteG, noteD, noteA, noteE, noteB, noteF, noteC, noteG, noteD, noteA, noteE, noteB, noteF, noteC, noteG, noteD, noteA, noteE, noteB, noteF, noteC, noteG, noteD, noteA, noteE, noteB  ]

      // Apply the given function to all notes in selection
      // or, if nothing is selected, in the entire score

      function applyToNotesInSelection(func) {
            curScore.startCmd();
            var cursor = curScore.newCursor();
            cursor.rewind(1);
            var startStaff;
            var endStaff;
            var endTick;
            var fullScore = false;
            if (!cursor.segment) { // no selection
                  fullScore = true;
                  startStaff = 0; // start with 1st staff
                  endStaff = curScore.nstaves - 1; // and end with last
            } else {
                  startStaff = cursor.staffIdx;
                  cursor.rewind(2);
                  if (cursor.tick === 0) {
                        // this happens when the selection includes
                        // the last measure of the score.
                        // rewind(2) goes behind the last segment (where
                        // there's none) and sets tick=0
                        endTick = curScore.lastSegment.tick + 1;
                  } else {
                        endTick = cursor.tick;
                  }
                  endStaff = cursor.staffIdx;
            }
            // console.log(startStaff + " - " + endStaff + " - " + endTick)
            for (var staff = startStaff; staff <= endStaff; staff++) {
                  for (var voice = 0; voice < 4; voice++) {
                        cursor.rewind(1); // sets voice to 0
                        cursor.voice = voice; //voice has to be set after goTo
                        cursor.staffIdx = staff;

                        if (fullScore)
                              cursor.rewind(0) // if no selection, beginning of score

                        while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                              if (cursor.element && cursor.element.type === Element.CHORD) {
                                    var graceChords = cursor.element.graceNotes;
                                    for (var i = 0; i < graceChords.length; i++) {
                                          // iterate through all grace chords
                                          var graceNotes = graceChords[i].notes;
                                          for (var j = 0; j < graceNotes.length; j++)
                                                func(graceNotes[j]);
                                    }
                                    var notes = cursor.element.notes;
                                    for (var k = 0; k < notes.length; k++) {
                                          var note = notes[k];
                                          func(note);
                                    }
                              }
                              cursor.next();
                        }
                  }
            }
      }

      function colorNote(note) {
            if (note.color == black) {
                  note.color = colors[note.tpc+1];
			} else {
                  note.color = black;
            } 
            if (note.accidental) {
				if (note.accidental.color == black) {
					note.accidental.color = colors[note.tpc+1];
					} else {
					note.accidental.color = black;
					}
			}
						
            for (var i = 0; i < note.dots.length; i++) {
                  if (note.dots[i]) {
                        if (note.dots[i].color == black) {
                              note.dots[i].color = colors[note.tpc+1];
				} else {
                              note.dots[i].color = black;
                        }
                  }
			}
                  curScore.endCmd();
      }

      onRun: {
            console.log("Figurenotes Colours!");

            applyToNotesInSelection(colorNote)

      if (typeof quit === "undefined") {
            // MuseScore 3
            Qt.quit();
            } else {
            // MuseScore 4
            quit();
      }
      }
}
