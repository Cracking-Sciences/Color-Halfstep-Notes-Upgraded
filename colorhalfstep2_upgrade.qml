//=============================================================================
//  MuseScore
//  Linux Music Score Editor
//  $Id:$
//
//  Color Half Steps (Sharps & Flats) plugin
//
//  Copyright (C)2011 Mike Magatagan
//  Modified for MuseScore 2.0 by Chad Kurszewski
//  Modified for MuseScore 3 and 4 by Joachim Schmitz
//  Modified: Add distinguishable colors to sharp and flat notes (red and blue). By Ric Cs.
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//=============================================================================

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
    version: "4.0"
    description: "This plugin colors sharp notes red and flat notes blue in the selection. Run it a second time to change back to all black notes."
    menuPath: "Plugins.Notes.Color HalfStep Notes Upgrade"

    Component.onCompleted: {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Color HalfStep Notes Upgrade")
            //thumbnailName = "some_thumbnail.png"
            categoryCode = "color-notes"
        }
    }

    property string black: "#000000"
    property string red: "#ff0000"
    property string blue: "#007799"
    property string invalid: "#886600"

    function applyToNotesInSelection(func) {
        var cursor = curScore.newCursor();
        cursor.rewind(1);
        var startStaff;
        var endStaff;
        var endTick;
        var fullScore = false;
        if (!cursor.segment) { // no selection
            fullScore = true;
            startStaff = 0;
            endStaff = curScore.nstaves - 1;
        } else {
            startStaff = cursor.staffIdx;
            cursor.rewind(2);
            if (cursor.tick === 0) {
                endTick = curScore.lastSegment.tick + 1;
            } else {
                endTick = cursor.tick;
            }
            endStaff = cursor.staffIdx;
        }
        console.log(startStaff + " - " + endStaff + " - " + endTick)
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
                            for (var j = 0; j < graceNotes.length; j++) {
                                var graceNote = graceNotes[j];
                                func(graceNote);
                            }
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
            switch (note.pitch % 12) {
                case 1:  // C#/Db
                case 3:  // D#/Eb
                case 6:  // F#/Gb
                case 8:  // G#/Ab
                case 10: // A#/Bb

                    if (note.tpc >= 20 ) { // Tonal Pitch Class
                        note.color = red;
                    } else if (note.tpc <= 12) {
                        note.color = blue;
                    }
                    else{
                        note.color = invalid;
                    }
                    break;
                default:
                    note.color = black;
                    break;
            }
        } else {
            note.color = black;
        }
    }

    onRun: {
        console.log("hello colorhalfsteps2");

        if (typeof curScore === 'undefined')
            (typeof(quit) === 'undefined' ? Qt.quit : quit)();

        applyToNotesInSelection(colorNote)

        (typeof(quit) === 'undefined' ? Qt.quit : quit)();
    }
}