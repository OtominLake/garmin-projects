import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

var batteryLevel = "20%";

class BigLCD_watchfaceView extends WatchUi.WatchFace {
    var viewHour, viewMinute, viewTemp, viewDate;
    var width, height;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        viewHour = View.findDrawableById("HoursLabel") as Text;
        viewMinute = View.findDrawableById("MinutesLabel") as Text;
        viewTemp = View.findDrawableById("TempLabel") as Text;
        viewDate = View.findDrawableById("DateLabel") as Text;
        width = dc.getWidth();
        height = dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Fill the layout with current data
        var timeAndDate = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        viewHour.setText(timeAndDate.hour.format("%d"));
        viewMinute.setText(timeAndDate.min.format("%02d"));
        viewDate.setText(timeAndDate.year.format("%d") + "-" + timeAndDate.month.format("%0d") + "-" + timeAndDate.day.format("%02d"));

        // Weather
        var cond = Weather.getCurrentConditions();
        if (cond != null) {
            viewTemp.setText(cond.temperature.format("%d") + "C");
        } else
        {
            viewTemp.setText("-");
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw battery level
        var batteryLevel = System.getSystemStats().battery; // 0 to 100 (percent)
        var batteryColor = 0x005500;
        if (batteryLevel <= 10) { batteryColor = 0xff0000; }
        else { 
            if (batteryLevel <= 25) { batteryColor = 0xff5500; }
            else {
                if (batteryLevel <= 50) { batteryColor = 0xaa5500; }
                else {
                    if (batteryLevel <= 75) { batteryColor = 0x55aa55; }
                }
            }
        }
     
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(width * 0.3, height * 0.85, width * 0.4, height * 0.06);
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(width * 0.3 + 1, height * 0.85 + 1, width * 0.4 * batteryLevel / 100 - 2, height * 0.06 - 2);
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
