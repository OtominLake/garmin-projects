import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ImageBackgroundView extends WatchUi.WatchFace {
    var bgImage;
    var centerX, centerY, handCenterY, imgOffsetX, imgOffsetY;
    var minHandLength, hourHandLength;

    static const BUNNY_NOSE_OFFSET = 176;
    static const BUNNY_NOSE_RADIUS = 25;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        // Image calculations
        bgImage = Application.loadResource(Rez.Drawables.Bunny) as BitmapResource;
        centerX = dc.getWidth() / 2;
        imgOffsetX = centerX - bgImage.getWidth() / 2;
        centerY = dc.getHeight() / 2; 
        imgOffsetY = centerY - bgImage.getHeight() / 2;

        // Clock hands calculations
        handCenterY = imgOffsetY + BUNNY_NOSE_OFFSET; // center y is in bunny's moustache
        var handMaxLength = bgImage.getHeight() - BUNNY_NOSE_OFFSET; // longest possible hand to fit in the watchface
        minHandLength = handMaxLength * 1;
        hourHandLength = handMaxLength * 0.8;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw image
        dc.drawBitmap(imgOffsetX, imgOffsetY, bgImage);

        // Draw clock hands
        var time = System.getClockTime();
        var minAngle = (time.min / 60.0) * Math.PI * 2 - Math.PI / 2;
        var hourAngle = ((time.hour % 12) + time.min / 60.0) / 12.0 * Math.PI * 2 - Math.PI / 2;
        
        // Each hand consists of smaller bunny moustache hairs
        var i;
        for (i = -2; i <= 2; i++) {
            drawHand(dc, minAngle + Math.PI / 25 * i, minHandLength, 3 - i.abs());
            drawHand(dc, hourAngle + Math.PI / 25 * i, hourHandLength, 3 - i.abs());
        }

        // Draw nose on the top
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, handCenterY, BUNNY_NOSE_RADIUS);

        // Add numers for hours and minutes to make this stuff readable
        var viewHour = View.findDrawableById("lblHour") as Text;
        var viewMinute = View.findDrawableById("lblMinute") as Text;
        viewHour.setText(time.hour.format("%d"));
        viewMinute.setText(time.min.format("%02d"));
        viewHour.draw(dc);
        viewMinute.draw(dc);
    }

    // Draw single hand
    function drawHand(dc, angle, length, width) {
        var x1 = Math.cos(angle) * length;
        var y1 = Math.sin(angle) * length;
/*        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(9);
        dc.drawLine(centerX, handCenterY, centerX + x1, handCenterY + y1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(7);
        dc.drawLine(centerX, handCenterY, centerX + x1, handCenterY + y1);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(centerX, handCenterY, centerX + x1, handCenterY + y1);
        */
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(width);
        dc.drawLine(centerX, handCenterY, centerX + x1, handCenterY + y1);        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
