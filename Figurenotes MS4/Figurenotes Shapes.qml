//=================================================================================
//  Figurenotes Shapes QML Plugin for Drake Music Scotland
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
//=================================================================================

import QtQuick 2.9
import MuseScore 3.0

MuseScore {

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

function applyToNotesInSelection(func) {
      curScore.startCmd();
      var cursor = curScore.newCursor();
      cursor.rewind(1);
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;

      if (!cursor.segment) {
            fullScore = true;
            startStaff = 0;
            endStaff = curScore.nstaves - 1;
      } 
      else {
            startStaff = cursor.staffIdx;
            cursor.rewind(2);
            if (cursor.tick === 0) {
                  endTick = curScore.lastSegment.tick + 1;
            } else {
                  endTick = cursor.tick;
            }
            endStaff = cursor.staffIdx;
      }
      
      for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                  cursor.rewind(1); 
                  cursor.voice = voice;
                  cursor.staffIdx = staff;

                  if (fullScore)
                        cursor.rewind(0)

                  while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                        if (cursor.element && cursor.element.type === Element.CHORD) {
                              var graceChords = cursor.element.graceNotes;
                              for (var i = 0; i < graceChords.length; i++) {
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

function changeShape(note){

            if (note.pitch >= 36) {note.headGroup = 1;}     //1   Crosses
            if (note.pitch >= 48) {note.headGroup = 18;}    //18  Squares
            if (note.pitch >= 60) {note.headGroup = 0;}     //0   Circles    
            if (note.pitch >= 72) {note.headGroup = 5;}     //5   Triangles
            if (note.pitch >= 84) {note.headGroup = 10;}    //10  Diamonds
            if (note.pitch >= 96) {note.headGroup = 15;}    //15  Slashes
      }

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