//====================================================================================
//  Figurenotes Shapes QML Plugin for Drake Music Scotland
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

//====================================================================================
// We Identify the plugin and give it a place in the MuseScore menu!
//====================================================================================

      version:  "4.0"
      description: qsTr("This plugin shapes noteheads in the selection depending on their pitch as per the Figurenotes System")
      menuPath: "Plugins.Figurenotes.Shapes"
      thumbnailName: "FNMS_thumb.png"
      id: figurenotesShapes
      Component.onCompleted: {
            if (mscoreMajorVersion >= 4){
                  figurenotesShapes.title = "Figurenotes Shapes";
                  figurenotesShapes.categoryCode = "color-notes";
                  figurenotesShapes.thumbnailName = "FNMS_thumb.png";
                  figurenotesShapes.menuPath = "Plugins.Figurenotes.Shapes" //Show it in Plugin Menu
                  }
      }

//====================================================================================
// Apply the given function to all notes in selection or, if nothing is selected, in the entire score
//====================================================================================

function applyToNotesInSelection(func) {
      curScore.startCmd();
      var cursor = curScore.newCursor();
      cursor.rewind(1);
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;

      //If nothing is selected, use the whole score:
      if (!cursor.segment) {
            fullScore = true;
            startStaff = 0; // start with 1st staff
            endStaff = curScore.nstaves - 1; // and end with last
      } 
      //Otherwise, use only the selected bits:
      else {
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
                                    func(note); // <-- DO THE THING TO THE NOTE
                              }
                        }
                        cursor.next();
                  }
            }
      }
      
}

//====================================================================================
// Do this to all notes in the selection:
//====================================================================================

function changeShape(note){

//TODO: Add another IF Statement that first tests the headgroup, if "0" it changes, if not "0" it changes it to "0" instead
//In other words, we could theoretically toggle the shapes!

      if (note.pitch >= 36) {note.headGroup = 1;}     //1   Crosses
      if (note.pitch >= 48) {note.headGroup = 18;}    //18  Squares
      if (note.pitch >= 60) {note.headGroup = 0;}     //0   Circles    
      if (note.pitch >= 72) {note.headGroup = 5;}     //5   Triangles
      if (note.pitch >= 84) {note.headGroup = 10;}    //10  Diamonds
      if (note.pitch >= 96) {note.headGroup = 15;}    //15  Slashes
      }

//====================================================================================
// Run this plugin when we choose it from the menu
//====================================================================================

      onRun: {
            console.log("Figurenotes Shapes!");
            
            applyToNotesInSelection(changeShape);
            
            curScore.endCmd();
            
            if (typeof quit === "undefined") {
            Qt.quit();
            } else {
            quit();
            }
      }
}