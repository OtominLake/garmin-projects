import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class BigLCD_watchfaceView extends WatchUi.WatchFace {
    var viewHour, viewMinute, viewTemp, viewDate;

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
