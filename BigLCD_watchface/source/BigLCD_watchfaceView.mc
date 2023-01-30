import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.WatchUi;

const ENERGY_HEARTS_NUM = 5;

class FullMinuteTrigger {
    var lastMinute = -1; // -1 means uninitialized - first call to trigger will return true
    var threashold = 1;

    function initialize(aThreashold) {
        threashold = aThreashold;
    }

    // Returns true if full minutes passed. This returns true only once per achieved minute threashold
    function trigger() as Boolean {
        var now = System.getClockTime();
        var currentMinute = now.min;
        if ((currentMinute % threashold == 0) && (lastMinute != currentMinute) || (lastMinute == -1)) {
            lastMinute = currentMinute;
            return true;
        }
        return false;
    }

    // Prevent from trigger returning true on next call
    function satisfy() as Void {
        lastMinute = System.getClockTime().min;
    }
}

class BigLCD_watchfaceView extends WatchUi.WatchFace {
    var viewHour, viewMinute, viewTemp, viewAuxData, viewDate;
    var width, height;
    var timeTrigger, fullUpdateTrigger;
    var batteryLevel, batteryColor;
    var steps = 0, energy = 100;
    var heartEmpty, heartHalf, heartFull;


    function initialize() {
        timeTrigger = new FullMinuteTrigger(1);
        fullUpdateTrigger = new FullMinuteTrigger(5);
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        width = dc.getWidth();
        height = dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        viewHour = View.findDrawableById("HoursLabel") as Text;
        viewMinute = View.findDrawableById("MinutesLabel") as Text;
        viewTemp = View.findDrawableById("TempLabel") as Text;
        viewAuxData = View.findDrawableById("AuxDataLabel") as Text;
        viewDate = View.findDrawableById("DateLabel") as Text;
        heartEmpty = Application.loadResource(Rez.Drawables.HeartEmpty) as BitmapResource;
        heartHalf = Application.loadResource(Rez.Drawables.HeartHalf) as BitmapResource;
        heartFull = Application.loadResource(Rez.Drawables.HeartFull) as BitmapResource;
    }

    // Update request. Optimize data use for frequent requests
    function onUpdate(dc as Dc) as Void {
        if (fullUpdateTrigger.trigger()) {
            timeTrigger.satisfy(); // do not call time trigger after 1 second from this
            fullUpdate(dc);
        } else if (timeTrigger.trigger()) {
            timeUpdate(dc);
        }
    }

    // Update entire view (time, temperature and battery level)
    function fullUpdate(dc as Dc) as Void {
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

        updateEnergy();
//        viewAuxData.setText(energy.toString());

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Auxaliary data
        drawEnergy(dc);

        // Draw battery level
        batteryLevel = System.getSystemStats().battery; // 0 to 100 (percent)
        batteryColor = 0x005500;
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
     
        // Elements drawn individually, that are not in layout
        drawBatteryLevel(dc);
        drawUnreadNotifications(dc);
    }

    // Update time
    function timeUpdate(dc as Dc) as Void {
        // Fill the layout with current data
        var timeAndDate = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        viewHour.setText(timeAndDate.hour.format("%d"));
        viewMinute.setText(timeAndDate.min.format("%02d"));
        viewDate.setText(timeAndDate.year.format("%d") + "-" + timeAndDate.month.format("%0d") + "-" + timeAndDate.day.format("%02d"));

        // Auxaliary data
//        viewAuxData.setText(energy.toString());

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        drawEnergy(dc);

        // Elements drawn individually, that are not in layout
        drawBatteryLevel(dc);
        drawUnreadNotifications(dc);
    }

    // Iterator used to get body energy level
    function getSensorHistoryIterator() {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            return Toybox.SensorHistory.getBodyBatteryHistory({});
        }
        return null;
    }

    // Update energy level to 'energy' variable
    function updateEnergy() {
        var bbIterator = getSensorHistoryIterator();
        var energyValue = bbIterator.next();
        energy = energyValue.data;
    }

    // Draw energy as a row of empty/full hearts
    function drawEnergy(dc as Dc) {
        var s = 100 / (2 * ENERGY_HEARTS_NUM + 1);

        for (var i = 0; i < ENERGY_HEARTS_NUM; i++) {
            if (energy < s + i * 2 * s) {
                dc.drawBitmap(width * 0.48 + 20 * i, height * 0.2 - 9, heartEmpty);
            } else if (energy < 2 * s + i * 2 * s) {
                dc.drawBitmap(width * 0.48 + 20 * i, height * 0.2 - 9, heartHalf);
            } else {
                dc.drawBitmap(width * 0.48 + 20 * i, height * 0.2 - 9, heartFull);
            }
        }
    }

    // Draw battery level. Use batteryLevel and batteryColor object variables
    function drawBatteryLevel(dc as Dc) {
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(width * 0.3, height * 0.85, width * 0.4, height * 0.06);
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(width * 0.3 + 1, height * 0.85 + 1, width * 0.4 * batteryLevel / 100 - 2, height * 0.06 - 2);
    }

    // Check for unread notifications and draw icon
    function drawUnreadNotifications(dc as Dc) {
        var deviceSettings = System.getDeviceSettings();
        if (deviceSettings.notificationCount > 0) {
            // Draw an envelope
            dc.setColor(0x55aaff, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawRectangle(width * 0.45, height * 0.07, width * 0.10, height * 0.05);
            dc.drawLine(width * 0.45, height * 0.07, width * 0.50, height * 0.10);
            dc.drawLine(width * 0.50, height * 0.10, width * 0.55, height * 0.07);
        }
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
