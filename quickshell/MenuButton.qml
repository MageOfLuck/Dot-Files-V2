import QtQuick
import QtQuick.Controls

Button {
    id: button
    property bool selected: false
    property bool audioAccent: false
    property bool compact: false
    // Dedicated workspace sizing; other menu buttons keep their original dimensions.
    property bool workspaceButton: false
    // Compact Nerd Font icon mode for top-bar menu triggers only.
    property bool iconButton: false
    // Optional normal-font value shown after a Nerd Font bar icon (audio %).
    property string valueText: ""
    property string hint: ""
    // Optional leading Nerd Font glyph for labeled buttons, e.g. power controls.
    property string leadingIcon: ""
    property int leadingIconSize: 17
    readonly property real glyphAndGap: leadingIcon.length ? leadingIconSize + 11 : 0

    // Reusable ink-centered Nerd Font icon. Text.AlignHCenter/VCenter centers
    // the font's advance/line metrics, not the painted symbol itself. Some
    // Nerd Font glyphs have asymmetric bearings, which makes them look shifted.
    // Measure the glyph's tight ink bounds and center those instead.
    // The parent button geometry and click target are NOT changed.
    component InkCenteredIcon: Item {
        id: iconCell
        property string symbol: ""
        property color symbolColor: Settings.foreground
        property int symbolSize: Settings.barIconSize
        implicitWidth: symbolSize
        implicitHeight: symbolSize

        TextMetrics {
            id: ink
            text: inkText.text
            font: inkText.font
        }
        Text {
            id: inkText
            text: iconCell.symbol
            font.family: Settings.iconFontFamily
            font.pixelSize: iconCell.symbolSize
            font.bold: false
            color: iconCell.symbolColor
            anchors.centerIn: parent
            // Text's origin is at the start of its advance, with glyph y
            // measured from the baseline. Offset the painted bounds to the
            // exact center of this fixed cell, independent of the symbol.
            anchors.horizontalCenterOffset: (inkText.implicitWidth - ink.tightBoundingRect.width) / 2 - ink.tightBoundingRect.x
            anchors.verticalCenterOffset: (inkText.implicitHeight - ink.tightBoundingRect.height) / 2 - inkText.baselineOffset - ink.tightBoundingRect.y
        }
    }
    implicitHeight: workspaceButton ? 32 : (iconButton ? 32 : (compact ? 28 : 34))
    implicitWidth: workspaceButton ? Math.max(30, label.implicitWidth + button.glyphAndGap + 14)
                                  : (iconButton ? (valueText.length > 0
                                                  ? Math.max(34, Settings.barIconSize + 5 + iconValue.implicitWidth + 14)
                                                  : 34)
                                                : Math.max(compact ? 28 : 54, label.implicitWidth + button.glyphAndGap + (compact ? 14 : 22)))
    leftPadding: workspaceButton ? 7 : ((compact || iconButton) ? 6 : 11)
    rightPadding: workspaceButton ? 7 : ((compact || iconButton) ? 6 : 11)
    topPadding: workspaceButton ? 4 : 5
    bottomPadding: workspaceButton ? 4 : 5
    font.pixelSize: workspaceButton ? 12 : (iconButton ? Settings.barIconSize : 13)
    font.bold: true
    font.family: iconButton ? Settings.iconFontFamily : Settings.fontFamily
    ToolTip.visible: hovered && hint.length > 0
    ToolTip.delay: 650
    ToolTip.text: hint
    contentItem: Item {
        id: content
        implicitWidth: button.iconButton
                       ? (button.valueText.length > 0
                          ? Settings.barIconSize + 5 + iconValue.implicitWidth
                          : Settings.barIconSize)
                       : label.implicitWidth + button.glyphAndGap
        implicitHeight: Math.max(label.implicitHeight, button.iconButton ? Settings.barIconSize : glyph.implicitHeight)

        // Icon-only triggers always use a fixed full-width area. Their
        // visual position does not depend on each glyph's advance width.
        InkCenteredIcon {
            visible: button.iconButton && button.valueText.length === 0
            anchors.fill: parent
            symbol: button.text
            symbolColor: button.audioAccent ? "#161222" : Settings.foreground
        }

        // Speaker icon uses Nerd Font; volume number/% uses Noto Sans like
        // the original audio button. Center both as a single group.
        Row {
            id: iconAndValue
            visible: button.iconButton && button.valueText.length > 0
            anchors.centerIn: parent
            height: parent.height
            spacing: 5
            InkCenteredIcon {
                width: Settings.barIconSize
                height: parent.height
                symbol: button.text
                symbolColor: button.audioAccent ? "#161222" : Settings.foreground
            }
            Text {
                id: iconValue
                height: parent.height
                text: button.valueText
                font.family: Settings.fontFamily
                font.pixelSize: 13
                font.bold: true
                color: button.audioAccent ? "#161222" : Settings.foreground
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Preserve existing labeled, compact and workspace button styling.
        Row {
            id: iconText
            visible: !button.iconButton
            spacing: button.leadingIcon.length ? 7 : 0
            width: Math.min(label.implicitWidth + button.glyphAndGap, content.width)
            height: content.height
            anchors.centerIn: parent
            Text {
                id: glyph
                visible: button.leadingIcon.length > 0
                text: button.leadingIcon
                font.family: Settings.iconFontFamily
                font.pixelSize: button.leadingIconSize
                color: button.audioAccent ? "#161222" : Settings.foreground
                width: button.leadingIcon.length ? button.leadingIconSize + 4 : 0
                height: iconText.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                id: label
                text: button.text
                color: button.audioAccent ? "#161222" : Settings.foreground
                font: button.font
                width: Math.max(0, iconText.width - (glyph.visible ? glyph.width + iconText.spacing : 0))
                height: iconText.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
    background: Rectangle {
        radius: 9
        color: button.audioAccent ? Settings.purple : (button.selected ? Settings.elevated : button.hovered ? Settings.hoverSurface : Settings.sectionSurface)
        opacity: button.enabled ? 1 : 0.45
        border.color: button.activeFocus ? Settings.foreground : (button.audioAccent || button.selected ? "transparent" : Settings.borderColor)
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}