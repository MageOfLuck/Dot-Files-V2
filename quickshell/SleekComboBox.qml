import QtQuick
import QtQuick.Controls

ComboBox {
    id: control
    font.family: Settings.fontFamily
    implicitHeight: 40
    leftPadding: 12
    rightPadding: 40
    contentItem: Text {
        text: control.displayText
        color: Settings.foreground
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
    }
    // Center a vector chevron; glyph-based arrows sit off-center on some fonts.
    indicator: Item {
        x: control.width - width - 8
        y: (control.height - height) / 2
        width: 28
        height: 28
        Canvas {
            anchors.centerIn: parent
            width: 14
            height: 10
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = Settings.muted;
                ctx.lineWidth = 1.8;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.beginPath();
                ctx.moveTo(2, 3);
                ctx.lineTo(7, 8);
                ctx.lineTo(12, 3);
                ctx.stroke();
            }
        }
    }
    background: Rectangle {
        radius: 10
        color: Settings.sectionSurface
        border.color: control.activeFocus || control.hovered ? Settings.purple : Settings.borderColor
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }
    delegate: ItemDelegate {
        required property int index
        width: control.width - 12
        implicitHeight: 40
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: control.textAt(index)
            color: Settings.foreground
            font: control.font
            leftPadding: 8
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 8
            color: parent.highlighted ? Settings.hoverSurface : "transparent"
        }
    }
    popup: Popup {
        y: control.height + 5
        width: control.width
        padding: 6
        implicitHeight: Math.min(list.contentHeight + 12, 280)
        contentItem: ListView {
            id: list
            clip: true
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        background: Rectangle {
            color: Settings.surface
            border.color: Settings.borderColor
            radius: 12
        }
    }
}
