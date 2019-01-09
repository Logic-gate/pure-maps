/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

Rectangle {
    id: ring

    anchors.left: parent.left
    anchors.leftMargin: app.styler.themePaddingLarge
    anchors.bottomMargin: app.styler.themePaddingLarge
    anchors.bottom: streetName.top
    border.width: 0.7*app.styler.themePaddingLarge
    border.color: "red"
    color: "white"
    height: width
    radius: width/2
    states: [
        State {
            when: (!app.portrait || app.mode === modes.followMe) && navigationInfoBlockLandscapeLeftShield.height > 0
            AnchorChanges {
                target: ring
                anchors.bottom: navigationInfoBlockLandscapeLeftShield.top
            }
        }
    ]
    width: Math.round(Math.max(limit.width,limit.height) + 1.6*app.styler.themePaddingLarge + app.styler.themePaddingSmall)
    visible: {
        if (app.mode === modes.explore || app.mode === modes.exploreRoute ||
                !map.route || map.route.mode !== "car" || app.conf.showSpeedLimit==="never")
            return false;
        if (app.conf.showSpeedLimit==="exceeding") {
            if (!gps.position.speedValid || gps.streetSpeedLimit==null || gps.streetSpeedLimit < 0)
                return false;
            if (gps.position.speed <= gps.streetSpeedLimit)
                return false;
        }
        return limit.text.length > 0
    }
    z: 400

    Text {
        id: limit
        anchors.centerIn: parent
        color: "black"
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: app.styler.themeFontSizeLarge
        style: Text.Outline
        styleColor: "white"

        Connections {
            target: app
            onModeChanged: limit.update()
        }

        Connections {
            target: gps
            onStreetSpeedLimitChanged: limit.update()
        }

        Component.onCompleted: limit.update()

        function update() {
            // Update speed limit in user's preferred units.
            if (app.mode === modes.explore || app.mode === modes.exploreRoute) {
                if (text.length > 0) text = "";
                return;
            }

            if (gps.streetSpeedLimit==null || gps.streetSpeedLimit < 0) {
                text = "";
                return;
            }

            // speed limit in m/s
            if (app.conf.units === "american") {
                text = "%1".arg(Math.round(gps.streetSpeedLimit * 2.23694))
            } else if (app.conf.units === "british") {
                text = "%1".arg(Math.round(gps.streetSpeedLimit * 2.23694))
            } else {
                text = "%1".arg(gps.streetSpeedLimit * 3.6)
            }
        }
    }

}
